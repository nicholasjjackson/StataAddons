{smcl}
CGEEINTERACT3D.ado
Program For Creating Three Dimensional Continuous by Continuous Two-Way interaction Graphs in Longitudinal Data
Stata Verison 11
Code Version 1.0 07/22/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{title:Invocation:}
	cgeeinteract3d varname [if] [in] [weight] [, iv1(varname) iv2(varname) covars(string) iterate(num) fam(name) link(name)  id(varname) time(varname) corr(name)]

{title:Purpose:} Provides predcited values of the outcome at 10 even increments of Iv1 and Iv2. (created by (max-min)/10 
	This is used to create a 3D Graph of the 2-way interaction of outcome=Iv1 X Iv2. Values output from this must be copy/pasted into
	SigmaPlot or other 3D Graphing software.

{title:Options}
{phang}
	{opt iv1 and iv2} Specify the continuous variables to be interacted.

{phang}
	{opt covars} this is the covariate variable list. Categorical covars with > 2 groups must have dummy variables created first. 	

{phang}
	{opt iterate} specifies the number of iterations for convergence

{phang}
	{opt id} specifies the panel id variable in the longitudinal design. Usually subject id. Must be specified.

{phang}
	{opt time} specifies the time variable in the longitudinal design (must be integer). Used for creating random coefficient models.
	
	
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
	
	
	
{title:Example}
	cgeeinteract3d ahi, iv1(age) iv2(weight) fam(binomial) link(logit) id(id) 




