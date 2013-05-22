/***This program was written with substantial help and explicit code copying from:
http://www.ats.ucla.edu/stat/stata/faq/conconb11.htm
A part of the University of California, Los Angeles: Academic Technology Services Statistical Computing Division (http://www.ats.ucla.edu/stat/)
**/

program define cinteract
syntax varlist [if] [, iv1(varlist) iv2(varlist) covars(string) fam(name) link(name) scatter]
qui {
noi: display "Please ensure covariates are centered before beginning "

tempfile faketemp output

version 11
preserve
save `faketemp', replace

clear
set more off
set obs 1
gen var=""
save `output', replace


if "`scatter'" != "" {
		use `faketemp', clear
		foreach iv1 of varlist `iv1' {
			foreach iv2 of varlist `iv2' {
				foreach var of varlist `varlist' {
					use `faketemp', clear
					
					tab `iv1' $_if
					local num1=r(r)
					tab `iv2' $_if
					local num2=r(r)
					
					if `num1' > 5 & `num2' > 5 {
							use `faketemp', clear
							glm `var' c.`iv1' c.`iv2' c.`iv1'#c.`iv2' `covars' $_if , family(`fam') link(`link')
								test c.`iv1'#c.`iv2'
								local p=r(p)
								capture drop temptag
								gen temptag=1 if e(sample)
								capture drop p
								gen p=`p'
								tostring p, force format(%9.4f) replace
								local p=p
								
								sum `iv1' if e(sample)
								local min=r(min)
								local max=r(max)
								sum `iv2' if e(sample), detail
										local 1=r(p1)
										local 5=r(p5)
										local 10=r(p10)
										local 25=r(p25)
										local 50=r(p50)
										local 75=r(p75)
										local 90=r(p90)
										local 95=r(p95)
										local 99=r(p99)
								margins, dydx(`iv1') at(`iv2'=(`1' `5' `10' `25' `50' `75' `90' `95' `99' ) )  atmeans
									matrix s=r(b)
								margins,  at(`iv1'=0 `iv2'=(`1' `5' `10' `25' `50' `75' `90' `95' `99' ) )  atmeans
									matrix i=r(b)
							twoway (function y = i[1,1] + s[1,1]*x, range(`min' `max') lcolor(gs10) lwidth(thin) lpattern(dash))  ///
							   (function y = i[1,2] + s[1,2]*x, range(`min' `max') lcolor(gs8) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,3] + s[1,3]*x, range(`min' `max') lcolor(gs6) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,4] + s[1,4]*x, range(`min' `max') lcolor(gs4) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,5] + s[1,5]*x, range(`min' `max') lcolor(gs4) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,6] + s[1,6]*x, range(`min' `max') lcolor(gs4) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,7] + s[1,7]*x, range(`min' `max') lcolor(gs2) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,8] + s[1,8]*x, range(`min' `max') lcolor(gs0) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,9] + s[1,9]*x, range(`min' `max') lcolor(black) lwidth(thin) lpattern(dash))  ///
							   (scatter `var' `iv1' if temptag==1,  mcolor(gs10) msymbol(circle) msize(vsmall) jitter(3)),                   ///
							   legend(order(1 "At 1% `iv2'" 5 "5,10,25,50,75,90,95% Percentiles of `iv2'" 9 "At 99% `iv2'") size(small)) /// 
							   ytitle("`var'") xtitle("`iv1'") scheme(sj) title(Effect Modification of `var' vs `iv1' by `iv2', size(small)) ///
							   subtitle(`iv1'*`iv2'  Interaction p=`p', size(vsmall)) name(`var'_`iv1'_`iv2', replace)
							
					}
					capture drop temptag
					else {
				 noi: display as error "One of the variables you wish to interact is not continuous!"  
				 noi: display as error "Please graph with a different program"
					}
				}
			}
		}
	}
	
	
if "`scatter'" == "" {
		use `faketemp', clear
		foreach iv1 of varlist `iv1' {
			foreach iv2 of varlist `iv2' {
				foreach var of varlist `varlist' {
					use `faketemp', clear
					
					tab `iv1' $_if
					local num1=r(r)
					tab `iv2' $_if
					local num2=r(r)
					
					if `num1' > 5 & `num2' > 5 {
							use `faketemp', clear
							glm `var' c.`iv1' c.`iv2' c.`iv1'#c.`iv2' `covars' $_if , family(`fam') link(`link')
								test c.`iv1'#c.`iv2'
								local p=r(p)
								capture drop temptag
								gen temptag=1 if e(sample)
								capture drop p
								gen p=`p'
								tostring p, force format(%9.4f) replace
								local p=p
								
								sum `iv1' if e(sample)
								local min=r(min)
								local max=r(max)
								sum `iv2' if e(sample), detail
										local 1=r(p1)
										local 5=r(p5)
										local 10=r(p10)
										local 25=r(p25)
										local 50=r(p50)
										local 75=r(p75)
										local 90=r(p90)
										local 95=r(p95)
										local 99=r(p99)
								margins, dydx(`iv1') at(`iv2'=(`1' `5' `10' `25' `50' `75' `90' `95' `99' ) )  atmeans
									matrix s=r(b)
								margins,  at(`iv1'=0 `iv2'=(`1' `5' `10' `25' `50' `75' `90' `95' `99' ) )  atmeans
									matrix i=r(b)
							twoway (function y = i[1,1] + s[1,1]*x, range(`min' `max') lcolor(gs10) lwidth(thin) lpattern(dash))  ///
							   (function y = i[1,2] + s[1,2]*x, range(`min' `max') lcolor(gs8) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,3] + s[1,3]*x, range(`min' `max') lcolor(gs6) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,4] + s[1,4]*x, range(`min' `max') lcolor(gs4) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,5] + s[1,5]*x, range(`min' `max') lcolor(gs4) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,6] + s[1,6]*x, range(`min' `max') lcolor(gs4) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,7] + s[1,7]*x, range(`min' `max') lcolor(gs2) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,8] + s[1,8]*x, range(`min' `max') lcolor(gs0) lwidth(thin) lpattern(solid))  ///
							   (function y = i[1,9] + s[1,9]*x, range(`min' `max') lcolor(black) lwidth(thin) lpattern(dash)),  ///
							   legend(order(1 "At 1% `iv2'" 5 "5,10,25,50,75,90,95% Percentiles of `iv2'" 9 "At 99% `iv2'") size(small)) /// 
							   ytitle("`var'") xtitle("`iv1'") scheme(sj) title(Effect Modification of `var' vs `iv1' by `iv2', size(small)) ///
							   subtitle(`iv1'*`iv2'  Interaction p=`p', size(vsmall)) name(`var'_`iv1'_`iv2', replace)
							
					}
					capture drop temptag
					else {
				 noi: display as error "One of the variables you wish to interact is not continuous!"  
				 noi: display as error "Please graph with a different program"
					}
				}
			}
		}
	}
restore
}
*

end
exit


