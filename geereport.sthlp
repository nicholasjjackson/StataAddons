{smcl}
GEE Report Program
Stata Verison 12
Code Version 1.1 08/18/2011 Nick Jackson, Biostatistician, University of Pennsylvania


{title:Invocation:}
	geereport varlist [if] [pweight] [,  iv(varlist) covars(string) id(varname) time(varname) fam(name) link(name) error(name) star cat(numlist max=1 integer) estround(numlist max=1 integer)  corr(name)]

{title:Purpose:}  Generalized Estimating Equations
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
			reciprocal               reciprocal; 1/y


{phang}
	{opt corr} is used to specify the variance-covariance structure of the random effects: Default is exchangeable
 
			exchangeable             exchangeable
			independent              independent
			unstructured             unstructured
			fixed matname            user-specified
			ar #                     autoregressive of order #
			stationary #             stationary of order #
			nonstationary #          nonstationary of order #


			
			
{title:Example:}
	geereport ahi odi minsao2 o2lt90mn, id(id) iv(lep cholest bmi) covars(gender age)  fam(gaussian) link(log) estround(2) error(ci)
	