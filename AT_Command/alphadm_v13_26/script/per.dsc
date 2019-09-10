/* display PER for AB3 */
/*
2190   	06/17-14:23:20 Rx Frame Counter =       290 
2191   	06/17-14:23:20 FCS Err Counter =        23 
2192   	06/17-14:23:20 PER =                    7.34 
2193   	06/17-14:23:20 SN Err Counter =         0 
2194   	06/17-14:23:20 RA Err Counter =         1456 
2195   	06/17-14:23:20 FN Err Counter =         0 
2196   	06/17-14:23:20 CRC Err Counter(AMPDU) = 0 
2197   	06/17-14:23:20 GRP Replay Counter =     0 
2198   	06/17-14:23:20 GRP DEC Err Counter =    0 
2199   	06/17-14:23:20 GRP MIC Err Counter =    0 
2200   	06/17-14:23:20 =====PHY Counter=====
2201   	06/17-14:23:20 11N Sig Err Counter =    0 
2202   	06/17-14:23:20 11N Format Err Counter = 0 
2203   	06/17-14:23:20 11N Sync Fail Counter =  0 
2204   	06/17-14:23:20 11N CCA Err Counter =    5958 
2205   	06/17-14:23:20 11N Serv Field Counter = 0 
2206   	06/17-14:23:20 11N No Err Counter =     215 
2207   	06/17-14:23:20 11B Sig Err Counter =    2 
2208   	06/17-14:23:20 11B Format Err Counter = 0 
2209   	06/17-14:23:20 11B Sync Fail Counter =  221 
2210   	06/17-14:23:20 11B CCA Err Counter =    0 
2211   	06/17-14:23:20 11B FCS Err Counter =    20 
2212   	06/17-14:23:20 11B No Err Counter =     1536 
2213   	06/17-14:23:20 =====Rx Frame Counter=====
2214   	06/17-14:23:20 11b_1Mbps =   1605 
2215   	06/17-14:23:20 11b_2Mbps =   0 
2216   	06/17-14:23:20 11b_5.5Mbps = 0 
2217   	06/17-14:23:20 11b_11Mbps =  122 
2218   	06/17-14:23:20 
2219   	06/17-14:23:20 11g_6Mbps = 356 
2220   	06/17-14:23:20 11g_9Mbps =   0 
2221   	06/17-14:23:20 11g_12Mbps =  1 
2222   	06/17-14:23:20 11g_18Mbps =  0 
2223   	06/17-14:23:20 11g_24Mbps =  3 
2224   	06/17-14:23:20 11g_36Mbps =  0 
2225   	06/17-14:23:20 11g_48Mbps =  0 
2226   	06/17-14:23:20 11g_54Mbps =  0 
2227   	06/17-14:23:20 
2228   	06/17-14:23:20 11n_MCS0 =  0 
2229   	06/17-14:23:20 11n_MCS1 =    0 
2230   	06/17-14:23:20 11n_MCS2 =    0 
2231   	06/17-14:23:20 11n_MCS3 =    0 
2232   	06/17-14:23:20 11n_MCS4 =    0 
2233   	06/17-14:23:20 11n_MCS5 =    0 
2234   	06/17-14:23:20 11n_MCS6 =    0 
2235   	06/17-14:23:20 11n_MCS7 =    0 
2236   	06/17-14:23:20 OK
*/

float getPER (void)
{
    char    buff[128];
    float   val;
    
    printf ("%@Srx cntr\f");    
    gets (buff); /* skip rx cntr */
    gets (buff); /* Rx Frame Counter =       290 */
    gets (buff); /* FCS Err Counter =        23  */
    gets (buff); /* PER =                    7.34 */
    val = atof (&buff[5]);
    printf ("%@Srx cntr clr\f");    
    return val;
}

void main (void)
{
    float val;
    
    printf ("%@Sdebug 0\f");

    while (1)
    {
        val = getPER ();
        printf ("%@C00000000 E:PER=%.2f\f%@G(_PER_)%d\f", val, (long)val);
        sleep (500);
    }

    printf ("%@Sdebug 4\f");    
}

