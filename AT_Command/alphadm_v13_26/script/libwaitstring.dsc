/* [lib] wait string: int wait_string (char *str, int timeout, char *buff) */

int wait_string (char *str, int timeout, char *buff)
{
    int pretime = timems ();
    int cnt = 1;

    timeout *= 1000;
    
    while (1)
    {
        cnt++;
        buff[0] = 0;
        gets (buff);        
        if (strstr (buff, str) != 0) return 1;   
        if (timeout != 0)
        {
            if (timems () - pretime >= timeout) return 0;
        }
    }
}
