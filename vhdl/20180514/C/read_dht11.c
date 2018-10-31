#include <stdio.h>
#include <stdlib.h>

int main(){
    FILE *f;
    char buf[5];

    if ((f=fopen("/dev/dht11", "r")) == NULL) {
        printf("Unable to open the dht11 /dev/dht11 file\n");
        return EXIT_FAILURE;
    }
    else{
        if (fread(buf, 1, 5, f)==5) {
                printf("The temperature read is %02d.%02d °C\n", buf[1], buf[0]);
                printf("The humidity read is %02d.%02d%%\n", buf[3], buf[2]);
                printf("The status register is  %02d\n", buf[4]);
        }
    }
    fclose(f);
    return 0;
}
