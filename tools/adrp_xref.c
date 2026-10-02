// adrp_xref.c — 宽泛的 ARM64 ADRP 交叉引用扫描
// 用法: adrp_xref <image> <payload_off_hex> [<payload_off_hex> ...]
// 对每个目标：扫描 ADRP，再在其后 1..8 条指令内找 ADD/LDR 凑出该地址
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static uint8_t *buf; static size_t fsz;
#define CODE_OFF 0x40

static uint32_t rd_of(uint32_t i){ return i & 0x1F; }

int main(int argc, char **argv){
    if (argc < 3){ fprintf(stderr,"用法: %s <image> <off_hex>...\n", argv[0]); return 1; }
    FILE *f = fopen(argv[1], "rb"); if (!f){ perror("open"); return 1; }
    fseek(f,0,SEEK_END); fsz = ftell(f); fseek(f,0,SEEK_SET);
    buf = malloc(fsz); fread(buf,1,fsz,f); fclose(f);

    uint64_t code_end = fsz; uint32_t csize = 0;
    if (!memcmp(buf,"DHTB",4)){ memcpy(&csize, buf+48, 4); code_end = csize; }
    printf("[*] 载荷 [0x%x, 0x%zx)\n", CODE_OFF, code_end);

    for (int a = 2; a < argc; a++){
        uint32_t want = (uint32_t)strtoul(argv[a], NULL, 16);
        printf("\n=== 目标载荷偏移 0x%x ===\n", want);
        int found = 0;
        for (size_t i = CODE_OFF; i + 4 <= code_end; i += 4){
            uint32_t ins; memcpy(&ins, buf+i, 4);
            // 也检测 ADR（PC 相对 ±1MB）: op=0 immlo 10000 immhi Rd
            if ((ins & 0x9F000000u) == 0x10000000u){
                uint32_t ad = ins & 0x1F;
                int64_t lo = (ins >> 29) & 3, hi = (ins >> 5) & 0x7FFFF;
                int64_t im = (hi << 2) | lo;
                if (im & (1<<20)) im -= (1<<21);
                uint32_t pc = (uint32_t)(i - CODE_OFF);
                if ((uint32_t)(pc + im) == want){
                    printf("  ADR@0x%x (X%u) → 目标  [PC相对]\n", pc, ad); found++;
                }
            }
            if ((ins & 0x9F000000u) != 0x90000000u) continue;
            uint32_t rd = rd_of(ins);
            int64_t immlo = (ins >> 29) & 3, immhi = (ins >> 5) & 0x7FFFF;
            int64_t imm = (immhi << 2) | immlo;
            if (imm & (1<<20)) imm -= (1<<21);
            uint32_t pc = (uint32_t)(i - CODE_OFF);
            int64_t page = (int64_t)(pc & ~0xFFFu) + (imm << 12);
            // 往后看 8 条
            for (int k = 1; k <= 8 && i + 4*k + 4 <= code_end; k++){
                uint32_t b; memcpy(&b, buf + i + 4*k, 4);
                uint32_t bpc = pc + 4*k;
                // ADD (imm) 64-bit，Rn == rd
                if ((b & 0x7F000000u) == 0x11000000u && (b >> 31) && ((b >> 5) & 0x1F) == rd){
                    uint32_t imm12 = (b >> 10) & 0xFFF;
                    if ((uint32_t)(page + imm12) == want){
                        printf("  ADRP@0x%x (X%u) + ADD@0x%x (X%u)  [间隔 %d]\n",
                               pc, rd, bpc, b & 0x1F, k); found++;
                    }
                }
                // ADD (imm) 32-bit，Wn == rd
                if ((b & 0x7F000000u) == 0x11000000u && !(b >> 31) && ((b >> 5) & 0x1F) == rd){
                    uint32_t imm12 = (b >> 10) & 0xFFF;
                    if ((uint32_t)(page + imm12) == want){
                        printf("  ADRP@0x%x (X%u) + ADD.W@0x%x  [间隔 %d]\n", pc, rd, bpc, k); found++;
                    }
                }
                // LDR (literal) 64/32-bit
                if ((b & 0x3B000000u) == 0x18000000u){
                    int64_t imm19 = (b >> 5) & 0x7FFFF;
                    if (imm19 & (1<<18)) imm19 -= (1<<19);
                    if ((uint32_t)(bpc + (imm19 << 2)) == want){
                        printf("  ADRP@0x%x + LDR-literal@0x%x  [间隔 %d]\n", pc, bpc, k); found++;
                    }
                }
            }
        }
        if (!found) printf("  （无引用）\n");
    }
    return 0;
}
