Paited Test (ttest and wilcoxon)
Stata Verison 11
Code Version 1.0 10/24/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	pairtest varlist [if] [in] [, by(varname) id(varname)  estround(numlist max=1 integer) log num]

{title: Purpose:} Conducts paired ttests on Longitudinal data. Automatically Reshapes data for appropriate statistical tests.

{title: Options:}

{phang}
	{opt by} specifies the longitudinal time variable (ie. post, time etc.). This must contain only 2 Groups. 

{phang}
	{opt id} specifies the subject unique identifier. 
	
{phang}
	{opt log} specifies conducting the analysis on log transformed data.
	
{phang}
	{opt num}	reports the number of observations (subjects) used.
	

{title: Example:}
use obey, clear
pairtest mr2 mr29 mr54, by(post) id(ptid) num
