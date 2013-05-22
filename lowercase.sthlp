Lowercase Variable Renaming Program
Stata Verison 11
Code Version 1.0 01/12/2011 Nick Jackson, Biostatistician, University of Pennsylvania



Invocation:
	lowercase varlist 

Purpose: takes Uppercase variable names and changes them to lowercase.



Examples:
1) A dataset where ID,GENDER, and Sex variables have uppercase names
	
	lowercase ID GENDER Sex
	
		produces id, gender, and sex varnames
2) A dataset where EVERY variable is uppercase
	
	lowercase _all
	
		produces all varnames as lowercase 
	

