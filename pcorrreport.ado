*version 1.5
program define pcorrreport
syntax varlist [if] [in] [, iv(varlist) by(varname) covars(varlist) estround(numlist max=1 integer) pval log]
qui {
set more off
noi: display "Please ensure Multicategorical variables in the COVARS List have Dummy codes for them"




tempfile master using
save `master', replace

capture keep $_if
capture keep $_in
capture drop if `by'==.

if "`log'" =="log" {
	foreach var of varlist `varlist' {
		sum `var'
		local min=r(min)
		
		if `min' < 0 {
				noi: display as error "Cannot Log Transform Variables with Negative Numbers"
		}
		else {
			if `min'>=0 & `min'<1 {
				replace `var'=log(`var'+1)
			}
			else {
				replace `var'=log(`var')
		
			}
		}
	}
}


save `using', replace


use `using', clear

	tempfile output temp	
	clear
		set more off
		set obs 1
		gen var=""
	save `output', replace

/**NO BY OPTION**/

if "`by'"=="" {	
		use `using', clear
		foreach indv in `iv' {
				use `using', clear
				foreach var of varlist `varlist' {
					use `using', clear
					
					pcorr `var' `indv' `covars'
						matrix x = r(p_corr)
						local corr=x[1,1]
					
					regress `var' `indv' `covars'
							local n=e(N)
							
					test `indv'
						local p=r(p)
						
					clear
					set obs 1
						gen var="`var'"
						gen iv="`indv'"
						gen N=`n'
						gen prho=`corr'
						gen p=`p'
							tostring N, force format(%9.0f) replace
						
						if "`estround'" != "" {
							tostring prho, force format(%9.`estround'fc) replace
						}
						else {
							tostring prho, force format(%9.2f) replace
						}
						if "`pval'" !="" {
							tostring p, force format(%9.4f) replace
							replace  p = "<.0001" if  p =="0.0000"
						}
						if "`pval'" =="" {
							gen star="†" if p <=0.10
							replace star="*" if p<=0.05
							replace star="**" if p<=0.01
							replace star="***" if p<=0.001
							
							gen est=star+prho
							drop prho p
							rename est prho
							drop star
						}
				
						
						save `temp', replace
						use `output', clear
							append using `temp'
						save `output', replace
					
				}/*IV*/
			}/*Var*/
}/*BY Option*/


/***BY Option**/
if "`by'"!="" {	
		use `using', clear
		foreach indv in `iv' {
				use `using', clear
				foreach var of varlist `varlist' {
					use `using', clear
					
						
							table `by', replace
							local num=_N
							
							forvalues i=1(1)`num' {
								local grp`i'=`by' in `i'
							}
							
						use `using', clear
						forvalues i=1(1)`num' {
								use `using', clear
								
								pcorr `var' `indv' `covars' if `by'==`grp`i''
									matrix x = r(p_corr)
									local corr=x[1,1]
								
								regress `var' `indv' `covars' if `by'==`grp`i''
										local n=e(N)
										
								test `indv'
									local p=r(p)
									
								clear
								set obs 1
									gen var="`var'"
									gen iv="`indv'"
									gen grp=`grp`i''
									gen N=`n'
									gen prho=`corr'
									gen p=`p'
										tostring N, force format(%9.0f) replace
									
									if "`estround'" != "" {
										tostring prho, force format(%9.`estround'fc) replace
									}
									else {
										tostring prho, force format(%9.2f) replace
									}
									
								tempfile temp`i'
								save `temp`i'', replace
						}/*Forvalues*/
								use `temp1', clear
									forvalues i=2(1)`num' {
										append using `temp`i''
									}
									reshape wide N p*, i(var iv) j(grp)
									
									
									if "`pval'" !="" {
										tostring p*, force format(%9.4f) replace
										forvalues i=1(1)`num' {
											replace  p`i' = "<.0001" if  p`i' =="0.0000"
										}	
									}
									if "`pval'" =="" {
										forvalues i=1(1)`num' {
									
											gen star`i'="†" if p`i' <=0.10
											replace star`i'="*" if p`i'<=0.05
											replace star`i'="**" if p`i'<=0.01
											replace star`i'="***" if p`i'<=0.001
											
											gen est`i'=star`i'+prho`i'
											drop prho`i' p`i'
											rename est`i' prho`i'
											drop star`i'
										}
									}
							
									
									save `temp', replace
									use `output', clear
										append using `temp'
									save `output', replace
								
							}/*IV*/
						}/*Var*/
}/*BY Option*/



			use `output', clear
			drop if var==""
			capture label var N "Nubmer of Obs"
			capture label var var "Outcome"
			capture label var iv "Independent Variable"
			capture label var prho "Partial Correlation Coefficient"
			capture label var p "P Value"
			
	
}/*QUI*/

end
exit
