/* Wi-Fi Generic Test 83 */

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

/* 83. 5Ghz AP mode Channel Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.83 ##\n");
    
    printf ("%@Sat*ict*apstart=test5g 157\f");
    
    if (wait_string ("*ICT*AP_STARTED:OK", 5, buff) == 1)
    {
        printf ("%@CTest Case 83 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 83\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

