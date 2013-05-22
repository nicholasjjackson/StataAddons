{smcl}
GCINTERACT.ado
Program For Creating a graph of Continuous by Group Two-Way interaction Graphs
Stata Verison 11
Code Version 2.0 09/06/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{title:Invocation:}
	gcinteract varname [if] [in] [weight] [, cont(varname) grp(varname) fam(name)  link(name) covars(string) iterate(integer) log ]

{title:Purpose:} Provides graph of linear predicition of continuous variable (cont) against outcome for various levels of a categoprical variable (grp).
	Within grp P values of linear prediciton presented.
	

{title:Options}
{phang}
	{opt weight} allows only for the use of sample weights [pweight]

{phang}
	{opt cont} Specify the continuous variable to be interacted.

{phang}
	{opt grp} Specify the group variable to be interacted. Currenlty limited to 2 or 3 groups.

{phang}
	{opt covars} this is the covariate variable list. Categorical covars with > 2 groups must have dummy variables created first. 	

{phang}
	{opt log} allows data to be analysed and presented on a log scale.
	
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
	
	
	
{title:Example}
	sysuse auto, clear
	gcinteract  price , cont(mpg) grp(foreign) 




