{smcl}
GGINTERACT.ado
Program For Creating a graph of Group by Group Two-Way interaction Graphs
Stata Verison 11
Code Version 1.0 07/25/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{title:Invocation:}
	gginteract varname [if] [in] [weight] [, grp1(varname) grp2(varname) covars(string) fam(name) link(name) log labsize(name)]

{title:Purpose:} Provides bar graph of means for outcome for each level of grp1 and grp2 categorical variables.
	

{title:Options}

{phang}
	{opt weight} allows only for the use of sample weights [pweight]
	
{phang}
	{opt grp1 and grp2} Specify the group variables to be interacted. 

{phang}
	{opt covars} this is the covariate variable list. Categorical covars with > 2 groups must have dummy variables created first. 	

{phang}
	{opt log} allows data to be analysed and presented on a log scale (this can also be done by specifying a log linkage with gauss distibution).
	
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
	{opt labsize} is used to specify the size of the labels in the resultant graph
 
			minuscule           	medsmall 
			quarter_tiny            medium      
			third_tiny              medlarge            
			half_tiny               large
			tiny                    vlarge                 
			vsmall                  huge
			small                   vhuge 
        
			tenth                one-tenth the size of the graph
			quarter              one-fourth the size of the graph
			third                one-third the size of the graph
			half                 one-half the size of the graph
			full  

	
{title:Example}
	sysuse auto, clear
	gginteract  price , grp1(foreign) grp2(rep78) 




