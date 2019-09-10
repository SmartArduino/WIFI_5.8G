/* shell input test */

void main (void)
{
    int addr, data;
    
    for (addr = 0x53000000; addr < 0x53001000; addr +=4)
    {
        printf ("%@Smem get %x 32\f", addr);
        scanf ("%x: %x", &addr, &data);
        printf ("%@Caddr=%x, data=%x\f", addr, data);
    }
}

