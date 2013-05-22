*version 1.0 10/22/2011
program define pairtest
syntax varlist [if] [in] [, by(varname) id(varname)  estround(numlist max=1 integer) log num]
qui {
set more off

tempfile master using
save `master', replace

capture keep $_if
capture keep $_in



if "`log'" =="log" {
	foreach var of varlist `varlist' {
		sum `var'
		local min=r(min)
		
		if `min' < 0 {
				noi: display as error "Cannot Log Transform Variables with Negative Numbers"
		}
		else {
			if `min'==0 {
				replace `var'=log(`var'+1)
			}
			else {
				replace `var'=log(`var')
		
			}
		}
	}
}

sum `by'
local min=r(min)
local max=r(max)


save `using', replace

	tempfile output temp	
	clear
		set more off
		set obs 1
		gen var=""
	save `output', replace

use `using', clear
foreach var of varlist `varlist' {

	use `using', clear
		keep `var' `id' `by'

		reshape wide `var', i(`id') j(`by')
			ttest `var'`min'==`var'`max'
				local p=r(p)
				local mean1=r(mu_1)
				local mean2=r(mu_2)
				local sd1=r(sd_1)
				local sd2=r(sd_2)
				local n=r(N_1)
			signrank `var'`min' = `var'`max'
				local pNP= 2*(1-normal( abs(r(z))))
			clear
			set obs 1
				gen var="`var'"
				gen n=`n'
				gen mean1=`mean1'
				gen mean2=`mean2'
				gen sd1=`sd1'
				gen sd2=`sd2'
				gen p=`p'
				gen pNP=`pNP'
			replace pNP=0.9999 if pNP>1
			
			tostring n, force format(%9.0f) replace
			tostring p*, force format(%9.4f) replace
				replace p = "<.0001" if p=="0.0000"
				replace pNP = "<.0001" if p=="0.0000"
				
				
			if "`estround'"!="" {
				tostring mean* sd*, force format(%9.`estround'fc) replace
			}
			else {
			
				local mean1 =abs(mean1)
				if `mean1' >= 1000 {
				tostring mean* sd*, force format(%9.0fc) replace
				}
				if `mean1' >= 10 & `mean1' <1000 {
				tostring mean* sd*, force format(%9.1f) replace
				}
				if `mean1' >=1 & `mean1' <10 {
				tostring mean* sd*, force format(%9.2f) replace
				}
				if `mean1' <1 {
				tostring mean* sd*, force format(%9.3f) replace
				}
			}
			
			if "`num'" =="" {
				gen grp`min'=mean1 + " ± " + sd1
				gen grp`max'=mean2 + " ± " + sd2
					
			}
			else {
				gen grp`min'="(" + n + ") " + mean1 + " ± " + sd1
				gen grp`max'="(" + n + ") " + mean2 + " ± " + sd2
			}
			if "`num'" =="" {	
				keep var n grp* p*
				order var n grp* p*
			}
			else {
				keep var  grp* p*
				order var grp* p*
			}
			save `temp', replace
			use `output', clear
				append using `temp'
			save `output', replace
			
	}/*FOREACH*/
	drop if var==""
	
}/*QUI*/
end
exit
