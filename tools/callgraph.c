// callgraph.c — 扫 BL / B imm26，产出调用图
// 用法: callgraph <image> <基址hex> [目标地址hex]
//   无目标: 输出全部调用边 + 被调用次数统计
//   有目标: 只输出调用该地址的边
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define CODE_OFF 0x200
static uint8_t *buf; static size_t fsz, code_end;
static uint32_t BASE;

static int64_t sx26(uint32_t imm){
    int64_t v = imm & 0x3FFFFFF;
    if (v & 0x2000000) v -= 0x4000000;
    return v;
}

int main(int argc, char **argv){
    if (argc < 3){ fprintf(stderr,"用法: %s <image> <基址hex> [目标hex]\n",argv[0]); return 1; }
    FILE *f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); fsz=ftell(f); fseek(f,0,SEEK_SET);
    buf=malloc(fsz); fread(buf,1,fsz,f); fclose(f);
    BASE=(uint32_t)strtoul(argv[2],NULL,16);
    int have_tgt = argc>3;
    uint32_t tgt = have_tgt ? (uint32_t)strtoul(argv[3],NULL,16) : 0;

    size_t last=0; for(size_t k=fsz;k-->0;) if(buf[k]){last=k;break;}
    code_end=last+1;
    printf("[*] 载荷 [0x%x, 0x%zx)  基址 0x%08x\n", CODE_OFF, code_end, BASE);

    // 被调用计数表（按 64KB 桶粗略统计）
    size_t nb = code_end/0x10000 + 2;
    uint32_t *hits = calloc(nb, sizeof(uint32_t));
    uint32_t edges=0, bls=0, bs=0;

    for (size_t i=CODE_OFF; i+4<=code_end; i+=4){
        uint32_t w; memcpy(&w,buf+i,4);
        int isbl = ((w & 0xFC000000u)==0x94000000u);
        int isb  = ((w & 0xFC000000u)==0x14000000u);
        if (!isbl && !isb) continue;
        uint32_t pc=(uint32_t)(i-CODE_OFF);
        int64_t t = (int64_t)pc + (sx26(w)<<2);
        if (t < 0 || (size_t)t >= code_end) continue;
        uint32_t addr = BASE + (uint32_t)t;
        if (isbl) bls++; else bs++;
        edges++;
        hits[t/0x10000]++;
        if (have_tgt){
            if (addr == tgt)
                printf("  0x%08x  %s→ 0x%08x   (目标)\n",
                       BASE+pc, isbl?"bl":"b ", addr);
        }
    }
    printf("[*] 调用指令: BL=%u  B=%u  合计 %u\n", bls, bs, edges);
    if (!have_tgt){
        printf("\n=== 被调用最频繁的 64KB 区间（热点函数区）===\n");
        // 简单选择排序前 12
        for (int r=0;r<12;r++){
            size_t best=0; uint32_t bv=0;
            for (size_t i=0;i<nb;i++) if (hits[i]>bv){bv=hits[i];best=i;}
            if (!bv) break;
            printf("  载荷 0x%06zx - 0x%06zx  地址 0x%08x  %u 次\n",
                   best*0x10000, (best+1)*0x10000, BASE+(uint32_t)(best*0x10000), bv);
            hits[best]=0;
        }
    }
    free(hits);
    return 0;
}
