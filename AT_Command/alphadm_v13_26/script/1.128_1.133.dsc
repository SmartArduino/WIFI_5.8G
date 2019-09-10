/* Wi-Fi Generic Test 128 */

int wait_string (char *str, int timeout, char *buff)
{
    int pretime = timesec ();

    while (1)
    {
        gets (buff);        
        if (strstr (buff, str) != 0) return 1;        
        if (timesec () - pretime >= timeout) return 0;
    }
}

int main (int argc, char **argv)
{
    char buff[128], result[128];;
    int a1;
    int i;

/* 128. STA mode WEP Disonnect Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.128 ##\n");

    printf ("%@Sat*ict*auconmode=0 0\f");
    
    printf ("%@Sat*ict*disassociate\f");
    
    if (wait_string ("*ICT*DISASSOCIATED", 5, buff) == 1)
    {
        printf ("%@CTest Case 128 : Pass\f");
        printf ("%$T============================\n");

    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 128\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

