program confound 
syntax varlist [if] [in] [pweight] [, iv(varlist) confound(varlist) covars(string) fam(name) link(name)  cat(numlist max=1 integer) plevel(numlist max=1) iterate(numlist max=1)]
*Version 2.0 12/23/2011
qui {
set more off

tempfile master output temp using
save `master', replace 

	capture keep $_if
	capture keep $_in

	
foreach cov in `covars' {
	capture drop if `cov' ==.
}
	
save `using', replace 


clear
set obs 1
gen outcome=""
save `output', replace


	if "`cat'"!="" {
			local cutpoint=`cat'
		}
		else {
			local cutpoint=9
		}

	if "`iterate'"!="" {
			local itnum=`iterate'
		}
		else {
			local itnum=100
		}
		
		
use `using', clear
foreach outcome of varlist `varlist' {
use `using', clear
	foreach conf in `confound' {
		use `using', clear
		foreach indv in `iv' {
		use `using', clear
		
		inspect `conf' if `outcome' !=. & `indv' !=.
			local c_num=r(N_unique)
		inspect `indv' if `outcome' !=. & `conf' !=.
			local i_num=r(N_unique)
			
if "`weight'" ==""	{		
	/*Evaluate Bivariate Relationships of Confounder and Predictor*/	
			*Categorcial vs Categorical
			if `c_num' <=`cutpoint' & `i_num' <=`cutpoint' {
					tab `conf' `indv' if `outcome' !=., exact
					local iv_con=  r(p_exact)
			}
			*Categorcial vs Continuous
			if `c_num' <=`cutpoint' & `i_num' > `cutpoint' {
					regress  `indv' i.`conf' `covars'  if `outcome' !=.
					testparm i.`conf'
					local iv_con= r(p) 
			}
			*Continuous vs Categorical
			if `c_num' >`cutpoint' & `i_num' <= `cutpoint' {
					regress  `conf' i.`indv' `covars' if `outcome' !=.
					*local iv_con=  Ftail(r(df_m), r(df_r), r(F))
					testparm i.`indv'
					local iv_con= r(p) 
			}
			*Continuous vs Continous
			if `c_num' >`cutpoint' & `i_num' > `cutpoint' {
					regress `conf' `indv' `covars' if `outcome' !=.
					test `indv'
					local iv_con= r(p) 
			}
	
	/*Evaluate Bivariate Relationships of Confounder and Outcome*/
			glmreport `outcome' if `indv' !=., iv(`conf') cat(`cutpoint') fam(`fam') link(`link') covars(`covars') iterate(`itnum')
					keep p_all
						duplicates drop
					replace p_all="0.0000" if p_all=="<.0001"
					destring p_all, replace
					local out_con =p_all in 1
	
			use `using', clear
	/*Evaluate % Change in Crude Estimates*/
			
			*Categorcial Predictor and Categorical Confounder
			if `c_num' <=`cutpoint' & `i_num' <=`cutpoint' {
					use `using', clear
						glm `outcome'  i.`indv' i.`conf' `covars', family(`fam') link(`link')	iterate(`itnum') 
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							split var, p(".")
							keep if var2=="`indv'"
							rename est adj
							drop var
						tempfile temp
						save `temp', replace
						
					use `using', clear
						glm `outcome'  i.`indv'  `covars' if `conf' !=., family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							split var, p(".")
							keep if var2=="`indv'"
							rename est unadj
							drop var
						joinby var1 var2 using `temp', unmatched(none)
					
						gen change=((adj-unadj)/adj)*100
						/*	gen ge10=1 if abs(change) >=10
							gen ge15=1 if abs(change) >=15
							gen ge20=1 if abs(change) >=20
							
						collapse (sum) ge*
						*/
							gen outcome="`outcome'"
							gen predictor="`indv'"
								replace predictor=var1 + "." + predictor
							gen confound="`conf'"
							gen  iv_con=`iv_con'
							capture gen  out_con=`out_con'
							
						
						tempfile result
						save `result', replace
						
						use `output', clear
							append using `result'
						save `output', replace
				}
					
			*Categorcial Predictor and Continous Confounder
			if `c_num' >`cutpoint' & `i_num' <=`cutpoint' {
					use `using', clear
						glm `outcome'  i.`indv' `conf' `covars', family(`fam') link(`link')	iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							split var, p(".")
							keep if var2=="`indv'"
							rename est adj
							drop var
						tempfile temp
						save `temp', replace
						
					use `using', clear
						glm `outcome'  i.`indv'  `covars' if `conf' !=., family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							split var, p(".")
							keep if var2=="`indv'"
							rename est unadj
							drop var
						joinby var1 var2 using `temp', unmatched(none)
					
						gen change=((adj-unadj)/adj)*100
						/*	gen ge10=1 if abs(change) >=10
							gen ge15=1 if abs(change) >=15
							gen ge20=1 if abs(change) >=20
							
						collapse (sum) ge*
						*/
							gen outcome="`outcome'"
							gen predictor="`indv'"
								replace predictor=var1 + "." + predictor
							gen confound="`conf'"
							gen  iv_con=`iv_con'
							capture gen  out_con=`out_con'
							
						
						tempfile result
						save `result', replace
						
						use `output', clear
							append using `result'
						save `output', replace
				}		
			
			*Continuous Predictor and Categorical Confounder
			if `c_num' <=`cutpoint' & `i_num' > `cutpoint' {
					use `using', clear
						glm `outcome'  `indv' i.`conf' `covars', family(`fam') link(`link')	 iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							keep if var=="`indv'"
							rename est adj
						tempfile temp
						save `temp', replace
						
					use `using', clear
						glm `outcome'  `indv'  `covars' if `conf' !=., family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							keep if var=="`indv'"
							rename est unadj
						joinby var using `temp', unmatched(none)
					
						gen change=((adj-unadj)/adj)*100
						/*	gen ge10=1 if abs(change) >=10
							gen ge15=1 if abs(change) >=15
							gen ge20=1 if abs(change) >=20
							
						collapse (sum) ge*
						*/
							gen outcome="`outcome'"
							gen predictor="`indv'"
							gen confound="`conf'"
							gen  iv_con=`iv_con'
							capture gen  out_con=`out_con'
							
						
						tempfile result
						save `result', replace
						
						use `output', clear
							append using `result'
						save `output', replace
				}
				
			*Continuous Predictor and Continuous Confounder
			if `c_num' > `cutpoint' & `i_num' > `cutpoint' {
					use `using', clear
						glm `outcome' `indv' `conf' `covars', family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							keep if var=="`indv'"
							rename est adj
						tempfile temp
						save `temp', replace
						
					use `using', clear
						glm `outcome'  `indv'  `covars' if `conf' !=., family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							keep if var=="`indv'"
							rename est unadj
						joinby var using `temp', unmatched(none)
					
						gen change=((adj-unadj)/adj)*100
						/*	gen ge10=1 if abs(change) >=10
							gen ge15=1 if abs(change) >=15
							gen ge20=1 if abs(change) >=20
							
						collapse (sum) ge*
						*/
							gen outcome="`outcome'"
							gen predictor="`indv'"
							gen confound="`conf'"
							gen  iv_con=`iv_con'
							capture gen  out_con=`out_con'
							
						
						tempfile result
						save `result', replace
						
						use `output', clear
							append using `result'
						save `output', replace
				}	
	} /*Weighting Bracket*/
	
	
	if "`weight'" !=""	{		
	/*Evaluate Bivariate Relationships of Confounder and Predictor*/	
			svyset _n [`weight'`exp'], vce(linearized) singleunit(missing)
			
			*Categorcial vs Categorical
			if `c_num' <=`cutpoint' & `i_num' <=`cutpoint' {
					svy linearized : tabulate `indv' `conf' if `outcome' !=.
					
					local iv_con= e(p_Pear) 
			}
			*Categorcial vs Continuous
			if `c_num' <=`cutpoint' & `i_num' > `cutpoint' {
					regress  `indv' i.`conf' `covars' if `outcome' !=. [`weight'`exp']
						testparm i.`conf'		
					local iv_con= r(p)
			}
			*Continuous vs Categorical
			if `c_num' >`cutpoint' & `i_num' <= `cutpoint' {
					regress  `conf'  i.`indv' `covars' if `outcome' !=. [`weight'`exp']
						testparm i.`indv'	
					local iv_con= r(p)
			}
			
			*Continuous vs Continuous
			if `c_num' >`cutpoint' & `i_num' > `cutpoint' {
					regress `conf' `indv' `covars' if `outcome' !=. [`weight'`exp']
					test `indv'
					local iv_con= r(p) 
			}
	
	/*Evaluate Bivariate Relationships of Confounder and Outcome*/
			glmreport `outcome' if `indv' !=. [`weight'`exp'], iv(`conf') cat(`cutpoint') fam(`fam') link(`link') covars(`covars') iterate(`itnum')
					keep p_all
						duplicates drop
					
					replace p_all="0.0000" if p_all=="<.0001"
					destring p_all, replace	
						
					local out_con =p_all in 1
	
			use `using', clear
	/*Evaluate % Change in Crude Estimates*/
			
			*Categorcial Predictor and Categorical Confounder
			if `c_num' <=`cutpoint' & `i_num' <=`cutpoint' {
					use `using', clear
						glm `outcome'  i.`indv' i.`conf' `covars' [`weight'`exp'] , family(`fam') link(`link')	 iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							split var, p(".")
							keep if var2=="`indv'"
							rename est adj
							drop var
						tempfile temp
						save `temp', replace
						
					use `using', clear
						glm `outcome'  i.`indv'  `covars' if `conf'!=. [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							split var, p(".")
							keep if var2=="`indv'"
							rename est unadj
							drop var
						joinby var1 var2 using `temp', unmatched(none)
					
						gen change=((adj-unadj)/adj)*100
						/*	gen ge10=1 if abs(change) >=10
							gen ge15=1 if abs(change) >=15
							gen ge20=1 if abs(change) >=20
							
						collapse (sum) ge*
						*/
							gen outcome="`outcome'"
							gen predictor="`indv'"
								replace predictor=var1 + "." + predictor
							gen confound="`conf'"
							gen  iv_con=`iv_con'
							capture gen  out_con=`out_con'
							
						
						tempfile result
						save `result', replace
						
						use `output', clear
							append using `result'
						save `output', replace
				}
					
			*Categorcial Predictor and Continous Confounder
			if `c_num' >`cutpoint' & `i_num' <=`cutpoint' {
					use `using', clear
						glm `outcome'  i.`indv' `conf' `covars' [`weight'`exp'], family(`fam') link(`link')	 iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							split var, p(".")
							keep if var2=="`indv'"
							rename est adj
							drop var
						tempfile temp
						save `temp', replace
						
					use `using', clear
						glm `outcome'  i.`indv'  `covars' if `conf'!=. [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							split var, p(".")
							keep if var2=="`indv'"
							rename est unadj
							drop var
						joinby var1 var2 using `temp', unmatched(none)
					
						gen change=((adj-unadj)/adj)*100
						/*	gen ge10=1 if abs(change) >=10
							gen ge15=1 if abs(change) >=15
							gen ge20=1 if abs(change) >=20
							
						collapse (sum) ge*
						*/
							gen outcome="`outcome'"
							gen predictor="`indv'"
								replace predictor=var1 + "." + predictor
							gen confound="`conf'"
							gen  iv_con=`iv_con'
							capture gen  out_con=`out_con'
							
							
						
						tempfile result
						save `result', replace
						
						use `output', clear
							append using `result'
						save `output', replace
				}		
			
			*Continuous Predictor and Categorical Confounder
			if `c_num' <=`cutpoint' & `i_num' > `cutpoint' {
					use `using', clear
						glm `outcome'  `indv' i.`conf' `covars' [`weight'`exp'], family(`fam') link(`link')	 iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							keep if var=="`indv'"
							rename est adj
						tempfile temp
						save `temp', replace
						
					use `using', clear
						glm `outcome'  `indv'  `covars' if `conf'!=. [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							keep if var=="`indv'"
							rename est unadj
						joinby var using `temp', unmatched(none)
					
						gen change=((adj-unadj)/adj)*100
						/*	gen ge10=1 if abs(change) >=10
							gen ge15=1 if abs(change) >=15
							gen ge20=1 if abs(change) >=20
							
						collapse (sum) ge*
						*/
							gen outcome="`outcome'"
							gen predictor="`indv'"
							gen confound="`conf'"
							gen  iv_con=`iv_con'
							capture gen  out_con=`out_con'
							
						
						tempfile result
						save `result', replace
						
						use `output', clear
							append using `result'
						save `output', replace
				}
				
			*Continuous Predictor and Continuous Confounder
			if `c_num' > `cutpoint' & `i_num' > `cutpoint' {
					use `using', clear
						glm `outcome' `indv' `conf' `covars' [`weight'`exp'], family(`fam') link(`link')	 iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							keep if var=="`indv'"
							rename est adj
						tempfile temp
						save `temp', replace
						
					use `using', clear
						glm `outcome'  `indv'  `covars' if `conf'!=. [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
							if "`link'" == "log" | "`link'" == "logit" {
								resout, error(se) clean estround(6) exp
							}
							else {
								resout, error(se) clean estround(6)
							}
							destring est, replace
							keep if var=="`indv'"
							rename est unadj
						joinby var using `temp', unmatched(none)
					
						gen change=((adj-unadj)/adj)*100
						/*	gen ge10=1 if abs(change) >=10
							gen ge15=1 if abs(change) >=15
							gen ge20=1 if abs(change) >=20
							
						collapse (sum) ge*
						*/
							gen outcome="`outcome'"
							gen predictor="`indv'"
							gen confound="`conf'"
							gen  iv_con=`iv_con'
							capture gen  out_con=`out_con'
							
						
						tempfile result
						save `result', replace
						
						use `output', clear
							append using `result'
						save `output', replace
				}	
	} /*Weighting Bracket*/
	
} /*IV*/
} /*Confound*/
} /*Outcome*/
use `output', clear
	drop if outcome==""
/*
if "`plevel'" != "" {
	local level=`plevel'
}
else {
	local level=0.05
}
	gen conf10= ge10>=1 &  iv_con <=`level' &  out_con <=`level'
	gen conf15= ge15>=1 &  iv_con <=`level' &  out_con <=`level'
	gen conf20= ge20>=1 &  iv_con <=`level' &  out_con <=`level'
	
label var conf10 "Confounded with > 10% Change in Estimate, Associations p < `level'"
label var  conf15 "Confounded with > 15% Change in Estimate, Associations p < `level'"
label var  conf20 "Confounded with > 20% Change in Estimate, Associations p < `level'"

keep outcome predictor confound conf*
*noi: list  outcome predictor confound conf10 conf15 conf20 if conf10==1 |  conf15==1 | conf20==1
*noi: desc conf10 conf15 conf20
*noi: display "Associations at p < `level'"

*use `master', clear
*/

drop *adj var*
tostring iv_con , force format(%9.4f) replace
capture tostring out_con , force format(%9.4f) replace

tostring change , force format(%9.2f) replace
foreach var in iv_con out_con {
	replace `var'="<.0001" if `var'=="0.0000"
}
label var iv_con "P value for relationship of IV to Confounder"
label var out_con "P value for relationship of Confounder to Outcome"

label var change "% Change in Adjusted Estimate"
label var confound "Confounder Tested"
rename predictor iv
order outcome iv confound change iv_con out_con



}
end
exit
