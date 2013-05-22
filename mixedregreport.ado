program define mixedregreport
syntax varlist [if] [in] [pweight] [, iv(varlist) covars(string) log error(name) star cat(numlist max=1 integer) estround(numlist max=1 integer) id(varname) time(varname) COVariance(name) ]
*Created 03/12/2012 Nick Jackson
*PROGRAM Version 1.1
*Version 1.0 03/12/2012: Created based upon geereport program version 2.0
*Version 1.1 04/05/2012: Allows i. in covars list
*Version 1.2 04/09/2012: Change N reporting as matrix

*version 12

qui {
tempfile faketemp output temp

capture keep $_if
capture keep $_in

save `faketemp', replace 


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
			

		if "`id'" == "" {
			noi: display as error "id() must be specified for longitudinal data"
		}
	
		
		if "`cat'"!="" {
			local cutpoint=`cat'
		}
		else {
			local cutpoint=9
		}
		
		if "`log'" == "log" {
			logtran `var', replace
		}
		else {
		}
		
		
		if `num' <=`cutpoint' {
		
			if "`weight'" !=""	{
				if "`covariance'" !="" {
					xtmixed `var' i.`iv' `covars' $_if [`weight' `exp'], ||`id':`time',  covariance(`covariance') reml
				}
				if "`covariance'" =="" {
					xtmixed `var' i.`iv' `covars' $_if [`weight' `exp'], ||`id':`time', reml
				}
			}
			else	{
				if "`covariance'" !="" {
					xtmixed `var' i.`iv' `covars' $_if , ||`id':`time', covariance(`covariance') reml
				}
				if "`covariance'" =="" {
					xtmixed `var' i.`iv' `covars' $_if , ||`id':`time', reml
				}
				
			}
					*capture drop resid
					*predict resid if e(sample), pearson
					*sum resid $_if , detail
				
					*local skew=r(skewness)
					matrix x=e(N_g)
					local N=x[1,1]
					testparm i.`iv'
					local p=r(p)
					
				if "`estround'" !="" {
					
					if "`log'" == "log" {
						if "`error'"=="ci" {
							resout, error(ci) exp pvalue estround(`estround')
						}
						else {
							resout, error(se) exp pvalue estround(`estround')
						}
					}
					else {
						if "`error'"=="ci" {
							resout, error(ci) pvalue estround(`estround')
						}
						else {
							resout, error(se) pvalue estround(`estround')
						}
					}
				}
				else {
					if "`log'" == "log" {
						if "`error'"=="ci" {
							resout, error(ci) exp pvalue
						}
						else {
							resout, error(se) exp pvalue
						}
					}
					else {
						if "`error'"=="ci" {
							resout, error(ci) pvalue
						}
						else {
							resout, error(se) pvalue
						}
					}
				}
					gen p_all=`p'
					tostring p_all, force format(%9.4f) replace
						replace p_all = "<.0001" if p_all=="0.0000"

					
					*gen residskew=`skew'
					*tostring residskew, force format(%9.1f) replace
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
				if "`covariance'" !="" {
					xtmixed `var' `iv' `covars' $_if [`weight' `exp'], ||`id':`time',  covariance(`covariance') reml
				}
				if "`covariance'" =="" {
					xtmixed `var' `iv' `covars' $_if [`weight' `exp'], ||`id':`time', reml
				}
			}
			else	{
				if "`covariance'" !="" {
					xtmixed `var' `iv' `covars' $_if , ||`id':`time', covariance(`covariance') reml
				}
				if "`covariance'" =="" {
					xtmixed `var' `iv' `covars' $_if , ||`id':`time', reml
				}
			}
		
					*capture drop resid
					*predict resid if e(sample), pearson
					*sum resid $_if , detail
				
					*local skew=r(skewness)
					matrix x=e(N_g)
					local N=x[1,1]
					
					test `iv'
					local p=r(p)
				
				if "`estround'" !="" {
					if "`log'" == "log" {
						if "`error'"=="ci" {
							resout, error(ci) exp pvalue estround(`estround')
						}
						else {
							resout, error(se) exp pvalue estround(`estround')
						}
					}
					else {
						if "`error'"=="ci" {
							resout, error(ci) pvalue estround(`estround')
						}
						else {
							resout, error(se) pvalue estround(`estround')
						}
					}
				}
				
				else {
					if "`log'" == "log" {
						if "`error'"=="ci" {
							resout, error(ci) exp pvalue
						}
						else {
							resout, error(se) exp pvalue
						}
					}
					else {
						if "`error'"=="ci" {
							resout, error(ci) pvalue
						}
						else {
							resout, error(se) pvalue
						}
					}
				}
					gen p_all=`p'
					tostring p_all, force format(%9.4f) replace
						replace p_all = "<.0001" if p_all=="0.0000"
					
					*gen residskew=`skew'
					*tostring residskew, force format(%9.1f) replace
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
*label var residskew "Skewness of Residuals"
label var est "Estimate"
label var p "P Value for IV"
label var p_all "Omnibus P Value for Categorical IV's"

if "`star'" !="" {
	destring p, replace
			gen star="†" if p <=0.10
			replace star="*" if p<=0.05
			replace star="**" if p<=0.01
			replace star="***" if p<=0.001
	replace est=star+est
	drop star
	tostring p, force format(%9.4f) replace
		replace p = "<.0001" if p=="0.0000"
}

order outcome iv N est p p_all

}
*

end
exit


