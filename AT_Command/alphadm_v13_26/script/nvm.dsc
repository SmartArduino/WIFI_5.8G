/* nvmemory read/write file */

#include "libwaitstring.dsc"

#define SIZE    128

void usage (void)
{
    printf ("%@CUsage : nvm [ram|rom] [read|write]\f");
    exit (0);
}

void main (int argc, char **argv)
{
    char file[128];;
    char *nv_img;
    int  size,  addr, rw, i, *ptr;
    FILE *fp;
    
    /* nvm [ram/rom] [read/write] */
    if (argc != 3)
    {
        usage ();
    }
    
    if (!strcmp (argv[1], "ram")) addr = 0x831FE000;
    else if (!strcmp (argv[1], "rom")) addr = 0x831FC000;
    else usage ();
    
    if (!strcmp (argv[2], "read")) rw = 0;
    else if (!strcmp (argv[2], "write")) rw = 1;
    else usage ();    
    
    size = 8192;
    strcpy (file, "*.bin");
    SelectFile (rw, file, "bin", sizeof (file));
    if (!file[0]) return;
    
    fp = fopen (file, rw ? "rb":"wb");
    if (fp == 0)
    {
        printf ("%@MFile(%s) open failed\f", file);
        return;
    }
    
    nv_img = malloc (size);
    if (nv_img == 0)
    {
        printf ("%@MMemory alloc failed\nf");
        fclose (fp);
        return;
    }    

    if (rw == 1)    /* write */
    {
        sprintf (file, "flash xmodem nv %x", addr);
        fread (nv_img, 1, size, fp);
        xmodem (file, nv_img, size);        
    }
    else
    {        
        char temp[128], *end;
        int step;

        ptr = (int*)nv_img;
        step = size / 16;

        printf ("%@Sdebug 0\f");
        wait_string ("OK", 1, temp);

        printf ("%@Smem dump %x %d 32\f", addr, size);
        gets(temp); /* skip shell command  */
        gets(temp); /* skip blank line */

        for (i = 0; i < step; i++)
        {
            gets(temp);	
            *ptr++ = strtoul (&temp[10], &end, 16);
            *ptr++ = strtoul (end, &end, 16);
            *ptr++ = strtoul (end, &end, 16);
            *ptr++ = strtoul (end, &end, 16);        
        }

        fwrite (nv_img, size, 1, fp);
        printf ("%@Sdebug 4\f");
     }
     fclose (fp);
     free (nv_img);
}

