Median Split Program
Stata Verison 11
Code Version 1.0 05/08/2012 Nick Jackson, Biostatistician, University of Pennsylvania



Invocation:
	medsplit varlist [if]  [in] [,REPlace]

Purpose: performs median split (data in terms of 0,1) for varlist.

{opt REPlace} replace the variable as 0,1 values. Default is to create variables named var_m



Example:
	medsplit ahi bmi 

