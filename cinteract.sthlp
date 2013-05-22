Continuous Interactions Graphical Exploration Program
Stata Verison 11
Code Version 1.0 11/09/2010 Nick Jackson, Biostatistician, University of Pennsylvania
Code Version 2.0 03/24/2011 Added Scatter Option
 
This program was written with substantial help and explicit code copying from:
http://www.ats.ucla.edu/stat/stata/faq/conconb11.htm
A part of the University of California, Los Angeles: Academic Technology Services, Statistical Computing Division (http://www.ats.ucla.edu/stat/)


Invocation:
	cinteract varlist [if] [,  iv1(varlist) iv2(varlist) covars(String) fam(name) link(name) scatter]

Purpose: Provides graphical exploration of CONTINUOUS variable interactions.
		 Graph of Outcome vs IV1 effect modification by IV2 (Interaction) at various percentiles of IV2.
		 NOTE: This means that IV1 is always on the X Axis at differing percentiles of IV2.

Scatter Option:  when specified will display a scatter plot of the varlist vs iv1.

IMPORTANT: Continuous covariates in covars() must be centered 
		   prior to analysis. SEE center.sthlp for information on centering.
		   
NOTE: 	The Program will not run any form of categorical interaction.
		

fam() is used to specify the family of distributions with the following options: Default is gaussian
    gaussian                 Gaussian (normal)
    igaussian                inverse Gaussian
    binomial[varnameN|#N]    Bernoulli/binomial
    poisson                  Poisson
    nbinomial[#k|ml]         negative binomial
    gamma                    gamma

link() is used to specify any necessary transformations: Default is identity

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



Examples:
	[1] cinteract ahi, iv1(bmi) iv2(fatpads age) 

	[1] Graph of the relationships between bmi and ahi, modifed by varying levels of fatpads and then age. 

		


