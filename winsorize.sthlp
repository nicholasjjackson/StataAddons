Winsorization Program
Stata Verison 11
Code Version 1.0 10/30/2010 Nick Jackson, Biostatistician, University of Pennsylvania



Invocation:
	winsorize varlist [if] [,level(#) dir(name)]

#=Level at which to winsorize. Options are 1,5,10,25,75,90,95,99
name= 'high' or 'low' indicating if we are winsorizing extremely high values or low values.
When name is unspecified, the default is to winsorize on both sides.


Purpose: performs winsorization of extreme values, setting them to a maximal or minimal (or both) percentile level.
Creates new variable called var_w.


Examples: [numbers in front of commands added to reference]
	[1] winsorize ahi bmi, level(95) 
	[2] winsorize ahi bmi, level(95) dir(high)
	[3] winsorize ahi bmi, level(5) dir(low)
	[4] winsorize ahi bmi, level(5) dir(high)
	
Descriptions:
[1] Takes high values above the 95 percentile and places them at the 95th percentile. Takes low values below the 5th percentile and places them at the 5th percentile.
[1] Takes high values above the 95 percentile and places them at the 95th percentile. 
[3] Takes low values below the 5th percentile and places them at the 5th percentile.
[4] The same as [2]

What is winsorization: http://en.wikipedia.org/wiki/Winsorising