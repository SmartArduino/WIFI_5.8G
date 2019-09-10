/* AT Command TCP server open/close repetition test */

#include "libwaitstring.dsc"

#define IP_PORT     1500
#define SSID        "kangap"
#define PASSWD      "12345678"
#define TEST_LOOP   10000

int test_tcp_server_open_close_loopback (void)
{
    char buff[128], snd[128];
    int a1,a2,a3,a4, b1,b2,b3,b4, sz;
    int socket_no, sndsock_no, cnt = 0;
    int port = IP_PORT;
    
    /* connect AP */
    printf ("%@Sat*ict*sconn=%s %s\f", SSID, PASSWD);
    
    if (wait_string ("IPALLOCATED", 10, buff) == 1)
    {
        sscanf (&buff[9], "*ICT*IPALLOCATED:%d.%d.%d.%d", &a1, &a2, &a3, &a4);
        printf ("%@CMy IP=%d.%d.%d.%d\f", a1,a2,a3,a4);
    }
    else
    {
        goto fail;
    }

    while (cnt < TEST_LOOP)
    {
        printf ("%@C00000000 W:TCP Open/Close Test %d\f", ++cnt);

        /* create TCP server */
        printf ("%@Sat*ict*socket=1\f");
        printf ("%@CWaiting for socket ok string\f");
        if (!wait_string ("*ICT*SOCKET:OK", 5, buff)) goto fail;        
        sscanf (buff, "*ICT*SOCKET:OK %d", &socket_no);
        
        printf ("%@Sat*ict*bind=%d %d\f", socket_no, port);
        printf ("%@CWaiting for bind ok string\f");        
        if (!wait_string ("*ICT*BIND:OK", 5, buff)) goto fail;
        
        printf ("%@Sat*ict*listen=%d\f", socket_no);
        printf ("%@CWaiting for listen ok string\f");
        if (!wait_string ("*ICT*LISTEN:OK", 5, buff)) goto fail;
        
        /* connect Module from PC */
        printf ("%@CTry to connect = %d.%d.%d.%d:%d\f",a1,a2,a3,a4, port);
        sprintf (buff, "%%@T(%d.%d.%d.%d:%d)", a1,a2,a3,a4, port);
        printf (buff);

        printf ("%@CWaiting for accept string\f");
        if (!wait_string ("*ICT*ACCEPTED", 30, buff)) goto fail;
        sscanf (buff, "*ICT*ACCEPTED:%d %d.%d.%d.%d %d", &socket_no, &b1,&b2,&b3,&b4, &sndsock_no);

        printf ("%@CTry to send string from PC to Modem\f");
        sz = sprintf (snd, "This is an example string..%d", cnt);
        printf ("%@T%s\f", snd);
        printf ("%@CWaiting received string from modem\f");        
        if (!wait_string (snd, 20, buff)) goto fail;

        printf ("%@CTry to send string from Modem to PC\f");
        printf ("%@Sat*ict*send=%d %d.%d.%d.%d %d %d %s\f", socket_no, b1,b2,b3,b4, sndsock_no, sz, snd);
        printf ("%@CWaiting for received string from PC\f");                
        if (!wait_string (snd, 20, buff)) goto fail;

        printf ("%@T()");      
        
        printf ("%@CWaiting for disconnected string from PC\f");                
        if (!wait_string ("*ICT*DISCONNECTED:", 5, buff)) goto fail;
        
        printf ("%@Sat*ict*close=%d\f", socket_no);

        printf ("%@CWaiting for closed string from PC\f");                        
        if (!wait_string ("*ICT*CLOSED:", 5, buff)) goto fail;        
    }

    printf ("%@C00000000 I: ------------------>> Complete\f");
    return 1;

fail:
    printf ("%@T()"); 
    printf ("%@C00000000 I: ------------------>> Failed\f");
    return 0;
}

int test_case_tcp_looback (void)
{
    char buff[128], snd[128];
    int a1,a2,a3,a4, b1,b2,b3,b4, sz;
    int socket_no, sndsock_no;

    /* connect AP */
    printf ("%@Sat*ict*sconn=%s %s\f", SSID, PASSWD);
    
    if (wait_string ("IPALLOCATED", 10, buff) == 1)
    {
        /* 1B9A798D *ICT*IPALLOCATED:192.168.1.85 255.255.255.0 192.168.1.1 164.124.101.2*/
        sscanf (&buff[9], "*ICT*IPALLOCATED:%d.%d.%d.%d", &a1, &a2, &a3, &a4);
        printf ("%@CMy IP=%d.%d.%d.%d\f", a1,a2,a3,a4);
    }
    else
    {
        goto fail;
    }

    /* create TCP server */
    printf ("%@Sat*ict*socket=1\f");
    printf ("%@CWaiting socket ok string\f");
    if (!wait_string ("*ICT*SOCKET:OK", 3, buff)) goto fail;    
    sscanf (buff, "*ICT*SOCKET:OK %d", &socket_no);

    printf ("%@Sat*ict*bind=%d %d\f", socket_no, IP_PORT);
    printf ("%@CWaiting bind ok string\f");        
    if (!wait_string ("*ICT*BIND:OK", 5, buff)) goto fail;
    
    printf ("%@Sat*ict*listen=%d\f", socket_no);
    printf ("%@CWaiting listen ok string\f");            
    if (!wait_string ("*ICT*LISTEN:OK", 5, buff)) goto fail;
    
    /* connect Module from PC */
    printf ("%@CTry to connect = %d.%d.%d.%d:%d\f",a1,a2,a3,a4, IP_PORT);
    sprintf (buff, "%%@T(%d.%d.%d.%d:%d)\f", a1,a2,a3,a4, IP_PORT);
    printf (buff);
    printf ("%@CWaiting accepted string\f");                
    if (!wait_string ("*ICT*ACCEPTED", 5, buff)) goto fail;
    sscanf (buff, "*ICT*ACCEPTED:%d %d.%d.%d.%d %d", &socket_no, &b1,&b2,&b3,&b4, &sndsock_no);

    a1 = 0;
    while (a1 < TEST_LOOP)
    {
        sz = sprintf (snd, "This is an example string..%d", a1++);
        printf ("%@CSend=\"%s\"\f", snd);
        printf ("%@T%s\f", snd);
        if (!wait_string (snd, 2, buff)) goto fail;
        printf ("%@Sat*ict*send=%d %d.%d.%d.%d %d %d %s\f", socket_no, b1,b2,b3,b4, sndsock_no, sz, snd);
        if (!wait_string (snd, 2, buff)) goto fail;
    }

    printf ("%@T()"); 
    printf ("%@C00000000 I: ------------------>> Complete\f");
    return 1;

fail:
    printf ("%@T()"); 
    printf ("%@C00000000 I: ------------------>> Failed\f");
    return 0;
}

int test_ap_list_connect (void)
{
    int cnt = 0;
    char buff[128];
    /* connect AP */
    //printf ("%@Sate1\f");

    while (cnt < 100)
    {
        printf ("%@C00000000 W: AP Connection Test %d\f", cnt++);
        
        printf ("%@Sat*ict*sconn=anygate_test 12345678\f");        
        if (wait_string ("IPALLOCATED", 30, buff) == 0) goto fail;

        printf ("%@Sat*ict*sconn=Standalone 987654321\f");        
        if (wait_string ("IPALLOCATED", 30, buff) == 0) goto fail;        

        printf ("%@Sat*ict*sconn=miguel_2\f");        
        if (wait_string ("IPALLOCATED", 30, buff) == 0) goto fail;        

        printf ("%@Sat*ict*sconn=kangap 12345678\f");        
        if (wait_string ("IPALLOCATED", 30, buff) == 0) goto fail;        
        
    }
    printf ("%@C00000000 I: ------------------>> Complete\f");
    return 1;

fail:
    printf ("%@C00000000 I: ------------------>> Failed\f");    
    return 0;
}

int test_tcp_server_multi_open (void)
{
    char buff[128], snd[128];
    int a1,a2,a3,a4;
    int socket_no, cnt = 0, i;
    int port = IP_PORT;
    
    while (cnt < 100)//TEST_LOOP)
    {
        printf ("%@C00000000 W:TCP Open/Close Test %d\f", ++cnt);

        /* connect AP */
        printf ("%@Sat*ict*sconn=%s %s\f", SSID, PASSWD);
        
        if (wait_string ("IPALLOCATED", 10, buff) == 1)
        {
            sscanf (buff, "*ICT*IPALLOCATED:%d.%d.%d.%d", &a1, &a2, &a3, &a4);
            printf ("%@CMy IP=%d.%d.%d.%d\f", a1,a2,a3,a4);
        }
        else
        {
            goto fail;
        }        

        for (i = 0; i < 10; i++)
        {
            /* create TCP server */
            printf ("%@Sat*ict*socket=1\f");
            printf ("%@CWaiting for socket ok string\f");
            if (!wait_string ("*ICT*SOCKET:OK", 1, buff)) continue;
            sscanf (buff, "*ICT*SOCKET:OK %d", &socket_no);
            
            printf ("%@Sat*ict*bind=%d %d\f", socket_no, port++);
            printf ("%@CWaiting for bind ok string\f");        
            if (!wait_string ("*ICT*BIND:OK", 1, buff)) continue;
            
            printf ("%@Sat*ict*listen=%d\f", socket_no);
            printf ("%@CWaiting for listen ok string\f");
            if (!wait_string ("*ICT*LISTEN:OK", 1, buff)) continue;
        }
        for (i = 0; i < 10; i++)
        {
            /* create TCP server */
            printf ("%@Sat*ict*close=%d\f", i);
            if (!wait_string ("*ICT*CLOSE:OK", 1, buff)) continue;
        }

        printf ("%@Sat*ict*disassociate\f");
        sleep (300);
    }
    printf ("%@C00000000 I: ------------------>> Complete\f");
    return 1;

fail:
    printf ("%@C00000000 I: ------------------>> Failed\f");    
    return 0;
}

int test_ap_con_maintain (void)
{
    char buff[128];
    int cnt;

    /* connect AP */
    //printf ("%@Sate1\f");

    while (1)
    {
        printf ("%@C00000000 W: AP Connection Maintain Test %d\f", cnt);        
        //printf ("%@Sat*ict*sconn=anygate_test 12345678\f");        
        printf ("%@Sat*ict*sconn=kangap 12345678\f");        
        wait_string ("*ICT*DISASSOCIATED", 0, buff);
    }
    printf ("%@C00000000 I: ------------------>> Complete\f");
    return 1;
}


int test_reset (void)
{
    int c = 1;
    char buff[128];    

    do
    {
        printf ("%@CReset Test %d\f", ++c);      
        printf ("%@Sat*ict*reset=1\f");                
        if (wait_string ("*ICT*DEVICEREADY", 5, buff) == 0) goto fail;
    }
    while (c < 100);
    
    printf ("%@C00000000 I: ------------------>> Complete\f");
    return 1;

fail:
    printf ("%@C00000000 I: ------------------>> Failed\f");    
    return 0;
}

int test_ap_mode (void)
{
    int c = 0;
    char buff[128];
        
    while (++c < 1000)
    {
        printf ("%@Sat*ict*apstart=dhkim_ap 6 3 1 1 12345678\f");
        sleep (15000);
        printf ("%@Sat*ict*sconn=anygate_test 12345678\f");
        //printf ("%@Sat*ict*sconn=Standalone 987654321\f");        
        if (wait_string ("IPALLOCATED", 15, buff) == 0) ;//goto fail;
        sleep (5000);
    }        

    printf ("%@C00000000 I: ------------------>> Complete\f");
    return 1;

fail:
    printf ("%@C00000000 I: ------------------>> Failed\f");    
    return 0;
}

int test_upnp_loopback (void)
{
    char buff[128], snd[128];
    int a1,a2,a3,a4;
    int cnt;

    while (++cnt < 100)
    {
        printf ("%@C00000000 W: UPNP Test %d\f", cnt);
        
        /* connect AP */
        printf ("%@Sat*ict*sconn=%s %s\f", SSID, PASSWD);
        
        if (wait_string ("IPALLOCATED", 15, buff) == 1)
        {
            sscanf (buff, "*ICT*IPALLOCATED:%d.%d.%d.%d", &a1, &a2, &a3, &a4);
            printf ("%@CMy IP=%d.%d.%d.%d\f", a1,a2,a3,a4);
        }
        else
        {
            continue;
        }        
        sleep(500);

        printf ("%@Sat*ict*upnp_extip\f");
        printf ("%@CWaiting for upnp_extip ok string\f");
        if (!wait_string ("*ICT*UPNP_EXTIP:OK", 1, buff)) ;//goto fail;
        printf ("%@CWaiting for externalip string\f");
        if (!wait_string ("*ICT*EXTERNALIP", 10, buff)) ;// goto fail;
        sleep(500);
        
        sprintf (snd, "%%@Sat*ict*upnp_delportmap=%d %d\f", 54321, 1);
        printf (snd);
        printf ("%@CWaiting for upnp_delportmap ok string\f");
        if (!wait_string ("*ICT*UPNP_DELPORTMAP:OK", 1, buff)) ;// goto fail;
        printf ("%@CWaiting for delportmapping ok string\f");
        if (!wait_string ("*ICT*DELPORTMAPPING:OK", 10, buff)) ;// goto fail;
        sleep(500);
        
        sprintf (snd, "%%@Sat*ict*upnp_addportmap=%d.%d.%d.%d %d %d %d\f", a1, a2, a3, a4, 12345, 54321, 1);
        printf (snd);
        printf ("%@CWaiting for upnp_addportmap ok string\f");
        if (!wait_string ("*ICT*UPNP_ADDPORTMAP:OK", 1, buff)) ;// goto fail;
        printf ("%@CWaiting for addportmapping ok string\f");
        if (!wait_string ("*ICT*ADDPORTMAPPING:OK", 10, buff)) ;// goto fail;
        
    }
    printf ("%@C00000000 I: ------------------>> Complete\f");
    return 1;

fail:
    printf ("%@C00000000 I: ------------------>> Failed\f");    
    return 0;
}


#define FAIL_TO_CONTINUE
//#define TEST_RESET
//#define TEST_SERVER_MULTI_OPEN
//#define TEST_AP_LIST_CONNECT
//#define TEST_TCP_SERVER_OPEN_CLOSE_LOOPBACK
//#define TEST_CASE_TCP_LOOPBACK
//#define TEST_AP_MODE
//#define TEST_UPNP_LOOPBACK
//#define TEST_AP_CON_MAINTAIN

void main (int argc, char **argv)
{
    printf ("%$T");
    while (1)
    {           
        if (0)//test_reset ())
        {
            printf ("%@C00000000 E: [[[[[[[[[[[[[[ TEST CASE Reset Complete ]]]]]]]]]]]]\f");
        }


         if (0)//test_tcp_server_multi_open () == 0)
         {
            printf ("%@C00000000 E: [[[[[[[[[[[[[[ TEST CASE 4 Complete ]]]]]]]]]]]]\f");
         }

        if (0)//test_ap_list_connect () == 0)
        {
            printf ("%@C00000000 E: [[[[[[[[[[[[[[ TEST CASE AP Connect Complete ]]]]]]]]]]]]\f");
        }

        if (0)//test_tcp_server_open_close_loopback () == 0)
        {
            printf ("%@C00000000 E: [[[[[[[[[[[[[[ TEST CASE TCP open/close Complete ]]]]]]]]]]]]\f");
        }

        if (test_case_tcp_looback () == 0)
        {
            printf ("%@C00000000 E: [[[[[[[[[[[[[[ TEST CASE TCP Loopback Complete ]]]]]]]]]]]]\f");
        }
        goto end;
        if (test_ap_mode () == 0){
            printf ("%@C00000000 E: [[[[[[[[[[[[[[ TEST CASE AP/STA Mode Change Complete ]]]]]]]]]]]]\f");
        }
        if (test_upnp_loopback () == 0)
        {
            printf ("%@C00000000 E: [[[[[[[[[[[[[[ TEST CASE UPNP Complete ]]]]]]]]]]]]\f");
        }

        if (test_ap_con_maintain ())
        {
            printf ("%@C00000000 E: [[[[[[[[[[[[[[ TEST CASE Connection Maintain Complete ]]]]]]]]]]]]\f");
        }        
    }
end:    
    printf ("%@Sat*ict*disassociate\f");
    printf ("%@MAll Test Complete\f");    
    return;

fail:
    printf ("%@Sat*ict*disassociate\f");
    printf ("%@MTest Failed\f");    
}

