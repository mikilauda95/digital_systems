#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


#define WORD_SIZE 4
#define STATUS_ADDR 4
#define DATA_W_ADDR 0
#define DATA_R_ADDR 8

#define MAX_BLOCK 100
#define HASH_SIZE 32
#define BLOCK_SIZE 64
#define PADD_SIZE 8

int f_sha;
int j;

//Check if the device is busy for waiting before writing new block or to read the hash
void check_busy(unsigned char *buff)
{
    /*char buff[4];*/
    pread(f_sha, &buff[0], 4, STATUS_ADDR);
}

//write a block of 512 bits 
int write_block(unsigned char * block_buffer)
{
    for (j = 0; j < 16; j++) {
        if (pwrite(f_sha,  &block_buffer[j*4], WORD_SIZE, DATA_W_ADDR) < 0) {
            printf("Error while writing a block\n");
        }
        else{
            /*printf("Will write this word 0x%02x%02x%02x%02x\n", block_buffer[j*4], block_buffer[j*4+1], block_buffer[j*4+2], block_buffer[j*4+3]);*/
            /*sleep(1);*/
        }
    }
    printf("Written block_buffer\n");
    return 1;
}

//read the hash
int read_hash(unsigned char hash_buffer[HASH_SIZE])
{
    for (j = 0; j < 8; j++) {
        pread(f_sha, &hash_buffer[j*4], WORD_SIZE, DATA_R_ADDR + j*4);
        /*printf("READ this word of the hash %02x%02x%02x%02x\n", hash_buffer[j*4+3],hash_buffer[j*4+2],hash_buffer[j*4+1],hash_buffer[j*4]);*/
        printf("Read a HASH word\n");
    }
}

// write in the status register the first_mess signal to notify it is the first block
int write_first(unsigned char first_m){
    printf("Setting the register for the start signal\n");
    unsigned char load[4];
    load[3] = first_m << 1;
    load[2] = 0;
    load[1] = 0;
    load[0] = 0;

    if (pwrite(f_sha, &load, 4, STATUS_ADDR) < 0) {
        printf("Error while writing a block\n");
    }
    else{
        printf("Written status register block\n");
        return 1;
    }
}



int main(int argc, char *argv[])
{

    FILE *f;
    char filename[100];
    int charin;
    int count_chars;
    int count_block;
    uint64_t bitcount;
    int i;
    char c;
    unsigned char block_buffer[BLOCK_SIZE];
    unsigned char hash_buffer[HASH_SIZE];
    unsigned char status[4];

    //flag that goes to 0 after first has been sent
    int first = 1;


    if (argc != 2) { printf("Usage : ./sha256 <filename>\n");
        return -1;
    }

    strcpy(filename, argv[1]);

    f = fopen(filename, "r");
    if (f == NULL) {
        printf("Error when opening the file\n");
        return -1;
    }


    count_chars = 0;
    charin = 0;

    if ((f_sha = open("/dev/sha256", O_RDWR)) < 0) {
        printf("Error when opening the virtual device file \n");
        return -1;
    };

    while (!feof(f)){

        c=fgetc(f); 
        block_buffer[charin] = c;

        count_chars++;
        charin++;

        if (charin == BLOCK_SIZE){
            if (first == 1) {
                write_first(1);
            }

            do {
                check_busy(status);
                printf("STATUS is %02x%02x%02x%02x \n", status[0], status[1], status[2], status[3]);
            }while(status[0] & 0x00000002 == 0x00000002);

            write_block( block_buffer);
            charin = 0;
            count_block ++;
            if (first == 1) {
                write_first(0);
                first = 0;
            }
        }
    }

    //Do not count the last "FF" byte for computing the hash
    count_chars--;
    charin--;

    if (charin <  BLOCK_SIZE - PADD_SIZE) {
        block_buffer[charin] = (uint8_t) 0x80;
        for (i = charin+1; i < BLOCK_SIZE - 8 ; ++i) {
            block_buffer[i] = (uint8_t) 0x00;
        }
        do {
            check_busy(status);
            printf("STATUS is %02x%02x%02x%02x \n", status[0], status[1], status[2], status[3]);
        }while(status[0] & 0x02 == 0x02);
    }
    else {
        //first complete the block with zeros and then write another block until Padd_size
        block_buffer[charin] = 0x80;
        for (i = charin+1; i < BLOCK_SIZE ; ++i) {
            block_buffer[i] = 0x00;
        }

        do {
            check_busy(status);
            printf("STATUS is %02x%02x%02x%02x \n", status[0], status[1], status[2], status[3]);
        }while(status[0] & 0x02 == 0x02);

        if (first == 1) {
            write_first(1);
        }
        write_block(block_buffer);
        if (first == 1) {
            write_first(0);
            first = 0;
        }
        for (i = 0; i < BLOCK_SIZE - PADD_SIZE ; ++i) {
            block_buffer[i] = 0x00;
        }
    }

    // bitnumber is chars*8
    bitcount = count_chars << 3;

    //Write the length of the message one byte at a time
    block_buffer[BLOCK_SIZE - PADD_SIZE + 0] = (bitcount >> 56) & 0xFF;
    block_buffer[BLOCK_SIZE - PADD_SIZE + 1] = (bitcount >> 48) & 0xFF;
    block_buffer[BLOCK_SIZE - PADD_SIZE + 2] = (bitcount >> 40) & 0xFF;
    block_buffer[BLOCK_SIZE - PADD_SIZE + 3] = (bitcount >> 32) & 0xFF;
    block_buffer[BLOCK_SIZE - PADD_SIZE + 4] = (bitcount >> 24) & 0xFF;
    block_buffer[BLOCK_SIZE - PADD_SIZE + 5] = (bitcount >> 16) & 0xFF;
    block_buffer[BLOCK_SIZE - PADD_SIZE + 6] = (bitcount >> 8) & 0xFF;
    block_buffer[BLOCK_SIZE - PADD_SIZE + 7] = bitcount & 0xFF;

    if (first == 1) {
        write_first(1);
    }
    write_block(block_buffer);
    if (first == 1) {
        write_first(0);
        first = 0;
    }

    do {
        check_busy(status);
        printf("STATUS is %02x%02x%02x%02x \n", status[0], status[1], status[2], status[3]);
    }while(status[0] & 0x02 == 0x02);

    read_hash(hash_buffer);
    for (int i = 0; i < HASH_SIZE/4; i++) {
        printf("%02x%02x%02x%02x", hash_buffer[i*4+3], hash_buffer[i*4+2], hash_buffer[i*4+1], hash_buffer[i*4]);
    }
    printf("\n");

    return 0;
}
