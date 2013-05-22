{smcl}
Linear Regression Report Program
Stata Verison 12
Code Version 1.1 04/05/2012 Nick Jackson, Biostatistician, University of Pennsylvania

{title:Invocation:}
	regreport varlist [if] [pweight] [,  iv(varlist) covars(string)  error(name) star log cat(numlist max=1 integer) estround(numlist max=1 integer) vce(string) ]

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
	{opt log} log transforms the outcome and reports exponentiated coefficients

{phang}
	{opt vce} changes the variance covariance matrix options

{tab}{bf:Least Squares}
{tab}ols{tab}{tab}ordinary least squares
{tab}{bf:Robust Alternatives}
{tab}hc2{tab}{tab}This estimate is unbiased if the model really is homoskedastic
{tab}hc3{tab}{tab}This estimate is unbiased if the model really is heteroskedastic
{tab}{bf:Sandwich estimators}
{tab}robust{tab}{tab}Huber/White/sandwich estimator
{tab}cluster{tab}{tab}clustered sandwich estimator
{tab}{bf:Replication Based}
{tab}bootstrap{tab}bootstrap estimation
{tab}jackknife{tab}jackknife estimation


Examples:
	[1] regreport softpalate rpairway, iv(apneic) covars(bmi age sex) log
	[2] regreport bmi, iv(age) 
	[3] regreport height weight, iv(age sex race) covars(bmi)

	[1] Reports exponentiated coefficient of the effect of apniec on log transformed softpalate and 
	    rpairway adjusting for bmi, age, and sex
	[2] Reports effect of age on bmi (linear regression)
	[3] Reports the effects of age on height and weight outcomes adjusted for bmi, as well the effects 
	    of sex on height and weight outcomes adjusted for bmi, and race on height and weight outcomes 
	    adjusted for bmi.
