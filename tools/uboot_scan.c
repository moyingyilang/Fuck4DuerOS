// uboot_scan.c — 展锐 U-Boot (DHTB) 镜像分析器
// 用法: uboot_scan <image> [目标字符串...]
// 做的事:
//   1. 解析 DHTB 头，定位载荷
//   2. 提取 NUL 分隔的可打印字符串及其偏移
//   3. 用 (指针值 - 字符串偏移) 直方图反推加载基址
//   4. 定位目标字符串的绝对指针引用
//   5. 扫描 ARM64 ADRP+ADD / ADRP+LDR 交叉引用
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static uint8_t *buf;
static size_t   fsz;

// ---- 字符串表 ----
typedef struct { uint32_t off; uint32_t len; } str_t;
static str_t *strs; static size_t nstr, cap_str;

// ---- 指针表 ----
static uint64_t *ptrs; static uint32_t *ptr_off; static size_t nptr, cap_ptr;

static int is_print(uint8_t c){ return c >= 0x20 && c < 0x7f; }

static void add_str(uint32_t off, uint32_t len){
    if (nstr == cap_str){ cap_str = cap_str ? cap_str*2 : 65536;
        strs = realloc(strs, cap_str*sizeof(str_t)); }
    strs[nstr].off = off; strs[nstr].len = len; nstr++;
}
static void add_ptr(uint64_t v, uint32_t off){
    if (nptr == cap_ptr){ cap_ptr = cap_ptr ? cap_ptr*2 : 65536;
        ptrs = realloc(ptrs, cap_ptr*sizeof(uint64_t));
        ptr_off = realloc(ptr_off, cap_ptr*sizeof(uint32_t)); }
    ptrs[nptr] = v; ptr_off[nptr] = off; nptr++;
}

// ---- 直方图：base = V - O 的众数 ----
#define HBITS 20
#define HSIZE (1u<<HBITS)
static uint32_t *hist;

static uint64_t find_base(void){
    hist = calloc(HSIZE, sizeof(uint32_t));
    // 只按 4KB 对齐统计：base & 0xFFF == 0
    for (size_t i = 0; i < nptr; i++){
        uint64_t v = ptrs[i];
        for (size_t j = 0; j < nstr; j++){
            uint64_t b = v - strs[j].off;
            if (!(b & 0xFFF)) hist[(unsigned)(b >> 12) & (HSIZE-1)]++;
        }
    }
    uint32_t best = 0; unsigned bi = 0;
    for (unsigned i = 0; i < HSIZE; i++) if (hist[i] > best){ best = hist[i]; bi = i; }
    free(hist);
    printf("[*] 直方图峰值: base[19:12] 桶=0x%05x  命中 %u 次\n", bi, best);
    return (uint64_t)bi << 12;
}

// ---- 目标字符串的绝对指针引用 ----
static void find_ptr_refs(const char *name, const uint8_t *s, size_t slen, uint64_t base){
    long off = -1;
    for (size_t i = 0; i + slen <= fsz; i++)
        if (!memcmp(buf+i, s, slen)){ off = (long)i; break; }
    if (off < 0){ printf("  [%s] 未找到该字符串\n", name); return; }
    uint64_t addr = base + (uint64_t)off;
    printf("  [%s] 文件偏移=0x%lx  推测地址=0x%lx\n", name, off, addr);
    int hits = 0;
    for (size_t i = 0; i + 8 <= fsz; i += 4){
        uint64_t v; memcpy(&v, buf+i, 8);
        if (v == addr){ printf("      → 指针出现在文件偏移 0x%zx\n", i); hits++; }
    }
    if (!hits) printf("      → 无绝对指针引用（可能通过相对偏移或指令流引用）\n");
}

// ---- ARM64 ADRP 交叉引用 ----
static void scan_adrp(const char *name, const uint8_t *s, size_t slen, uint32_t code_off){
    long off = -1;
    for (size_t i = 0; i + slen <= fsz; i++)
        if (!memcmp(buf+i, s, slen)){ off = (long)i; break; }
    if (off < 0 || (uint32_t)off < code_off) return;
    uint32_t want = (uint32_t)off - code_off;
    printf("  [%s] 载荷内偏移=0x%x\n", name, want);
    int hits = 0;
    for (size_t i = code_off; i + 8 <= fsz; i += 4){
        uint32_t a; memcpy(&a, buf+i, 4);
        if ((a & 0x9F000000u) != 0x90000000u) continue;
        uint32_t rd    = a & 0x1F;
        int64_t  immlo = (a >> 29) & 3;
        int64_t  immhi = (a >> 5) & 0x7FFFF;
        int64_t  imm   = (immhi << 2) | immlo;
        if (imm & (1<<20)) imm -= (1<<21);
        uint32_t pc    = (uint32_t)(i - code_off);
        uint64_t page  = (uint64_t)(pc & ~0xFFFu) + ((uint64_t)imm << 12);
        uint32_t b; memcpy(&b, buf+i+4, 4);
        // ADD (imm) 64-bit
        if ((b & 0x7F000000u) == 0x11000000u && (b >> 31)){
            uint32_t imm12 = (b >> 10) & 0xFFF;
            if (((b >> 5) & 0x1F) == rd && (b & 0x1F) == rd)
                if ((uint32_t)(page + imm12) == want){
                    printf("      ADRP+ADD @ 载荷偏移 0x%x  X%u\n", pc, rd); hits++; }
        }
        // LDR (literal) 64-bit
        if ((b & 0xFF000000u) == 0x58000000u && (b & 0x1F) == rd){
            int64_t imm19 = (b >> 5) & 0x7FFFF;
            if (imm19 & (1<<18)) imm19 -= (1<<19);
            uint32_t tgt = (uint32_t)(pc + 4 + (imm19 << 2));
            if (tgt == want){ printf("      ADRP+LDR @ 载荷偏移 0x%x  X%u\n", pc, rd); hits++; }
        }
    }
    if (!hits) printf("      → 无 ADRP 交叉引用\n");
}

int main(int argc, char **argv){
    if (argc < 2){ fprintf(stderr, "用法: %s <image> [字符串...]\n", argv[0]); return 1; }
    FILE *f = fopen(argv[1], "rb");
    if (!f){ perror("open"); return 1; }
    fseek(f, 0, SEEK_END); fsz = ftell(f); fseek(f, 0, SEEK_SET);
    buf = malloc(fsz); fread(buf, 1, fsz, f); fclose(f);
    printf("[*] 文件 %s  %zu 字节 (0x%zx)\n", argv[1], fsz, fsz);

    uint32_t code_off = 0x40, code_size = 0;
    if (fsz >= 64 && !memcmp(buf, "DHTB", 4)){
        memcpy(&code_size, buf+48, 4);
        printf("[*] DHTB 头: version=%u  载荷大小=0x%x\n", *(uint32_t*)(buf+4), code_size);
        code_size -= code_off;
    } else { code_size = fsz - code_off; }

    // 1) 字符串
    for (size_t i = code_off; i < fsz; ){
        if (is_print(buf[i])){
            size_t j = i; while (j < fsz && is_print(buf[j])) j++;
            if (j - i >= 6) add_str((uint32_t)(i - code_off), (uint32_t)(j - i));
            i = j;
        } else i++;
    }
    printf("[*] 提取到 %zu 个可打印串\n", nstr);

    // 2) 指针候选
    for (size_t i = code_off; i + 8 <= fsz; i += 4){
        uint64_t v; memcpy(&v, buf+i, 8);
        /* 真实指针：8 字节值本身落在候选地址区间内（高 32 位为 0） */
        if (v >= 0x9E000000ull && v <= 0xA2000000ull)
            add_ptr(v, (uint32_t)(i - code_off));
    }
    printf("[*] 候选指针 %zu 个\n", nptr);

    // 3) 反推基址
    uint64_t base = find_base();
    printf("[*] 推断基址 ≈ 0x%llx\n", (unsigned long long)base);

    // 4) 校准：试若干邻近基址，看哪个让最多指针命中字符串
    printf("\n[*] 基址校准（命中字符串的指针数）:\n");
    for (int d = -8; d <= 8; d++){
        uint64_t B = base + (int64_t)d * 0x1000;
        size_t hit = 0;
        for (size_t i = 0; i < nptr; i++){
            uint64_t o = ptrs[i] - B;
            for (size_t j = 0; j < nstr; j++) if (strs[j].off == o){ hit++; break; }
        }
        printf("    base=0x%llx  命中 %zu\n", (unsigned long long)B, hit);
    }

    // 5) 目标字符串
    if (argc > 2){
        printf("\n=== 目标字符串引用分析（基址 0x%llx）===\n", (unsigned long long)base);
        for (int i = 2; i < argc; i++){
            size_t sl = strlen(argv[i]);
            printf("\n-- %s --\n", argv[i]);
            find_ptr_refs(argv[i], (const uint8_t*)argv[i], sl, base);
            scan_adrp(argv[i], (const uint8_t*)argv[i], sl, code_off);
        }
    }
    return 0;
}
