/* UDP Test */

#include "libwaitstring.dsc"

#define IP_PORT 1500
#define SSID    "anygate_test"

void main (void)
{
    int socket_no, port;
    int a1,a2,a3,a4;
    char buff[128];

    /* connect AP */
    printf ("%@Sate1\fat*ict*sconn=%s\f", SSID);
    
    if (wait_string ("IPALLOCATED", 10, buff) == 1)
    {
        sscanf (buff, "*ICT*IPALLOCATED:%d.%d.%d.%d", &a1, &a2, &a3, &a4);
        printf ("%@CMy IP=%d.%d.%d.%d\f", a1,a2,a3,a4);
    }
    else
    {
        goto fail;
    }    
    printf ("%@Sat*ict*socket=2\f");
    if (!wait_string ("*ICT*SOCKET:OK", 3, buff)) goto fail;    
    sscanf (buff, "*ICT*SOCKET:OK %d", &socket_no);

    printf ("%@Sat*ict*bind=%d %d\f", socket_no, IP_PORT);
    printf ("%@CWaiting for bind ok string\f");        
        if (!wait_string ("*ICT*BIND:OK", 5, buff)) goto fail;    
    printf ("%@U(192.168.10.100:1501:1500)");
    sleep (100);
    printf ("%@UTest\f");
    printf ("%@Sat*ict*sendto=%d 192.168.10.113 %d 2 ", socket_no, 1501);
    buff[0] = 'A'; buff[1]='B';
    send (buff, 2);
    printf ("\f");
    
    sleep (1000);    
    printf ("%@CSuccess\f");
    goto end;
    
fail:
    printf ("%@CFailed\f");    
end:
    printf ("%@U()");
}

