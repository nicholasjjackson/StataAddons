Bootstrapped R-Squared Comparison Program
Stata Verison 12
Code Version 1.0 10/26/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	{cmd: scatteradjust} varlist  [{it:if}] [{it:in}] [, iv({it:varlist}) adjust({it:string})]

{title: Purpose:} Used for creating scatter plots and linear predictions of 2 vars adjusted for covariates.
Creates adjusted variables named: youtcome_iv and xiv_outcome, where outcome and iv are the specified vars. 
			

{title: Options:} 

{phang}
	{opt iv} is an Independent variable

{phang}
	{opt adjust} specifies the covariates to be adjusted for. 

	
{title: Examples:}


{cmd: Example 1:}
sysuse auto
scatteradjust price, iv(mpg weight) adjust(turn foreign)
		
{phang}
	{opt Explanation 1:} The above produces variables yprice_mpg yprice_weight xmpg_price xweight_price that can be used
	in a scatter plot of yprice_mpg with xmpg_price, yprice_weight with xweight_price. 
	These scatterplots produce graphs of price and mpg adjusted for turn and foreign etc. These can also be used to represent 
	partial correlations when specifying lfit in stata graphics
	
	