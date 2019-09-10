/* fft and draw plot */

#define PI	        3.1415927
#define TWOPI	    (2.0*PI)
#define FFT_SIZE    1024

/*
 FFT/IFFT routine. (see pages 507-508 of Numerical Recipes in C)

 Inputs:
	data[] : array of complex* data points of size 2*NFFT+1.
		data[0] is unused,
		* the n'th complex number x(n), for 0 <= n <= length(x)-1, is stored as:
			data[2*n+1] = real(x(n))
			data[2*n+2] = imag(x(n))
		if length(Nx) < NFFT, the remainder of the array must be padded with zeros

	nn : FFT order NFFT. This MUST be a power of 2 and >= length(x).
	isign:  if set to 1, 
				computes the forward FFT
			if set to -1, 
				computes Inverse FFT - in this case the output values have
				to be manually normalized by multiplying with 1/NFFT.
 Outputs:
	data[] : The FFT or IFFT results are stored in data, overwriting the input.
*/

void four1 (float *data, int nn, int isign)
{
    int n, mmax, m, j, istep, i;
    float wtemp, wr, wpr, wpi, wi, theta;
    float tempr, tempi;
    
    n = nn << 1;
    j = 1;
    for (i = 1; i < n; i += 2) 
    {
    	if (j > i) 
        {
    	    tempr = data[j];     data[j] = data[i];     data[i] = tempr;
    	    tempr = data[j+1]; data[j+1] = data[i+1]; data[i+1] = tempr;
    	}
    	m = n >> 1;
    	while (m >= 2 && j > m) 
        {
    	    j -= m;
    	    m >>= 1;
    	}
    	j += m;
    }
    
    mmax = 2;
    while (n > mmax) 
    {
    	istep   = 2 * mmax;
    	theta   = TWOPI / (isign * mmax);
    	wtemp   = sin (0.5*theta);
    	wpr     = -2.0 * wtemp * wtemp;
    	wpi     = sin (theta);
    	wr      = 1.0;
    	wi      = 0.0;
        
    	for (m = 1; m < mmax; m += 2) 
        {
    	    for (i = m; i <= n; i += istep) 
            {
        		j           = i + mmax;
        		tempr       = wr * data[j] - wi * data[j+1];
        		tempi       = wr * data[j+1] + wi * data[j];
        		data[j]     = data[i]   - tempr;
        		data[j+1]   = data[i+1] - tempi;
        		data[i]    += tempr;
        		data[i+1]  += tempi;
    	    }
    	    wr = (wtemp = wr) * wpr - wi * wpi + wr;
    	    wi = wi * wpr + wtemp * wpi + wi;
    	}
    	mmax = istep;
    }
}

void fft (float *re, float *im, int size, int bInv)
{
    float  *data, *ptr;
    int  i;
    int     sign = bInv ? -1:1;
    
    data = (float*)malloc ((size*2+1)*sizeof(float));
    if (data == NULL) return;

    ptr = &data[1];
    for (i = 0; i < size; i++)
    {
        *ptr++ = re[i]; 
        *ptr++ = im[i]; 
    }
    
    four1 (data, size, sign);
    
    ptr = &data[1];
    for (i = 0; i < size; i++)
    {
        re[i] = *ptr++;
        im[i] = *ptr++;
    }

    free (data);    
}

void main (void)
{
    float re[FFT_SIZE];
    float im[FFT_SIZE];
    float amp[FFT_SIZE];
    int i;

    printf ("%@CFFT test....\f");
    printf ("%@G(SINE)");
    
    for (i = 0; i < FFT_SIZE; i++)
    {
        re[i] = sin(PI/5.0*(float)i)*500;
        im[i] = cos(PI/20.0*(float)i)*1000;
        printf ("%f\f", re[i]);
    }

    fft (re,im, FFT_SIZE, 0);

    for (i = 0; i < FFT_SIZE/2; i++)    
    {
        amp[i] = sqrt (re[i]*re[i]+im[i]*im[i]);
    }

    printf ("%@G(FFT)");
    for (i = 0; i < FFT_SIZE/2; i++)
    {
        printf ("%f,%f,%f\f", amp[i], re[i], im[i]);
    }
    plot ("FFT", "IQ", re, im, FFT_SIZE/2);
}

