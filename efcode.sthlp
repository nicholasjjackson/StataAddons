{smcl}
Effect Code Program
Stata Verison 12
Code Version 1.0 04/10/2013 Nicholas Jackson, Applied Statistician

{title:Invocation:}
	efcode varlist [if] [, code(numlist min=2 max=2) ref(numlist integer max=1) ]

{title:Purpose:} Creates Effect Codes for variables of varlist.


{title:Options}
{phang}
	{opt ref} Default=ref(1). Changes the group to be used as a reference value.

{phang}
	{opt code} Default=code(-1 1). Changes the effect codes used. A popular alternative would be "half-effect codes" with code(-0.5 0.5). 


Examples:
	[1]	syuse auto, clear
		efcode foreign
		*Creates effect codes of -1, 1 referenced to group 1 of forein
		
		
	[2]	syuse auto, clear
		efcode rep78, code(-0.5 0.5) ref(4)
		*Creates effect codes of -0.5, 0.5 referenced to group 4 of rep78
