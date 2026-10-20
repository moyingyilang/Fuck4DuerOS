// xref_hist.c — 统计 ADRP+ADD 目标地址的分布
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
static uint8_t *buf; static size_t fsz;
int main(int argc, char **argv){
    if (argc < 2){ fprintf(stderr,"用法: %s <image>\n", argv[0]); return 1; }
    FILE *f = fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); fsz=ftell(f); fseek(f,0,SEEK_SET);
    buf=malloc(fsz); fread(buf,1,fsz,f); fclose(f);
    size_t last=0; for(size_t k=fsz;k-->0;) if(buf[k]){last=k;break;}
    size_t code_end=last+1, CODE_OFF=0x40;
    printf("[*] 载荷 [0x%zx, 0x%zx)\n", CODE_OFF, code_end);

    // 64KB 桶
    size_t NBUCK=code_end/0x10000 + 2;
    uint32_t *h = calloc(NBUCK, sizeof(uint32_t));
    uint32_t total=0;
    for (size_t i=CODE_OFF; i+8<=code_end; i+=4){
        uint32_t a; memcpy(&a, buf+i, 4);
        if ((a & 0x9F000000u)!=0x90000000u) continue;
        uint32_t rd=a&0x1F;
        int64_t lo=(a>>29)&3, hi=(a>>5)&0x7FFFF;
        int64_t imm=(hi<<2)|lo; if(imm&(1<<20)) imm-=(1<<21);
        uint32_t pc=(uint32_t)(i-CODE_OFF);
        int64_t page=(int64_t)(pc & ~0xFFFu) + (imm<<12);
        // 找后续 ADD
        for(int k=1;k<=8 && i+4*k+4<=code_end;k++){
            uint32_t b; memcpy(&b, buf+i+4*k, 4);
            if ((b & 0x7F000000u)!=0x11000000u || !(b>>31)) continue;
            if (((b>>5)&0x1F)!=rd) continue;
            uint32_t imm12=(b>>10)&0xFFF;
            if (b & (1u<<22)) imm12 <<= 12;
            int64_t tgt = page + imm12;
            if (tgt < 0 || (size_t)tgt >= code_end) continue;
            h[tgt/0x10000]++; total++;
        }
    }
    printf("[*] 共 %u 个 ADRP+ADD 目标\n\n", total);
    printf("=== 目标分布的 64KB 桶 ===\n");
    for (size_t i=0;i<NBUCK;i++){
        if (!h[i]) continue;
        printf("  载荷 0x%06zx-0x%06zx (地址 0x%08llx)  %5u  %s\n",
               i*0x10000, (i+1)*0x10000, (unsigned long long)(0x9f006000 + i*0x10000),
               h[i], h[i]>200?"###":h[i]>50?"##":"#");
    }
    free(h);
    return 0;
}
