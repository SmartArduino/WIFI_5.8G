/* conn/disconn test */
#define SSID    "Standalone"

int main (int argc, char **argv)
{
    char buff[128];
    int preTime, curTime, cnt = 0;;

    printf ("%@Smem cget 840b0000,840b0004,840b0008,840b000C,840b0010 32 1\f");

    while (cnt < 1000)
    {
        printf ("%@C00000000 E:Connect Test Loop = %d\f", ++cnt);
        printf ("%@Siwconfig sconn %s\f", SSID);
        printf ("%@Cwaiting dhcp ok...\f");        

        preTime = timesec ();
        
        while (1)
        {            
            gets (buff);
            if (strstr (buff, "DHCP ACK") != 0)
            {
                break;
            }
            curTime = timesec ();
            if (curTime - preTime > 10)
            {
                goto fail;
            }
        }        
        printf ("%@Siwconfig disconn\f");        
    }    

    printf ("%@MTest Complete\f");
    return 0;

fail:
    printf ("%@MTest Failed\f");
    return 0;
}

