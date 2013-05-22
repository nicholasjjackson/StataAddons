program standard
	syntax varlist [if] [in] [, REPlace]
qui {
	version 11
	set more off
	
	foreach var of varlist `varlist' {
		sum `var' $_if $_in
		
		if "`replace'" =="" {
			capture drop `var'_s
			capture gen `var'_s=.
			replace `var'_s= (`var'- r(mean))/r(sd) $_if $_in
		}
		if "`replace'" !="" {
			replace `var'=(`var'- r(mean))/r(sd) $_if $_in
		}
	}
}
end
exit
