// findptr.c — 搜 8 字节绝对指针（用于定位字符串指针表）
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
int main(int argc,char**argv){
    if(argc<3){fprintf(stderr,"用法: %s <image> <目标地址hex>...\n",argv[0]);return 1;}
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t*d=malloc(fsz); fread(d,1,fsz,f); fclose(f);
    for(int a=2;a<argc;a++){
        uint64_t T=strtoull(argv[a],NULL,16);
        uint8_t pat[8]; for(int k=0;k<8;k++) pat[k]=(uint8_t)(T>>(8*k));
        printf("=== 目标 0x%08llx ===\n",(unsigned long long)T);
        int cnt=0;
        for(size_t i=0;i+8<=fsz;i+=8){
            if(memcmp(d+i,pat,8)) continue;
            printf("  指针位置 文件 0x%zx  绝对 0x%08llx\n",i,(unsigned long long)(0x9f000000+i-512));
            /* 打印邻近表项 */
            for(int k=-2;k<=2;k++){
                long long o=(long long)i+k*8;
                if(o<0||(size_t)o+8>fsz) continue;
                uint64_t v; memcpy(&v,d+o,8);
                printf("    [%+d] 0x%08llx = 0x%08llx%s\n",k,(unsigned long long)(0x9f000000+o-512),
                       (unsigned long long)v, v==T?"  <<<":"");
            }
            if(++cnt>=3) break;
        }
        if(!cnt) printf("  （无 8 字节指针）\n");
        printf("\n");
    }
    return 0;
}
