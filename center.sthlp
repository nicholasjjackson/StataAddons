Data Centering Program
Stata Verison 11
Code Version 1.0 10/30/2010 Nick Jackson, Biostatistician, University of Pennsylvania

Invocation:
	center varlist [if] [in] [,REPlace]

Purpose: Creates variable which contains values of var minus the mean of var (centering).

{opt REPlace} replace the variable as centered values. Default is to create variables named var_c


Examples:
	center age, replace
	center age bmi 
	center age if sex==1, replace
	center age bmi if sex==1

Subtracts the mean of age from the age variable, creating age_c which now has mean=0

