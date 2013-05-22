
program cinteract3d
syntax varlist (max=1) [if] [pweight] [, iv1(varname) iv2(varname) covars(string)  fam(name) link(name) iterate(numlist max=1 integer)]
set more off

qui{ 
noi: display "Please ensure covariates are centered before beginning"
tempfile output temp current
save `current', replace 

if "`iterate'" == "" {
	local itnum=500
}
if "`iterate'" != "" {
	local itnum=`iterate'
}


clear
set obs 1
gen `varlist'=.
save `output', replace

use `current', clear
/*
forvalues x =1(9)99 {
	forvalues y =1(9)99 {
use `current', clear
capture keep $_if


_pctile `iv1' if `varlist' !=. & `iv2' !=. , p(`x')
	local xval=r(r1)
_pctile `iv2' if `varlist' !=. & `iv2' !=. , p(`y')
	local yval=r(r1)

	regress `varlist' c.`iv1'##c.`iv2'

	margins, at(`iv1'=`xval' `iv2'=`yval')
		matrix z=r(b)
		
	clear
	set obs 1
	gen `varlist'=z[1,1]
	gen `iv1'=`xval'
	gen `iv2'=`yval'
	save `temp', replace

	use `output', clear
	append using `temp'
	save `output',replace
}
}
*/
forvalues x =0(1)10 {
	forvalues y =0(1)10 {
use `current', clear
capture keep $_if
drop if `varlist'==.
drop if `iv1'==.
drop if `iv2'==.


sum `iv1'
local iv1min=r(min) 
local iv1max=r(max)
local iv1inc=(`iv1max'-`iv1min')/10

sum `iv2'
local iv2min=r(min) 
local iv2max=r(max)
local iv2inc=(`iv2max'-`iv2min')/10

	local xval=`iv1min' + (`x'*`iv1inc')
	local yval=`iv2min' + (`y'*`iv2inc')

if "`weight'" == "" {
	glm `varlist' c.`iv1'##c.`iv2' `covars', family(`fam') link(`link')  iterate(`itnum')
}
if "`weight'" != "" {
	glm `varlist' c.`iv1'##c.`iv2' `covars' [`weight'`exp'], family(`fam') link(`link')  iterate(`itnum')
}
	margins, at(`iv1'=`xval' `iv2'=`yval')  atmeans
		matrix z=r(b)
		
	clear
	set obs 1
	gen `varlist'=z[1,1]
	gen `iv1'=`xval'
	gen `iv2'=`yval'
	save `temp', replace

	use `output', clear
	append using `temp'
	save `output',replace
}
}
drop if `varlist'==.
}

end
