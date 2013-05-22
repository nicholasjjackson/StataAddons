StataAddons
===========

.ADO Programs for Stata Versions 11-12.

1) Place these in your default personal Stata ADO directory (often c:\ado).
2) type "help programslist" in the Stata Command window to see a list of available programs (also below)
3) type "help PROGRAM_NAME" to see a further description and information on how to use the programs.


 List of Nick's Toolbox Add-On Programs

Programs created in Stata Version 11 and 12
Nicholas Jackson, Applied Statistician



 Statistical Models

 Cross-Sectional Analysis:
    grpscompare Overall summary statistics and between group statistics

    glmreport Statistical GLM reporting program for main effects

    regreport Statistical Linear Regression reporting program for main effects

    logitreport Statistical Logistic Regression reporting program for main effects

 Longitudinal Analysis:
    pairtest conducts paired ttest and wilcoxon sign rank on longitudinal designs

    geereport Statistical GEE reporting program for main effects in longitudinal designs (Generalized Estimating Equations)

    mixedregreport Statistical Mixed Effects Linear Regression reporting program for main effects in longitudinal designs (Restricted Maximum Likelihood)

    mixedlogitreport Statistical Mixed Effects Logistic Regression reporting program for main effects in longitudinal designs (Maximum Likelihood)



 Correlation Analyses                      
        
    corrreport Correlation table program

    pcorrreport Partial Correlation table program

    r2comp Bootstrapped R-Squared Comparison Program



 Mediation, Moderation (Interaction), Confounding                  
        
 Cross-Sectional Analysis: 
    confound Examines potential confounders in models

    glmint Statistical exploration program for Two-Way interactions using a GLM

    regint Statistical exploration program for Two-Way interactions using Linear Regression

    logitint Statistical exploration program for Two-Way interactions using Logistic Regression

 Longitudinal Analysis:
    geeint Statistical exploration program for Two-Way interactions in longitudinal designs (Generalized Estimating Equations)

    mixedregint Statistical exploration program for Two-Way interactions in longitudinal designs (Mixed Effects Linear Regression)

    mixedlogitint Statistical exploration program for Two-Way interactions in longitudinal designs (Mixed Effects Logistic Regression)



 Interaction Graphs        

 Cross-Sectional Analysis: 
    cinteract Two-Way Continuous X Continuous interaction exploration program for 2D Graphs in Stata

    cinteract3d Two-Way Continuous X Continuous interaction extraction program for 3D Graphs in SigmaPlot

    gginteract Two-Way Categorical X Categorical interaction exploration program for 2D Graphs in Stata

    gcinteract Two-Way Categorical X Continuous interaction exploration program for 2D Graphs in Stata

 Longitudinal Analysis:            
    cgeeinteract3d Generalized Estimating Equation Two-Way Continuous X Continuous interaction extraction program for 3D Graphs in SigmaPlot


        
 Distribution and Relationship Graphs              

    distdesc Summary statistics with graphical exploration of distributions

    scatteradjust Used for creating scatter plots and linear predictions of 2 vars adjusted for covariates.

    tabgraph Creates a frequency graph of an variable accross various other categorical vars (a visual cross tabs)



 P Value Correction
    benhoch Benjamini and Hochberg P Value correction

    bholm Holm-Bonferonni P Value correction

    bonfer Bonferonni P Value correction

        
        
 Data and Variable Manipulation            
        
    center Centers variables (subtracts mean)

    charid Identifies the characters present in numeric variables for destring conversion

    efcode Creates Effect Coded variables

    logtran Log Transforms variables

    lowercase Renames Variable Names to lowercase

    medsplit Creates median split of a variable

    outliers Conducts basic outlier analysis

    rowdup Finds duplicate observations within subjects

    coldup Finds duplicate observations between subjects

    standard Standardizes variables (subtracts mean, divides by standard deviation)

    winsorize Winsorize variables

                                

 Data Extraction           
    exout Exportation of results to excel tables. Used to make Stata's built in Excel Exportation easier.  Stata Version 12 Required.

    resout extracts results from a model and places in a table

        
 UPENN Special Programs
    psacompile Power Spectral Analysis Compilation Program for Spectral Analysis files created in Sandman. See Word Doc "UPENN PSA Compilation Instructions" for Details

