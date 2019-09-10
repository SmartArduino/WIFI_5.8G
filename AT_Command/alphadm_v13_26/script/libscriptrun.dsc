/* [lib] run script: void script_run (char *file) */
#define FALSE       0
#define TRUE        1

typedef enum
{
    SCR_CMD_WAIT,
    SCR_CMD_LOOP,
    SCR_CMD_LOOP_END,    
    SCR_CMD_SHELL,
    SCR_CMD_MAX
}
SCR_CMD_TYPE;

typedef struct
{
    SCR_CMD_TYPE    type;
    unsigned long   param[4];
    char            shell[128];
}
SCRIPT_LIST;

static char *cmdStr[4] = { "WAIT", "LOOP", "ENDLOOP", "SHELL" };

int add_script (SCRIPT_LIST **pScrList, unsigned long maxNo, SCR_CMD_TYPE cmdType, unsigned long *param)
{
    SCRIPT_LIST *pList;
    unsigned long      temp;
        
    if (*pScrList == NULL)
    {
        *pScrList = malloc (sizeof (SCRIPT_LIST));
    }
    else
    {
        *pScrList = realloc (*pScrList, sizeof (SCRIPT_LIST) * (maxNo+1));
    }

    if (*pScrList == NULL)
    {
        printf ("%@MCmemory alloc failed !\f");
        return FALSE;
    }

    pList = *pScrList;
    pList = &pList[maxNo];

    pList->type = cmdType;
    switch (cmdType)
    {
    case SCR_CMD_WAIT:
        pList->param[0] = param[0]; /* delay time */
        break;
        
    case SCR_CMD_LOOP:
        pList->param[0] = param[0]; /* loop id */        
        pList->param[1] = param[1]; /* loop count */
        pList->param[2] = param[1]; /* loop count */        
        break;

    case SCR_CMD_LOOP_END:
        pList->param[0] = param[0]; /* loop id */
        break;
                
    case SCR_CMD_SHELL:
        temp = strlen ((char*)param[0]);
        if(temp >= sizeof (pList->shell))
        {
            temp = sizeof (pList->shell) - 1;
        }
        pList->param[0] = temp;
        strncpy (pList->shell, (char*)param[0], temp);
        pList->shell[temp] = 0;
        
        break;
    }

    return TRUE;
}

char *trimLeft (char *str)
{
    if (str == 0)
    {
        return 0;
    }
    while (*str)
    {
        if (*str != ' ' && *str != '\t' && *str != 0x0A && *str != 0x0D)
        {
            break;
        }
        str++;
    }
    return str;
}

void trimRight (char *str)
{
    char *bigin = str;
    
    if (str == 0 || *str == 0)
    {
        return;
    }
    while (*str++);
    str -= 2;
    while ((int)str >= (int)bigin)
    {
        if (*str != ' ' && *str != '\t' && *str != 0x0A && *str != 0x0D)
        {
            break;
        }
        *str = 0;
        str--;
    }
}

int is_digit_string (char *str)
{
    while (*str)
    {
        if (*str < '0' || *str > '9')
        {
            return FALSE;
        }
        str++;
    }
    return TRUE;
}

void script_run (char *file)
{
    FILE    *fp;    
    char    buff[128], *ptr;   
    unsigned long  i = 0, pc = 0;
    char    *name;
    char    *val;
    unsigned long  param[2];
    unsigned long  lineNo = 0;
    int    bError = FALSE;
    unsigned long  loopCntList[16][2];    
    SCRIPT_LIST *pScrList = NULL;
        
    fp = fopen (file, "rb");
    
    if (fp == 0)
    {
        printf ("%@M%s file open failed\f", file);
        return;
    }

    memset (loopCntList, 0x00, sizeof (loopCntList));    

    while (!bError && !feof (fp))
    {
        if (fgets (buff, sizeof(buff), fp) != 0)
        {
            lineNo++;
            
            ptr = trimLeft (buff);
            trimRight (ptr);
            
            if (ptr[0] == 0) continue;
            else if (ptr[0] == '#') continue;            
            else if (!strncmp (ptr, "wait", 4))
            {
                name = strtok (ptr, " \x0d\x0a");
                val = strtok (NULL, " \x0d\x0a");

                if (val != 0 && is_digit_string (val) != 0)
                {
                    param[0] = atoi (val);
                    bError = !add_script (&pScrList, i, SCR_CMD_WAIT, param);
                    i++;
                    continue;                    
                }
                bError = TRUE;
                
            }
            else if (!strncmp (ptr, "loop", 4))
            {
                name = strtok (ptr, " \x0d\0x0a");
                val = strtok (NULL, " \x0d\0x0a");

                if (val != 0 && is_digit_string (val) != 0)
                {
                    param[0] = atoi (val);
                    if (param[0] < 16)
                    {
                        loopCntList[param[0]][0] = i;
                        
                        val = strtok (NULL, " \x0d\0x0a");
                        if (val != 0 && is_digit_string (val) != 0)
                        {
                            param[1] = atoi (val);                    
                            bError = !add_script (&pScrList, i, SCR_CMD_LOOP, param);
                            i++;
                            continue;
                        }                        
                        else
                        {
                            printf ("%@CThere is no loop count value\f");
                        }
                    }                                        
                    else
                    {
                        printf ("%@CLoop id must be 0~15 !\f");
                    }
                }       
                bError = TRUE;

            }
            else if (!strncmp (ptr, "endloop", 7))
            {
                name = strtok (ptr, " \x0d\0x0a");
                val = strtok (NULL, " \x0d\0x0a");
                
                if (val != 0 && is_digit_string (val) != 0)
                {
                    param[0] = atoi (val);                    
                    if (param[0] < 16)
                    {
                        loopCntList[param[0]][1] = i;                    
                        bError = !add_script (&pScrList, i, SCR_CMD_LOOP_END, param);
                        i++;
                        continue;
                    }
                    printf ("%@CLoop id must be 0~15 !\f");
                }
                bError = TRUE;
            }
            else
            {
                param[0] = (unsigned long)ptr;
                bError = !add_script (&pScrList, i, SCR_CMD_SHELL, param);
                i++;                
            }            
        }
    }
    fclose (fp);

    if (!bError)
    {        
        while (!GetWindowClosed () && pc < i)
        {
            SCRIPT_LIST *pList = &pScrList[pc];
            
            switch (pList->type)
            {
            case SCR_CMD_WAIT:
                sleep (pList->param[0]);
                pc++;
                break;
                
            case SCR_CMD_LOOP:
                if (pList->param[2])
                {
                    pList->param[2]--;  /* decrease loop cnt */
                    pc++;
                    continue;
                }
                
                pList->param[2] = pList->param[1];  /* reset loop cnt */
                pc = loopCntList[pList->param[0]][1]+1;
                break;

            case SCR_CMD_LOOP_END:
                pc = loopCntList[pList->param[0]][0]; /* goto loop */
                break;
                
            case SCR_CMD_SHELL:
                printf ("%@S%s\f", pList->shell);
                pc++;
                break;
            }
        }
    }
    else
    {
        printf ("%@MLine %d format error !", lineNo);
    }        
    
    if (pScrList != 0)
    {
        free (pScrList);
    }
}
