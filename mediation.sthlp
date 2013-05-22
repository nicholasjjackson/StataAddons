{smcl}
{bf:Mediation Analysis Program}
Stata Verison 12
Code Version 2.0 05/13/2012 Nick Jackson, Biostatistician, University of Pennsylvania

{title: Invocation:}
	{cmd: mediation} {it:varlist} [{it:if}] [{it:in}] [{it:pweight}] [, {cmd: iv}({it:varlist}) {cmd: mv}({it:varlist}) {cmd: covars}({it:string}) {cmd: cat}({it:integer}) {cmd: SOBel} {cmd: bootstrap}({it:integer})]

	
{title: Purpose:} Conducts Mediational Analyses for the following types of Data:

{tab}{tab}   | {bf:Continuous} | {bf:Binary} | {bf:Categorical} |
{tab}{tab}----------------------------------------
{tab}{tab}{bf:DV} |     X      |    X   |             |
{tab}{tab}----------------------------------------
{tab}{tab}{bf:IV} |     X      |    X   |      X      |
{tab}{tab}----------------------------------------
{tab}{tab}{bf:MV} |     X      |    X   |             |
{tab}{tab}----------------------------------------


{title: Options:}

{phang}
	{opt iv} speficies the independent variable. 

{phang}
	{opt mv} speficies the mediator variable. 
	
{phang}
	{opt covars} this is the covariate variable list. Categorical covars with > 2 groups must have dummy variables created first.	

{phang}
	{opt sobel} speficies Sobel-Goodman mediation tests. 
	
{phang}
	{opt cat} allows for changing the threshold for determining if the IV should be modeled categorically or continuously. Default for categorical is <= 9 unique groups. 

{phang}
	{opt bootstrap} specifies bootstraping with (XXX) number of replications to determine the significance of the indirect effects. (cannot be used with sample weigths)
