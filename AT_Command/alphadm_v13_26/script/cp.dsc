/* fft and draw graph */
#define PI	        3.1415927
#define TWOPI	    (2.0*PI)
#define SIZE        128

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
    float nr[SIZE], r[SIZE], i[SIZE], a;
    int   c;
    
    for (c = 0; c < SIZE; c++)
    {
        r[c] = 0;
        i[c] = 0;               
    }  
    
    r[1] = 1000;
    r[SIZE/2] = 1000;
    r[SIZE-2] = 1000;

    for (c = 0; c < SIZE; c++)
    {
        printf ("%@G(ORG)%f\f", r[c]);
    } 

    fft (r,i,SIZE, 1);
    
    for (c = 0; c < SIZE; c++)
    {
        printf ("%@G(IFFT)%f\f", r[c]);
    } 

    fft (r,i,SIZE, 0);

    for (c = 0; c < SIZE; c++)
    {
        printf ("%@G(FFT)%f\f", r[c]);
    } 
    
}

