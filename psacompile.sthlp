{smcl}
{bf:UPENN Power Specrtal Analysis Compilation Program}
Stata Verison 12
Code Version 3.4 04/22/2013 Nick Jackson, Applied Statistician


{title: Invocation:}
	{cmd: psacompile}  [, {cmd:directory}({it:string}) {it:options}]

{title: Purpose:} Compiles Power Spectral Analysis (PSA) files for further analysis. See UPENN PSA Compilation Instructions.doc for further info. 
	
	
{title: Options:}

{phang}
	{opt directory()} speficies directory to start in for PSA. If not specified, by default will look within the current directory. 

{phang}
	{opt rem()} specifies REM window length (minutes) for defining REM cycles. Default value is 5 to indicate 5 consolidated minutes of REM to define REM cycle onset.
	
{phang}
	{opt nrem()} specifies NREM window length (minutes) for defining NREM cycles. Default value is 15 to indicate 15 consolidated minutes of NREM to define NREM cycle onset.
	
{phang}
	{opt win()} specifies window length (minutes) for conducting artifact rejection. Default value is 3 minutes
	
{phang}
	{opt time()} specifies length of time from Sleep Onset to be analyzed/aggregated (hours).  Default value is 6 hours.

{phang}
	{opt epoch()} specifies unit of analysis for the spectral bins (seconds). Default value is 4 seconds.

{phang}
	{opt breject()} specifies the spectral band to be used in the Brunner artifact rejection method. Default is {bf:beta2}. If {bf:beta2} does not exist then the lowest frequency band is used.  
	{tab} A band range OR group of bands can also be specified. 
	{tab} ex: breject(alpha) OR breject(alpha beta sigma) OR breject(alpha-sigma)

{phang}
	{opt altreject()} specifies the spectral band to be used in the alternate artifact rejection method. Default is the second highest frequency band. 
	{tab} A band range OR group of bands can also be specified. 
	{tab} ex: altreject(beta1) OR breject(beta1 beta2 gamma1) OR breject(beta1-gamma1)
	
{phang}
	{opt soextract} specifies data extraction from sleep onset . Default is extraction from lights out.
	
{phang}
	{opt arexact} specifies exact arousal event tagging (ie. matched on time and duration). Default is tagging the entire sleep 30 second epoch.

{phang}
	{opt avgslpepoch} specifies averaging values within a 30 Second Sleep Epoch and then averaging across the sleep epoch.	
	
{phang}
	{opt remlogic} Used for processing REMLOGIC files (must have events files associated. Specifies different initial processing.
	
{phang}
	{opt correct} specifies signal correction options to the power values. Default is a no correction. Alternate options are:
{tab}{tab} {bf:2x}{tab} power_new=(power_old*2)
{tab}{tab} {bf:x^2}{tab} power_new=(power_old)^2
{tab}{tab} {bf:2x^2}{tab} power_new=(power_old*2)^2
{tab}{tab} {bf:x^.5}{tab} power_new=sqrt(power_old)=(power_old)^.5
	
{phang}
	{opt relaltcalc} specifies the calculation of Relative Power as the Ratio of the Mean of the Absolute Powers over the Total Power. Default is the mean of the within-epoch relative power calculation.	
	
{phang}
	{opt relaltcalc} specifies the calculation of Relative Power as the Ratio of the Mean of the Absolute Powers over the Total Power. Default is the mean of the within-epoch relative power calculation.		
	
{phang}
	{opt sleeponset()} specifies the definition of Sleep Onset to be used. Three options are available

{tab}{tab} {bf:n1}{tab} First instance of stage 1
{tab}{tab} {bf:n2}{tab} First instance of stage 2 ({it:Default})
{tab}{tab} {bf:8of10}{tab} First 8 of 10 epochs containing sleep.
	
{title: Examples:}

{cmd:Example 1:}
psacompile, dir(c:\documents and settings\John Doe\My Documents\Stress Study) sleeponset(8of10)
{cmd:Example 2:}
psacompile, dir(c:\documents and settings\John Doe\My Documents\Stress Study) sleeponset(n1) nrem(12) rem(4) win(1.5) time(5) lightsout altreject(gamma1) epoch(5)
