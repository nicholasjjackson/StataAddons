{smcl}
GLM Report Program
Stata Verison 11
Code Version 3.6 05/24/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{title:Invocation:}
	glmreport varlist [if] [pweight] [,  iv(varlist) covars(string) fam(name) link(name) error(name) star cat(numlist max=1 integer) estround(numlist max=1 integer) iterate(numlist max=1 integer) vce(string)]

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
	{opt iterate} changes the maximmum number of iterations before finishing the model (useful to force convergence)

{phang}
	{opt fam} is used to specify the family of distributions with the following options: Default is gaussian
			
			gaussian                 Gaussian (normal)
			igaussian                inverse Gaussian
			binomial[varnameN|#N]    Bernoulli/binomial
			poisson                  Poisson
			nbinomial[#k|ml]         negative binomial
			gamma                    gamma

{phang}
	{opt link} is used to specify any necessary transformations: Default is identity
 
			identity                 identity
			log                      log
			logit                    logit
			probit                   probit
			cloglog                  cloglog
			power #                  power
			opower #                 odds power
			nbinomial                negative binomial
			loglog                   log-log
			logc                     log-complement

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
			

Examples:
	[1] glmreport softpalate rpairway, iv(apneic) covars(bmi age sex) fam(gauss) link(log)
	[2] glmreport bmi, iv(age) 
	[3] glmreport height weight, iv(age sex race) covars(bmi)

	[1] Reports exponentiated coefficient of the effect of apniec on log transformed softpalate and 
	    rpairway adjusting for bmi, age, and sex
	[2] Reports effect of age on bmi (linear regression)
	[3] Reports the effects of age on height and weight outcomes adjusted for bmi, as well the effects 
	    of sex on height and weight outcomes adjusted for bmi, and race on height and weight outcomes 
	    adjusted for bmi.
