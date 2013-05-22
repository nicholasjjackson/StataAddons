program define logitreport
syntax varlist [if] [pweight] [, iv(varlist) covars(string) error(name) star cat(numlist max=1 integer) estround(numlist max=1 integer) or iterate(numlist max=1 integer) vce(string)]
*Created  03/12/2012 Nick Jackson
*PROGRAM Version 1.1
*Version 1.0 03/12/2012-created based upon glmreport.ado version 3.8
*Version 1.1 04/05/2012-Removed Specification of Pearson Residuals, Allows i. in covar list
*Version 1.2 05/11/2012: added VCE option

*version 12
qui {
tempfile faketemp output temp
save `faketemp', replace 

if "`iterate'" == "" {
	local itnum=500
}
if "`iterate'" != "" {
	local itnum=`iterate'
}



clear
set more off
set obs 1 
gen outcome=""
gen N=.
save `output', replace 

use `faketemp', clear
foreach iv in `iv' {
	use `faketemp', clear
	inspect `iv'
		local num= r(N_unique)
	foreach var of varlist `varlist' {
		use `faketemp', clear
		*For categorical Predictors
		
		if "`cat'"!="" {
			local cutpoint=`cat'
		}
		else {
			local cutpoint=9
		}
		if "`vce'"!="" {
			local vcetype `vce'
		}
		if "`vce'"=="" & "`weight'"=="" {
			local vcetype oim
		}
		if "`vce'"=="" & "`weight'"!="" {
			local vcetype robust
		}
		
		if `num' <=`cutpoint' {
		
			if "`weight'" !=""	{
				logit `var' i.`iv' `covars' $_if [`weight' `exp'] , iterate(`itnum') vce(`vcetype')
			}
			else	{
				logit `var' i.`iv' `covars' $_if  , iterate(`itnum') vce(`vcetype')
			}
					capture drop resid
					predict resid if e(sample)
					sum resid $_if , detail
				
					local skew=r(skewness)
					local N=r(N)
					testparm i.`iv'
					local p=r(p)
					
				if "`estround'" !="" {
					
					if "`or'" == "or" {
						if "`error'"=="ci" {
							resout, error(ci) exp pvalue estround(`estround')
							replace p = "0.0000" if p=="<.0001"
						}
						else {
							resout, error(se) exp pvalue estround(`estround')
							replace p = "0.0000" if p=="<.0001"
						}
					}
					else {
						if "`error'"=="ci" {
							resout, error(ci) pvalue estround(`estround')
							replace p = "0.0000" if p=="<.0001"
						}
						else {
							resout, error(se) pvalue estround(`estround')
							replace p = "0.0000" if p=="<.0001"
						}
					}
				}
				else {
					if "`or'" == "or"  {
						if "`error'"=="ci" {
							resout, error(ci) exp pvalue
							replace p = "0.0000" if p=="<.0001"
						}
						else {
							resout, error(se) exp pvalue
							replace p = "0.0000" if p=="<.0001"
						}
					}
					else {
						if "`error'"=="ci" {
							resout, error(ci) pvalue
							replace p = "0.0000" if p=="<.0001"
						}
						else {
							resout, error(se) pvalue
							replace p = "0.0000" if p=="<.0001"
						}
					}
				}
					gen p_all=`p'

			
					
					gen residskew=`skew'
					tostring residskew, force format(%9.1f) replace
					rename var iv
					gen outcome="`var'"
					gen N=`N'
				save `temp', replace
					
				use `output', clear
				append using `temp'
				save `output', replace
		}
		*For Continuous Predictors
		else {
			if "`weight'" !=""	{
				logit `var' `iv' `covars' $_if [`weight' `exp'], iterate(`itnum') vce(`vcetype')
			}
			else	{
				logit `var' `iv' `covars' $_if , iterate(`itnum') vce(`vcetype')
			}
		
					capture drop resid
					predict resid if e(sample)
					sum resid $_if , detail
				
					local skew=r(skewness)
					local N=r(N)
					test `iv'
					local p=r(p)
				
				if "`estround'" !="" {
					if "`or'" == "or" {
						if "`error'"=="ci" {
							resout, error(ci) exp pvalue estround(`estround')
							replace p = "0.0000" if p=="<.0001"
						}
						else {
							resout, error(se) exp pvalue estround(`estround')
							replace p = "0.0000" if p=="<.0001"
						}
					}
					else {
						if "`error'"=="ci" {
							resout, error(ci) pvalue estround(`estround')
							replace p = "0.0000" if p=="<.0001"
						}
						else {
							resout, error(se) pvalue estround(`estround')
							replace p = "0.0000" if p=="<.0001"
						}
					}
				}
				
				else {
					if "`or'" == "or" {
						if "`error'"=="ci" {
							resout, error(ci) exp pvalue
							replace p = "0.0000" if p=="<.0001"
						}
						else {
							resout, error(se) exp pvalue
							replace p = "0.0000" if p=="<.0001"
						}
					}
					else {
						if "`error'"=="ci" {
							resout, error(ci) pvalue
							replace p = "0.0000" if p=="<.0001"
						}
						else {
							resout, error(se) pvalue
							replace p = "0.0000" if p=="<.0001"
						}
					}
				}
					gen p_all=`p'

					gen residskew=`skew'
					tostring residskew, force format(%9.1f) replace
					rename var iv
					gen outcome="`var'"
					gen N=`N'
				save `temp', replace
					
				use `output', clear
				append using `temp'
				save `output', replace
		}
	}
}

split iv, p(.) gen(ind)
gen covar=""
foreach x in `covars' {
	replace covar="`x'"
	split covar, p(.) gen(new)
	capture drop if ind2==new2 
	capture drop if ind2==new1 
	capture drop if ind1==new2 
	capture drop if ind1==new1
	drop new*
}


capture drop covar
capture drop ind*


drop if outcome==""
label var outcome "Outcome"
label var iv "Independent Variable"
label var residskew "Skewness of Residuals"
label var est "Estimate"
label var p "P Value for IV"
label var p_all "Omnibus P Value for Categorical IV's"

if "`star'" =="" {
	tostring p p_all, force format(%9.4f) replace
	replace p = "<.0001" if p=="0.0000"
	replace p_all = "<.0001" if p_all=="0.0000"
}

if "`star'" !="" {
	destring p, replace
			gen star="†" if p <=0.10
			replace star="*" if p<=0.05
			replace star="**" if p<=0.01
			replace star="***" if p<=0.001
	replace est=star+est
	drop star
	tostring p p_all, force format(%9.4f) replace
	replace p = "<.0001" if p=="0.0000"
	replace p_all = "<.0001" if p_all=="0.0000"
}

}


	

end
exit

