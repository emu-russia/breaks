#include <stdio.h>
#include <stdlib.h>

#define WIDTH   8*16*2
#define HEIGHT 8*16
#define FSIZE   (WIDTH * HEIGHT * 3) + 0x36 

char chr_name[256] = "bomber.chr";
unsigned char chr_data[8192];
char bmp_name[256];

typedef struct
{
    unsigned char b, g, r;
} PIXEL;

void usage()
{
    printf("Usage: chr2bmp FILENAME.CHR\n");
    exit(0);
}

int main(int argc, char *argv[])
{
    FILE *chr, *bmp;
    unsigned char hdr[0x36];
    int i = 0;
    int x, y, r, b, pat;

    printf("chr2bmp - CHR ROM convertor. v.1.0\n");
    printf("Created (C) org /2002/ \nkvzorganic@mail.ru\n\n");

    if(argc <= 1)
        usage();
    else
        sprintf(chr_name, "%s", argv[1]);

    while(1)
    {
        char c;
        c = chr_name[i];
        if(!c || c=='.') break;
        bmp_name[i++] = c;
    }
    sprintf(&bmp_name[i], ".bmp");

    chr = fopen(chr_name, "rb");
    fread(chr_data, 1, 8192, chr);

    printf("processing %s\n", bmp_name);

    bmp = fopen(bmp_name, "wb");

    // hardcoded header
    hdr[0] = 'B'; hdr[1] = 'M';
    *(unsigned long *)(hdr+2) = FSIZE;
    *(unsigned long *)(hdr+6) = 0;
    *(unsigned long *)(hdr+10) = 0x36;
    *(unsigned long *)(hdr+14) = 0x28;
    *(unsigned long *)(hdr+18) = WIDTH;
    *(unsigned long *)(hdr+22) = HEIGHT;
    *(unsigned short *)(hdr+26) = 1;
    *(unsigned short *)(hdr+28) = 24;
    *(unsigned long *)(hdr+30) = 0;
    *(unsigned long *)(hdr+34) = FSIZE - 0x36;
    *(unsigned long *)(hdr+38) = 0x0ec4;
    *(unsigned long *)(hdr+42) = 0x0ec4;
    *(unsigned long *)(hdr+46) = 0;
    *(unsigned long *)(hdr+50) = 0;
    fwrite(hdr, 1, 0x36, bmp);

    // 24-bit image
    for(y=15; y>=0; y--)
    for(r=7; r>=0; r--)     // ROW
    for(x=0; x<32; x++)
    {
        unsigned char lo, hi;

        // setup pattern address
        pat = 0;
        if(x >= 16)
            pat += 4096;
        pat = pat + 16*16*y;
        if(x >= 16)
            pat = pat + 16*(x-16);
        else
            pat = pat + 16*x;

        lo = chr_data[pat + r];
        hi = chr_data[pat + r + 8];
        for(b=7; b>=0; b--)
        {
            int c;
            PIXEL p;
            c = (((hi>>b)&1)<<1) | ((lo>>b)&1);
            switch(c)
            {
                case 0:
                    p.r = p.g = p.b = 0;
                    break;
                case 1:
                    p.r = p.g = p.b = 0x3f;
                    break;
                case 2:
                    p.r = p.g = p.b = 0x7f;
                    break;
                case 3:
                    p.r = p.g = p.b = 0xff;
            }
            fwrite(&p, 1, 3, bmp);
        }
    }
}
