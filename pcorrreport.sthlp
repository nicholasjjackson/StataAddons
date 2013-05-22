Partial Correlation Report Program
Stata Verison 11
Code Version 1.5 10/14/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	pcorrreport varlist [if] [in] [, iv(varlist) by(varname) covars(varlist)  pval estround(integer) log]

{title: Purpose:} Produces partial correlation tables, correlating items in varlist with items in iv() adjusted for covars.

{title: Options:}

{phang}
	{opt iv} is the independent variable list. 

{phang}
	{opt covars} is the covariate variable list. Categorical covars with > 2 groups must have dummy variables created first. 	

{phang}
	{opt by} produces within by group correlations

{phang}
	{opt pval} allows reporting of pvalues rather than stars

{phang}
	{opt estround} controls the number of decimals estimates are rounded to
	
{phang}
	{opt log} log transforms the outcome

{title: Example:}
sysuse auto, clear
pcorrreport  mpg headroom trunk, iv(length turn) covars(gear_ratio foreign displacement) 

†=p<0.10, *=p<0.05, **=p<0.01, ***=p<0.001	
