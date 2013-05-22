{smcl}
String Stripping Program
Stata Verison 12
Code Version 1.0 05/20/2013 Nick Jackson, Applied Statistician

{title:Invocation:}
	{cmd: siggen } ,  {cmd:samplefreq}({it:integer}) {cmd:time}({it:integer}) {cmd:amp}({it:numberlist}) {cmd:freq}({it:numberlist}) {cmd:error} {cmd:mixed}]

{title:Purpose:} Generates Sinusoidal Signals of Know Amplitudes and Frequencies

{title:Options:}
{phang}
	{opt samplefreq(#):} Sampling Frequecy desired in Hertz 
		{it:ex samplefreq(512):}  512HZ sampling frequency
 	
{phang}
	{opt time(#):} Time (length) of signal in seconds.
	{it:ex time(180):} 180 second/3 minute signal.
	
{phang}
	{opt amp(#1 #2 #3..):} Specifies Amplitudes for the Signal(s)
	{it:ex amp(5 20 40):} 
 	
{phang}
	{opt freq(#1 #2 #3..):} Specifies Frequencies for the Signal(s)
	{it:ex freq(0.5 4 10):}
	
{phang}
	{opt error:} Specifies values to be created with random ERROR imposed
	
{phang}
	{opt mixed:} Creates a single signal of mixed frequency/amplitude based upon the amp and freq values specified 
	
	
	

{title: Examples:}
	[1] siggen, samplefreq(512) time(180) amp(10 20 30) freq(1 2 3) 
		*Generates 9 signals at 512 HZ for 180 seconds of Amplitude 10 @ 1,2,and 3 HZ Amplitude 20 @ 1,2,and 3 HZ frequencies and Amplitude 30 @ 1,2,and 3 HZ frequencies
	[2] siggen, samplefreq(512) time(180) amp(10 20 30) freq(1 2 3) mixed
		*Generates 1 signal at 512 HZ for 180 seconds, composed of the 9 signals from example [1]. 
	[3] siggen, samplefreq(512) time(180) amp(10) freq(1 2 3) mixed error
		*Generates 1 signal at 512 HZ for 180 seconds composed of mixed frequencies (1 2 and 3), all at the same amplitde with random error imposed on the signal. 
		

