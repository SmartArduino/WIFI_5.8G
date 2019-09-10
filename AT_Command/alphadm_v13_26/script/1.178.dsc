/* Wi-Fi Generic Test 178 */

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

/* 178. Socket Close Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.178 ##\n");

    printf ("%@Sat*ict*close=0\f");

    if (wait_string ("*ICT*CLOSE:OK", 5, buff) == 1)
    {
        printf ("%@CTest Case 178 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 178\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

