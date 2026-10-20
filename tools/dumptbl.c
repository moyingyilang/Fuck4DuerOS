#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#define CODE_OFF 0x200
int main(int argc,char**argv){
    if(argc<4){fprintf(stderr,"用法: %s <image> <基址hex> <表地址hex> [项数]\n",argv[0]);return 1;}
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("open");return 1;}
    fseek(f,0,SEEK_END); size_t fsz=ftell(f); fseek(f,0,SEEK_SET);
    uint8_t*d=malloc(fsz); fread(d,1,fsz,f); fclose(f);
    uint64_t B=strtoull(argv[2],NULL,16), T=strtoull(argv[3],NULL,16);
    int cnt=argc>4?atoi(argv[4]):16;
    size_t base_off=(size_t)(T-B)+CODE_OFF;
    for(int k=0;k<cnt;k++){
        size_t o=base_off+k*8;
        if(o+8>fsz) break;
        uint64_t v; memcpy(&v,d+o,8);
        /* 判断目标像不像代码：读它前 4 字节 */
        size_t to=(size_t)(v-B)+CODE_OFF;
        unsigned char b0=0,b1=0,b2=0,b3=0;
        if(to+4<=fsz){b0=d[to];b1=d[to+1];b2=d[to+2];b3=d[to+3];}
        printf("  [%2d] 表@0x%08llx = 0x%08llx  目标首字节 %02x %02x %02x %02x\n",
               k,(unsigned long long)(T+k*8),(unsigned long long)v,b0,b1,b2,b3);
    }
    return 0;
}
