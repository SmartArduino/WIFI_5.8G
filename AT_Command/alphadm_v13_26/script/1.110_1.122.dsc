/* Wi-Fi Generic Test 110 */

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

/* 110. STA mode Open Connect Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.110 ##\n");
    
    printf ("%@Sat*ict*ipconfig=1\f");

    printf ("%@Sat*ict*crypto=0 0 0\f");

    printf ("%@Sat*ict*sconn=SQC4-dlink-550a_24G\f");
    
    if (wait_string ("*ICT*SCONN:OK", 5, buff) == 1)
    {
        if (wait_string ("*ICT*IPALLOCATED:", 10, buff) == 1)
        {
            printf ("%@CTest Case 110 : Pass\f");
            printf ("%$T============================\n");
        }
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 110\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

