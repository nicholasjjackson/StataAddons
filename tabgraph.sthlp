Frequency Graph Creation Program
Stata Verison 12
Code Version 2.0 04/15/2012 Nick Jackson, Biostatistician, University of Pennsylvania

{smcl}
{title: Invocation:}
	{cmd: tabgraph} {it:varname} [{it:if}] [{it:in}] [{it:pweight}] [, {cmd: by}({it:varlist}) {it:options}]

{title: Purpose:} Produces a Frequency graph of {it:varlist} (max=1) against subgroups of the {bf:by} variables (max=8).
		

{title: Options:}

{phang}
	{opt bw} speficies graph to be in black & white. Color graph is default. 

{phang}
	{opt colors()} used to specify colors to be used for {bf:by} groups. The first color will be for the first {bf:by:} group, second for the second etc. If not specified, defaults used. 
	Use the program {bf:vgcolormap} to help in selecting colors (may need to install)

{phang}
	{opt legend()} specifies legend properties. Default is legeng(off). Use standard Legend specifications
		
{phang}
	{opt same} speficies each group to have the same colors. Can be used by itself or with the {it:colors()} or {it:bw} commands

{phang}
	{opt nobyname} speficies x-axis labels to only display the value label and not the variable name. 
	
{phang}
	{opt xlabsize()} specifies the size of the X axis labels. Default is medsmall.

{phang}
	{opt xnolab} supresses x-axis labeling.	
	
{phang}
	{opt ylabsize()} specifies the size of the X axis labels. Default is medsmall.
	
{phang}
	{opt intensity()} specifies the intensity levels (shading) of the bars. This should be a number list starting with the intensity for the first bar. 	

{phang}
	{opt width()} specifies the width of the graph in inches.  		

{phang}
	{opt height()} specifies the height of the graph in inches.  
	
{phang}
	{opt outline()} specifies the thickness of the outlines for the within {bf:by} group frequency bars. Default is vvthin.
	
{phang}
	{opt outcolor()} specifies the color of the outlines for the within {bf:by} group frequency bars. Default is black.	

{phang}
	{opt ytitle()} specifies the Y axis title. Default is "% of {it:`varlist'}".	
	
{phang}
	{opt ytitlesize()} specifies the size of the Y axis title. Default is medsmall.

	
{title: Examples:}

{cmd: Example 1:}
use ptpros, clear
tabgraph bmi3grp, by(gender cd med_statin) bw same outline(none) ytitle(Frequency of BMI Groups accross Demographic Vars) ytitlesize(small) ylabsize(small) intensity(30 60 90)
	