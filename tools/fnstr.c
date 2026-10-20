// fnstr.c — 列出指定地址区间内所有 ADRP+ADD 引用的字符串
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#define CODE_OFF 0x200
static uint8_t *d; static size_t n; static uint64_t BASE;
static const char* str_at(uint64_t abs){
    if (abs < BASE) return NULL;
    size_t o=(size_t)(abs-BASE);
    if (o>=n) return NULL;
    if (o>0 && d[o-1]!=0) return NULL;
    if (d[o]<0x20 || d[o]>0x7e) return NULL;
    size_t k=0; while(o+k<n && d[o+k]>=0x20 && d[o+k]<=0x7e && k<160) k++;
    if (k<4) return NULL;
    if (o+k<n && d[o+k]!=0) return NULL;
    return (const char*)(d+o);
}
int main(int argc,char**argv){
    if(argc<4){fprintf(stderr,"用法: %s <image> <基址hex> <起hex> [止hex]\n",argv[0]);return 1;}
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t*file=malloc(fsz); fread(file,1,fsz,f); fclose(f);
    d=file+CODE_OFF; n=fsz-CODE_OFF;
    size_t last=0; for(size_t k=n;k-->0;) if(d[k]){last=k;break;} n=last+1;
    BASE=strtoull(argv[2],NULL,16);
    uint64_t A=strtoull(argv[3],NULL,16);
    uint64_t Z=argc>4?strtoull(argv[4],NULL,16):A+0x200;
    size_t s=(size_t)(A-BASE), e=(size_t)(Z-BASE);
    if(e>n) e=n;
    int cnt=0;
    for(size_t i=s;i+8<=e;i+=4){
        /* ADRP */
        uint32_t a; memcpy(&a,d+i,4);
        if((a&0x9F000000u)!=0x90000000u) continue;
        uint32_t rd=a&0x1F;
        int64_t lo=(a>>29)&3, hi=(a>>5)&0x7FFFF;
        int64_t im=(hi<<2)|lo; if(im&(1<<20)) im-=(1<<21);
        /* 该指令的绝对地址 = 当前指令地址；页基址 = 指令地址页 + imm<<12 */
        int64_t page=(int64_t)((BASE+i)&~0xFFFull)+(im<<12);
        for(int j=1;j<=8 && i+4*j+8<=e;j++){
            uint32_t b; memcpy(&b,d+i+4*j,4);
            if((b&0x7F000000u)!=0x11000000u || !(b>>31)) continue;
            if(((b>>5)&0x1F)!=rd) continue;
            uint32_t imm12=(b>>10)&0xFFF;
            if(b&(1u<<22)) imm12<<=12;
            const char*str=str_at((uint64_t)(page+imm12));
            if(str){ printf("  0x%08llx → \"%s\"\n",(unsigned long long)(BASE+i),str); cnt++; }
            break;
        }
    }
    printf("  (%d 个字符串引用)\n",cnt);
    return 0;
}
