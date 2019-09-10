/* Wi-Fi Generic Test 5 */

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

/* 53. AP mode passphrase Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.53 ##\n");
    
    printf ("%@Sat*ict*apstart=testÅ×½ºÆ®$$_5 6 2 0 0 \"test 12345678\"\f");
    
    if (wait_string ("*ICT*APSTART:OK", 10, buff) == 1)
    {
        printf ("%@CTest Case 53 : Pass\f");
        printf ("%$T============================\n");

    }
    else
    {
        goto fail;
    }

    printf ("%@MComplete\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

