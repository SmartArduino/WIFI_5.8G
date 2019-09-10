/* Wi-Fi Generic Test 4 */

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

/* 44. AP mode SSID Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.44 ##\n");
    
    printf ("%@Sat*ict*apstart=\"test Å×½ºÆ® $ $ _ 5\" 6 3 1 1 12345678\f");
    
    if (wait_string ("*ICT*AP_STARTED:OK", 5, buff) == 1)
    {
        printf ("%@CTest Case 44 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 44\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

