/* Wi-Fi Generic Test 88 */

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

/* 88. 2.4Ghz AP mode Security Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.88 ##\n");
    
    printf ("%@Sat*ict*apstart=testÅ×½ºÆ®$$_5 6 2 0 0 test12345678\f");
    
    if (wait_string ("*ICT*AP_STARTED:OK", 5, buff) == 1)
    {
        printf ("%@CTest Case 88 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 88\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

