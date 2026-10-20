// basecheck.c — 给一个候选基址，统计「8字节值=指针」中有多少指向可打印串
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#define CODE_OFF 0x200
static uint8_t *d; static size_t n;
static int is_str_at(size_t off, int minlen){
    if (off >= n) return 0;
    if (off>0 && d[off-1]!=0) return 0;
    if (d[off]<0x20 || d[off]>0x7e) return 0;
    size_t k=0; while (off+k<n && d[off+k]>=0x20 && d[off+k]<=0x7e && k<200) k++;
    if ((int)k<minlen) return 0;
    return (off+k<n && d[off+k]==0);
}
int main(int argc,char**argv){
    if (argc<3){ fprintf(stderr,"用法: %s <image> <基址hex>...\n",argv[0]); return 1; }
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t *file=malloc(fsz); fread(file,1,fsz,f); fclose(f);
    d=file+CODE_OFF; n=fsz-CODE_OFF;
    size_t last=0; for(size_t k=n;k-->0;) if(d[k]){last=k;break;} n=last+1;

    /* 预先把所有 8 字节值在 0x9e000000..0x9fffffff 的记录收集起来 */
    size_t cap=1<<20, cnt=0; uint64_t *vals=malloc(cap*8);
    for (size_t off=0; off+8<=n; off+=8){
        uint64_t v; memcpy(&v,d+off,8);
        if (v<0x9e000000ull || v>0x9fffffffull) continue;
        if (cnt==cap){ cap*=2; vals=realloc(vals,cap*8); }
        vals[cnt++]=v;
    }
    printf("[*] 载荷 %zu 字节，0x9e..0x9f 区间的 8 字节值 %zu 个\n\n", n, cnt);

    for (int a=2;a<argc;a++){
        uint64_t B = strtoull(argv[a],NULL,16);
        size_t hit=0, inrange=0;
        for (size_t i=0;i<cnt;i++){
            int64_t off = (int64_t)vals[i] - (int64_t)B;
            if (off < 0 || (uint64_t)off >= n) continue;
            inrange++;
            if (is_str_at((size_t)off, 6)) hit++;
        }
        printf("基址 0x%08llx: 落在载荷内 %zu 个，其中指向可打印串 %zu 个\n",
               (unsigned long long)B, inrange, hit);
    }
    return 0;
}
