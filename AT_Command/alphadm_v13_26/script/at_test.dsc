/* AT Command TCP loopback test*/

#include "libwaitstring.dsc"
#define IP_PORT 1500

int main (int argc, char **argv)
{
    char buff[128], snd[128];
    int a1,a2,a3,a4, b1,b2,b3,b4, sz;
    int socket_no, sndsock_no;

    /* connect AP */
    printf ("%@Sate1\fat*ict*sconn=Standalone\f");
    
    if (wait_string ("IPALLOCATED", 10, buff) == 1)
    {
        sscanf (buff, "*ICT*IPALLOCATED:%d.%d.%d.%d", &a1, &a2, &a3, &a4);
        printf ("%@CMy IP=%d.%d.%d.%d\f", a1,a2,a3,a4);
    }
    else
    {
        goto fail;
    }

    /* create TCP server */
    printf ("%@Sat*ict*socket=1\f");
    if (!wait_string ("*ICT*SOCKET:OK", 3, buff)) goto fail;
    
    sscanf (buff, "*ICT*SOCKET:OK %d", &socket_no);
    printf ("at*ict*bind=%d %d\f", socket_no, IP_PORT);
    
    printf ("at*ict*listen=%d\f", socket_no);
    if (!wait_string ("*ICT*LISTEN:OK", 5, buff)) goto fail;
    
    /* connect Module from PC */
    printf ("%@CTry to connect = %d.%d.%d.%d:%d\f",a1,a2,a3,a4, IP_PORT);
    sprintf (buff, "%%@T(%d.%d.%d.%d:%d)\f", a1,a2,a3,a4, IP_PORT);
    printf (buff);
    if (!wait_string ("*ICT*ACCEPTED", 5, buff)) goto fail;
    sscanf (buff, "*ICT*ACCEPTED:%d %d.%d.%d.%d %d", &socket_no, &b1,&b2,&b3,&b4, &sndsock_no);

    a1 = 0;
    while (a1 < 10000)
    {
        sz = sprintf (snd, "This is an example string..%d", a1++);
        printf ("%@T%s\f", snd);
        if (!wait_string (snd, 2, buff)) goto fail;
        printf ("%@Sat*ict*send=%d %d.%d.%d.%d %d %d %s\f", socket_no, b1,b2,b3,b4, sndsock_no, sz, snd);
        if (!wait_string (snd, 2, buff)) goto fail;
    }
    printf ("%@Sat*ict*disassociate\f");
    printf ("%@MComplete\f");
    return 0;

fail:
    printf ("%@Sat*ict*disassociate\f");
    printf ("%@MFailed\f");
    return 0;
}

