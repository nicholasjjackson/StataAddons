program efcode
syntax varlist [if] [, code(numlist min=2 max=2) ref(numlist integer max=1)]
*Version 1.0 04/10/2013

qui {	
set more off
version 12


if "`code'" == "" {
	local reff=-1
	local eff=1
	noi dis "Reference=`reff', Effect=`eff'"
}
if "`code'" != "" {
	tokenize `code'
		local reff=`1'
		local eff=`2'
	noi dis "Reference=`reff', Effect=`eff'"
}
	
	
if "`ref'"=="" {
	local base=1
	noi dis "Effect Codes Comparing to Group `base'"

}
if "`ref'"!="" {
	local base=`ref'
	noi dis "Effect Codes Comparing to Group `base'"	
}
	
foreach var of varlist `varlist' {
	capture drop `var'_*
	capture drop fake_*
	tab `var' $_if, gen(`var'_)
	local rows=r(r)
	tab `var' $_if, gen(fake_)
	
	forvalues i=1(1)`rows' {
		recode `var'_`i' (1=`eff')
		recode `var'_`i' (0=`reff') if fake_`base'==1
	}
	drop `var'_`base'
}
	drop fake_* 

}/*Qui*/	
end
exit	
	