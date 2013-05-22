program define glmreport
syntax varlist [if] [pweight] [, iv(varlist) covars(string) fam(name) link(name) error(name) star cat(numlist max=1 integer) estround(numlist max=1 integer) iterate(numlist max=1 integer) vce(string)]
*Revised/Rewritten 05/25/2011 Nick Jackson
*PROGRAM Version 3.8-added iterate
*Version 4.0 12/24/2011-Replaced "results" command with "resout"
*Version 4.1 04/05/2012-Allows i. in Covars List
*Version 4.2 05/11/2012: added VCE option

*version 11
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
				glm `var' i.`iv' `covars' $_if [`weight' `exp'], family(`fam') link(`link') iterate(`itnum') vce(`vcetype')
			}
			else	{
				glm `var' i.`iv' `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
					capture drop resid
					predict resid if e(sample), pearson
					sum resid $_if , detail
				
					local skew=r(skewness)
					local N=r(N)
					testparm i.`iv'
					local p=r(p)
					
				if "`estround'" !="" {
					
					if "`link'" == "log" | "`link'" == "logit" {
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
					if "`link'" == "log" | "`link'" == "logit" {
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
				glm `var' `iv' `covars' $_if [`weight' `exp'], family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
			else	{
				glm `var' `iv' `covars' $_if , family(`fam') link(`link')  iterate(`itnum') vce(`vcetype')
			}
		
					capture drop resid
					predict resid if e(sample), pearson
					sum resid $_if , detail
				
					local skew=r(skewness)
					local N=r(N)
					test `iv'
					local p=r(p)
				
				if "`estround'" !="" {
					if "`link'" == "log" | "`link'" == "logit" {
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
					if "`link'" == "log" | "`link'" == "logit" {
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


/*CODE FROM BEFORE 05/24/2011
qui {
*preserve
save faketemp.dta, replace
	
	
clear
set more off
set obs 1
gen var=""
save output.dta, replace

	

use faketemp.dta, clear
foreach iv in `iv' {
	use faketemp.dta, clear
	tab `iv'
		local num=r(r)
foreach var of varlist `varlist' {
	
	
	use faketemp.dta, clear
	/***Overall Adjusted means***/
	
if `num' == 2 {
	glm `var' i.`iv' `covars' $_if , family(`fam') link(`link') eform
	capture drop resid
	predict resid if e(sample), pearson
	sum resid $_if , detail
	local skew=r(skewness)
	test 1.`iv'
	local p=r(p)
	
	estout using temp.txt, cells(b ci) replace eform
	estout using temp1.txt, cells(b ci) replace 
	
		/***Exponentiated Coef*/
	insheet using temp.txt, clear
		keep v2
		rename v2 est
		keep in 6/7
		egen float id = seq(), from(1) to(2) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}
		
		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est1 cilow cihigh
		gen var="`var'"
		gen iv="`iv'"
		drop id
		rename est expB
	save temp.dta, replace
	
			/***Reg Coef*/
	insheet using temp1.txt, clear
		keep v2
		rename v2 est
		keep in 6/7
		egen float id = seq(), from(1) to(2) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}
		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
		drop id
		rename est B
			gen iv="`iv'"
		gen p=`p'
			tostring p, force format(%9.4f) replace
	save temp1.dta, replace
	
	use temp.dta, clear
	joinby var iv using temp1.dta, unmatched(none)
	
	gen skew=`skew'
	tostring skew, force format(%9.1f) replace
	save temp.dta, replace
	
	use output.dta, clear
	append using temp.dta
	save output.dta, replace
	noi: display "You have modeled `var'=`iv' + `covars' with famliy(`fam') and link(`link')"
}

else if `num' == 3 {
	glm `var' i.`iv' `covars' $_if , family(`fam') link(`link') eform
	capture drop resid
	predict resid if e(sample), pearson
	sum resid $_if , detail
	local skew=r(skewness)
	test 2.`iv' 3.`iv'
		local p=r(p)
	test 2.`iv' 
		local p2=r(p)
	test 3.`iv'
		local p3=r(p)
	estout using temp.txt, cells(b ci) replace eform
	estout using temp1.txt, cells(b ci) replace 
	
		/***Exponentiated Coef*/
	insheet using temp.txt, clear
		keep v2
		rename v2 est
		keep in 6/9
		egen float id = seq(), from(1) to(2) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}

		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
			gen iv="`iv'"
		rename id grporder
		rename est expB
	save temp.dta, replace
	
			/***Reg Coef*/
	insheet using temp1.txt, clear
		keep v2
		rename v2 est
		keep in 6/9
		egen float id = seq(), from(1) to(2) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}

		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
			gen iv="`iv'"
		rename id grporder
		rename est B
		gen p=`p'
		gen pvar=`p2' if grporder==1
		replace pvar=`p3' if grporder==2
		tostring p*, force format(%9.4f) replace
	save temp1.dta, replace
	
	use temp.dta, clear
	joinby var iv grporder using temp1.dta, unmatched(none)
		gen skew=`skew'
		tostring skew, force format(%9.1f) replace
	save temp.dta, replace
	
	use output.dta, clear
	append using temp.dta
	save output.dta, replace
	noi: display "You have modeled `var'=`iv' + `covars' with famliy(`fam') and link(`link')"
}

else if `num' == 4 {
	glm `var' i.`iv' `covars' $_if , family(`fam') link(`link') eform
	capture drop resid
	predict resid if e(sample), pearson
	sum resid $_if , detail
	local skew=r(skewness)
	test 2.`iv' 3.`iv' 4.`iv'
		local p=r(p)
	test 2.`iv' 
		local p2=r(p)
	test 3.`iv'
		local p3=r(p)
	test 4.`iv'
		local p4=r(p)
	estout using temp.txt, cells(b ci) replace eform
	estout using temp1.txt, cells(b ci) replace 
	
		/***Exponentiated Coef*/
	insheet using temp.txt, clear
		keep v2
		rename v2 est
		keep in 6/11
		egen float id = seq(), from(1) to(3) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}

		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
			gen iv="`iv'"
		rename id grporder
		rename est expB
	save temp.dta, replace
	
			/***Reg Coef*/
	insheet using temp1.txt, clear
		keep v2
		rename v2 est
		keep in 6/11
		egen float id = seq(), from(1) to(3) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}

		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
			gen iv="`iv'"
		rename id grporder
		rename est B
		gen p=`p'
		gen pvar=`p2' if grporder==1
		replace pvar=`p3' if grporder==2
		replace pvar=`p4' if grporder==3
		tostring p*, force format(%9.4f) replace
	save temp1.dta, replace
	
	use temp.dta, clear
	joinby var iv grporder using temp1.dta, unmatched(none)
			gen skew=`skew'
		tostring skew, force format(%9.1f) replace
	save temp.dta, replace
	
	use output.dta, clear
	append using temp.dta
	save output.dta, replace
	noi: display "You have modeled `var'=`iv' + `covars' with famliy(`fam') and link(`link')"
}


else if `num' == 5 {
	glm `var' i.`iv' `covars' $_if , family(`fam') link(`link') eform
	capture drop resid
	predict resid if e(sample), pearson
	sum resid $_if , detail
	local skew=r(skewness)

	test 2.`iv' 3.`iv' 4.`iv' 5.`iv'
		local p=r(p)
	test 2.`iv' 
		local p2=r(p)
	test 3.`iv'
		local p3=r(p)
	test 4.`iv'
		local p4=r(p)
	test 5.`iv'
		local p5=r(p)
	estout using temp.txt, cells(b ci) replace eform
	estout using temp1.txt, cells(b ci) replace 
	
		/***Exponentiated Coef*/
	insheet using temp.txt, clear
		keep v2
		rename v2 est
		keep in 6/13
		egen float id = seq(), from(1) to(4) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}

		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
			gen iv="`iv'"
		rename id grporder
		rename est expB
	save temp.dta, replace
	
			/***Reg Coef*/
	insheet using temp1.txt, clear
		keep v2
		rename v2 est
		keep in 6/13
		egen float id = seq(), from(1) to(4) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}

		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
			gen iv="`iv'"
		rename id grporder
		rename est B
		gen p=`p'
		gen pvar=`p2' if grporder==1
		replace pvar=`p3' if grporder==2
		replace pvar=`p4' if grporder==3
		replace pvar=`p5' if grporder==4
		tostring p*, force format(%9.4f) replace
	save temp1.dta, replace
	
	use temp.dta, clear
	joinby var grporder using temp1.dta, unmatched(none)
		gen skew=`skew'
		tostring skew, force format(%9.1f) replace
	
	save temp.dta, replace
	
	use output.dta, clear
	append using temp.dta
	save output.dta, replace
noi: display "You have modeled `var'=`iv' + `covars' with famliy(`fam') and link(`link')"
}


else if `num' > 5 {
	glm `var' `iv' `covars' $_if , family(`fam') link(`link') eform
	capture drop resid
	predict resid if e(sample), pearson
	sum resid $_if , detail
	local skew=r(skewness)

	test `iv'
		local p=r(p)
	estout using temp.txt, cells(b ci) replace eform
	estout using temp1.txt, cells(b ci) replace 
	
		/***Exponentiated Coef*/
	insheet using temp.txt, clear
		keep v2
		rename v2 est
		keep in 4/5
		egen float id = seq(), from(1) to(4) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}

		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
			gen iv="`iv'"
		drop id
		rename est expB
	save temp.dta, replace
	
			/***Reg Coef*/
	insheet using temp1.txt, clear
		keep v2
		rename v2 est
		keep in 4/5
		egen float id = seq(), from(1) to(4) block(2)
		egen float order = seq(), from(1) to(2) block(1)
		reshape wide est, i(id) j(order)
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
		tostring est1 ci*, force format(%9.3f) replace
		}

		gen est=est1 + "  (" + cilow + " - " + cihigh + ")"
		keep id est
		gen var="`var'"
			gen iv="`iv'"
		drop id
		rename est B
		gen p=`p'
		tostring p*, force format(%9.4f) replace
		gen pvar=p
	save temp1.dta, replace
	
	use temp.dta, clear
	joinby var iv using temp1.dta, unmatched(none)
	gen skew=`skew'
	tostring skew, force format(%9.1f) replace
	save temp.dta, replace
	
	use output.dta, clear
	append using temp.dta
	save output.dta, replace
noi: display "You have modeled `var'=`iv' + `covars' with famliy(`fam') and link(`link')"
}
}
}
*
destring p*, replace
			gen star="†" if p <=0.10
			replace star="*" if p<=0.05
			replace star="**" if p<=0.01
			replace star="***" if p<=0.001
			
			capture gen starvar="†" if pvar <=0.10
			capture replace starvar="*" if pvar<=0.05
			capture replace starvar="**" if pvar<=0.01
			capture replace starvar="***" if pvar<=0.001
	
tostring p*, force format(%9.4f) replace	
order var iv expB B p star

if "`link'" == "" | "`link'" == "identity" {
	drop expB
	gen estnew=star + B
	drop B
	rename estnew B
	order var iv B p star skew
	label var B "Coefficient (95% CI)"
	}
	
else {
	drop B
	gen estnew=star + expB
	drop expB
	rename estnew expB
	order var iv expB p star skew
		gen est=expB + "  (" + cilow + " - " + cihigh + ")"
	label var expB "Exponentiated Coefficient (95% CI)"
	}

label var var "Outcome"
label var iv "Independent Variable"
rename skew residskew
label var residskew "Skewness of Residuals"
label var p "P Value for IV"
label var star "Star of P Value"
drop if var==""
capture drop starvar
capture move residskew grporder
save output.dta, replace	


*
	capture erase temp1.dta
	capture erase temp.dta
	capture erase faketemp.dta
	capture erase temp.txt
	capture erase temp1.txt
drop star
}
describe
list ,  noobs divider sepby(var iv)
*restore
end
exit
