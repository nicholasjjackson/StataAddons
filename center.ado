program center
syntax varlist [if] [in] [, REPlace]
qui {
	version 11
	set more off



foreach var of varlist `varlist' {
	sum `var' $_if $_in
	
	if "`replace'"=="" {
	capture drop `var'_c
		capture gen `var'_c=.
		replace `var'_c= `var'- r(mean) $_if $_in
	}
	if "`replace'"!="" {
		replace `var'= `var'- r(mean) $_if $_in
	}

}
}
end
exit


