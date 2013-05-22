{smcl}
{bf:Row Duplicates Identification Program}
Stata Verison 12
Code Version 1.0 03/14/2014 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	{cmd: rowdup} {it:varlist} [, {it:options}]

{title: Purpose:} Produces indicators of duplciates observations within a subject (dup_*).
		

{title: Note:} A maximum of 64 Variables can be tested in Intercooled Stata due to variable limits
		
		
{title: Options:}

{phang}
	{opt replace} replaces data in memory with a listing of duplicate observations, must be used with {cmd:{it:id}} option

{phang}
	{opt id} specifices the variable(s) that uniquely identify a subject/row observation. Must be used with {cmd:{it:replace}} option

{phang}
	{opt NOIneger} excludes integer values from consideration as duplicates
		
	
{title: Examples:}

{cmd: Example 1:}
use ptpros, clear
rowdup mr1-mr12, id(id) replace
	