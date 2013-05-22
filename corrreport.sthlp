Correlation Report Program
Stata Verison 11
Code Version 2.9 10/14/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	corrreport varlist [if] [, iv(varlist) by(varname)  bootstrap(number) pval bootcorr(name) estround(integer) log]

{title: Purpose:} Produces spearman and pearson correlation tables correlating items in varlist with items in iv()

{title: Options:}

{phang}
	{opt iv} is the independent variable list which will be correlated with varlist.

{phang}
	{opt by} produces within by group correlations

{phang}
	{opt estround} allows for changing the number of decimal places the estimates are rounded to.  	
	
{phang}
	{opt pval} allows reporting of pvalues rather than stars

{phang}
	{opt log} log transforms the outcome		
	
{title: Bootstrap Options:}
{opt bootstrap} specifies bootstraping with (XXX) number of replications. Percentile Confidence Intervals for Rhos presented.
	
	Without the {opt by} option specified, the p value for comparison of the correlations of IV with each outcome is made.
	
	With the {opt by} option specified, the p values for between by group comparisons of the correlations is presented.
	
{opt bootcorr} specifies the type of bootstrap correaltion to conduct. Options are spearman or pearson. Pearson is default.

	
{title: Example:}
sysuse auto, clear	
corrreport  price mpg  gear_ratio, by(foreign) iv( weight length turn) bootstrap(1000) bootcorr(spearman)

†=p<0.10, *=p<0.05, **=p<0.01, ***=p<0.001	


