/* LTE-AMI on/off aging test */

#define MAX_TEST_NO     3000
#define LB_STATUS1      0
#define LB_STATUS2      1
#define LB_STATUS3      2

#define PRG_PROGRESS    0

void win_init (void)
{
    char *item[3] = { "item1", "item2", "item3" };
    int size[3] = { 50, 50, 50};
    ResetWindow (0);
    SetActiveWindow (0);
    SetWindowTitle ("LTE AMI Modem On/Off Test");
    SetWindowSize (500, 100);    
    SetLabel (LB_STATUS1, 10, 10, 50, 15, "Status: ");
    SetLabel (LB_STATUS2, 60, 10, 200, 15, "");        
    SetLabel (LB_STATUS3, 10, 30, 200, 15, "");      
    SetProgress (PRG_PROGRESS, 0, 100-40, 500-16, 10, 0, 100);
    
    SetWindowView (1);   
}

void update_status (int d_time, int prog)
{ 
    char buff[128];
    
    sprintf (buff, "wait %d sec", d_time);
    SetLabelText (LB_STATUS2, buff);    
    
    sprintf (buff, "Test Count = %d", prog);
    SetLabelText (LB_STATUS3, buff);    
}

void update_progress (int per)
{
    static int pre_per = 0;
    if (pre_per == per) return;
    pre_per = per;
    per = per * 100 / MAX_TEST_NO;
    SetProgressPos (PRG_PROGRESS, per);
}

int wait_string (char *str)
{
    char buff[128];
        
    buff[0] = 0;
    gets (buff);    
    return strstr (buff, str) != 0;        
}
void main (void)
{
    int prog = 0;
    int st_time, pre_time, cur_time, d_time;
    int st_flag=0;
    
    win_init ();
    
    st_time = pre_time = timems ();
    printf ("%@Scls\f");
    printf ("%@CTest Stated\f");    
    
    while (!GetWindowClosed ())
    {
        if (wait_string ("DEVICEREADY"))
        {
            st_time = pre_time = timems ();
            if (st_flag == 0)            
            {   
                st_flag = 1;     
                prog++;
                update_progress (prog);
                
                if (prog >= MAX_TEST_NO)
                {
                    printf ("%@MTest Complete\f");
                    return;
                }
                printf ("%@C00000000 W:device ready received=%d\f", prog);
             }
        }
        
        cur_time = timems ();
        
        if ((cur_time - pre_time) >= 1000)
        {                        
            d_time = (cur_time - st_time) / 1000;
            if (d_time > 3) st_flag = 0;
            update_status (d_time, prog);
            pre_time = cur_time;
            
            if (d_time >= 60)
            {
                printf ("%@C00000000 E:Timeout(%d sec), Test Stopped, Current Test Count=%d\f", d_time, prog);
                printf ("%@MTimeout(%d sec), Test Stopped, Current Test Count=%d\f", d_time, prog);
                return;
            }
        }    
        else

        sleep (10);
    }
    printf ("%@CTest halted\f");
    printf ("%@MTest halted\f");

}