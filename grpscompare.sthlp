{smcl}
GRPS COMPARE.ado
Program For Creating Descriptive Statistics
Stata Verison 11
Code Version 2.2 02/26/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{title:Invocation:}
	grpscompare varlist [if] [in] [weight] [, by(varname) med log num cat(numlist max=1 integer) estround(numlist max=1 integer)]

{title:Purpose:} Provides frequencies for Categorical Variables (Number of Groups <=8) and Means (SD) for continuous variables. 
	If "by(varname)" option is specified then overall and within group descriptives are reported with between group 
	statistical tests conducted. Skewness values are reported for continuous variables.


{title:Options}
{phang}
	{opt weight} allows only for the use of sample weights [pweight]. If the weight option is specified all desctiptives are reported as adjusted 
	for the sample weight. The (N) reported will be the observed sample N and not the population N, thus there may be discrepencies in the N proportions
	when examining categorical variable frequencies.

{phang}
	{opt by()} allows for descriptives to be reported within each level of the "by" variable. Between group statistical tests conducted are:
	Pearson Chi2, T-Test unequal variance, ANOVA, Wilcoxon Rank Sum, Kruskal Wallis ANOVA.
	When [weight] is specified non-parametrics cannot be reported and the T-Test assumes equal variance.

{phang}
	{opt med} includes the median in the descriptives of continuous variables. This option cannot be specified with the [weight] option.

{phang}
	{opt log} allows continuous data to be analysed and presented on a log scale.
	
{phang}
	{opt num} supresses the reporting of the number of observations (ie. (N) ).
	
{phang}
	{opt cat} allows for changing the threshold for determining if an DV should be modeled categorically or continuously. Default for categorical is <= 9 unique groups. 

{phang}
	{opt estround} allows for changing the number of decimal places the estimates are rounded to.  	
	

{title:Examples}
	grpscompare gender ahi bmi
	grpscompare gender ahi bmi, med
	grpscompare gender ahi bmi, by(race) med log
	grpscompare gender ahi bmi if income==0 [pweight=smpl_wt], by(race) log num



