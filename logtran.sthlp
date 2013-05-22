Log Transform Program
Stata Verison 11
Code Version 1.0 10/24/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	logtran varlist [if] [in] [, REPlace]

{title: Purpose:} Log Transforms Variables. Automatically Detects if Log(var+1) is required.

{title: Options:}

{phang}
	{opt REPlace} replace the variable as log transformed values. Default is to create variables named log"varname"


{title: Example:}
sysuse auto, clear
logtran mpg headroom trunk if foreign==0, rep
