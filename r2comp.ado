program r2comp 
syntax varlist [if] [in] [, predm1(varlist) predm2(varlist)  adjust(varlist) bootstrap(numlist missingokay max=1) estround(numlist max=1 integer) model pcorr]
*Created 10/12/2011 Based upon isacr2comp Version 2.0 
*version 2.0 10/14/2011
*version 3.0 01/7/2012: Changed Pcorr option because it was previously computing semipartial correlation coefficients.
version 11
set more off
qui {

tempfile current
capture keep $_if
capture keep $_in
save `current', replace

tempfile output temp

local pred1="`predm1'"
local pred2="`predm2'"



clear
set obs 1
gen outcome=""
save `output', replace


if "`model'" == "" & "`pcorr'"=="" {
		use `current', clear
		foreach var of varlist `varlist' {
			use `current', clear
				foreach pred1 of varlist `predm1' {
					use `current', clear
						foreach pred2 of varlist `predm2' {
							use `current', clear
								/*This part restricts the analysis to only those with values for both Obesity variables*/
								capture drop tag
								
									drop if `pred1'==.
									drop if `pred2'==.
								/***Pred1****/	
									/*Overall Model-PRED1*/
									tempfile model1 all 
									bootstrap all=e(r2), seed(`bootstrap') reps(`bootstrap')  saving(`all', replace): regress `var' `pred1' `adjust'
										gen tag=1 if e(sample)
										local r2_all= _b[all]
									
									/*Overall Model-without PRED1*/
									bootstrap model1=e(r2), seed(`bootstrap') reps(`bootstrap')  saving(`model1', replace): regress `var' `adjust' if tag==1
										local model1r2=`r2_all'-_b[model1]
										
									use `all', clear
										egen id=seq()
									save `all', replace
									
									use `model1', clear
										egen id=seq()
									save `model1', replace
									
									use `all', clear
									joinby id using `model1', unmatched(none)
									gen pred1r2=all-model1
										drop all model1
									_pctile pred1r2, p(2.5 97.5)
										local pred1r2hi=r(r2)
										local pred1r2lo=r(r1)
									save `model1', replace
										
								/***Pred2****/	
									use `current', clear
								/*This part restricts the analysis to only those with values for both Obesity variables*/
									capture drop tag
									foreach pred of varlist `predm1' `predm2' {
										drop if `pred'==.
									}
									/*Overall Model-PRED2*/
									tempfile model2 all 
									bootstrap all=e(r2), seed(`bootstrap') reps(`bootstrap')  saving(`all', replace): regress `var' `pred2' `adjust'
										gen tag=1 if e(sample)
										local r2_all= _b[all]
									
									/*Overall Model-without PRED2*/
									bootstrap model2=e(r2), seed(`bootstrap') reps(`bootstrap')  saving(`model2', replace): regress `var' `adjust' if tag==1
										local model2r2=`r2_all'-_b[model2]
										
									use `all', clear
										egen id=seq()
									save `all', replace
									
									use `model2', clear
										egen id=seq()
									save `model2', replace
									
									use `all', clear
									joinby id using `model2', unmatched(none)
									gen pred2r2=all-model2
										drop all model2
									_pctile pred2r2, p(2.5 97.5)
										local pred2r2hi=r(r2)
										local pred2r2lo=r(r1)
									save `model2', replace
									
							/**Combine to Get P value***/
								use `model1', clear
								joinby id using `model2', unmatched(none)
								
								local threshold=_N/2
								
								count if pred1r2 >= pred2r2
								local n=r(N)
								
								if `n' >= `threshold' {
									local p=2* (1-(`n'/`bootstrap'))
								}
								if `n' < `threshold' {
									local p=2* (1-((`bootstrap'-`n')/`bootstrap'))
								}
								
								clear
								set obs 1
									gen pred1=`model1r2'*100
									gen pred1hi=`pred1r2hi'*100
									gen pred1lo=`pred1r2lo'*100
									gen pred2=`model2r2'*100
									gen pred2hi=`pred2r2hi'*100
									gen pred2lo=`pred2r2lo'*100
								if "`estround'" == "" {
									tostring pred*, force format(%9.2f) replace
								}
								else {
									tostring pred*, force format(%9.`estround'f) replace
								}
									gen outcome="`var'"

								
								gen predm1R2=pred1 + " (" + pred1lo + " - " + pred1hi + ")"
								gen predm2R2=pred2 + " (" + pred2lo + " - " + pred2hi + ")"
								
								drop pred1* pred2*
								gen p=`p'
								gen predm1="`pred1'"
								gen predm2="`pred2'"
								replace p=.9999 if p >1
								
							if `bootstrap' <=100 {
								tostring p, force format(%9.2f) replace
								replace p ="<.01" if p=="0.00"
							}
							
							if `bootstrap' >100 &  `bootstrap' <=1000{
								tostring p, force format(%9.3f) replace
								replace p ="<.001" if p=="0.000"
							}
							
							if  `bootstrap' >1000  {
								tostring p, force format(%9.4f) replace
								replace p ="<.0001" if p=="0.0000"
							}
							
							save `temp', replace
							use `output', clear
								append using `temp'
								capture drop if outcome==""
							save `output', replace
					}/*Pred2*/
				}/*Pred 1*/			
		}/*Varlist*/
}/*MODEL*/
*

if "`model'" != "" & "`pcorr'"!="" {
	display as error "Cannot Specify Model and Pcorr option together"
}
*

if "`model'" == "" & "`pcorr'"!="" {
		use `current', clear
		foreach var of varlist `varlist' {
			use `current', clear
				foreach pred1 of varlist `predm1' {
					use `current', clear
						foreach pred2 of varlist `predm2' {
							use `current', clear
								/*This part restricts the analysis to only those with values for both Obesity variables*/
								capture drop tag
								
									drop if `pred1'==.
									drop if `pred2'==.

								/***Pred1****/	
									/*Overall Model-PRED1*/
									tempfile model1 all 

									pcorr `var' `pred1' `adjust'
										matrix x = r(p_corr)
										local corr1=x[1,1]
									regress `var' `pred1' `adjust'
										test `pred1'
										local p1=r(p)
										local df1= e(df_r)
									
									bootstrap coef1=_b[`pred1']  se1=_se[`pred1'], seed(`bootstrap') reps(`bootstrap') saving(`model1', replace): regress `var' `pred1' `adjust'

									use `model1', clear
										egen id=seq()
										gen t1=coef1/se1
										gen pcorr1=sqrt(t1^2/(t1^2 + `df1'))
									_pctile pcorr1, p(2.5 97.5)
										local pred1hi=r(r2)
										local pred1lo=r(r1)
									
									save `model1', replace
									

										
								/***Pred2****/	
									use `current', clear
								/*This part restricts the analysis to only those with values for both Obesity variables*/
									capture drop tag
									foreach pred of varlist `predm1' `predm2' {
										drop if `pred'==.
									}
									/***Pred1****/	
									/*Overall Model-PRED1*/
									tempfile model2 all 

									pcorr `var' `pred2' `adjust'
										matrix x = r(p_corr)
										local corr2=x[1,1]
									regress `var' `pred2' `adjust'
										test `pred2'
										local p2=r(p)
										local df2= e(df_r)
									
									bootstrap coef2=_b[`pred2']  se2=_se[`pred2'], seed(`bootstrap') reps(`bootstrap') saving(`model2', replace): regress `var' `pred2' `adjust'

									use `model2', clear
										egen id=seq()
										gen t2=coef2/se2
										gen pcorr2=sqrt(t2^2/(t2^2 + `df2'))
									_pctile pcorr2, p(2.5 97.5)
										local pred2hi=r(r2)
										local pred2lo=r(r1)
									
									save `model2', replace
									
							/**Combine to Get P value***/
								use `model1', clear
								joinby id using `model2', unmatched(none)
								
								local threshold=_N/2
								
								count if pcorr1 >= pcorr2
								local n=r(N)
								
								if `n' >= `threshold' {
									local p=2* (1-(`n'/`bootstrap'))
								}
								if `n' < `threshold' {
									local p=2* (1-((`bootstrap'-`n')/`bootstrap'))
								}
								
							/*Input Values*/	
							
								clear
								set obs 1
									gen pred1=`corr1'
										*replace pred1=pred1*-1 if `coef1' < 0
									gen pred1hi=`pred1hi'
										*replace pred1hi=pred1hi*-1 if `ub1' < 0
									gen pred1lo=`pred1lo'
										*replace pred1lo=pred1lo*-1 if `lb1' < 0
									
									gen pred2=`corr2'
										*replace pred2=pred2*-1 if `coef2' < 0
									gen pred2hi=`pred2hi'
										*replace pred2hi=pred2hi*-1 if `ub2' < 0
									gen pred2lo=`pred2lo'
										*replace pred2lo=pred2lo*-1 if `lb2' < 0
									gen p1=`p1'
									gen p2=`p2'
									gen star1 = "†" if p1 <=0.10
										replace star1="*" if p1 <=0.05
										replace star1="**" if p1 <=0.01
										replace star1="***" if p1 <=0.001
									gen star2 = "†" if p2 <=0.10
										replace star2="*" if p2 <=0.05
										replace star2="**" if p2 <=0.01
										replace star2="***" if p2 <=0.001									
								
								if "`estround'" == "" {
									tostring pred*, force format(%9.2f) replace
								}
								else {
									tostring pred*, force format(%9.`estround'f) replace
								}
								gen outcome="`var'"

								
								gen predm1Rho=star1+pred1 + " (" + pred1lo + " - " + pred1hi + ")"
								gen predm2Rho=star2+pred2 + " (" + pred2lo + " - " + pred2hi + ")"
								
								drop pred1* pred2* 
								*drop p1 p2 star1 star2
								gen p=`p'
								gen predm1="`pred1'"
								gen predm2="`pred2'"
								replace p=.9999 if p >1
								
							if `bootstrap' <=100 {
								tostring p, force format(%9.2f) replace
								replace p ="<.01" if p=="0.00"
							}
							
							if `bootstrap' >100 &  `bootstrap' <=1000{
								tostring p, force format(%9.3f) replace
								replace p ="<.001" if p=="0.000"
							}
							
							if  `bootstrap' >1000  {
								tostring p, force format(%9.4f) replace
								replace p ="<.0001" if p=="0.0000"
							}
							
							drop p1 p2 star1 star2
							drop if predm1==predm2
							save `temp', replace
							use `output', clear
								append using `temp'
								capture drop if outcome==""
							save `output', replace
				}/*Pred2*/
			}/*Pred1*/				
		}/*Varlist*/
}/*MODEL*/

if "`model'" != ""  {
	use `current', clear
		foreach var of varlist `varlist' {
			use `current', clear
				foreach pred1 of varlist `predm1' {
					use `current', clear
						foreach pred2 of varlist `predm2' {
							use `current', clear
								/*This part restricts the analysis to only those with values for both Obesity variables*/
								capture drop tag
								
									drop if `pred1'==.
									drop if `pred2'==.
									/*Overall Model-PRED1*/
									tempfile model1 all 
									bootstrap pred1=e(r2), seed(`bootstrap') reps(`bootstrap')  saving(`model1', replace): regress `var' `pred1' `adjust'
										local pred1r2= _b[pred1]
									
									use `model1', clear
										egen id=seq()
									_pctile pred1, p(2.5 97.5)
										local pred1r2hi=r(r2)
										local pred1r2lo=r(r1)
									save `model1', replace
										
	
								/***PRED2****/	
								use `current', clear
								capture drop tag
									/*This part restricts the analysis to only those with values for both Obesity variables*/
									foreach pred of varlist `predm1' `predm2' {
										drop if `pred'==.
									}
									/*Overall Model-PRED2*/
									tempfile model2 all 
									bootstrap pred2=e(r2), seed(`bootstrap') reps(`bootstrap')  saving(`model2', replace): regress `var' `pred2' `adjust'
										local pred2r2= _b[pred2]
									
									use `model2', clear
										egen id=seq()
									_pctile pred2, p(2.5 97.5)
										local pred2r2hi=r(r2)
										local pred2r2lo=r(r1)
									save `model2', replace
									
							/**Combine to Get P value***/
								use `model1', clear
								joinby id using `model2', unmatched(none)
								
								local threshold=_N/2
								
								count if pred1 >= pred2
								local n=r(N)
								
								if `n' >= `threshold' {
									local p=2* (1-(`n'/`bootstrap'))
								}
								if `n' < `threshold' {
									local p=2* (1-((`bootstrap'-`n')/`bootstrap'))
								}
								
							/*Input Values*/	
								clear
								set obs 1
									gen pred1=`pred1r2'*100
									gen pred1hi=`pred1r2hi'*100
									gen pred1lo=`pred1r2lo'*100
									gen pred2=`pred2r2'*100
									gen pred2hi=`pred2r2hi'*100
									gen pred2lo=`pred2r2lo'*100
								if "`estround'" == "" {
									tostring pred*, force format(%9.2f) replace
								}
								else {
									tostring pred*, force format(%9.`estround'f) replace
								}
									gen outcome="`var'"
								
								gen predm1R2=pred1 + " (" + pred1lo + " - " + pred1hi + ")"
								gen predm2R2=pred2 + " (" + pred2lo + " - " + pred2hi + ")"
								
								drop pred1* pred2*
								gen p=`p'
								gen predm1="`pred1'"
								gen predm2="`pred2'"
								replace p=.9999 if p >1
								
							if `bootstrap' <=100 {
								tostring p, force format(%9.2f) replace
								replace p ="<.01" if p=="0.00"
							}
							
							if `bootstrap' >100 &  `bootstrap' <=1000{
								tostring p, force format(%9.3f) replace
								replace p ="<.001" if p=="0.000"
							}
							
							if  `bootstrap' >1000  {
								tostring p, force format(%9.4f) replace
								replace p ="<.0001" if p=="0.0000"
							}
							
							save `temp', replace
							use `output', clear
								append using `temp'
								capture drop if outcome==""
							save `output', replace
			}/*PRED2*/				
		}/*PRED 1*/				
	}/*VARLIST*/
}/*MODEL*/

}/*QUI*/
			*
end
exit
