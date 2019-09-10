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

/* 124. STA mode WEP Connect Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.124 ##\n");
    
    printf ("%@Sat*ict*ipconfig=1\f");

    printf ("%@Sat*ict*crypto=0 0 0\f");

    printf ("%@Sat*ict*sconn=SQC7-netis_WF2780_24G 12345\f");
    
    if (wait_string ("*ICT*SCONN:OK", 5, buff) == 1)
    {
        if (wait_string ("*ICT*IPALLOCATED:", 10, buff) == 1)
        {
            printf ("%@CTest Case 124 : Pass\f");
            printf ("%$T============================\n");
        }
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 124\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

