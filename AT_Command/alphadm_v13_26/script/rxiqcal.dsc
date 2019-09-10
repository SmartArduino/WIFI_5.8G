/* RXIQ Calibration for AB5 */

#include "libscriptrun.dsc"

/* slider / text / edit window index */
#define GAIN        0
#define PHASE       1
#define DC_I        2
#define DC_Q        3
#define ADD1        4
#define ADD2        5
#define MUL1        6
#define MUL2        7
#define MUL3        8
#define TXT_SCALE   9

#define EDIT_GAIN   9
#define EDIT_PHASE  10
#define EDIT_DC_I   11
#define EDIT_DC_Q   12

#define CHK_UPDATE  0

/* bttton window index */
#define BTN_READ    0
#define BTN_SAVE    1
#define BTN_RWRITE  2
#define BTN_LOAD    3
#define BTN_SCRIPT  4

#define STEP        20

#define REG_ADD1    0x90005318
#define REG_ADD2    0x9000531A
#define REG_MUL1    0x90005312
#define REG_MUL2    0x90005314
#define REG_MUL3    0x90005316
 
/* inititial cal value */
int realtime = 0;
int reg_val[5] = { 0, 0, 0, 0, 0};
float cal_val[4] = {0, 0, 0, 0};
float step[4] = { 0.1, 0.01, 1, 1 };
float range[4] = { 20, 10, 1000, 1000 };
float scr_range[4];

void init_windows (void)
{
    int y, i;
    char buff[16];
    
    for (i = 0; i < 4; i++)
    {
        scr_range[i] = range[i] / step[i];
    }
    
    ResetWindow (0);
    SetActiveWindow (0);
    
    SetWindowPos (100, 100, 460, 260);
    SetWindowTitle ("RxIQ Calibration Test");
    
    SetLabel (TXT_SCALE, 390, 7, 400, STEP-2, "Step");
    
    y = 25;
    SetLabel (GAIN, 10, y, 120, STEP, "Rx Gain Mismatch");   y+= STEP;
    SetLabel (PHASE,10, y, 120, STEP, "Rx Phase Mismatch");  y+= STEP;
    SetLabel (DC_I, 10, y, 120, STEP, "I-Ch DC Offset");     y+= STEP;
    SetLabel (DC_Q, 10, y, 120, STEP, "Q-Ch DC Offset");     y+= STEP;
    
    y = 25;
    for (i = 0; i < 4; i++)
    {
        SetScrollBar (i, 130, y, 200, STEP-2, -scr_range[i], scr_range[i]);    
        y += STEP; 
        SetScrollBarPos (i, scr_range[i]);     
        SetScrollBarPos (i, cal_val[i] / step[i]);
    }
    
    y = 25;
    for (i = 0; i < 4; i++)
    {
        sprintf (buff, "%.3f", step[i]);  
        SetEdit (i, 330, y, 50, STEP, "0"); 
        SetEdit (EDIT_GAIN+i, 385, y, 50, STEP, buff); 
        y+= STEP;
    }
    
    y = 115;
    SetLabel (ADD1, 10, y, 50, STEP, "RxAdd1");    y+= STEP;
    SetLabel (ADD2, 10, y, 50, STEP, "RxAdd2");    y+= STEP;
    SetLabel (MUL1, 10, y, 50, STEP, "RxMult1");   y+= STEP;
    SetLabel (MUL2, 10, y, 50, STEP, "RxMult2");   y+= STEP;
    SetLabel (MUL3, 10, y, 50, STEP, "RxMult3");   y+= STEP;        

    y = 115;
    for (i = 0; i < 5; i++)
    {
        SetEdit (ADD1+i, 60, y, 50, STEP, "0");   y+= STEP;
    }
    
    y = 115;
    SetButton (BTN_SCRIPT,330, y, 100, 30, "Script");   y += 32;       
    SetButton (BTN_READ,  330, y, 100, 30, "Read");     
    SetButton (BTN_RWRITE,220, y, 100, 30, "Write");    y += 32;       
    SetButton (BTN_SAVE,  330, y, 100, 30, "Save");   
    SetButton (BTN_LOAD,  220, y, 100, 30, "Load");     
        
    y = 115;
    SetCheckBox (CHK_UPDATE, 120, y, 150, STEP, "Realtime Update", 0);
    SetWindowView (1);
}

void update_slider (void)
{
    int     i;
    float   val;
    char    buff[128];
    int     changed = 0;
    
    for (i = 0; i < 4; i++)
    {
        val = (float)GetScrollBarPos (i) * step[i];
        if (fabs (val-cal_val[i]) > 0.0001)
        {           
            cal_val[i] = val;
            sprintf (buff, "%.3f", val);
            SetEditText (i, buff);
            changed = 1;            
        }
    }
    
    if (changed)
    {
        calculate (0);
    }
}

void update_cal (void)
{
    int     i;
    float   val;
    char    buff[128];
    
    for (i = 0; i < 4; i++)
    {
        GetEdit (i, buff, sizeof (buff));
        val = atof (buff);
        if (fabs (val-cal_val[i]) > 0.0001)
        {            
            cal_val[i] = val;
            SetScrollBarPos (i, val/step[i]);
        }
    }
}

void check_step (void)
{
    char    buff[16];
    int     i, y;
    float   val;
    int     changed = 0;
    
    for (i = 0; i < 4; i++)
    {
        GetEdit (i+EDIT_GAIN, buff, sizeof (buff));
        val = atof (buff);
        if (val != step[i])
        {
            step[i] = val;
            changed = 1;
        }
    }

    if (changed)
    {
        y = 25;
        for (i = 0; i < 4; i++)
        {
            scr_range[i] = range[i] / step[i];            
            SetScrollBar (i, 130, y, 200, STEP-2, -scr_range[i], scr_range[i]);    
            SetScrollBarPos (i, cal_val[i] / step[i]);
            y += STEP; 
        }
    }
}

int check_reg (void)
{
    int i;
    unsigned short val;
    char buff[128];
    int changed = 0;
    char *end;
    
    for (i = ADD1; i <= MUL3; i++)
    {
        GetEdit (i, buff, sizeof (buff));        
        val = strtoul (buff, &end, 16);   
        if (val != reg_val[i-ADD1])
        {
            reg_val[i-ADD1] = val;
            changed = 1;
        }
    }
    return changed;
}

void write_register (unsigned short add1, unsigned short add2, unsigned short mul1, unsigned short mul2, unsigned short mul3)
{
    printf ("%@S");
    printf ("mem set %X %X 16\f", REG_ADD1, add1);
    printf ("mem set %X %X 16\f", REG_ADD2, add2);
    printf ("mem set %X %X 16\f", REG_MUL1, mul1);
    printf ("mem set %X %X 16\f", REG_MUL2, mul2);
    printf ("mem set %X %X 16\f", REG_MUL3, mul3); 
}

void calculate (int force)
{
    unsigned short add1, add2, mul1, mul2, mul3;
    float   phase;
    char    buff[16];   
    int     i;

    phase = cal_val[PHASE] / 180.0 * 3.1415927;
    add1 = (unsigned short)cal_val[DC_I];
    add2 = (unsigned short)cal_val[DC_Q];
    mul1 = (unsigned short)round((1.0 + cal_val[GAIN]) * cos(phase) * 16384.0);
    mul2 = (unsigned short)round((1.0 + cal_val[GAIN]) * sin(phase) * 16384.0 * (-1));
    mul3 = (unsigned short)round((1.0 - cal_val[GAIN])              * 16384.0);

    sprintf (buff, "%03X", add1);   SetEditText (ADD1, buff);
    sprintf (buff, "%03X", add2);   SetEditText (ADD2, buff);
    sprintf (buff, "%04X", mul1);   SetEditText (MUL1, buff);
    sprintf (buff, "%04X", mul2);   SetEditText (MUL2, buff);
    sprintf (buff, "%04X", mul3);   SetEditText (MUL3, buff);

    for (i = 0; i < 4; i++)
    {
        sprintf (buff, "%.3f", cal_val[i]);
        SetEditText (i, buff);
    }

    check_reg ();

    if (force || GetCheckBox (CHK_UPDATE))
    {
        write_register (add1, add2, mul1, mul2, mul3);
    }
}

unsigned long read_reg (int addr)
{
    char temp[128], *end;
    
	printf ("%@Smem dump %x 2 16\f", addr, 4);
    gets (temp); /* skip shell command  */
	gets (temp); /* skip blank line */
    gets(temp);	
    return strtoul (&temp[10], &end, 16);
}

void read_register (int read_modem)
{
    unsigned short add1, add2, mul1, mul2, mul3;
    float gain, phase, idc, qdc, fmul1, fmul2, fmul3;
    char buff[128], *end;
    int i_add1, i_add2, i_mul1, i_mul2, i_mul3;

    printf ("%@Smem dump %x %d 16\f", REG_MUL1, 5*2);
    gets(buff); /* skip shell command  */
    gets(buff); /* skip blank line */    
    gets(buff);	
    
    mul1 = strtoul (&buff[10], &end, 16);
    mul2 = strtoul (end, &end, 16);
    mul3 = strtoul (end, &end, 16);
    add1 = strtoul (end, &end, 16);
    add2 = strtoul (end, &end, 16);
    
    sprintf (buff, "%03X", add1);   SetEditText (ADD1, buff);
    sprintf (buff, "%03X", add2);   SetEditText (ADD2, buff);
    sprintf (buff, "%04X", mul1);   SetEditText (MUL1, buff);
    sprintf (buff, "%04X", mul2);   SetEditText (MUL2, buff);
    sprintf (buff, "%04X", mul3);   SetEditText (MUL3, buff);

    if ((int)add1 > 2047) {
        i_add1 = (int)add1 - 4096;
    }
    else {
        i_add1 = (int)add1;
    }

    if ((int)add2 > 2047) {
        i_add2 = (int)add2 - 4096;
    }
    else {
        i_add2 = (int)add2;
    }

    if ((int)mul1 > 32767) {
        i_mul1 = (int)mul1 - 65536;
    }
    else {
        i_mul1 = (int)mul1;
    }

    if ((int)mul2 > 32767) {
        i_mul2 = (int)mul2 - 65536;
    }
    else {
        i_mul2 = (int)mul2;
    }

    if ((int)mul3 > 32767) {
        i_mul3 = (int)mul3 - 65536;
    }
    else {
        i_mul3 = (int)mul3;
    }

    fmul1 = (float)i_mul1 / 16384.0;
    fmul2 = (float)i_mul2 / 16384.0;
    fmul3 = (float)i_mul3 / 16384.0;

    gain = 1.0 - fmul3;
    phase = asin(fmul2/(1+gain)/(-1)) * 180.0 / 3.1415927;
    idc = i_add1;
    qdc = i_add2;

    SetScrollBarPos (GAIN, gain / step[GAIN]);
    SetScrollBarPos (PHASE,phase / step[PHASE]);
    SetScrollBarPos (DC_I, idc / step[DC_I]);
    SetScrollBarPos (DC_Q, qdc / step[DC_Q]);    
}

void check_button (void)
{
    if (GetButton (BTN_READ))
    {
        read_register (1);
    }  
    if (GetButton (BTN_SAVE))
    {
        char file[256];
        
        strcpy (file, "reg.txt");
        SelectFile (0, file, "txt", sizeof (file));
        if (file[0])
        {
            FILE *fp = fopen (file, "w");
            if (fp != 0)
            {
                fprintf (fp, "%.3f,%.3f,%.3f,%.3f", cal_val[0], cal_val[1], cal_val[2], cal_val[3]);                
                fclose (fp);
            }
            else
            {
                printf ("%@M%s file open error!!");                
            }            
        }        
    }
    if (GetButton (BTN_LOAD))
    {    
        char    file[256];        
        
        strcpy (file, "reg.txt");
        SelectFile (1, file, "txt", sizeof (file));
        
        if (file[0])
        {            
            FILE    *fp = fopen (file, "r");
            int     i;
            float   val[4];
            
            if (fp != 0)
            {
                fscanf (fp, "%lf,%lf,%lf,%lf", &val[0], &val[1], &val[2], &val[3]);                                
                fclose (fp);
                printf ("%@CGain=%.3f, Phase=%.3f, I-DC=%.3f, Q-DC=%.3f\n", val[0], val[1], val[2], val[3]);
                for (i = 0; i < 4; i++)
                {
                    sprintf (file, "%.3f", val[i]);
                    SetEditText (i, file);
                }
                update_cal ();  
                calculate (0);        
            }
            else
            {
                printf ("%@M%s file open error!!");                
            }            
        }  
    }
    if (GetButton (BTN_RWRITE))
    {
        check_reg ();
        write_register (reg_val[0], reg_val[1], reg_val[2], reg_val[3], reg_val[4]);
        sleep(500);
        read_register (1);
    }
    if (GetButton (BTN_SCRIPT))
    {
        char    file[256];        
        
        strcpy (file, "*.ads");
        SelectFile (1, file, "ads", sizeof (file));
        if (file[0])
        {
            script_run (file);
        }
    }
}

void main (void)
{
    int i;
    
    //printf ("%@Sdebug fd off\f");
    init_windows ();        
    
    while (!GetWindowClosed ())
    {
        if (GetKey () == 13)
        {                    
            check_step ();
            update_cal ();
            calculate (0);
        }
        
        update_slider ();        
        check_button ();
        sleep (100);
    }
    
    printf ("%@Cscript end\f");
}
