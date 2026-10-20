// findval.c — 搜索 32 位值在镜像中的所有出现形式
//   1) rodata 中的 4 字节小端
//   2) movz/movk wN,#imm16（低 16 位）
//   3) movz/movk xN,#imm16
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#define CODE_OFF 0x200
static uint8_t *d; static size_t n; static uint64_t BASE;
static size_t off_of(uint64_t abs){ return (size_t)(abs-BASE); }
int main(int argc,char**argv){
    if(argc<4){fprintf(stderr,"用法: %s <image> <基址hex> <值hex>...\n",argv[0]);return 1;}
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t*file=malloc(fsz); fread(file,1,fsz,f); fclose(f);
    d=file+CODE_OFF; n=fsz-CODE_OFF;
    size_t last=0; for(size_t k=n;k-->0;) if(d[k]){last=k;break;} n=last+1;
    BASE=strtoull(argv[2],NULL,16);

    for (int a=3;a<argc;a++){
        uint32_t v=(uint32_t)strtoul(argv[a],NULL,16);
        printf("=== 值 0x%08x ===\n", v);

        /* 1) rodata 4 字节小端 */
        printf("  [数据] ");
        int cnt=0;
        for (size_t i=0;i+4<=n;i++){
            uint32_t w; memcpy(&w,d+i,4);
            if (w==v){ printf("0x%08llx ",(unsigned long long)(BASE+i)); if(++cnt>=8) break; }
        }
        if(!cnt) printf("（无）");
        printf("\n");

        /* 2) movz/movk  低16位 */
        uint16_t lo=v&0xFFFF, hi=(v>>16)&0xFFFF;
        for (int part=0; part<2; part++){
            uint16_t imm = part? hi : lo;
            char tag = part?'h':'l';
            printf("  [movz %c] ", tag);
            cnt=0;
            for (size_t i=0;i+4<=n;i+=4){
                uint32_t w; memcpy(&w,d+i,4);
                /* movz wN,#imm  = 0x52800000|(imm<<5)|Rd */
                if ((w & 0xFF80001Fu)==0x52800000u && ((w>>5)&0xFFFF)==imm){
                    printf("0x%08llx(w%u) ",(unsigned long long)(BASE+i), w&0x1F); if(++cnt>=6) break; }
            }
            if(!cnt) printf("（无）");
            printf("\n");
            printf("  [movk %c] ", tag);
            cnt=0;
            for (size_t i=0;i+4<=n;i+=4){
                uint32_t w; memcpy(&w,d+i,4);
                if ((w & 0xFF80001Fu)==0x72800000u && ((w>>5)&0xFFFF)==imm
                    && ((w>>21)&3)==1){
                    printf("0x%08llx(w%u) ",(unsigned long long)(BASE+i), w&0x1F); if(++cnt>=6) break; }
            }
            if(!cnt) printf("（无）");
            printf("\n");
        }
        /* 3) bfi w0,w0,#0x10,#0x10 模式（0x33103C00|Rn|Rd） */
        printf("  [bfi 0x10,0x10] ");
        cnt=0;
        for (size_t i=0;i+4<=n;i+=4){
            uint32_t w; memcpy(&w,d+i,4);
            if ((w & 0xFFC00000u)==0x33000000u && ((w>>16)&0x3F)==0x10 && ((w>>10)&0x3F)==0x10){
                printf("0x%08llx ",(unsigned long long)(BASE+i)); if(++cnt>=10) break; }
        }
        if(!cnt) printf("（无）");
        printf("\n\n");
    }
    return 0;
}
