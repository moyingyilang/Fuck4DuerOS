// basefind.c — 求解 U-Boot 载荷的真实加载基址
// 原理：若 V 是指向偏移 S 处字符串的绝对指针，则 B = V - S 必对齐且集中。
// 对所有 (指针, 字符串) 组合计算 B，取 4KB 桶众数即为基址。
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define CODE_OFF 0x200
static uint8_t *d; static size_t n;

static int32_t *strs; static size_t nstr;

static void collect_strings(void){
    size_t cap=1<<16; strs=malloc(cap*sizeof(int32_t)); nstr=0;
    for (size_t i=0;i<n;i++){
        if (d[i]==0 || d[i]<0x20 || d[i]>0x7e) continue;
        if (i>0 && d[i-1]!=0) continue;              /* 必须是串起点 */
        size_t k=0;
        while (i+k<n && d[i+k]>=0x20 && d[i+k]<=0x7e && k<120) k++;
        if (k<6) continue;
        if (i+k>=n || d[i+k]!=0) continue;
        if (nstr==cap){ cap*=2; strs=realloc(strs,cap*sizeof(int32_t)); }
        strs[nstr++]=(int32_t)i;
    }
}

#define NBUCK (1u<<24)                    /* 64MB 空间按 4KB 分桶 => 16K 桶 */
int main(int argc,char**argv){
    if (argc<2){ fprintf(stderr,"用法: %s <image>\n",argv[0]); return 1; }
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t *file=malloc(fsz); fread(file,1,fsz,f); fclose(f);
    /* 只分析 CODE_OFF 之后的载荷 */
    d=file+CODE_OFF; n=fsz-CODE_OFF;
    size_t last=0; for(size_t k=n;k-->0;) if(d[k]){last=k;break;}
    n=last+1;
    printf("[*] 载荷 %zu 字节（文件偏移 0x%x 起）\n", n, CODE_OFF);

    collect_strings();
    printf("[*] 可打印串起点 %zu 个\n", nstr);

    uint32_t *hist=calloc(1<<14, sizeof(uint32_t));   /* 16K 桶，每桶 4KB */
    if(!hist){ fprintf(stderr,"calloc 失败\n"); return 1; }
    uint64_t pairs=0;

    for (size_t off=0; off+8<=n; off+=8){
        uint64_t v; memcpy(&v,d+off,8);
        if (v < 0x9e000000ull || v > 0x9fffffffull) continue;   /* 只考虑 0x9e..0x9f 区间 */
        for (size_t s=0;s<nstr;s++){
            /* 指针 V 指向载荷偏移 strs[s] => 基址 B = V - strs[s] + CODE_OFF */
            int64_t B = (int64_t)v - (int64_t)strs[s] + CODE_OFF;
            if (B < 0x9e000000ll || B > 0x9fffffffull) continue;
            if (B & 0xFFF) continue;                            /* 基址必须页对齐 */
            hist[(uint32_t)((B - 0x9e000000ll) >> 12)]++;
            pairs++;
        }
    }
    printf("[*] 枚举 (指针,字符串) 组合 %llu 个\n\n", (unsigned long long)pairs);

    printf("=== 基址候选（前 10，按命中数）===\n");
    for (int r=0;r<10;r++){
        uint32_t best=0, bv=0;
        for (uint32_t i=0;i<(1u<<14);i++) if (hist[i]>bv){bv=hist[i];best=i;}
        if (!bv) break;
        uint64_t B = 0x9e000000ull + ((uint64_t)best<<12);
        printf("  0x%08llx  %u 次\n", (unsigned long long)B, bv);
        hist[best]=0;
    }

    /* 验证：用最优基址，统计有多少指针真正落在字符串起点上 */
    uint32_t besti=0,bv2=0;
    for (uint32_t i=0;i<(1u<<14);i++) if (hist[i]>bv2){bv2=hist[i];besti=i;}
    return 0;
}
