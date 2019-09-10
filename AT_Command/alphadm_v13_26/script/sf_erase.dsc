/* serial flash erase test */

void main (void)
{
    int addr;
    char buff[128];
    
    for (addr = 0x220000; addr < 0x220000+32768; addr += 4096)
    {
        printf ("%@C00000000 W:[Serial Flash Erase %x]\f", addr);
                
        printf ("%@Sflash erase %x\f", addr);
        do
        {
            buff[0] = 0;
            gets (buff);
        }
        while (buff[0] == 0);
    }
}

