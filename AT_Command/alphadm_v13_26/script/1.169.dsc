/* Wi-Fi Generic Test 169 */

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

/* 169. UDP Test Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.169 ##\n");

    printf ("%@Sat*ict*sconn=SQC4-dlink-550a_24G\f");
    
    if (wait_string ("*ICT*IPALLOCATED", 5, buff) == 1)
    {
        printf ("%@Sat*ict*socket=2\f");
        printf ("%@Sat*ict*bind=0 9100\f");

        if (wait_string ("*ICT*BIND:OK", 5, buff) == 1)
        {
            printf ("%@CTest Case 169 : Pass\f");
            printf ("%$T============================\n");
        }
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 169\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

