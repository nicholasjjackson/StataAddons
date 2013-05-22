{smcl}
Logistic Regression Report Program
Stata Verison 12
Code Version 1.1 04/05/2012 Nick Jackson, Biostatistician, University of Pennsylvania



{title:Invocation:}
	logitreport varlist [if] [pweight] [,  iv(varlist) covars(string)  error(name) star or cat(integer) estround(integer)  iterate(integer) vce(string)]

{title:Purpose:} Provides P values and effect size of ivS vs varlist adjusting for covars. 
	For independent variables, the program will automatically determine 
	whether to model the variable as continuous or categorical. 


{title:Options}
{phang}
	{opt iv} this is the independent variable list. This must be specified. The program automatically determines if the variable is modeled continuously or catecorally based upon having <=9 unique groups (this can be changed with the "cat()" option). For categorical IV's, the lowest value of the IV is taken as the reference group.

{phang}
	{opt covars} this is the covariate variable list. 
	
{phang}
	{opt weight} allows only for the use of sample weights [pweight]

{phang}
	{opt error} allows for the reporting of 95% CI's instead of default SE when specified as error(ci)

{phang}
	{opt star} allows for the p value indicator Stars to be reported with the estimate.

{phang}
	{opt cat} allows for changing the threshold for determining if an IV should be modeled categorically or continuously. Default for categorical is <= 9 unique groups. 

{phang}
	{opt estround} allows for changing the number of decimal places the estimates are rounded to.  	
	
{phang}
	{opt or} reports odds ratios (exponentiated coefficients)
	
{phang}
	{opt iterate} changes the maximmum number of iterations before finishing the model (useful to force convergence)	

{phang}
	{opt vce} changes the variance covariance matrix options

{tab}{bf:Likelihood based}
{tab}oim{tab}{tab}observed information matrix
{tab}opg{tab}{tab}outer product of the gradient information matrix
{tab}{bf:Sandwich estimators}
{tab}robust{tab}{tab}Huber/White/sandwich estimator
{tab}cluster{tab}{tab}clustered sandwich estimator
{tab}{bf:Replication Based}
{tab}bootstrap{tab}bootstrap estimation
{tab}jackknife{tab}jackknife estimation
