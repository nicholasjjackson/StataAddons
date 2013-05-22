Standardization Program
Stata Verison 11
Code Version 1.0 10/30/2010 Nick Jackson, Biostatistician, University of Pennsylvania



Invocation:
	standard varlist [if]  [in] [,REPlace]

Purpose: performs standardization (data in terms of standard scores) for varlist by subtracting the mean and dividing by the SD.
Creates new variable called var_s with mean=0 and SD=1.

{opt REPlace} replace the variable as standardized values. Default is to create variables named var_s



Example:
	standard ahi bmi 

creates ahi_s which is (ahi-mean)/sd and bmi_s which is (bmi-mean)/sd



What is standardization: http://en.wikipedia.org/wiki/Standard_score
						 http://en.wikipedia.org/wiki/Normalization_(statistics)
