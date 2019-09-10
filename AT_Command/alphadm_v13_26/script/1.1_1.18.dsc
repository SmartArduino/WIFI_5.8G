/* Wi-Fi Generic Test 1 ~ 18 */

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

/* 1. SW Version Check Start */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.1 ##\n");
    
    printf ("%@Sat*ict*swver=?\f");
    
    if (wait_string ("*ICT*SWVER:OK", 5, buff) == 1)
    {
        printf ("%@CTest Case 1 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 2. FW Version Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.2 ## \n");
    
    printf ("%@Sat*ict*fwver=?\f");
    
    if (wait_string ("*ICT*FWVER:OK", 10, buff) == 1)
    {
        printf ("%@CTest Case 2 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 5. Mac Address Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.5 ##\n");
    
    printf ("%@Sat*ict*mac=?\f");
    
    if (wait_string ("*ICT*MAC:OK", 5, buff) == 1)
    {
        printf ("%@CTest Case 5 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 6. Antenna Type Check */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.6 ##\n");
    
    printf ("%@Sat*ict*antver=?\f");
    
    if (wait_string ("*ICT*ANTVER:OK", 5, buff) == 1)
    {
        sscanf (buff, "*ICT*ANTVER:OK:%d", &a1);

        if(a1 == 0)
            printf ("%@CAnt. Type : Chip Antenna\f");
        else
            printf ("%@CAnt. Type : u.FL Antenna\f");

        printf ("%@CTest Case 6 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 10. Reset Check - Internal RAM Start */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.10 ##\n");

    printf ("%@Sat*ict*reset=0\f");
    
    if (wait_string ("*ICT*DEVICEREADY", 20, buff) == 1)
    {
        printf ("%@CTest Case 10 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 11. Reset Check - Internal RAM Start */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.11 ##\n");

    printf ("%@Sat*ict*reset=1\f");
    
    if (wait_string ("*ICT*DEVICEREADY", 20, buff) == 1)
    {
        printf ("%@CTest Case 11 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 14. Event Message */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.14 ##\n");

    printf ("%@Sat*ict*evtdel=?\f");
    
    if (wait_string ("*ICT*EVTDEL", 10, buff) == 1)
    {
        printf ("%@CTest Case 14 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 15. Event Message Off */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.15 ##\n");

    printf ("%@Sat*ict*evtdel=0\f");
    
    if (wait_string ("*ICT*EVTDEL", 10, buff) == 1)
    {
        printf ("%@CTest Case 15 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 16. Event Message On */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.16 ##\n");

    printf ("%@Sat*ict*evtdel=1\f");
    
    if (wait_string ("*ICT*EVTDEL", 10, buff) == 1)
    {
        printf ("%@CTest Case 16 : Pass\f");
        printf ("%$T============================\n");
        printf ("%@Sat*ict*evtdel=0\f");    // roll back
    }
    else
    {
        goto fail;
    }

/* 17. Scan */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.17 ##\n");

    printf ("%@Sat*ict*scan\f");
    
    if (wait_string ("*ICT*SCAN:OK", 20, buff) == 1)
    {
        printf ("%@CTest Case 17 : Pass\f");
        printf ("%$T============================\n");
    }
    else
    {
        goto fail;
    }

/* 18. Scan repeat */
    printf ("%$T============================\n");
    printf ("%$T## Test Case No.18 ##\n");

    printf ("%@Sat*ict*scan\f");

    for(i=0; i<5; i++)
    {
        if (wait_string ("*ICT*SCAN:OK", 20, buff) == 1)
        {
            printf ("%@CTest Case 18 repeat : %d\f",i+1);
            
            if(i==4)
            {
                printf ("%@CTest Case 18 : Pass\f");
                printf ("%$T============================\n");
            }
        }
        else
        {
            goto fail;
        }
    }

    printf ("%@MComplete\f");
    return 0;

fail:
    printf ("Test Case Fail\f");
    return 0;
}

