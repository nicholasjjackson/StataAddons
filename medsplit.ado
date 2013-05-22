program medsplit
	syntax varlist [if] [in] [, REPlace]
qui {
	version 11
	set more off
	
	foreach var of varlist `varlist' {
		sum `var' $_if $_in, det
		
		if "`replace'" =="" {
			capture drop `var'_m
			capture drop tag
			gen tag=1 $_if $_in
			
			capture gen `var'_m=.
			
			replace `var'_m= 1 if `var' >=r(p50) & `var' !=. & tag==1 
			replace `var'_m= 0 if `var' <r(p50) & tag==1
			capture drop tag
		}
		if "`replace'" !="" {
			capture drop tag
			gen tag=1 $_if $_in
			
			replace `var'=1 if `var' >=r(p50) & `var' !=. & tag==1 
			replace `var'=0 if `var' <r(p50) & tag==1 
			replace  `var'=. if tag!=1
			capture drop tag
		}
	}
}
end
exit
