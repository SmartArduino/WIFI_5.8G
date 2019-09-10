/* file operaion test */

void main (void)
{
    FILE *fp;
    int i;
    char buff[128];
    
    fp = fopen ("d:\\test3.txt", "w");
    if (fp == 0)
    {
        printf ("file open error\f");
    }
    for (i = 0; i<128;i++)
    {
        buff[i] = i;
        fprintf (fp, "data=%d\n", i);
    }
    fclose (fp);
    
    fp = fopen("d:\\test4.bin", "wb");
    fwrite (buff, 1, 128, fp);
    fclose (fp);
}
