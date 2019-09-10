/* read specific register and set */

#define READ_REG    0x840b0000

unsigned long read_reg (int addr)
{
    char temp[128], *end;
    
	printf ("%@Smem dump %x 4 32\f", addr, 4);
    gets (temp); /* skip shell command  */
	gets (temp); /* skip blank line */
    gets(temp);	
    return strtoul (&temp[10], &end, 16);
}

void main (void)
{
    int reg = read_reg (READ_REG);
        
    printf ("%@CAddr 0x%x=%08x\f", READ_REG, reg);
    printf ("%@Smem set %x %x 32\f", READ_REG, reg | 0x80000000);
}
        
