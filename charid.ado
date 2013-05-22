program charid
syntax varlist
*Version 1.0 03/14/2012, Nick Jackson, Biostatistician, University of Pennsylvania
qui {
set more off
version 11

tempfile master
save `master', replace


tempfile output
clear
set obs 1
gen var=""
save `output', replace


use `master', clear
	capture drop new*
	foreach var of varlist `varlist' {

		use `master', clear
			capture drop new*
			split `var', p(1 2 3 4 5 6 7 8 9 0 .) gen(new)
				tempfile split
				save `split', replace
				
				
				foreach new of varlist new* {
					use `split', clear
						capture assert `new'==""
							if _rc==9 {
								gen char=`new'
								table char, replace
								drop table1
								gen var="`var'"
									tempfile temp
									save `temp', replace
								
									use `output', clear
										drop if var==""
										append using `temp'
									save `output', replace
									
								use `split', clear
									drop `new'
								save `split', replace
							}
							else {
									drop `new'
								save `split', replace
							}
							
				}
		}
	use `output', clear
		noi: list, noobs
	use `master', clear
}
end

