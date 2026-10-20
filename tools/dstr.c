#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#define CODE_OFF 0x200
int main(int argc,char**argv){
    if(argc<4){fprintf(stderr,"用法: %s <image> <基址hex> <地址hex...>\n",argv[0]);return 1;}
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t*d=malloc(fsz); fread(d,1,fsz,f); fclose(f);
    uint64_t B=strtoull(argv[2],NULL,16);
    for(int a=3;a<argc;a++){
        uint64_t A=strtoull(argv[a],NULL,16);
        size_t o=(size_t)(A-B)+CODE_OFF;
        if(o>=fsz){printf("  0x%08llx : 越界\n",(unsigned long long)A);continue;}
        size_t k=0; while(o+k<fsz && d[o+k] && d[o+k]>=0x20 && d[o+k]<=0x7e && k<200) k++;
        printf("  0x%08llx : ",(unsigned long long)A);
        fwrite(d+o,1,k>0?k:0,stdout);
        printf("\n");
    }
    return 0;
}
