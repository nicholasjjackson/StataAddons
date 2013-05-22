Excel Table Output Program 
Stata Verison 12
Code Version 1.0 12/19/2011 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	{cmd: exout} [{it:if}] [{it:in}] [, Vars({it:varlist}) TABle({it:namelist}) SHeet({it:namelist}) DIRectory({it:string}) overwrite]

{title: Purpose:} To export reults tables into excel

{title: Options:}

{phang}
	{opt vars} Specifies which variables to export. Default is ALL

{phang}
	{opt table} Specifies excel filename. Default is Results_$S_DATE.xlsx

{phang}
	{opt sheet} Specifies sheet name within excel file. Must be specified.

{phang}
	{opt dir} specifies the directory to export excel file to. Default is current directory.  

{phang}
	{opt overwrite} Overwrites the current excel table if it already exists. Typically, this is specified in the first export, and then omitted to allow appending of new data.

{title: Examples:}


{cmd: Example 1:}
sysuse auto, clear
grpscompare price mpg, by(foreign) 

exout ,  sheet(Mean Comparisons) table(AUTO Results) dir(c:\Analysis\) overwrite		
