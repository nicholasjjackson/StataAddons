{smcl}
Mixed Effects Linear Regression Report Program (Restricted Maximum Likelihood)
Stata Verison 12
Code Version 1.0 03/12/2012 Nick Jackson, Biostatistician, University of Pennsylvania


{title:Invocation:}
	mixedregreport varlist [if] [pweight] [,  iv(varlist) covars(string) id(varname) time(varname) log error(name) star cat(numlist max=1 integer) estround(numlist max=1 integer)  COVariance(name)]

{title:Purpose:}  Mixed Effects Linear Regression using Restricted Maximum Likelihood estimation.
	Provides P values and effect size of ivS vs varlist adjusting for covars. 
	For independent variables, the program will automatically determine 
	whether to model the variable as continuous or categorical. 


{title:Options}
{phang}
	{opt iv} this is the independent variable list. This must be specified. The program automatically determines if the variable is modeled continuously or catecorally based upon having <=9 unique groups (this can be changed with the "cat()" option). For categorical IV's, the lowest value of the IV is taken as the reference group.

{phang}
	{opt covars} this is the covariate variable list. Categorical covars with > 2 groups must have dummy variables created first. 

{phang}
	{opt id} specifies the panel id variable in the longitudinal design. Usually subject id. Must be specified.

{phang}
	{opt time} specifies the time variable in the longitudinal design (must be integer). Used for creating random coefficient models.
	
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
	{opt covariance} is used to specify the variance-covariance structure of the random effects: Default is identity
 
			exchangeable             exchangeable (equal variances for random effects, and one common pairwise covariance)
			independent              independent (one variance parameter per random effect, all covariances zero; the default unless a factor variable is specified)
			unstructured             unstructured (all variances and covariances distinctly estimated)
			identity				 identity (equal variances for random effects, all covariances zero; the default for factor variables)
			
