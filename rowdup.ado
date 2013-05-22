program rowdup
syntax varlist [if] [in] [, REPlace id(varlist) cat(numlist max=1 integer) NOInteger]
*Version 1.0 03/14/2012 Nick Jackson, Biostatistician, University of Pennsylvania
version 11
set more off
qui {
capture drop dup_*
tempfile master  using
save `master', replace

capture keep $_if
capture keep $_in
capture keep `id' `varlist'
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
		foreach var1 of varlist `varlist' {
			foreach var2 of varlist `varlist' {
			
			capture assert dup_`var2'_`var1' 
				if _rc==111 {
					if "`var1'" != "`var2'"  {
						gen dup_`var1'_`var2'=.
						replace dup_`var1'_`var2'=1 if `var1'==`var2' & `var1' != .
							local num= length("dup_`var1'_`var2'")
							format dup_`var1'_`var2' %`num'.0g		
					}/*if "`var1'" != "`var2'" */
					else {
					}
				}
				else{
				}
			}/*Var2*/
		}/*Var1*/

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

			use `master', clear

			foreach var1 of varlist `varlist' {
				use `master', clear
				foreach var2 of varlist `varlist' {
					use `using', clear
						capture assert dup_`var2'_`var1' 
					use `master', clear

						if _rc==111 {
							if "`var1'" != "`var2'"  {
									use `using', clear
									gen dup_`var1'_`var2'=.
										capture drop `var1' 
										capture drop `var2'
									save `using', replace 
									
								use `master', clear
						
								capture keep $_if
								capture keep $_in
								keep if `var1'==`var2' & `var1' !=.
									gen var1="`var1'" 
									gen var2="`var2'" 
									gen value=`var1'
								keep `id' var1 var2 value
								save `temp', replace
								
								use `output', clear
									capture drop if var2=="`var1'" & var1=="`var2'"
									capture drop if var2=="`var2'" & var1=="`var1'"
									append using `temp'
									drop if var1==""
								save `output', replace 
							}/*if "`var1'" != "`var2'" */
							else {
							}
						}
						else{
						}
				}/*Var2*/
			}/*Var1*/
			use `output', clear
				order `id' var1 var2 value
			sort `id' var1 var2
		}/*Else*/
	}/*if "`replace'"!= ""*/
}/*if "`nointeger'" == "" */

if "`nointeger'" != "" {

	if "`replace'"== "" {
		use `master', clear
		foreach var1 of varlist `varlist' {
			foreach var2 of varlist `varlist' {
			
			capture assert dup_`var2'_`var1' 
				local num1=r(N)
				local integer= r(N_0) +  r(N_negint) + r(N_posint)
				
				if `num1' != `integer' {
					if _rc==111 {
						if "`var1'" != "`var2'"  {
							gen dup_`var1'_`var2'=.
							replace dup_`var1'_`var2'=1 if `var1'==`var2' & `var1' != .
								local num= length("dup_`var1'_`var2'")
								format dup_`var1'_`var2' %`num'.0g		
						}/*if "`var1'" != "`var2'" */
						else {
						}
					}
					else{
					}
				}
				else{
				}
			}/*Var2*/
		}/*Var1*/

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

			use `master', clear
			foreach var1 of varlist `varlist' {
			use `master', clear
				foreach var2 of varlist `varlist' {
				use `using', clear
					capture assert dup_`var2'_`var1' 
				
				use `master', clear
					inspect `var1'
					local num1=r(N)
					local integer= r(N_0) +  r(N_negint) + r(N_posint)
				
					if `num1' != `integer' {
					
							if _rc==111 {
								if "`var1'" != "`var2'"  {	
									use `using', clear
									gen dup_`var1'_`var2'=.
										capture drop `var1' 
										capture drop `var2'
									save `using', replace 
									
									use `master', clear
										capture keep $_if
										capture keep $_in
								
									keep if `var1'==`var2' & `var1' !=.
										gen var1="`var1'" 
										gen var2="`var2'" 
										gen value=`var1'
									keep `id' var1 var2 value
									save `temp', replace
									
									use `output', clear
										capture drop if var2=="`var1'" & var1=="`var2'"
										capture drop if var2=="`var2'" & var1=="`var1'"
										append using `temp'
										drop if var1==""
									save `output', replace 
								}/*if "`var1'" != "`var2'" */
								else {
								}
							}
							else{
							}
					}
					else{
					}
				}/*Var2*/
			}/*Var1*/
			use `output', clear
				order `id' var1 var2 value
			sort `id' var1 var2
		}/*Else*/
	}/*if "`replace'"!= ""*/
}/*if "`nointeger'" != "" */
}/*QUI*/
end
exit
