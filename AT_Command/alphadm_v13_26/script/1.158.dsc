/* Wi-Fi Generic Test 158 */

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

/* 158. TCP Server Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.158 ##\n");

    printf ("%@Sat*ict*sconn=SQC4-dlink-550a_24G\f");
    
    if (wait_string ("*ICT*IPALLOCATED", 5, buff) == 1)
    {
        printf ("%@Sat*ict*socket=1\f");
        printf ("%@Sat*ict*bind=0 9100\f");
        printf ("%@Sat*ict*listen=0\f");

        if (wait_string ("*ICT*LISTEN:OK", 5, buff) == 1)
        {
            printf ("%@CTest Case 158 : Pass\f");
            printf ("%$T============================\n");
        }
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 158\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

