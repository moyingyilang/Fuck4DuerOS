// funcmap.c — 扫描 ARM64 函数序言，并用「该函数引用的字符串」推测其用途
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static uint8_t *buf; static size_t fsz, code_end;
static uint32_t BASE;
#define CODE_OFF 0x200

// 判断是否为函数序言：stp x29,x30,[sp,#-N]!  或  paciasp + stp
static int is_prologue(uint32_t w){
    // stp x29, x30, [sp, #-imm]!   => 0xA9B?7BFD  (imm7 = -N/8)
    if ((w & 0xFFC07FFF) == 0xA9807BFD) return 1;
    // stp x29, x30, [sp, #-imm]! 的变体
    if ((w & 0xFF800000) == 0xA9800000 && ((w>>5)&0x1F)==0x1E && (w&0x1F)==0x1E) return 1;
    // paciasp
    if (w == 0xD503233F) return 1;
    return 0;
}

// 取字符串（若该偏移处是可打印串起点）
static const char* str_at(size_t off){
    if (off >= code_end) return NULL;
    if (off > 0 && buf[off-1] != 0) return NULL;      // 必须是串起点
    if (buf[off] < 0x20 || buf[off] > 0x7E) return NULL;
    size_t n = 0;
    while (off+n < code_end && buf[off+n] >= 0x20 && buf[off+n] <= 0x7E && n < 80) n++;
    if (n < 4) return NULL;
    if (off+n < code_end && buf[off+n] != 0) return NULL;   // 必须 NUL 结尾
    return (const char*)(buf+off);
}

int main(int argc, char **argv){
    if (argc < 4){ fprintf(stderr,"用法: %s <image> <基址> [最小函数字节]\n", argv[0]); return 1; }
    FILE *f = fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); fsz=ftell(f); fseek(f,0,SEEK_SET);
    buf=malloc(fsz); fread(buf,1,fsz,f); fclose(f);
    BASE = (uint32_t)strtoul(argv[2],NULL,16);
    size_t minsz = argc>3 ? (size_t)atoi(argv[3]) : 16;

    // 真实载荷末尾
    size_t last=0; for(size_t k=fsz;k-->0;) if(buf[k]){last=k;break;}
    code_end = last+1;
    printf("[*] 镜像 %zu 字节，载荷 [0x%x, 0x%zx)，基址 0x%08x\n", fsz, CODE_OFF, code_end, BASE);

    // 收集函数起点
    size_t *fn = NULL; size_t n=0, cap=0;
    for (size_t i=CODE_OFF; i+4<=code_end; i+=4){
        uint32_t w; memcpy(&w,buf+i,4);
        if (is_prologue(w)){
            // 避免把函数内部的对齐填充误判：要求前一条不是无条件返回
            if (n==cap){ cap = cap?cap*2:4096; fn=realloc(fn,cap*sizeof(size_t)); }
            fn[n++] = i;
        }
    }
    printf("[*] 候选函数起点 %zu 个\n\n", n);

    // 对每个函数：扫描函数体里的 ADRP+ADD，收集字符串
    printf("%-12s %-8s %s\n","地址","字节数","引用的字符串（前 3 个）");
    printf("---------------------------------------------------------------\n");
    size_t named=0;
    for (size_t k=0;k<n;k++){
        size_t s = fn[k];
        size_t e = (k+1<n)? fn[k+1] : code_end;
        if (e-s < minsz) continue;
        const char *hits[3]; int nh=0;
        for (size_t i=s; i+8<=e && nh<3; i+=4){
            uint32_t a; memcpy(&a,buf+i,4);
            if ((a & 0x9F000000u)!=0x90000000u) continue;
            uint32_t rd=a&0x1F;
            int64_t lo=(a>>29)&3, hi=(a>>5)&0x7FFFF;
            int64_t imm=(hi<<2)|lo; if(imm&(1<<20)) imm-=(1<<21);
            uint32_t pc=(uint32_t)(i-CODE_OFF);
            int64_t page=(int64_t)(pc & ~0xFFFu) + (imm<<12);
            for (int j=1;j<=6 && i+4*j+4<=e;j++){
                uint32_t b; memcpy(&b,buf+i+4*j,4);
                if ((b & 0x7F000000u)!=0x11000000u || !(b>>31)) continue;
                if (((b>>5)&0x1F)!=rd) continue;
                uint32_t imm12=(b>>10)&0xFFF;
                if (b & (1u<<22)) imm12 <<= 12;
                const char *str = str_at((size_t)(page+imm12));
                if (str){ hits[nh++]=str; }
                break;
            }
        }
        if (nh){ named++;
            printf("0x%08x  %-8zu", BASE+(uint32_t)(s-CODE_OFF), e-s);
            for (int j=0;j<nh;j++) printf(" %s%s", j?" | ":"", hits[j]);
            printf("\n");
        }
    }
    printf("\n[*] 其中有字符串引用的函数: %zu / %zu\n", named, n);
    free(fn);
    return 0;
}
