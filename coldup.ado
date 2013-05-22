program coldup
syntax varlist [if] [in] [, REPlace id(varlist) cat(numlist max=1 integer) NOInteger]
*Version 1.0 03/26/2012 Nick Jackson, Biostatistician, University of Pennsylvania
version 11
set more off
qui {
capture drop dup_*
tempfile master  using
save `master', replace

capture keep `id' `varlist'
capture keep $_if
capture keep $_in
save `using', replace



*Establish Categorical Cutpoint
if "`cat'"!="" {
	local cutpoint=`cat'
}
else {
	local cutpoint=9
}

if "`nointeger'" == "" {

	if "`replace'"== "" {
		use `master', clear
		foreach var of varlist `varlist' {
			duplicates tag `var' if `var'!=., gen(dup_`var')
			
		}/*Var*/

		egen dup_any=rowtotal(dup_*)
	}/*if "`replace'"== ""*/



	if "`replace'"!= "" {

		if "`id'"=="" {
			dis as error "id must be filled in when using replace option"
		}
		else {
			tempfile temp output

			clear
			set obs 1
			gen value=.
			save `output', replace 

			use `using', clear

				foreach var of varlist `varlist' {
				use `using', clear
					duplicates tag `var' if `var'!=., gen(dup_`var')
					
					sum dup_`var'
					if r(max) != 0 {
						keep if dup_`var'!=0 & dup_`var'!= . 
							local value= `var' in 1
						keep `id'
						gen var="`var'"
						gen value=`value'
		
								save `temp', replace
								
								use `output', clear
									append using `temp'
									drop if var==""
								save `output', replace 
					} /*If Rmax*/
					else {
					}
				}/*Var*/
		}/*Else*/
		
			use `output', clear
				capture order `id' var value
		capture egen float group = group(var value)
		capture  sort group

	}/*if "`replace'"!= ""*/
}/*if "`nointeger'" == "" */

if "`nointeger'" != "" {

	if "`replace'"== "" {
		use `master', clear
		foreach var of varlist `varlist' {
			
				local num1=r(N)
				inspect `var'
				local integer= r(N_0) +  r(N_negint) + r(N_posint)
				
				if `num1' != `integer' {
							duplicates tag `var' if `var'!=., gen(dup_`var')

				}/*num1 != integer*/	
				else {
				}
		}/*Var*/
		egen dup_any=rowtotal(dup_*)
	}/*if "`replace'"== ""*/
*


if "`replace'"!= "" {

		if "`id'"=="" {
			dis as error "id must be filled in when using replace option"
		}
		else {
			tempfile temp output

			clear
			set obs 1
			gen value=.
			save `output', replace 

			use `using', clear
			foreach var of varlist `varlist' {
			use `using', clear
				
					inspect `var'
					local num1=r(N)
					local integer= r(N_0) +  r(N_negint) + r(N_posint)
				
					if `num1' != `integer' {
							duplicates tag `var' if `var'!=., gen(dup_`var')
					
								sum dup_`var'
								if r(max) != 0 {
									keep if dup_`var'!=0 & dup_`var'!= . 
				
									keep `id' `var'
									rename `var' value 
									gen var="`var'"
									
											save `temp', replace
											
											use `output', clear
												append using `temp'
												drop if var==""
											save `output', replace 

								}/*rmax*/
								else {
								}
					}/*num1 != integer*/
					else{
					}
				}/*Var*/
		}/*ELSE*/
			use `output', clear
				capture order `id' var value
		capture egen float group = group(var value)
		capture  sort group
}/*if "`replace'"!= ""*/
}/*No integer*/
*
}/*QUI*/
end
exit
