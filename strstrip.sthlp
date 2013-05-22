{smcl}
String Stripping Program
Stata Verison 12
Code Version 1.0 05/20/2013 Nick Jackson, Applied Statistician

{title:Invocation:}
	{cmd: strstrip } {it: varlist}  [,  {cmd:Lcut}({it:integer}) {cmd:Rcut}({it:integer}) {cmd:ignore}({it:string}) {cmd:nodestring}]

{title:Purpose:} Advanced applications of Substring Command for removing leading and trailing values.

{title:Options:}
{phang}
	{opt lcut(#):} Removes X positions from the Left of the variable (ie. lcut(1) removes value at position 1) 
	{it:ex rcut(1):} token=512345 - > token=12345
 	
{phang}
	{opt rcut(#):} Removes X positions from the Right of the variable (ie. rcut(1) removes value at last position) 
	{it:ex rcut(1):} token=512345 - > token=51234
	
{phang}
	{opt lkeep(#):} Keeps X positions from the Left of the variable (ie. lkeep(2) keeps value at <= position 2) 
	{it:ex rcut(1):} token=512345 - > token=51
 	
{phang}
	{opt rkeep(#):} Keeps X positions from the Right of the variable (ie. rkeep(2) keeps value at >= position 2) 
	{it:ex rcut(1):} token=512345 - > token=45	
	
	
{phang}
	{opt ignore():} Specifies String values to be ignored in destringing 
	
{phang}
	{opt nodestring():} Specifies not to destring end result 


{title: Examples:}
[1] sysuse auto, clear 
		strstrip make, l(2) r(1) nodestring


[2] sysuse auto, clear
		tostring gear_ratio, force replace 
		split gear_ratio, p(.)
		replace gear_ratio=gear_ratio1 + ".a" + gear_ratio2
	
		strstrip gear_ratio,  r(5) ignore(a) 
	
  
[3] sysuse auto, clear 
		strstrip price, rk(3) 

