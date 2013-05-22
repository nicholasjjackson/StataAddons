program define mixedlogitint
syntax varlist [if] [in] [pweight]  [, iv1(varlist) iv2(varlist) covars(string) or  error(name) star cat(numlist max=1 integer) estround(numlist max=1 integer) id(varname) time(varname) COVariance(name) full]
*Created 03/12/2012 Nick Jackson
*PROGRAM Version 1.1
*Version 1.0 03/12/2012 : Created based upon geeint program version 2.0
*Version 1.1 04/05/2012-Allows i. in Covars List
*Version 1.2 04/09/2012: Change N reporting as matrix

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
foreach var of varlist `varlist' {
/****RUN FROM IV1 to IV2*****/
use `faketemp', clear
foreach iv_1 in `iv1' {
use `faketemp', clear
foreach iv_2 in `iv2' {
	use `faketemp', clear
	
	
			if "`id'" == ""  {
				noi: display as error "id() must be specified for longitudinal data"
			}
			
	
			
			inspect `iv_1'
				local num1= r(N_unique)
			inspect `iv_2'
				local num2= r(N_unique)
		
			*Set the Cut Point
			if "`cat'"!="" {
				local cutpoint=`cat'
			}
			else {
				local cutpoint=9
			}
		
		/***CATEGORICAL VS CATEGORICAL INTERACTION***/
		if `num1' <=`cutpoint' & `num2' <=`cutpoint' {
		
			if "`weight'" !=""	{
				if "`covariance'" !="" {
					xtmelogit `var' `iv_1'##`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time', covariance(`covariance') 
						testparm `iv_1'#`iv_2'
							local pint=r(p)
					xtmelogit `var' i.`iv_1' i.`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time', covariance(`covariance') 
				}
				if "`covariance'" =="" {
					xtmelogit `var' `iv_1'##`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time'
						testparm `iv_1'#`iv_2'
							local pint=r(p)
					xtmelogit `var' i.`iv_1' i.`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time'
				}
			}
			
			else	{
				if "`covariance'" !="" {
					xtmelogit `var' `iv_1'##`iv_2' `covars' $_if , ||`id':`time', covariance(`covariance') 
						testparm `iv_1'#`iv_2'
							local pint=r(p)
					xtmelogit `var' i.`iv_1' i.`iv_2' `covars' $_if , ||`id':`time', covariance(`covariance') 
				}
				if "`covariance'" =="" {
					xtmelogit `var' `iv_1'##`iv_2' `covars' $_if , ||`id':`time'
						testparm `iv_1'#`iv_2'
							local pint=r(p)
					xtmelogit `var' i.`iv_1' i.`iv_2' `covars' $_if, ||`id':`time'
				}
			}
					*capture drop resid
					*predict resid if e(sample), pearson
					*sum resid $_if , detail
				
					*local skew=r(skewness)
					matrix x=e(N_g)
					local N=x[1,1]
					testparm i.`iv_1'
						local p1=r(p)
					testparm i.`iv_2'
						local p2=r(p)
					
				if "`estround'" !="" {
					
					if "`or'" == "or"  {
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
					if "`or'" == "or" {
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
					split var, p(.)
					gen p_all=.
						replace p_all=`p1' if var2=="`iv_1'"
						replace p_all=`p2' if var2=="`iv_2'"
					drop var1 var2
					gen pint=`pint'
					tostring p_all pint, force format(%9.4f) replace
						replace p_all = "<.0001" if p_all=="0.0000"
						replace pint = "<.0001" if pint=="0.0000"
					*gen residskew=`skew'
					*tostring residskew, force format(%9.1f) replace
					rename var iv
					gen outcome="`var'"
					gen interaction="`var' = `iv_1' * `iv_2'"
					gen N=`N'
				save `temp', replace
					
				use `output', clear
				append using `temp'
				save `output', replace
		}
		/***CATEGORICAL VS CONTINUOUS INTERACTION***/
		if `num1' <=`cutpoint' & `num2' >`cutpoint' {
		
			if "`weight'" !=""	{
				if "`covariance'" !="" {
					xtmelogit `var' `iv_1'##c.`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time', covariance(`covariance') 
						testparm `iv_1'#c.`iv_2'
							local pint=r(p)
					xtmelogit `var' i.`iv_1' `iv_2' `covars' $_if [`weight' `exp'], ||`id':`time', covariance(`covariance') 
				}
				if "`covariance'" =="" {
					xtmelogit `var' `iv_1'##c.`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time'
						testparm `iv_1'#c.`iv_2'
							local pint=r(p)
					xtmelogit `var' i.`iv_1' `iv_2' `covars' $_if [`weight' `exp'], ||`id':`time'
				}				
			}
			else	{
				if "`covariance'" !="" {
					xtmelogit `var' `iv_1'##c.`iv_2' `covars' $_if , ||`id':`time', covariance(`covariance')
						testparm `iv_1'#c.`iv_2'
							local pint=r(p)
					xtmelogit `var' i.`iv_1' `iv_2' `covars' $_if , ||`id':`time', covariance(`covariance') 
				}
				if "`covariance'" =="" {
					xtmelogit `var' `iv_1'##c.`iv_2' `covars' $_if , ||`id':`time'
						testparm `iv_1'#c.`iv_2'
							local pint=r(p)
					xtmelogit `var' i.`iv_1' `iv_2' `covars' $_if , ||`id':`time'
				}
			}
					*capture drop resid
					*predict resid if e(sample), pearson
					*sum resid $_if , detail
				
					*local skew=r(skewness)
					matrix x=e(N_g)
					local N=x[1,1]
					testparm i.`iv_1'
						local p1=r(p)
					testparm `iv_2'
						local p2=r(p)
					
				if "`estround'" !="" {
					
					if "`or'" == "or" {
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
					if "`or'" == "or" {
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
					split var, p(.)
					gen p_all=.
						replace p_all=`p1' if var2=="`iv_1'"
						replace p_all=`p2' if var=="`iv_2'"
					drop var1 var2
					gen pint=`pint'
					tostring p_all pint, force format(%9.4f) replace
						replace p_all = "<.0001" if p_all=="0.0000"
						replace pint = "<.0001" if pint=="0.0000"
					*gen residskew=`skew'
					*tostring residskew, force format(%9.1f) replace
					rename var iv
					gen outcome="`var'"
					gen interaction="`var' = `iv_1' * `iv_2'"
					gen N=`N'
				save `temp', replace
					
				use `output', clear
				append using `temp'
				save `output', replace
		}
		/***CONTINUOUS VS CATEGORICAL INTERACTION***/
		if `num1' > `cutpoint' & `num2' <=`cutpoint' {
		
			if "`weight'" !=""	{
				if "`covariance'" !="" {
					xtmelogit `var' `iv_2'##c.`iv_1' `covars' $_if [`weight' `exp'], ||`id':`time', covariance(`covariance') 
						testparm `iv_2'#c.`iv_1'
							local pint=r(p)
					xtmelogit `var'  `iv_1' i.`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time', covariance(`covariance') 
				}
				if "`covariance'" =="" {
					xtmelogit `var' `iv_2'##c.`iv_1' `covars' $_if [`weight' `exp'], ||`id':`time'
						testparm `iv_2'#c.`iv_1'
							local pint=r(p)
					xtmelogit `var'  `iv_1' i.`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time'
				}
			}
			else	{
				if "`covariance'" !="" {
					xtmelogit `var' `iv_2'##c.`iv_1' `covars' $_if , ||`id':`time', covariance(`covariance') 
						testparm `iv_2'#c.`iv_1'
							local pint=r(p)
					xtmelogit `var' `iv_1' i.`iv_2'  `covars' $_if , ||`id':`time', covariance(`covariance')
				}
				if "`covariance'" =="" {
					xtmelogit `var' `iv_2'##c.`iv_1' `covars' $_if , ||`id':`time'
						testparm `iv_2'#c.`iv_1'
							local pint=r(p)
					xtmelogit `var' `iv_1' i.`iv_2'  `covars' $_if , ||`id':`time'
				}
			}
					*capture drop resid
					*predict resid if e(sample), pearson
					*sum resid $_if , detail
				
					*local skew=r(skewness)
					matrix x=e(N_g)
					local N=x[1,1]
					testparm `iv_1'
						local p1=r(p)
					testparm i.`iv_2'
						local p2=r(p)
					
				if "`estround'" !="" {
					
					if "`or'" == "or" {
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
					if "`or'" == "or" {
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
					split var, p(.)
					gen p_all=.
						replace p_all=`p1' if var=="`iv_1'"
						replace p_all=`p2' if var2=="`iv_2'"
					drop var1 var2
					gen pint=`pint'
					tostring p_all pint, force format(%9.4f) replace
						replace p_all = "<.0001" if p_all=="0.0000"
						replace pint = "<.0001" if pint=="0.0000"
					*gen residskew=`skew'
					*tostring residskew, force format(%9.1f) replace
					rename var iv
					gen outcome="`var'"
					gen interaction="`var' = `iv_1' * `iv_2'"
					gen N=`N'
				save `temp', replace
					
				use `output', clear
				append using `temp'
				save `output', replace
		}
		/***CONTINUOUS VS CONTINUOUS INTERACTION***/
		if `num1' > `cutpoint' & `num2' >`cutpoint' {
		
			if "`weight'" !=""	{
				if "`covariance'" !="" {
					xtmelogit `var' c.`iv_1'##c.`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time', covariance(`covariance')
						testparm c.`iv_1'#c.`iv_2'
							local pint=r(p)
					xtmelogit `var' `iv_1' `iv_2' `covars' $_if [`weight' `exp'], ||`id':`time', covariance(`covariance') 
				}
				if "`covariance'" =="" {
					xtmelogit `var' c.`iv_1'##c.`iv_2' `covars' $_if [`weight' `exp'], ||`id':`time'
						testparm c.`iv_1'#c.`iv_2'
							local pint=r(p)
					xtmelogit `var' `iv_1' `iv_2' `covars' $_if [`weight' `exp'], ||`id':`time'
				}	
			}
			else	{
				if "`covariance'" !="" {
					xtmelogit `var' c.`iv_1'##c.`iv_2' `covars' $_if , ||`id':`time', covariance(`covariance')
						testparm c.`iv_1'#c.`iv_2'
							local pint=r(p)
					xtmelogit `var' `iv_1' `iv_2' `covars' $_if , ||`id':`time', covariance(`covariance')
				}
				if "`covariance'" =="" {
					xtmelogit `var' c.`iv_1'##c.`iv_2' `covars' $_if , ||`id':`time'
						testparm c.`iv_1'#c.`iv_2'
							local pint=r(p)
					xtmelogit `var' `iv_1' `iv_2' `covars' $_if , ||`id':`time'
				}
			}
					*capture drop resid
					*predict resid if e(sample), pearson
					*sum resid $_if , detail
				
					*local skew=r(skewness)
					matrix x=e(N_g)
					local N=x[1,1]
					testparm `iv_1'
						local p1=r(p)
					testparm `iv_2'
						local p2=r(p)
					
				if "`estround'" !="" {
					
					if "`or'" == "or"  {
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
					if "`or'" == "or"  {
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
					*split var, p(.)
					gen p_all=.
						replace p_all=`p1' if var=="`iv_1'"
						replace p_all=`p2' if var=="`iv_2'"
					*drop var1 var2
					gen pint=`pint'
					tostring p_all pint, force format(%9.4f) replace
						replace p_all = "<.0001" if p_all=="0.0000"
						replace pint = "<.0001" if pint=="0.0000"
					*gen residskew=`skew'
					*tostring residskew, force format(%9.1f) replace
					rename var iv
					gen outcome="`var'"
					gen interaction="`var' = `iv_1' * `iv_2'"
					gen N=`N'
				save `temp', replace
					
				use `output', clear
				append using `temp'
				save `output', replace
		}
		
	}
}
}
*

use `output', clear

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
label var pint "P Value for Interaction"

if "`star'" !="" {
	destring p, replace
			gen star="†" if p <=0.10
			replace star="*" if p<=0.05
			replace star="**" if p<=0.01
			replace star="***" if p<=0.001
	replace est=star+est
	drop star
	drop p
	
	destring p_all, replace
		gen star="†" if p_all <=0.10
		replace star="*" if p_all<=0.05
		replace star="**" if p_all<=0.01
		replace star="***" if p_all<=0.001
	rename star star_all
	drop p_all
	
	destring pint, replace
		gen star="†" if pint <=0.10
		replace star="*" if pint<=0.05
		replace star="**" if pint<=0.01
		replace star="***" if pint<=0.001
	rename star starint
	drop pint
	
	label var star_all "Omnibus P Value for Categorical IV's"
	label var starint "P Value for Interaction"
	
	order outcome iv interaction N est star_all starint 
}
else {
	order outcome iv interaction N est p p_all pint
}
capture {
	split iv, p(.)
	drop if iv1=="o"
	drop iv1 iv2
}
capture drop iv1 
capture drop iv2


if "`star'"=="" {
		if "`full'"=="" {
				keep outcome interaction pint 
					duplicates drop
		}
		else {
		}
}

if "`star'"!="" {
		if "`full'"=="" {
				keep outcome interaction starint 
					duplicates drop
		}
		else {
		}
}


}
*
end
exit
