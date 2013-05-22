Outliers Program 
Stata Verison 11
Code Version 1.0 11/06/2010 Nick Jackson, Biostatistician, University of Pennsylvania



Invocation:
	outliers varlist [if] 

Purpose: Examines outliers of varlist through reporting % of observations within:
		1 SD, 2 SD, 3 SD, 3.5 SD, and 4 SD of the mean (median analysis also stored in output).
		
		This program makes use of the 68, 95, 99.7 rule such that:
			68% of Data should be within 1 SD
			95% of Data should be within 2 SDs
			99.7% of Data should be within 3 SDs
			
			In conjunction with skewness values, these can be used to examine normality assuptions of the data.
			
			



Examples: 
	 outliers ahi bmi
	 outliers ahi bmi if sex==1
	

What is the 68-95-99.7 Rule: http://en.wikipedia.org/wiki/68-95-99.7_rule
