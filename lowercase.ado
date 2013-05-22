program lowercase
syntax varlist 

version 11
set more off
qui {
	foreach var of varlist `varlist' {
		capture rename `var' `=lower("`var'")'
		}
}
end 
exit
