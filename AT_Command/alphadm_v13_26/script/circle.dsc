/* draw circle plot */
void main (void)
{
    float x[129], y[129];
    float a;
    int i = 0;
    
    plotclear("DEMO");
    for (a = 0; a <= 6.28; a += (6.28/128.0))
    {
        x[i] = sin (a)*0.5;
        y[i] = cos (a);
        i++;
    }
    plot ("DEMO", "circle", x, y, 129);
}