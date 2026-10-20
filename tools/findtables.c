// findtables.c — 找连续的函数指针表（U-Boot 的 initcall / 命令表等）
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#define CODE_OFF 0x200
static uint8_t *d; static size_t n; static uint64_t BASE;

static int valid_ptr(uint64_t v){ return v >= BASE && v < BASE + n; }
static int is_prologue_off(size_t off){
    if (off+4 > n) return 0;
    uint32_t w; memcpy(&w,d+off,4);
    if ((w & 0xFF800000u)==0xA9800000u && ((w>>5)&0x1F)==0x1E && (w&0x1F)==0x1E) return 1; /* stp x29,x30 */
    if (w==0xD503233Fu) return 1;                                                            /* paciasp */
    if ((w & 0xFFC07FFFu)==0xA9807BFDu) return 1;
    return 0;
}
int main(int argc,char**argv){
    if (argc<3){ fprintf(stderr,"用法: %s <image> <基址hex> [最小连续项]\n",argv[0]); return 1; }
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t *file=malloc(fsz); fread(file,1,fsz,f); fclose(f);
    d=file+CODE_OFF; n=fsz-CODE_OFF;
    size_t last=0; for(size_t k=n;k-->0;) if(d[k]){last=k;break;} n=last+1;
    BASE=strtoull(argv[2],NULL,16);
    int minrun = argc>3? atoi(argv[3]) : 3;
    printf("[*] 载荷 %zu 字节  基址 0x%08llx  有效期 0x%08llx..0x%08llx\n",
           n,(unsigned long long)BASE,(unsigned long long)BASE,
           (unsigned long long)(BASE+n));

    size_t run=0, start=0, tables=0, entries=0;
    printf("\n%-12s %-6s %s\n","表地址","项数","指向（前 8 项，带 'P' 表示疑似函数序言）");
    printf("-----------------------------------------------------------------\n");
    for (size_t off=0; off+8<=n; off+=8){
        uint64_t v; memcpy(&v,d+off,8);
        if (valid_ptr(v)){
            if (run==0) start=off;
            run++;
        } else {
            if ((int)run>=minrun){
                tables++; entries+=run;
                printf("0x%08llx %-6zu", (unsigned long long)(BASE+start), run);
                size_t lim = run<8?run:8;
                for (size_t k=0;k<lim;k++){
                    uint64_t p; memcpy(&p,d+start+k*8,8);
                    size_t po = (size_t)(p-BASE);
                    printf(" 0x%08llx%s",(unsigned long long)p, is_prologue_off(po)?"P":"");
                }
                printf("\n");
            }
            run=0;
        }
    }
    if ((int)run>=minrun){
        tables++; entries+=run;
        printf("0x%08llx %-6zu (表尾)\n",(unsigned long long)(BASE+start),run);
    }
    printf("\n[*] 共 %zu 张表，%zu 个表项\n", tables, entries);
    return 0;
}
