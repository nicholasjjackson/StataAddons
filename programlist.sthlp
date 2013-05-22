{smcl}
{title: List of Nick's Toolbox Add-On Programs}

Programs created in Stata Version 11 and 12
Nicholas Jackson, Applied Statistician



{ul: Statistical Models}

{it: Cross-Sectional Analysis:}
{phang}
	{opt grpscompare:} Overall summary statistics and between group statistics	

{phang}
	{opt glmreport:} Statistical GLM reporting program for main effects
	
{phang}
	{opt regreport:} Statistical Linear Regression reporting program for main effects 

{phang}
	{opt logitreport:} Statistical Logistic Regression reporting program for main effects 	
	
{it: Longitudinal Analysis:}
{phang}
	{opt pairtest:} conducts paired ttest and wilcoxon sign rank on longitudinal designs	
	
{phang}
	{opt geereport:} Statistical GEE reporting program for main effects in longitudinal designs (Generalized Estimating Equations)
	
{phang}
	{opt mixedregreport:} Statistical Mixed Effects Linear Regression reporting program for main effects in longitudinal designs (Restricted Maximum Likelihood)
	
{phang}
	{opt mixedlogitreport:} Statistical Mixed Effects Logistic Regression reporting program for main effects in longitudinal designs (Maximum Likelihood)	



{ul: Correlation Analyses}			
	
{phang}
	{opt corrreport:} Correlation table program
	
{phang}
	{opt pcorrreport:} Partial Correlation table program
	
{phang}
	{opt r2comp:} Bootstrapped R-Squared Comparison Program



{ul: Mediation, Moderation (Interaction), Confounding}			
	
{it: Cross-Sectional Analysis:}	
{phang}
	{opt confound:} Examines potential confounders in models

{phang}
	{opt glmint:} Statistical exploration program for Two-Way interactions using a GLM
	
{phang}
	{opt regint:} Statistical exploration program for Two-Way interactions using Linear Regression

{phang}
	{opt logitint:} Statistical exploration program for Two-Way interactions using Logistic Regression		

{it: Longitudinal Analysis:}
{phang}
	{opt geeint:} Statistical exploration program for Two-Way interactions in longitudinal designs (Generalized Estimating Equations)

{phang}
	{opt mixedregint:} Statistical exploration program for Two-Way interactions in longitudinal designs (Mixed Effects Linear Regression)

{phang}
	{opt mixedlogitint:} Statistical exploration program for Two-Way interactions in longitudinal designs (Mixed Effects Logistic Regression)	



{ul: Interaction Graphs}	

{it: Cross-Sectional Analysis:}	
{phang}
	{opt cinteract:} Two-Way Continuous X Continuous interaction exploration program for 2D Graphs in Stata

{phang}
	{opt cinteract3d:} Two-Way Continuous X Continuous interaction extraction program for 3D Graphs in SigmaPlot
	
{phang}
	{opt gginteract:} Two-Way Categorical X Categorical interaction exploration program for 2D Graphs in Stata	

{phang}
	{opt gcinteract:} Two-Way Categorical X Continuous interaction exploration program for 2D Graphs in Stata	
		
{it: Longitudinal Analysis:}		
{phang}
	{opt cgeeinteract3d:} Generalized Estimating Equation Two-Way Continuous X Continuous interaction extraction program for 3D Graphs in SigmaPlot	


	
{ul: Distribution and Relationship Graphs}		

{phang}
	{opt distdesc:} Summary statistics with graphical exploration of distributions 
	
{phang}
	{opt scatteradjust:} Used for creating scatter plots and linear predictions of 2 vars adjusted for covariates.
	
{phang}
	{opt tabgraph:} Creates a frequency graph of an variable accross various other categorical vars (a visual cross tabs)



{ul: P Value Correction}
{phang}
	{opt benhoch:} Benjamini and Hochberg P Value correction
	
{phang}
	{opt bholm:} Holm-Bonferonni P Value correction
	
{phang}
	{opt bonfer:} Bonferonni P Value correction

	
	
{ul: Data and Variable Manipulation}		
	
{phang}
	{opt center:} Centers variables (subtracts mean)

{phang}
	{opt charid:} Identifies the characters present in numeric variables for destring conversion
	
{phang}
	{opt efcode:} Creates Effect Coded variables
	
{phang}
	{opt logtran:} Log Transforms variables
	
{phang}
	{opt lowercase:} Renames Variable Names to lowercase
	
{phang}
	{opt medsplit:} Creates median split of a variable
	
{phang}
	{opt outliers:} Conducts basic outlier analysis 
	
{phang}
	{opt rowdup:} Finds duplicate observations within subjects

{phang}
	{opt coldup:} Finds duplicate observations between subjects
	
{phang}
	{opt standard:} Standardizes variables (subtracts mean, divides by standard deviation)
	
{phang}
	{opt winsorize:} Winsorize variables 
				
				

{ul: Data Extraction}		
{phang}
	{opt exout:} Exportation of results to excel tables. Used to make Stata's built in Excel Exportation easier.  Stata Version 12 Required.

{phang}
	{opt resout:} extracts results from a model and places in a table	

	
{ul: UPENN Special Programs}
{phang}
	{opt psacompile:} Power Spectral Analysis Compilation Program for Spectral Analysis files created in Sandman. See Word Doc "UPENN PSA Compilation Instructions" for Details
