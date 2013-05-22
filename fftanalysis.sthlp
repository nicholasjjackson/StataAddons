Spectral Analysis Program
Stata Verison 12
Code Version 1.0 09/11/2012 Nick Jackson, Graduate Student, University of Southern California

{smcl}
{title: Invocation:}
	{cmd: fftanalysis} {it:varlist} [{it:if}] [{it:in}] [, {it:options}]

{title: Purpose:} Produces power spectral analysis estimates for defined frequency bands using either A) Barlett's Method or B) Welch's Method
		

{title: Options:}

{phang}
	{opt bands()} specifies the frequency bands for which to estimate the power spectrm:
{tab}{tab}Ex: bands(delta 0.5-4 theta 4-8 alpha 8-13)

{phang}
	{opt epoch()} speficies epoch length (blocks) for which to analyize the signal

{phang}
	{opt samplefreq()} speficies the sampling frequency of signal	in HZ (ie. data points per second).
	
{phang}
	{opt overlap()} speficies percentage of overlap for blocks. 0% would be Barlett's method, 0.5-<1 would be Welch's Method.
	
{phang}
	{opt window()} specifies a "{it:hanning}" (default), "{it:hamming}", or "{it:none}" windowing method.
	
{phang}
	{opt pof2} specifies to run the FFT on the signal blocks as a power of 2, thus trailing zeros used to make signal a power of 2 if this specified.
	
{phang}
	{opt epochanal} provides the spectral estimates at the block level
	
{phang}
	{opt nophase} specifies not to unclude Phase information in the FFT magnitude (ie. imaginary)
	
{phang}
	{opt detrend} specifies the signal detrending method as either "{it:mean}" (default) or "{it: linear}" (based on linear regression)
	
{phang}
	{opt density} specifies the calculation of power spectral density instead of power where PSD=power/sample rate
{phang}
	{opt amplitude} specifies the calculation of amplitude instead of power

{phang}
	{opt peak2peak} specifies peak-to-peak amplitude/power calculations instead of peak-amplitude
					
		
{title: Examples:}

{cmd: Example 1:}
