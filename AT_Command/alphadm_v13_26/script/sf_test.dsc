/* Serial Flash Test Script
# Erase/Program/Verify for 2MByte range at Bank2
loop 0 1000
    flash test 50220000 32
    wait 2000
    flash test 50240000 32
    wait 2000
    flash test 50260000 32
    wait 2000
    flash test 50280000 32
    wait 2000    
    flash test 502A0000 32
    wait 2000
    flash test 502C0000 32
    wait 2000    
    flash test 502E0000 32
    wait 2000
    flash test 50300000 64
    wait 3800    
    flash test 50340000 64
    wait 4000
    flash test 50380000 64
    wait 4000
    flash test 503C0000 64
    wait 4000
#    debug reset
#    wait 8000
endloop 0
*/

void main (void)
{
    int loop, addr, size, t1, t2;
    char buff[128];

    printf ("%@Sdebug 2\fdebug mask 0\f");
    sleep (500);
    
    for (loop = 0; loop < 1000; loop++)
    {
        printf ("%@C00000000 E:[Serial Flash Test %d]\f", loop+1);
        
        for (addr = 0x220000; addr <= 0x3C0000;)
        {
            size = (addr < 0x300000) ? 32 : 64;
            t1 = timems ();
            printf ("%@Sflash test %x %d\f", addr, size);
            do
            {
                buff[0] = 0;
                gets (buff);
            }
            while (buff[0] == 0);
            t2 = timems ();
            gets (buff);
            gets (buff);
            printf ("%@C%s\f", buff);
            
            if (strstr (buff, "OK") != 0)
            {
                printf ("%@CWrite Success(%d ms) !!\f", t2-t1);
            }
            else
            {
                printf ("%@CWrite Failed(%d ms) !!\f", t2-t1);
                goto end;
            }
            addr += size * 4096;
        }
    }
end:    
}

