program define glmint
syntax varlist [if] [pweight]  [, iv1(varlist) iv2(varlist) covars(string) fam(name) link(name) error(name) star cat(numlist max=1 integer) estround(numlist max=1 integer)  iterate(numlist max=1 integer) full vce(string)]
*Version 3.3 Created on 05/26/2011-Code completely rewritten.
*added Full option version 3.5
*added Iterate option version 3.6
*Version 4.0 12/24/2011-Replaced "results" command with "resout"
*Version 4.1 04/05/2012-Allows i. in covars list
*Version 4.2 05/11/2012: added VCE option
qui {
tempfile faketemp output temp
save `faketemp', replace 


clear
set more off
set obs 1 
gen outcome=""
gen N=.
save `output', replace 

if "`iterate'"=="" {
	local itnum=500
}
if "`iterate'"!="" {
	local itnum=`iterate'
}


use `faketemp', clear
foreach var of varlist `varlist' {
/****RUN FROM IV1 to IV2*****/
use `faketemp', clear
foreach iv_1 in `iv1' {
use `faketemp', clear
foreach iv_2 in `iv2' {
	use `faketemp', clear
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
		if "`vce'"!="" {
			local vcetype `vce'
		}
		if "`vce'"=="" & "`weight'"=="" {
			local vcetype oim
		}
		if "`vce'"=="" & "`weight'"!="" {
			local vcetype robust
		}
		
		/***CATEGORICAL VS CATEGORICAL INTERACTION***/
		if `num1' <=`cutpoint' & `num2' <=`cutpoint' {
		
			if "`weight'" !=""	{
				glm `var' `iv_1'##`iv_2' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
					testparm `iv_1'#`iv_2'
						local pint=r(p)
				glm `var' i.`iv_1' i.`iv_2' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
			else	{
				glm `var' `iv_1'##`iv_2' `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
					testparm `iv_1'#`iv_2'
						local pint=r(p)
				glm `var' i.`iv_1' i.`iv_2' `covars' $_if , family(`fam') link(`link')   iterate(`itnum') vce(`vcetype')
			}
					capture drop resid
					predict resid if e(sample), pearson
					sum resid $_if , detail
				
					local skew=r(skewness)
					local N=r(N)
					testparm i.`iv_1'
						local p1=r(p)
					testparm i.`iv_2'
						local p2=r(p)
					
				if "`estround'" !="" {
					
					if "`link'" == "log" | "`link'" == "logit" {
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
					if "`link'" == "log" | "`link'" == "logit" {
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
					
					gen residskew=`skew'
					tostring residskew, force format(%9.1f) replace
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
				glm `var' `iv_1'##c.`iv_2' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
					testparm `iv_1'#c.`iv_2'
						local pint=r(p)
				glm `var' i.`iv_1' `iv_2' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
			else	{
				glm `var' `iv_1'##c.`iv_2' `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
					testparm `iv_1'#c.`iv_2'
						local pint=r(p)
				glm `var' i.`iv_1' `iv_2' `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
					capture drop resid
					predict resid if e(sample), pearson
					sum resid $_if , detail
				
					local skew=r(skewness)
					local N=r(N)
					testparm i.`iv_1'
						local p1=r(p)
					testparm `iv_2'
						local p2=r(p)
					
				if "`estround'" !="" {
					
					if "`link'" == "log" | "`link'" == "logit" {
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
					if "`link'" == "log" | "`link'" == "logit" {
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
					gen residskew=`skew'
					tostring residskew, force format(%9.1f) replace
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
				glm `var' `iv_2'##c.`iv_1' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
					testparm `iv_2'#c.`iv_1'
						local pint=r(p)
				glm `var'  `iv_1' i.`iv_2' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
			else	{
				glm `var' `iv_2'##c.`iv_1' `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
					testparm `iv_2'#c.`iv_1'
						local pint=r(p)
				glm `var' `iv_1' i.`iv_2'  `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
					capture drop resid
					predict resid if e(sample), pearson
					sum resid $_if , detail
				
					local skew=r(skewness)
					local N=r(N)
					testparm `iv_1'
						local p1=r(p)
					testparm i.`iv_2'
						local p2=r(p)
					
				if "`estround'" !="" {
					
					if "`link'" == "log" | "`link'" == "logit" {
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
					if "`link'" == "log" | "`link'" == "logit" {
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
					gen residskew=`skew'
					tostring residskew, force format(%9.1f) replace
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
				glm `var' c.`iv_1'##c.`iv_2' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
					testparm c.`iv_1'#c.`iv_2'
						local pint=r(p)
				glm `var' `iv_1' `iv_2' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
			else	{
				glm `var' c.`iv_1'##c.`iv_2' `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
					testparm c.`iv_1'#c.`iv_2'
						local pint=r(p)
				glm `var' `iv_1' `iv_2' `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
					capture drop resid
					predict resid if e(sample), pearson
					sum resid $_if , detail
				
					local skew=r(skewness)
					local N=r(N)
					testparm `iv_1'
						local p1=r(p)
					testparm `iv_2'
						local p2=r(p)
					
				if "`estround'" !="" {
					
					if "`link'" == "log" | "`link'" == "logit" {
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
					if "`link'" == "log" | "`link'" == "logit" {
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
					gen residskew=`skew'
					tostring residskew, force format(%9.1f) replace
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
label var residskew "Skewness of Residuals"
label var est "Estimate"
label var p "P Value for IV"
label var p_all "Omnibus P Value for Categorical IV's"
label var pint "P Value for Interaction"

if "`star'" !="" {
	replace p="0.0000" if p=="<.0001"
	destring p, replace
			gen star="†" if p <=0.10
			replace star="*" if p<=0.05
			replace star="**" if p<=0.01
			replace star="***" if p<=0.001
	replace est=star+est
	drop star
	drop p
	replace p_all="0.0000" if p_all=="<.0001"
	destring p_all, replace
		gen star="†" if p_all <=0.10
		replace star="*" if p_all<=0.05
		replace star="**" if p_all<=0.01
		replace star="***" if p_all<=0.001
	rename star star_all
	drop p_all
	
	replace pint="0.0000" if pint=="<.0001"
	destring pint, replace
		gen star="†" if pint <=0.10
		replace star="*" if pint<=0.05
		replace star="**" if pint<=0.01
		replace star="***" if pint<=0.001
	rename star starint
	drop pint
	
	label var star_all "Omnibus P Value for Categorical IV's"
	label var starint "P Value for Interaction"
	
	order outcome iv interaction N est star_all starint residskew
}
else {
	order outcome iv interaction N est p p_all pint residskew
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
				keep outcome interaction pint residskew
					duplicates drop
		}
		else {
		}
}

if "`star'"!="" {
		if "`full'"=="" {
				keep outcome interaction starint residskew
					duplicates drop
		}
		else {
		}
}

}
*
end
exit

/*Code prior to 05/26/2011 Below
qui {
*preserve
save faketemp.dta, replace
	
	
clear
set more off
set obs 1
gen var=""
save output.dta, replace


use faketemp.dta, clear
foreach iv1 in `iv1' {
	foreach iv2 in `iv2' {
	use faketemp.dta, clear
	tab `iv1'
		local num1=r(r)
	sum `iv1'
		local f1=r(min)+1 
		local f2=r(min)+2
		local f3=r(min)+3
		local f4=r(min)+4
	
	tab `iv2'
		local num2=r(r)
	sum `iv2'
		local s1=r(min)+1 
		local s2=r(min)+2
		local s3=r(min)+3
		local s4=r(min)+4
		
		foreach var of varlist `varlist' {		
		
		use faketemp.dta, clear
		
		
		/***Continuous (IV1) vs Integer  (IV2)***/
			if `num1' > 5 & `num2' <=5 {
			
						if `num2'==2 {
							glm `var' c.`iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
								test c.`iv1'#`s1'.`iv2'
								local p=r(p)
							glm `var' c.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
								test `iv1'
								local iv1p=r(p)
								test `s1'.`iv2'
								local iv2p1=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1 =="`iv1'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv2p1' if var=="`s1'.`iv2'"
							replace pvar=`iv1p' if var=="`iv1'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1 =="`iv1'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}

					if `num2'==3 {
							glm `var' c.`iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
								test c.`iv1'#`s1'.`iv2' c.`iv1'#`s2'.`iv2'
								local p=r(p)
							glm `var' c.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
								test `iv1'
								local iv1p=r(p)
								test `s1'.`iv2'
								local iv2p1=r(p)
								test `s2'.`iv2'
								local iv2p2=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1 =="`iv1'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv2p1' if var=="`s1'.`iv2'"
							replace pvar=`iv2p2' if var=="`s2'.`iv2'"
							replace pvar=`iv1p' if var=="`iv1'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1 =="`iv1'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
	
	
					if `num2'==4 {
							glm `var' c.`iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
								test c.`iv1'#`s1'.`iv2' c.`iv1'#`s2'.`iv2' c.`iv1'#`s3'.`iv2'
								local p=r(p)
							glm `var' c.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
								test `iv1'
								local iv1p=r(p)
								test `s1'.`iv2'
								local iv2p1=r(p)
								test `s2'.`iv2'
								local iv2p2=r(p)
								test `s3'.`iv2'
								local iv2p3=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1 =="`iv1'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv2p1' if var=="`s1'.`iv2'"
							replace pvar=`iv2p2' if var=="`s2'.`iv2'"
							replace pvar=`iv2p3' if var=="`s3'.`iv2'"
							replace pvar=`iv1p' if var=="`iv1'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1 =="`iv1'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
	
					if `num2'==5 {
							glm `var' c.`iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
								test c.`iv1'#`s1'.`iv2' c.`iv1'#`s2'.`iv2' c.`iv1'#`s3'.`iv2' c.`iv1'#`s4'.`iv2'
								local p=r(p)
							glm `var' c.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
								test `iv1'
								local iv1p=r(p)
								test `s1'.`iv2'
								local iv2p1=r(p)
								test `s2'.`iv2'
								local iv2p2=r(p)
								test `s3'.`iv2'
								local iv2p3=r(p)
								test `s4'.`iv2'
								local iv2p4=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`s4'.`iv2'" | v1 =="`iv1'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv2p1' if var=="`s1'.`iv2'"
							replace pvar=`iv2p2' if var=="`s2'.`iv2'"
							replace pvar=`iv2p3' if var=="`s3'.`iv2'"
							replace pvar=`iv2p4' if var=="`s4'.`iv2'"
							replace pvar=`iv1p' if var=="`iv1'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`s4'.`iv2'" | v1 =="`iv1'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
				}
				
				
				
		/***Integer (iv1) vs Continuous(iv2)***/
		if `num1' <= 5 & `num2' > 5 {
			
						if `num1'==2 {
							glm `var' c.`iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
								test c.`iv2'#`f1'.`iv1'
								local p=r(p)
							glm `var' c.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
								test `iv2'
								local iv2p=r(p)
								test `f1'.`iv1'
								local iv1p1=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1 =="`iv2'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv1p1' if var=="`f1'.`iv1'"
							replace pvar=`iv2p' if var=="`iv2'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1 =="`iv2'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}

					if `num1'==3 {
							glm `var' c.`iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
								test c.`iv2'#`f1'.`iv1' c.`iv2'#`f2'.`iv1'
								local p=r(p)
							glm `var' c.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
								test `iv2'
								local iv2p=r(p)
								test `f1'.`iv1'
								local iv1p1=r(p)
								test `f2'.`iv1'
								local iv1p2=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1 =="`iv2'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv1p1' if var=="`f1'.`iv1'"
							replace pvar=`iv1p2' if var=="`f2'.`iv1'"
							replace pvar=`iv2p' if var=="`iv2'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1 =="`iv2'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
	
	
					if `num1'==4 {
							glm `var' c.`iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
								test c.`iv2'#`f1'.`iv1' c.`iv2'#`f2'.`iv1' c.`iv2'#`f3'.`iv1'
								local p=r(p)
							glm `var' c.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
								test `iv2'
								local iv2p=r(p)
								test `f1'.`iv1'
								local iv1p1=r(p)
								test `f2'.`iv1'
								local iv1p2=r(p)
								test `f3'.`iv1'
								local iv1p3=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1 =="`iv2'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv1p1' if var=="`f1'.`iv1'"
							replace pvar=`iv1p2' if var=="`f2'.`iv1'"
							replace pvar=`iv1p3' if var=="`f3'.`iv1'"
							replace pvar=`iv2p' if var=="`iv2'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1 =="`iv2'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
	
					if `num1'==5 {
							glm `var' c.`iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
								test c.`iv2'#`f1'.`iv1' c.`iv2'#`f2'.`iv1' c.`iv2'#`f3'.`iv1' c.`iv2'#`f4'.`iv1'
								local p=r(p)
							glm `var' c.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
								test `iv2'
								local iv2p=r(p)
								test `f1'.`iv1'
								local iv1p1=r(p)
								test `f2'.`iv1'
								local iv1p2=r(p)
								test `f3'.`iv1'
								local iv1p3=r(p)
								test `f4'.`iv1'
								local iv1p4=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`f4'.`iv1'" | v1 =="`iv2'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv1p1' if var=="`f1'.`iv1'"
							replace pvar=`iv1p2' if var=="`f2'.`iv1'"
							replace pvar=`iv1p3' if var=="`f3'.`iv1'"
							replace pvar=`iv1p4' if var=="`f4'.`iv1'"
							replace pvar=`iv2p' if var=="`iv2'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`f4'.`iv1'" | v1 =="`iv2'" 
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
				}

				
	/***Continuous (iv1) vs Continuous(iv2)***/
		if `num1' > 5 & `num2' > 5 {
			
							glm `var' c.`iv2'##c.`iv1' `covars' $_if , family(`fam') link(`link') eform
								test `iv2'#`iv1'
								local p=r(p)
							glm `var' `iv2' `iv1' `covars' $_if , family(`fam') link(`link') eform	
								test `iv2'
								local iv2p=r(p)
								test `iv1'
								local iv1p=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`iv1'" | v1 =="`iv2'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv1p' if var=="`iv1'"
							replace pvar=`iv2p' if var=="`iv2'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`iv1'" | v1 =="`iv2'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
							local est1=est1
							if `est1' >=1000 {
							tostring est1 ci*, force format(%9.0fc) replace
							}
							if `est1' >=10 & `est1' <1000 {
							tostring est1 ci*, force format(%9.1f) replace
							}
							if `est1' <10 {
							tostring est1 ci*, force format(%9.2f) replace
							}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
			
				
	
	
	
	/****Integer (iv1) vs Integer (iv2)****/
		if `num1' <= 5 & `num2' <=5 {
			
						if `num2'==2 & `num1'==2 {
									glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
										test `f1'.`iv1'#`s1'.`iv2'
										local p=r(p)
									glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
										test `f1'.`iv1'
										local iv1p1=r(p)
										test `s1'.`iv2'
										local iv2p1=r(p)
										
										estout using temp.txt, cells(b ci) replace eform
										estout using temp1.txt, cells(b ci) replace 
								
									/***Exponentiated Coef*/
								insheet using temp.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`s1'.`iv2'" | v1 =="`f1'.`iv1'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									gen pvar=.
									gen pint=.
									replace pvar=`iv2p1' if var=="`s1'.`iv2'"
									replace pvar=`iv1p1' if var=="`f1'.`iv1'"
									replace pint=`p'
									tostring p*, force format(%9.4f) replace
									rename est expB
								save temp.dta, replace
								
										/***Reg Coef*/
									insheet using temp1.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`s1'.`iv2'" | v1 =="`f1'.`iv1'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									rename est B
								save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}

					
					if `num2'==2 & `num1'==3 {
									glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
										test `f1'.`iv1'#`s1'.`iv2' `f2'.`iv1'#`s1'.`iv2'
										local p=r(p)
									glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
										test `f1'.`iv1'
										local iv1p1=r(p)
										
										test `f2'.`iv1'
										local iv1p2=r(p)
										
										test `s1'.`iv2'
										local iv2p1=r(p)
										
										estout using temp.txt, cells(b ci) replace eform
										estout using temp1.txt, cells(b ci) replace 
								
									/***Exponentiated Coef*/
								insheet using temp.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`s1'.`iv2'" | v1 =="`f1'.`iv1'" |  v1 =="`f2'.`iv1'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									gen pvar=.
									gen pint=.
									replace pvar=`iv2p1' if var=="`s1'.`iv2'"
									replace pvar=`iv1p1' if var=="`f1'.`iv1'"
									replace pvar=`iv1p2' if var=="`f2'.`iv1'"
									replace pint=`p'
									tostring p*, force format(%9.4f) replace
									rename est expB
								save temp.dta, replace
								
										/***Reg Coef*/
									insheet using temp1.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`s1'.`iv2'" | v1 =="`f1'.`iv1'" |  v1 =="`f2'.`iv1'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									rename est B
								save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
					
						if `num2'==2 & `num1'==4 {
									glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
										test `f1'.`iv1'#`s1'.`iv2' `f2'.`iv1'#`s1'.`iv2' `f3'.`iv1'#`s1'.`iv2'
										local p=r(p)
									glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
										test `f1'.`iv1'
										local iv1p1=r(p)
										
										test `f2'.`iv1'
										local iv1p2=r(p)
										
										test `f3'.`iv1'
										local iv1p3=r(p)
										
										test `s1'.`iv2'
										local iv2p1=r(p)
										
										estout using temp.txt, cells(b ci) replace eform
										estout using temp1.txt, cells(b ci) replace 
								
									/***Exponentiated Coef*/
								insheet using temp.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`s1'.`iv2'" | v1 =="`f1'.`iv1'" |  v1 =="`f2'.`iv1'" |  v1 =="`f3'.`iv1'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}

									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									gen pvar=.
									gen pint=.
									replace pvar=`iv2p1' if var=="`s1'.`iv2'"
									replace pvar=`iv1p1' if var=="`f1'.`iv1'"
									replace pvar=`iv1p2' if var=="`f2'.`iv1'"
									replace pvar=`iv1p3' if var=="`f3'.`iv1'"
									replace pint=`p'
									tostring p*, force format(%9.4f) replace
									rename est expB
								save temp.dta, replace
								
										/***Reg Coef*/
									insheet using temp1.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`s1'.`iv2'" | v1 =="`f1'.`iv1'" |  v1 =="`f2'.`iv1'" |  v1 =="`f3'.`iv1'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}

									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									rename est B
								save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
					
					
					if `num2'==2 & `num1'==5 {
									glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
										test `f1'.`iv1'#`s1'.`iv2' `f2'.`iv1'#`s1'.`iv2' `f3'.`iv1'#`s1'.`iv2' `f4'.`iv1'#`s1'.`iv2'
										local p=r(p)
									glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
										test `f1'.`iv1'
										local iv1p1=r(p)
										
										test `f2'.`iv1'
										local iv1p2=r(p)
										
										test `f3'.`iv1'
										local iv1p3=r(p)
										
										test `f4'.`iv1'
										local iv1p4=r(p)
										
										test `s1'.`iv2'
										local iv2p1=r(p)
										
										estout using temp.txt, cells(b ci) replace eform
										estout using temp1.txt, cells(b ci) replace 
								
									/***Exponentiated Coef*/
								insheet using temp.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`s1'.`iv2'" | v1 =="`f1'.`iv1'" |  v1 =="`f2'.`iv1'" |  v1 =="`f3'.`iv1'"  |  v1 =="`f4'.`iv1'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}

									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									gen pvar=.
									gen pint=.
									replace pvar=`iv2p1' if var=="`s1'.`iv2'"
									replace pvar=`iv1p1' if var=="`f1'.`iv1'"
									replace pvar=`iv1p2' if var=="`f2'.`iv1'"
									replace pvar=`iv1p3' if var=="`f3'.`iv1'"
									replace pvar=`iv1p4' if var=="`f4'.`iv1'"
									replace pint=`p'
									tostring p*, force format(%9.4f) replace
									rename est expB
								save temp.dta, replace
								
										/***Reg Coef*/
									insheet using temp1.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`s1'.`iv2'" | v1 =="`f1'.`iv1'" |  v1 =="`f2'.`iv1'" |  v1 =="`f3'.`iv1'"  |  v1 =="`f4'.`iv1'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}

									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									rename est B
								save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
					
					
					if `num2'==3 & `num1'==3 {
							glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
								test `f1'.`iv1'#`s1'.`iv2' `f1'.`iv1'#`s2'.`iv2' `f2'.`iv1'#`s1'.`iv2' `f2'.`iv1'#`s2'.`iv2'
								local p=r(p)
							glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
								
								test `f1'.`iv1'
								local iv1p1=r(p)
								
								test `f2'.`iv1'
								local iv1p2=r(p)
								
								test `s1'.`iv2'
								local iv2p1=r(p)
								
								test `s2'.`iv2'
								local iv2p2=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}

							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv2p1' if var=="`s1'.`iv2'"
							replace pvar=`iv2p2' if var=="`s2'.`iv2'"
							replace pvar=`iv1p1' if var=="`f1'.`iv1'"
							replace pvar=`iv1p2' if var=="`f2'.`iv1'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
	
			if `num2'==3 & `num1'==4 {
							glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
								test `f1'.`iv1'#`s1'.`iv2' `f1'.`iv1'#`s2'.`iv2' `f2'.`iv1'#`s1'.`iv2' `f2'.`iv1'#`s2'.`iv2' `f3'.`iv1'#`s1'.`iv2' `f3'.`iv1'#`s2'.`iv2'
								local p=r(p)
							glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
								
								test `f1'.`iv1'
								local iv1p1=r(p)
								
								test `f2'.`iv1'
								local iv1p2=r(p)
								
								test `f3'.`iv1'
								local iv1p3=r(p)
								
								test `s1'.`iv2'
								local iv2p1=r(p)
								
								test `s2'.`iv2'
								local iv2p2=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv2p1' if var=="`s1'.`iv2'"
							replace pvar=`iv2p2' if var=="`s2'.`iv2'"
							replace pvar=`iv1p1' if var=="`f1'.`iv1'"
							replace pvar=`iv1p2' if var=="`f2'.`iv1'"
							replace pvar=`iv1p3' if var=="`f3'.`iv1'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
	
	
						if `num2'==3 & `num1'==5 {
								glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
									test `f1'.`iv1'#`s1'.`iv2' `f1'.`iv1'#`s2'.`iv2' `f2'.`iv1'#`s1'.`iv2' `f2'.`iv1'#`s2'.`iv2' `f3'.`iv1'#`s1'.`iv2' `f3'.`iv1'#`s2'.`iv2' `f4'.`iv1'#`s1'.`iv2' `f4'.`iv1'#`s2'.`iv2'
									local p=r(p)
								glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
									
									test `f1'.`iv1'
									local iv1p1=r(p)
									
									test `f2'.`iv1'
									local iv1p2=r(p)
									
									test `f3'.`iv1'
									local iv1p3=r(p)
									
									test `f4'.`iv1'
									local iv1p4=r(p)
									
									test `s1'.`iv2'
									local iv2p1=r(p)
									
									test `s2'.`iv2'
									local iv2p2=r(p)
									
									estout using temp.txt, cells(b ci) replace eform
									estout using temp1.txt, cells(b ci) replace 
							
								/***Exponentiated Coef*/
							insheet using temp1.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`f4'.`iv1'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								gen pvar=.
								gen pint=.
								replace pvar=`iv2p1' if var=="`s1'.`iv2'"
								replace pvar=`iv2p2' if var=="`s2'.`iv2'"
								replace pvar=`iv1p1' if var=="`f1'.`iv1'"
								replace pvar=`iv1p2' if var=="`f2'.`iv1'"
								replace pvar=`iv1p3' if var=="`f3'.`iv1'"
								replace pvar=`iv1p4' if var=="`f4'.`iv1'"
								replace pint=`p'
								tostring p*, force format(%9.4f) replace
								rename est expB
							save temp.dta, replace
							
									/***Reg Coef*/
								insheet using temp.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`f4'.`iv1'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								rename est B
							save temp1.dta, replace
							
							use temp.dta, clear
							joinby var outcome using temp1.dta, unmatched(none)
							gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
							use output.dta, clear
							append using temp.dta
							save output.dta, replace
						}
						
						
						if `num2'==4 & `num1'==5 {
								glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
									test `f1'.`iv1'#`s1'.`iv2' `f1'.`iv1'#`s2'.`iv2'  `f1'.`iv1'#`s3'.`iv2'   `f2'.`iv1'#`s1'.`iv2' `f2'.`iv1'#`s2'.`iv2' `f2'.`iv1'#`s3'.`iv2' `f3'.`iv1'#`s1'.`iv2' `f3'.`iv1'#`s2'.`iv2' `f3'.`iv1'#`s3'.`iv2'  `f4'.`iv1'#`s1'.`iv2' `f4'.`iv1'#`s2'.`iv2'  `f4'.`iv1'#`s3'.`iv2'
									local p=r(p)
								glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
									
									test `f1'.`iv1'
									local iv1p1=r(p)
									
									test `f2'.`iv1'
									local iv1p2=r(p)
									
									test `f3'.`iv1'
									local iv1p3=r(p)
									
									test `f4'.`iv1'
									local iv1p4=r(p)
									
									test `s1'.`iv2'
									local iv2p1=r(p)
									
									test `s2'.`iv2'
									local iv2p2=r(p)
									
									test `s3'.`iv2'
									local iv2p3=r(p)
									
									estout using temp.txt, cells(b ci) replace eform
									estout using temp1.txt, cells(b ci) replace 
							
								/***Exponentiated Coef*/
							insheet using temp.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`f4'.`iv1'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								gen pvar=.
								gen pint=.
								replace pvar=`iv2p1' if var=="`s1'.`iv2'"
								replace pvar=`iv2p2' if var=="`s2'.`iv2'"
								replace pvar=`iv2p3' if var=="`s3'.`iv2'"
								replace pvar=`iv1p1' if var=="`f1'.`iv1'"
								replace pvar=`iv1p2' if var=="`f2'.`iv1'"
								replace pvar=`iv1p3' if var=="`f3'.`iv1'"
								replace pvar=`iv1p4' if var=="`f4'.`iv1'"
								replace pint=`p'
								tostring p*, force format(%9.4f) replace
								rename est expB
							save temp.dta, replace
							
									/***Reg Coef*/
								insheet using temp1.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`f4'.`iv1'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								rename est B
							save temp1.dta, replace
							
							use temp.dta, clear
							joinby var outcome using temp1.dta, unmatched(none)
							gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
							use output.dta, clear
							append using temp.dta
							save output.dta, replace
						}

						if `num2'==5 & `num1'==5 {
								glm `var' `iv1'##`iv2' `covars' $_if , family(`fam') link(`link') eform
									test `f1'.`iv1'#`s1'.`iv2' `f1'.`iv1'#`s2'.`iv2'  `f1'.`iv1'#`s3'.`iv2' `f1'.`iv1'#`s4'.`iv2' `f2'.`iv1'#`s1'.`iv2' `f2'.`iv1'#`s2'.`iv2' `f2'.`iv1'#`s3'.`iv2' `f2'.`iv1'#`s4'.`iv2' `f3'.`iv1'#`s1'.`iv2' `f3'.`iv1'#`s2'.`iv2' `f3'.`iv1'#`s3'.`iv2' `f3'.`iv1'#`s4'.`iv2' `f4'.`iv1'#`s1'.`iv2' `f4'.`iv1'#`s2'.`iv2'  `f4'.`iv1'#`s3'.`iv2' `f4'.`iv1'#`s4'.`iv2'
									local p=r(p)
								glm `var' i.`iv1' i.`iv2' `covars' $_if , family(`fam') link(`link') eform	
									
									test `f1'.`iv1'
									local iv1p1=r(p)
									
									test `f2'.`iv1'
									local iv1p2=r(p)
									
									test `f3'.`iv1'
									local iv1p3=r(p)
									
									test `f4'.`iv1'
									local iv1p4=r(p)
									
									test `s1'.`iv2'
									local iv2p1=r(p)
									
									test `s2'.`iv2'
									local iv2p2=r(p)
									
									test `s3'.`iv2'
									local iv2p3=r(p)
									
									test `s4'.`iv2'
									local iv2p3=r(p)
									
									estout using temp.txt, cells(b ci) replace eform
									estout using temp1.txt, cells(b ci) replace 
							
								/***Exponentiated Coef*/
							insheet using temp.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`s4'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`f4'.`iv1'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								gen pvar=.
								gen pint=.
								replace pvar=`iv2p1' if var=="`s1'.`iv2'"
								replace pvar=`iv2p2' if var=="`s2'.`iv2'"
								replace pvar=`iv2p3' if var=="`s3'.`iv2'"
								replace pvar=`iv1p1' if var=="`f1'.`iv1'"
								replace pvar=`iv1p2' if var=="`f2'.`iv1'"
								replace pvar=`iv1p3' if var=="`f3'.`iv1'"
								replace pvar=`iv1p4' if var=="`f4'.`iv1'"
								replace pint=`p'
								tostring p*, force format(%9.4f) replace
								rename est expB
								save temp.dta, replace
							
									/***Reg Coef*/
								insheet using temp1.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`s4'.`iv2'" | v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`f4'.`iv1'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								rename est B
							save temp1.dta, replace
							
							use temp.dta, clear
							joinby var outcome using temp1.dta, unmatched(none)
							gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
							use output.dta, clear
							append using temp.dta
							save output.dta, replace
						}
					
					
					if `num1'==2 & `num2'==3 {
									glm `var' `iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
										test `s1'.`iv2'#`f1'.`iv1' `s2'.`iv2'#`f1'.`iv1'
										local p=r(p)
									glm `var' i.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
										test `s1'.`iv2'
										local iv2p1=r(p)
										
										test `s2'.`iv2'
										local iv2p2=r(p)
										
										test `f1'.`iv1'
										local iv1p1=r(p)
										
										estout using temp.txt, cells(b ci) replace eform
										estout using temp1.txt, cells(b ci) replace 
								
									/***Exponentiated Coef*/
								insheet using temp.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`f1'.`iv1'" | v1 =="`s1'.`iv2'" |  v1 =="`s2'.`iv2'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									gen pvar=.
									gen pint=.
									replace pvar=`iv1p1' if var=="`f1'.`iv1'"
									replace pvar=`iv2p1' if var=="`s1'.`iv2'"
									replace pvar=`iv2p2' if var=="`s2'.`iv2'"
									replace pint=`p'
									tostring p*, force format(%9.4f) replace
									rename est expB
								save temp.dta, replace
								
										/***Reg Coef*/
									insheet using temp1.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`f1'.`iv1'" | v1 =="`s1'.`iv2'" |  v1 =="`s2'.`iv2'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									rename est B
								save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
					
						if `num1'==2 & `num2'==4 {
									glm `var' `iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
										test `s1'.`iv2'#`f1'.`iv1' `s2'.`iv2'#`f1'.`iv1' `s3'.`iv2'#`f1'.`iv1'
										local p=r(p)
									glm `var' i.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
										test `s1'.`iv2'
										local iv2p1=r(p)
										
										test `s2'.`iv2'
										local iv2p2=r(p)
										
										test `s3'.`iv2'
										local iv2p3=r(p)
										
										test `f1'.`iv1'
										local iv1p1=r(p)
										
										estout using temp.txt, cells(b ci) replace eform
										estout using temp1.txt, cells(b ci) replace 
								
									/***Exponentiated Coef*/
								insheet using temp.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`f1'.`iv1'" | v1 =="`s1'.`iv2'" |  v1 =="`s2'.`iv2'" |  v1 =="`s3'.`iv2'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									gen pvar=.
									gen pint=.
									replace pvar=`iv1p1' if var=="`f1'.`iv1'"
									replace pvar=`iv2p1' if var=="`s1'.`iv2'"
									replace pvar=`iv2p2' if var=="`s2'.`iv2'"
									replace pvar=`iv2p3' if var=="`s3'.`iv2'"
									replace pint=`p'
									tostring p*, force format(%9.4f) replace
									rename est expB
								save temp.dta, replace
								
										/***Reg Coef*/
									insheet using temp1.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`f1'.`iv1'" | v1 =="`s1'.`iv2'" |  v1 =="`s2'.`iv2'" |  v1 =="`s3'.`iv2'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									rename est B
								save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
					
					
					if `num1'==2 & `num2'==5 {
									glm `var' `iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
										test `s1'.`iv2'#`f1'.`iv1' `s2'.`iv2'#`f1'.`iv1' `s3'.`iv2'#`f1'.`iv1' `s4'.`iv2'#`f1'.`iv1'
										local p=r(p)
									glm `var' i.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
										test `s1'.`iv2'
										local iv2p1=r(p)
										
										test `s2'.`iv2'
										local iv2p2=r(p)
										
										test `s3'.`iv2'
										local iv2p3=r(p)
										
										test `s4'.`iv2'
										local iv2p4=r(p)
										
										test `f1'.`iv1'
										local iv1p1=r(p)
										
										estout using temp.txt, cells(b ci) replace eform
										estout using temp1.txt, cells(b ci) replace 
								
									/***Exponentiated Coef*/
								insheet using temp.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`f1'.`iv1'" | v1 =="`s1'.`iv2'" |  v1 =="`s2'.`iv2'" |  v1 =="`s3'.`iv2'"  |  v1 =="`s4'.`iv2'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									gen pvar=.
									gen pint=.
									replace pvar=`iv1p1' if var=="`f1'.`iv1'"
									replace pvar=`iv2p1' if var=="`s1'.`iv2'"
									replace pvar=`iv2p2' if var=="`s2'.`iv2'"
									replace pvar=`iv2p3' if var=="`s3'.`iv2'"
									replace pvar=`iv2p4' if var=="`s4'.`iv2'"
									replace pint=`p'
									tostring p*, force format(%9.4f) replace
									rename est expB
								save temp.dta, replace
								
										/***Reg Coef*/
									insheet using temp1.txt, clear
									drop in 1/3
									gen lag=v1[_n-1]
									replace v1=lag if v1==""
									drop lag
									drop if v1=="_cons"
									keep if v1=="`f1'.`iv1'" | v1 =="`s1'.`iv2'" |  v1 =="`s2'.`iv2'" |  v1 =="`s3'.`iv2'"  |  v1 =="`s4'.`iv2'"
									egen float order = seq(), from(1) to(2) block(1)
									rename v2 est
									reshape wide est, i(v1) j(order)
									split est2, p(,)
									destring est1 est21 est22, replace
									gen cihigh=est22
									gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
									gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
									rename v1 var
									keep var est
									gen outcome="`var'"
									rename est B
								save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
					
			
	
				if `num1'==3 & `num2'==4 {
							glm `var' `iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
								test `s1'.`iv2'#`f1'.`iv1' `s1'.`iv2'#`f2'.`iv1' `s2'.`iv2'#`f1'.`iv1' `s2'.`iv2'#`f2'.`iv1' `s3'.`iv2'#`f1'.`iv1' `s3'.`iv2'#`f2'.`iv1'
								local p=r(p)
							glm `var' i.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
								
								test `s1'.`iv2'
								local iv2p1=r(p)
								
								test `s2'.`iv2'
								local iv2p2=r(p)
								
								test `s3'.`iv2'
								local iv2p3=r(p)
								
								test `f1'.`iv1'
								local iv1p1=r(p)
								
								test `f2'.`iv1'
								local iv1p2=r(p)
								
								estout using temp.txt, cells(b ci) replace eform
								estout using temp1.txt, cells(b ci) replace 
						
							/***Exponentiated Coef*/
						insheet using temp.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							gen pvar=.
							gen pint=.
							replace pvar=`iv1p1' if var=="`f1'.`iv1'"
							replace pvar=`iv1p2' if var=="`f2'.`iv1'"
							replace pvar=`iv2p1' if var=="`s1'.`iv2'"
							replace pvar=`iv2p2' if var=="`s2'.`iv2'"
							replace pvar=`iv2p3' if var=="`s3'.`iv2'"
							replace pint=`p'
							tostring p*, force format(%9.4f) replace
							rename est expB
						save temp.dta, replace
						
								/***Reg Coef*/
							insheet using temp1.txt, clear
							drop in 1/3
							gen lag=v1[_n-1]
							replace v1=lag if v1==""
							drop lag
							drop if v1=="_cons"
							keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'"
							egen float order = seq(), from(1) to(2) block(1)
							rename v2 est
							reshape wide est, i(v1) j(order)
							split est2, p(,)
							destring est1 est21 est22, replace
							gen cihigh=est22
							gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
							gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
							rename v1 var
							keep var est
							gen outcome="`var'"
							rename est B
						save temp1.dta, replace
						
						use temp.dta, clear
						joinby var outcome using temp1.dta, unmatched(none)
						gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
						use output.dta, clear
						append using temp.dta
						save output.dta, replace
					}
	
	
						if `num1'==3 & `num2'==5 {
								glm `var' `iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
									test `s1'.`iv2'#`f1'.`iv1' `s1'.`iv2'#`f2'.`iv1' `s2'.`iv2'#`f1'.`iv1' `s2'.`iv2'#`f2'.`iv1' `s3'.`iv2'#`f1'.`iv1' `s3'.`iv2'#`f2'.`iv1' `s4'.`iv2'#`f1'.`iv1' `s4'.`iv2'#`f2'.`iv1'
									local p=r(p)
								glm `var' i.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
									
									test `s1'.`iv2'
									local iv2p1=r(p)
									
									test `s2'.`iv2'
									local iv2p2=r(p)
									
									test `s3'.`iv2'
									local iv2p3=r(p)
									
									test `s4'.`iv2'
									local iv2p4=r(p)
									
									test `f1'.`iv1'
									local iv1p1=r(p)
									
									test `f2'.`iv1'
									local iv1p2=r(p)
									
									estout using temp.txt, cells(b ci) replace eform
									estout using temp1.txt, cells(b ci) replace 
							
								/***Exponentiated Coef*/
							insheet using temp.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`s4'.`iv2'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								gen pvar=.
								gen pint=.
								replace pvar=`iv1p1' if var=="`f1'.`iv1'"
								replace pvar=`iv1p2' if var=="`f2'.`iv1'"
								replace pvar=`iv2p1' if var=="`s1'.`iv2'"
								replace pvar=`iv2p2' if var=="`s2'.`iv2'"
								replace pvar=`iv2p3' if var=="`s3'.`iv2'"
								replace pvar=`iv2p4' if var=="`s4'.`iv2'"
								replace pint=`p'
								tostring p*, force format(%9.4f) replace
								rename est expB
							save temp.dta, replace
							
									/***Reg Coef*/
								insheet using temp1.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`s4'.`iv2'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								rename est B
							save temp1.dta, replace
							
							use temp.dta, clear
							joinby var outcome using temp1.dta, unmatched(none)
							gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
							use output.dta, clear
							append using temp.dta
							save output.dta, replace
						}
						
						if `num1'==4 & `num2'==4 {
								glm `var' `iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
									test `s1'.`iv2'#`f1'.`iv1' `s1'.`iv2'#`f2'.`iv1'  `s1'.`iv2'#`f3'.`iv1'   `s2'.`iv2'#`f1'.`iv1' `s2'.`iv2'#`f2'.`iv1' `s2'.`iv2'#`f3'.`iv1' `s3'.`iv2'#`f1'.`iv1' `s3'.`iv2'#`f2'.`iv1' `s3'.`iv2'#`f3'.`iv1'  
									local p=r(p)
								glm `var' i.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
									
									test `s1'.`iv2'
									local iv2p1=r(p)
									
									test `s2'.`iv2'
									local iv2p2=r(p)
									
									test `s3'.`iv2'
									local iv2p3=r(p)
														
									test `f1'.`iv1'
									local iv1p1=r(p)
									
									test `f2'.`iv1'
									local iv1p2=r(p)
									
									test `f3'.`iv1'
									local iv1p3=r(p)
									
									estout using temp.txt, cells(b ci) replace eform
									estout using temp1.txt, cells(b ci) replace 
							
								/***Exponentiated Coef*/
							insheet using temp.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" 
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								gen pvar=.
								gen pint=.
								replace pvar=`iv1p1' if var=="`f1'.`iv1'"
								replace pvar=`iv1p2' if var=="`f2'.`iv1'"
								replace pvar=`iv1p3' if var=="`f3'.`iv1'"
								replace pvar=`iv2p1' if var=="`s1'.`iv2'"
								replace pvar=`iv2p2' if var=="`s2'.`iv2'"
								replace pvar=`iv2p3' if var=="`s3'.`iv2'"
								replace pint=`p'
								tostring p*, force format(%9.4f) replace
								rename est expB
							save temp.dta, replace
							
									/***Reg Coef*/
								insheet using temp1.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" 
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								rename est B
							save temp1.dta, replace
							
							use temp.dta, clear
							joinby var outcome using temp1.dta, unmatched(none)
							gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
							use output.dta, clear
							append using temp.dta
							save output.dta, replace
						}

						
						
						
						if `num1'==4 & `num2'==5 {
								glm `var' `iv2'##`iv1' `covars' $_if , family(`fam') link(`link') eform
									test `s1'.`iv2'#`f1'.`iv1' `s1'.`iv2'#`f2'.`iv1'  `s1'.`iv2'#`f3'.`iv1'   `s2'.`iv2'#`f1'.`iv1' `s2'.`iv2'#`f2'.`iv1' `s2'.`iv2'#`f3'.`iv1' `s3'.`iv2'#`f1'.`iv1' `s3'.`iv2'#`f2'.`iv1' `s3'.`iv2'#`f3'.`iv1'  `s4'.`iv2'#`f1'.`iv1' `s4'.`iv2'#`f2'.`iv1'  `s4'.`iv2'#`f3'.`iv1'
									local p=r(p)
								glm `var' i.`iv2' i.`iv1' `covars' $_if , family(`fam') link(`link') eform	
									
									test `s1'.`iv2'
									local iv2p1=r(p)
									
									test `s2'.`iv2'
									local iv2p2=r(p)
									
									test `s3'.`iv2'
									local iv2p3=r(p)
									
									test `s4'.`iv2'
									local iv2p4=r(p)
									
									test `f1'.`iv1'
									local iv1p1=r(p)
									
									test `f2'.`iv1'
									local iv1p2=r(p)
									
									test `f3'.`iv1'
									local iv1p3=r(p)
									
									estout using temp.txt, cells(b ci) replace eform
									estout using temp1.txt, cells(b ci) replace 
							
								/***Exponentiated Coef*/
							insheet using temp.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`s4'.`iv2'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								gen pvar=.
								gen pint=.
								replace pvar=`iv1p1' if var=="`f1'.`iv1'"
								replace pvar=`iv1p2' if var=="`f2'.`iv1'"
								replace pvar=`iv1p3' if var=="`f3'.`iv1'"
								replace pvar=`iv2p1' if var=="`s1'.`iv2'"
								replace pvar=`iv2p2' if var=="`s2'.`iv2'"
								replace pvar=`iv2p3' if var=="`s3'.`iv2'"
								replace pvar=`iv2p4' if var=="`s4'.`iv2'"
								replace pint=`p'
								tostring p*, force format(%9.4f) replace
								rename est expB
							save temp.dta, replace
							
									/***Reg Coef*/
								insheet using temp1.txt, clear
								drop in 1/3
								gen lag=v1[_n-1]
								replace v1=lag if v1==""
								drop lag
								drop if v1=="_cons"
								keep if v1=="`f1'.`iv1'" | v1=="`f2'.`iv1'" | v1=="`f3'.`iv1'" | v1=="`s1'.`iv2'" | v1=="`s2'.`iv2'" | v1=="`s3'.`iv2'" | v1=="`s4'.`iv2'"
								egen float order = seq(), from(1) to(2) block(1)
								rename v2 est
								reshape wide est, i(v1) j(order)
								split est2, p(,)
								destring est1 est21 est22, replace
								gen cihigh=est22
								gen cilow=est21
									local est1=est1
									if `est1' >=1000 {
									tostring est1 ci*, force format(%9.0fc) replace
									}
									if `est1' >=10 & `est1' <1000 {
									tostring est1 ci*, force format(%9.1f) replace
									}
									if `est1' <10 {
									tostring est1 ci*, force format(%9.2f) replace
									}
								gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
								rename v1 var
								keep var est
								gen outcome="`var'"
								rename est B
							save temp1.dta, replace
							
							use temp.dta, clear
							joinby var outcome using temp1.dta, unmatched(none)
													
							gen iv1="`iv1'"
							gen iv2="`iv2'"
							gen inter= iv1 + " * " + iv2
							drop iv*
							save temp.dta, replace
							use output.dta, clear
							append using temp.dta
							save output.dta, replace
						}
					
				}
		}
	}
}

*						
	
	

destring p*, replace
			gen star="†" if pvar <=0.10
			replace star="*" if pvar<=0.05
			replace star="**" if pvar<=0.01
			replace star="***" if pvar<=0.001
			
	
tostring p*, force format(%9.4f) replace	
order outcome inter var expB B pvar pint star

if "`link'" == "" | "`link'" == "identity" {
	drop expB
	gen estnew=star + B
	drop B
	rename estnew B
	order outcome inter var B pint pvar star
	label var B "Coefficient (95% CI) Main Effect"
	}
	
else {
	drop B
	gen estnew=star + expB
	drop expB
	rename estnew expB
	order outcome inter var expB pint pvar star 
	label var expB "Exponentiated Coefficient (95% CI) Main Effect"
	}

label var outcome "Outcome"
label var var "Independent Variable"
label var inter "Interaction"
label var pint "P Value for Interaction"
label var pvar "P Value for Main Effects"
label var star "Star of Main Effects P Value"
drop if var==""
save output.dta, replace	



	capture erase temp1.dta
	capture erase temp.dta
	capture erase faketemp.dta
	capture erase temp.txt
	capture erase temp1.txt
drop star

}
describe
list ,  noobs divider sepby(outcome inter)
*restore

end
exit
