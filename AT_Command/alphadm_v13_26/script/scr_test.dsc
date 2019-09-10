/* AT Command TCP server open/close repetition test */

#include "libwaitstring.dsc"

#define IP_PORT     1500
#define SSID        "kangap"
#define PASSWD      "12345678"
#define TEST_LOOP   10000

int main (void)
{
    char buff[128], snd[128];
    int a1,a2,a3,a4, b1,b2,b3,b4, sz;
    int socket_no, sndsock_no;

    printf ("%$T");
        
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
    sscanf (&buff[9], "*ICT*SOCKET:OK %d", &socket_no);

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
    sscanf (&buff[9], "*ICT*ACCEPTED:%d %d.%d.%d.%d %d", &socket_no, &b1,&b2,&b3,&b4, &sndsock_no);

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

