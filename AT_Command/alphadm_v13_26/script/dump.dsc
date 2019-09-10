/* memory dump and save to file

    dump modem memory and save 
    usage:
        test.dsc [base address] [size] [file]
*/

#include "libmemdump.dsc"
#include "libwaitstring.dsc"

#define SIZE    128

void main (int argc, char **argv)
{
	int i;
	int buff[1024*1024/4], *pBuf = buff;
	char temp[128], *end;
    int addr = 0x840B0000;
    int size =SIZE, step;
    FILE *fp;

    if (argc < 4)
    {
        printf ("usage: dump.dsc [base address with hex] [size] [file]\f");
        exit(0);
    }
    
    if (argc > 1) addr = strtoul (argv[1], &end, 16);
    if (argc > 2) size = atoi (argv[2]);
    step = size / 16;

    printf ("%@Sdebug 0\f");
    wait_string ("OK", 1, temp);
    
    mem_dump (addr, size, buff, 32);
      
    pBuf = buff;
    step /= 2;

    if (strstr (argv[3], "txt") != 0)
    {
        fp = fopen (argv[3], "w");
        for (i = 0; i < step; i++)
        {        
            fprintf (fp, "%08X %08X %08X %08X %08X %08X %08X %08X\n", 
                pBuf[0],pBuf[1],pBuf[2],pBuf[3],pBuf[4],pBuf[5],pBuf[6],pBuf[7]);
            pBuf += 8;
        }
        fclose (fp);
    }
    else
    {
        fp = fopen (argv[3], "wb");
        if (fp != 0)
        {
            fwrite (buff, size, 1, fp);
            fclose (fp);
        }
    }
    printf ("%@Sdebug 4\f");
}

