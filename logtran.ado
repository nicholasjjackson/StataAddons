program logtran
syntax varlist [if] [in] [, REPlace]
*version 1.0 10/24/2011
*Note: 12/4/2012 in Stata the function log() and ln() both return the natural log
qui {
set more off
version 11

	foreach var of varlist `varlist' {
		sum `var' $_if $_in
		local min=r(min)
		
		if "`replace'" !="" {
			if `min' < 0 {
					noi: display as error "Cannot Log Transform Variables with Negative Numbers"
			}
			else {
				if `min'>=0 & `min'<1   {
					replace `var'=log(`var'+1) $_if $_in
				}
				else {
					replace `var'=log(`var') $_if $_in
			
				}
			}
		}
		
		if "`replace'" ==""  {
			if `min' < 0 {
					noi: display as error "Cannot Log Transform Variables with Negative Numbers"
			}
			else {
				if `min'>=0 & `min'<1   {
					capture drop log`var'
					gen log`var'=log(`var'+1) $_if $_in
				}
				else {
					capture drop log`var'
					gen log`var'=log(`var') $_if $_in
			
				}
			}
		}
	}
}
end 
exit
	