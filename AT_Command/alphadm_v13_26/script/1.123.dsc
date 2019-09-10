/* Wi-Fi Generic Test 123 */

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

/* 123. STA mode Open Disonnect Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.123 ##\n");
    
    printf ("%@Sat*ict*disassociate\f");
    
    if (wait_string ("*ICT*DISASSOCIATED", 5, buff) == 1)
    {
        printf ("%@CTest Case 123 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

    printf ("%@MTest Case 123\nSuccess\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

