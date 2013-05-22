{smcl}
Logistic Regression Interaction Program
Stata Verison 12
Code Version 1.1 04/05/2012 Nick Jackson, Biostatistician, University of Pennsylvania



{title:Invocation:}
	logitint varlist [if] [pweight] [, iv1(varlist)  iv2(varlist)  covars(string) or  error(name)  star  cat(integer)  estround(integer) iterate(integer)  full vce(string)] 

{title:Purpose:} Provides P values and effect size for dependent Main Effects of IV1 and IV1 in a non-interactive model, and provides the P Value for an IV1*IV2 Interaction. 
	For independent variables (IV1 and IV2), the program will automatically determine whether to model the variable as continuous or categorical. 
	
{title:iv1 and iv2}
	These are the independent variable lists. These must be specified. The interaction effects tested will be IV1 X IV2
	The program automatically determines if the IV is modeled continuously or catecorally based upon having <=9 unique groups (this can be changed with the "cat()" option). 
	For categorical IV's, the lowest value of the IV is taken as the reference group.
	
{title:Options}

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
	{opt full} shows the coefficients and significance of the IVs in a noninteractive model adjusting for eachother
	
{phang}
	{opt or} displays odds ratios (reports exponentiated coefficients)

{phang}
	{opt estround} allows for changing the number of decimal places the estimates are rounded to.  	

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
