{smcl}
GEE Interaction Program
Stata Verison 11
Code Version 1.5 11/29/2011 Nick Jackson, Biostatistician, University of Pennsylvania



{title:Invocation:}
	geeint varlist [if] [pweight] [, iv1(varlist) iv2(varlist) covars(string) id(varname) time(varname) fam(name) link(name) error(name) star cat(integer) estround(integer) corr(name) full]

{title:Purpose:} Generalized Estimating Equations
	Provides P values and effect size for dependent Main Effects of IV1 and IV1 in a non-interactive model, and provides the P Value for an IV1*IV2 Interaction. 
	For independent variables (IV1 and IV2), the program will automatically determine whether to model the variable as continuous or categorical. 

	
{title:iv1 and iv2}
	These are the independent variable lists. These must be specified. The interaction effects tested will be IV1 X IV2
	The program automatically determines if the IV is modeled continuously or catecorally based upon having <=9 unique groups (this can be changed with the "cat()" option). 
	For categorical IV's, the lowest value of the IV is taken as the reference group.
	
{title:Options}

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
	{opt full} shows the coefficients and significance of the IVs in a noninteractive model adjusting for eachother	

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
			loglog                   log-log
			logc                     log-complement

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
	geeint ahi odi minsao2 o2lt90mn, id(id) iv1(lep cholest) iv2(bmi age) covars(gender cad)  fam(gaussian) link(log) estround(2) error(ci)
	