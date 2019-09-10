/* Wi-Fi Generic Test 28 ~ 29 */

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

/* 28. AP mode Start Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.28 ##\n");
    
    printf ("%@Sat*ict*apstart=TestAP24g 6 3 1 1 12345678\f");
    
    if (wait_string ("*ICT*AP_STARTED:OK", 5, buff) == 1)
    {
        printf ("%@CTest Case 28 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 29. AP mode Stop Check */
    printf ("\n## Test Case No.29 ## \n");
    
    printf ("%@Sat*ict*apstop\f");
    
    if (wait_string ("*ICT*AP_STOPED:OK", 5, buff) == 1)
    {
        printf ("%@CTest Case 29 : Pass\f");
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

