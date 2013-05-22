Bootstrapped R-Squared Comparison Program
Stata Verison 12
Code Version 2.0 10/14/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	{cmd: r2comp} varlist  [{it:if}] [{it:in}] [, predm1({it:varlist}) predm2({it:varlist}) adjust({it:varlist}) bootstrap(numlist missingokay max=1) estround(numlist max=1 integer) model pcorr ]

{title: Purpose:} Produces a comparison of R-Squared Values (with 95% CI) for the variables PredM1 versus PredM2 using Bootstrapping.
When model is specified, the comparison is between the whole model R2 and not the variable group Contributions to R2.

{title: Options:} 

{phang}
	{opt predm1} is an predictor or group of predictors for Model 1. 

{phang}
	{opt predm2} is an predictor or group of predictors for Model 2. 

{phang}
	{opt adjust} specifies the covariates to be adjusted for. 
			
{phang}
	{opt bootstrap} specifies the number of Bootstrap repititions to be used (recommend 1000). 

{phang}
	{opt model} compares model R2 between predm1 model and predm2 model as opposed to comparing R2 contribution to the model for the variables. 

{phang}
	{opt estround}	will round your estimates to X decimal places (default 2)
	
{phang}
	{opt pcorr}	presents estimates as partial correlation coefficients (cannot be specified with "model" and should not be used when more than one variable is present as a predictor in a model.
	
{title: Examples:}


{cmd: Example 1:}
use ptpros, clear
r2comp loglep_bl if overlap==1, predm1(ahi) predm2(bmi mr54) adjust(gender) bootstrap(1000)
		
{phang}
	{opt Explanation 1:} The above produces R-Squared estimates with 95% CI for ahi and seperately bmi with mr54 in regression model for Log(Leptin). 
	The R2 Contributions of these variables/variable groups is modeled with gender adjustment.
	A P-value derived from bootstrapping (1000 replications) indicates if the r-squared values of ahi are significantly different from the combined r-squared of bmi and mr54. 		
	
{cmd: Example 2:}
use ptpros, clear
r2comp loglep_bl if overlap==1, predm1(ahi) predm2(bmi mr54) adjust(gender) bootstrap(1000) model
{phang}
	{opt Explanation 2:} The above produces Model R-Squared estimates with 95% CI for a model with ahi and a Model with bmi and mr54 in a regression Model for Log(Leptin), adjusted for gender.
	A P-value derived from bootstrapping (1000 replications) indicates if the  model r-squared values are significantly different. 
