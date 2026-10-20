// findref.c — 找引用任意绝对地址的指令（ADRP+ADD/LDR/STR 等）
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#define CODE_OFF 0x200
static uint8_t *d; static size_t n; static uint64_t BASE;
int main(int argc,char**argv){
    if(argc<4){fprintf(stderr,"用法: %s <image> <基址hex> <目标绝对地址hex>...\n",argv[0]);return 1;}
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t*file=malloc(fsz); fread(file,1,fsz,f); fclose(f);
    d=file+CODE_OFF; n=fsz-CODE_OFF;
    size_t last=0; for(size_t k=n;k-->0;) if(d[k]){last=k;break;} n=last+1;
    BASE=strtoull(argv[2],NULL,16);

    for(int a=3;a<argc;a++){
        uint64_t T=strtoull(argv[a],NULL,16);
        printf("=== 目标 0x%08llx ===\n",(unsigned long long)T);
        int cnt=0;
        for(size_t i=0;i+4<=n;i+=4){
            uint32_t w; memcpy(&w,d+i,4);
            /* ADRP */
            if((w&0x9F000000u)!=0x90000000u) continue;
            uint32_t rd=w&0x1F;
            int64_t lo=(w>>29)&3, hi=(w>>5)&0x7FFFF;
            int64_t im=(hi<<2)|lo; if(im&(1<<20)) im-=(1<<21);
            int64_t page=(int64_t)((BASE+i)&~0xFFFull)+(im<<12);
            if((uint64_t)page > T || (uint64_t)page + 0xFFF < T) continue;
            uint32_t off=(uint32_t)(T - (uint64_t)page);
            /* 在后续 12 条内找 ADD/LDR/STR with imm12==off 且 Rn==rd */
            for(int k=1;k<=12 && i+4*k+4<=n;k++){
                uint32_t b; memcpy(&b,d+i+4*k,4);
                uint32_t op = b & 0xFFC00000u;
                const char*name=NULL;
                if((b&0xFF000000u)==0x91000000u) name="ADD";
                else if((b&0xFFC00000u)==0xF9400000u) name="LDR";
                else if((b&0xFFC00000u)==0xF9000000u) name="STR";
                else if((b&0xFFC00000u)==0xB9400000u) name="LDRw";
                else if((b&0xFFC00000u)==0xB9000000u) name="STRw";
                if(!name) continue;
                if(((b>>5)&0x1F)!=rd) continue;
                uint32_t imm12=(b>>10)&0xFFF;
                if(b&(1u<<22)) imm12<<=12;
                if(imm12!=off) continue;
                printf("  0x%08llx  ADRP+%s (X%u)  [间隔 %d]%s\n",
                       (unsigned long long)(BASE+i), name, rd, k,
                       (name[0]=='S')?"  ← 写入!":"");
                cnt++;
                break;
            }
        }
        if(!cnt) printf("  （无引用）\n");
        printf("\n");
    }
    return 0;
}
