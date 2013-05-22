{smcl}
Confounding Analysis Program
Stata Verison 11
Code Version 1.0 07/28/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{title:Invocation:}
	confound varlist [if] [in] [pweight] [,  iv(varlist) confound(varlist) covars(string) fam(name) link(name) star cat(numlist max=1 integer) plevel(numlist max=1)]

{title:Purpose:} Indicates confounding vairable by examinging significant associations between confounder with predictor and outcome. 
	Additionally requires > 10% change in  Crude estimate after adjustment for confounder.
	
	For independent variables (iv) and confounders , the program will automatically determine 
	whether to model the variable as continuous or categorical. 


{title:Options}
{phang}
	{opt iv} this is the independent variable list. This must be specified. 
	         The program automatically determines if the variable is modeled continuously or catecorally 
			 based upon having <=9 unique groups (this can be changed with the "cat()" option). 
             For categorical IV's, the lowest value of the IV is taken as the reference group.

{phang}
	{opt confound} this is the confounder variable list. This must be specified. 
	         The program automatically determines if the variable is modeled continuously or catecorally 
			 based upon having <=9 unique groups (this can be changed with the "cat()" option). 
             For categorical Confounders's, the lowest value of the Confounder is taken as the reference group.			 
			 
{phang}
	{opt covars} this is the covariate variable list. Categorical covars with > 2 groups must have dummy variables created first. 

{phang}
	{opt weight} allows only for the use of sample weights [pweight]

{phang}
	{opt cat} allows for changing the threshold for determining if an IV should be modeled categorically or continuously. Default for categorical is <= 9 unique groups. 

{phang}
	{opt plevel} allows for the p value level to be set for significant associations between confounder with predictor and outcome.
	
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



Example:
sysuse auto, clear
confound  price mpg, iv(weight length) confound(gear_ratio foreign) covars(turn) plevel(0.10)

