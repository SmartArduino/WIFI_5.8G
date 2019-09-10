/* Test Terminal and DM Port output */

#include "libwaitstring.dsc"

void main (void)
{
    char buff[128];
    printf ("%$T"); /* change to terminal io */
    
    while (1)
    {
        printf ("%@Sat\f");
        if (wait_string ("OK", 1, buff) == 0)
        {
            printf ("%$D"); /* change to MDP io */
            printf ("%@C00000000 E:system down\f");
            return;
        }
        sleep (1000);
    }
}