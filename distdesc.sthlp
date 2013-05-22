{smcl}
DIST DESC.ado
Program For Distribution Descriptions
Stata Verison 11
Code Version 1.5 02/20/2012 Nick Jackson, Biostatistician, University of Pennsylvania

{title:Invocation:}
	distdesc varlist [if] [in] [, by(varname) bin(numlist max=1 integer) freq curve minmax cat(numlist max=1 integer) estround(numlist  missingokay max=1 integer)]

{title:Purpose:} Provides Histogram and embedded Descriptive statistics for Varlist. 
	"by(varname)" option does not currently work


{title:Options}

{phang}
	{opt by()} allows for histograms/descriptives to be reported within each level of the "by" variable. Currently this option does not work.
	
{phang}
	{opt bin} Specifies the Bin number to be used in generating the histogram. 

{phang}
	{opt freq} For continuous data, displays a Frequency histogram. For categorical data, displays a relative Frequency (%) histogram. 
		Default for continuous data is a density histogram, for categorical default is a frequency (N) histogram.
	
{phang}
	{opt curve} Allows for a normal curve to be fit to the histogram for continuous data.
	
{phang}
	{opt minmax} Displays the minimums and maximums of the data. 
	
{phang}
	{opt cat} allows for changing the threshold for determining if an DV should be modeled categorically or continuously. Default for categorical is <= 9 unique groups. 

{phang}
	{opt estround} allows for changing the number of decimal places the descriptive estimates are rounded to.  	
	

{title:Examples}
	distdesc gender ahi bmi if bmigrp==2
	distdesc gender ahi bmi if bmigrp==2, bin(20) freq
	distdesc gender ahi bmi if bmigrp==2, curve freq cat(5) estround(2)




