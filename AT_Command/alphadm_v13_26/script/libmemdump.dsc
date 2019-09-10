/* [lib] memdump: void mem_dump (int addr, int size, void *buff, int bits) */

void mem_dump (int addr, int size, void *buff, int bits)
{    
    char *end;
    char temp[128];
    unsigned char  *buff8;   
    unsigned short *buff16;
    unsigned long  *buff32;
    int step, i, j, total;
    
    step = size / 16 + 1;
    total = size / (bits / 8);
    
    printf ("%@Smem dump %x %d %d\f", addr, size, bits);
    gets(temp); /* skip shell command  */
    gets(temp); /* skip blank line */
    
    if (bits == 8)
    {
        buff8 = (unsigned char*)buff;
        for (i = 0; i < step; i++)
        {
            gets(temp);	
            for (j = 0; j < 16; j++)
            {
                if (j == 0)
                {
                    *buff8++ = (unsigned char)strtoul (&temp[10], &end, 16);
                }
                else
                {
                    *buff8++ = strtoul (end, &end, 16);
                }
                total--;
                if (total == 0) return;
            }
        }        
    }
    else if (bits == 16)
    {
        buff16 = (unsigned short*)buff;
        for (i = 0; i < step; i++)
        {
            gets(temp);	
            for (j = 0; j < 8; j++)
            {
                if (j == 0)
                {
                    *buff16++ = (unsigned short)strtoul (&temp[10], &end, 16);
                }
                else
                {
                    *buff16++ = strtoul (end, &end, 16);
                }
                total--;
                if (total == 0) return;
            }
        }        
    }
    else if (bits == 32)
    {
        buff32 = (unsigned long*)buff;
        for (i = 0; i < step; i++)
        {
            gets(temp);	
            for (j = 0; j < 4; j++)
            {
                if (j == 0)
                {
                    *buff32++ = (unsigned long)strtoul (&temp[10], &end, 16);
                }
                else
                {
                    *buff32++ = strtoul (end, &end, 16);
                }
                total--;
                if (total == 0) return;
            }
        }        
    }     
}

/* TEST CODE

void main (void)
{
    char buff8[128];
    short buff16[64];
    long buff32[32];
    int i, j;
        
    mem_dump (0x90000000, 4, buff8, 8);
    mem_dump (0x90000000, 4, buff16, 16);
    mem_dump (0x90000000, 4, buff32, 32);
    
    printf ("%@C");
    for (i = 0; i < 128; i++)
    {
        if (((i+1) % 16) == 0)
        {
            printf ("%02X\f", buff8[i]);
        }
        else
        {
            printf ("%02X ", buff8[i]);
        }
    }
    for (i = 0; i < 64; i++)
    {
        if (((i+1) % 8) == 0)
        {
            printf ("%04X\f", buff16[i]);
        }
        else
        {
            printf ("%04X ", buff16[i]);
        }
    }
    for (i = 0; i < 32; i++)
    {
        if (((i+1) % 4) == 0)
        {
            printf ("%08X\f", buff32[i]);
        }
        else
        {
            printf ("%08X ", buff32[i]);
        }
    }    
}

*/