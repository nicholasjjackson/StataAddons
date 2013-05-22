Results Output Program for Regression and Marginal Tables
Stata Verison 12
Code Version 1.0 12/24/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	{cmd: resout}  [, {cmd:Error(}{it:name}{cmd:)} {cmd:exp} {cmd:CLean} {cmd:SEParate} {cmd:TRend} {cmd:ESTround(}{it:numlist max=1 integer}{cmd:)} {cmd:PRound(}{it:numlist max=1 integer}{cmd:)}]

{title: Purpose:} Creates Results table from a regression model or margins estimation with Beta, Error, and P values. This is meant to replace RESULTS.ADO.

{title: Options:}

{phang}
	{opt error} Specifies error structure that is reported. Options are {it:ci} (confidence interval) or {it:se} (stadard error). SE is default.

{phang}
	{opt exp} Exponentiates the results. This is required for reporting logistic or log-transformed models.

{phang}
	{opt clean} Removes all p-value, symbols, and error measures keeping only the point estimate.  

{phang}
	{opt separate} Places the estimate and error in seperate columns.

{phang}
	{opt trend} In absence of the "{it: pvalue}" option, this placea a "‡" symbol for p<0.20 and "****" for p<0.00001.

{phang}
	{opt estround} Rounds estimates to {it:X} decimal places. Integers Only.

{phang}
	{opt pround} Rounds p values to {it:X} decimal places. Integers Only.	
	

{title: Example:}
sysuse auto, clear
	regress price mpg i.foreign
	resout, error(ci) sep trend estround(2)
	