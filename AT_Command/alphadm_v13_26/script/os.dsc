/* OS test */

void task1 (void)
{
    printf ("[%10d]task1\f", timems());
}

void task2 (void)
{
    printf ("[%10d]     task2\f", timems());
}

void task3 (void)
{
    printf ("[%10d]          task3\f", timems());
}

void task4 (void)
{
    printf ("[%10d]               task4\f", timems());
}

void main (void)
{
    int t1, t2, t3, t4, t5;
    t2 = t3 = t4 = t5 = timems ();
    while (1)
    {
        if (timems ()-t2 >= 100) {t2=timems ();  task1 ();}
        if (timems ()-t3 >= 250) {t3=timems ();  task2 ();}
        if (timems ()-t4 >= 500) {t4=timems ();  task3 ();}
        if (timems ()-t5 >= 1000) {t5=timems ();  task4 ();}        
    }
}

