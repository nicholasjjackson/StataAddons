
program gcinteract
*Version 2.0 12/03/2011
syntax varlist (max=1) [if] [pweight] [, cont(varname) grp(varname) covars(string) fam(name) link(name) iterate(numlist max=1 integer)]
set more off
qui {
noi: display "Please ensure covariates are centered before beginning "

if "`iterate'" == "" {
	local itnum=500
}
if "`iterate'" != "" {
	local itnum=`iterate'
}

inspect `grp'
	local num =  r(N_unique)

tempfile current master
	save `master', replace
	capture keep $_if


	save `current', replace
*
if "`weight'" == "" {
	if `num' == 2 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2'))  atmeans
				matrix i=r(b)
			
		glm `varlist' `cont' `covars'  if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		tostring p1 p2, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(black) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'" ) rows(1)) scheme(s1mono)
		}/*If*/

	if `num' == 3 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'   if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'    if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'   if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		tostring p1 p2 p3, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs8) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(black) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				 note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'") rows(1)) scheme(s1mono)
		}/*If*/

	if `num' == 4 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'  if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g4', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		tostring p1 p2 p3 p4, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(black) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3',  `l4' = `p4'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'") rows(2)) scheme(s1mono)
		} /*If*/
		
	if `num' == 5 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		local g5=`grp' in 5
		local l5=label in 5
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4' `g5'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4' `g5'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'  if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g4', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g5', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p5
			gen p5=r(p)
			
			
		tostring p1 p2 p3 p4 p5, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
			local p5=p5 in 1
		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(longdash_dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(gs6) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,5] + s[1,5]*x, range(`cont') lcolor(black) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3',  `l4' = `p4', `l5' = `p5'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'" 5 "`l5'") rows(2)) scheme(s1mono)
		} /*If*/		
		
	if `num' == 6 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		local g5=`grp' in 5
		local l5=label in 5
		
		local g6=`grp' in 6
		local l6=label in 6
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4' `g5' `g6'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4' `g5' `g6'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'  if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g4', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g5', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p5
			gen p5=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g6', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p6
			gen p6=r(p)	
			
			
		tostring p1 p2 p3 p4 p5 p6, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
			local p5=p5 in 1
			local p6=p6 in 1
		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(longdash_dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(gs6) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,5] + s[1,5]*x, range(`cont') lcolor(black) lpattern(solid)) ///
				(function y = i[1,6] + s[1,6]*x, range(`cont') lcolor(gs10) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3'"  "`l4' = `p4', `l5' = `p5', `l6' = `p6'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'" 5 "`l5'" 6 "`l6'") rows(2)) scheme(s1mono)
		} /*If*/	
		
	if `num' == 7 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		local g5=`grp' in 5
		local l5=label in 5
		
		local g6=`grp' in 6
		local l6=label in 6
		
		local g7=`grp' in 7
		local l7=label in 7
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4' `g5' `g6' `g7'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4' `g5' `g6' `g7'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'  if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g4', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g5', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p5
			gen p5=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g6', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p6
			gen p6=r(p)	
			
		glm `varlist' `cont' `covars'  if `grp'==`g7', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p7
			gen p7=r(p)		
			
			
		tostring p1 p2 p3 p4 p5 p6 p7, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
			local p5=p5 in 1
			local p6=p6 in 1
			local p7=p7 in 1		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(longdash_dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(gs6) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,5] + s[1,5]*x, range(`cont') lcolor(black) lpattern(solid)) ///
				(function y = i[1,6] + s[1,6]*x, range(`cont') lcolor(black) lpattern(dash)) ///
				(function y = i[1,7] + s[1,7]*x, range(`cont') lcolor(gs10) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3'"  "`l4' = `p4', `l5' = `p5', `l6' = `p6', `l7' = `p7'" , size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'" 5 "`l5'" 6 "`l6'" 7 "`l7'") rows(2)) scheme(s1mono)
		} /*If*/						
	if `num' == 8 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		local g5=`grp' in 5
		local l5=label in 5
		
		local g6=`grp' in 6
		local l6=label in 6
		
		local g7=`grp' in 7
		local l7=label in 7
		
		local g8=`grp' in 8
		local l8=label in 8
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4' `g5' `g6' `g7' `g8'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4' `g5' `g6' `g7' `g8'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'  if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g4', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g5', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p5
			gen p5=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g6', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p6
			gen p6=r(p)	
			
		glm `varlist' `cont' `covars'  if `grp'==`g7', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p7
			gen p7=r(p)		
		
		glm `varlist' `cont' `covars'  if `grp'==`g8', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p8
			gen p8=r(p)					
			
		tostring p1 p2 p3 p4 p5 p6 p7 p8, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
			local p5=p5 in 1
			local p6=p6 in 1
			local p7=p7 in 1		
			local p8=p8 in 1
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(longdash_dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(gs6) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,5] + s[1,5]*x, range(`cont') lcolor(black) lpattern(solid)) ///
				(function y = i[1,6] + s[1,6]*x, range(`cont') lcolor(black) lpattern(dash)) ///
				(function y = i[1,7] + s[1,7]*x, range(`cont') lcolor(gs6) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,8] + s[1,8]*x, range(`cont') lcolor(gs10) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3', `l4' = `p4'"  "`l5' = `p5', `l6' = `p6', `l7' = `p7', `l8' = `p8'" , size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'" 5 "`l5'" 6 "`l6'" 7 "`l7'" 8 "`l8'") rows(2)) scheme(s1mono)
		} /*If*/						
}/*Weight*/
		
		use `master', clear
		
/***WEIGHTING***/
if "`weight'" != "" {
	if `num' == 2 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2'))  atmeans
				matrix i=r(b)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		tostring p1 p2, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(black) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'" ) rows(1)) scheme(s1mono)
		}/*If*/

	if `num' == 3 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars' [`weight'`exp']  if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  [`weight'`exp']  if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp']  if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		tostring p1 p2 p3, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs8) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(black) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				 note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'") rows(1)) scheme(s1mono)
		}/*If*/

	if `num' == 4 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g4', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		tostring p1 p2 p3 p4, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(black) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3',  `l4' = `p4'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'") rows(2)) scheme(s1mono)
		} /*If*/
		
	if `num' == 5 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		local g5=`grp' in 5
		local l5=label in 5
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4' `g5'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4' `g5'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g1', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g2', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g3', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g4', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		glm `varlist' `cont' `covars' [`weight'`exp'] if `grp'==`g5', family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p5
			gen p5=r(p)
			
			
		tostring p1 p2 p3 p4 p5, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
			local p5=p5 in 1
		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(longdash_dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(gs6) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,5] + s[1,5]*x, range(`cont') lcolor(black) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3',  `l4' = `p4', `l5' = `p5'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'" 5 "`l5'") rows(2)) scheme(s1mono)
		} /*If*/
		
	if `num' == 6 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		local g5=`grp' in 5
		local l5=label in 5
		
		local g6=`grp' in 6
		local l6=label in 6
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars'  [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4' `g5' `g6'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4' `g5' `g6'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'  if `grp'==`g1'  [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2'  [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g3'  [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g4'  [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g5'  [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p5
			gen p5=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g6'  [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p6
			gen p6=r(p)	
			
			
		tostring p1 p2 p3 p4 p5 p6, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
			local p5=p5 in 1
			local p6=p6 in 1
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(longdash_dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(gs6) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,5] + s[1,5]*x, range(`cont') lcolor(black) lpattern(solid)) ///
				(function y = i[1,6] + s[1,6]*x, range(`cont') lcolor(gs10) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3'"  "`l4' = `p4', `l5' = `p5', `l6' = `p6'", size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'" 5 "`l5'" 6 "`l6'") rows(2)) scheme(s1mono)
		} /*If*/		

	if `num' == 7 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		local g5=`grp' in 5
		local l5=label in 5
		
		local g6=`grp' in 6
		local l6=label in 6
		
		local g7=`grp' in 7
		local l7=label in 7
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4' `g5' `g6' `g7'))  atmeans
				matrix s=r(b) 
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4' `g5' `g6' `g7'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'  if `grp'==`g1' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g3' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g4' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g5' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p5
			gen p5=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g6' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont' 
			capture drop p6
			gen p6=r(p)	
			
		glm `varlist' `cont' `covars'  if `grp'==`g7' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p7
			gen p7=r(p)		
			
			
		tostring p1 p2 p3 p4 p5 p6 p7, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
			local p5=p5 in 1
			local p6=p6 in 1
			local p7=p7 in 1		
		
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(longdash_dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(gs6) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,5] + s[1,5]*x, range(`cont') lcolor(black) lpattern(solid)) ///
				(function y = i[1,6] + s[1,6]*x, range(`cont') lcolor(black) lpattern(dash)) ///
				(function y = i[1,7] + s[1,7]*x, range(`cont') lcolor(gs10) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3'"  "`l4' = `p4', `l5' = `p5', `l6' = `p6', `l7' = `p7'" , size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'" 5 "`l5'" 6 "`l6'" 7 "`l7'") rows(2)) scheme(s1mono)
		} /*If*/						
	if `num' == 8 {
		table `grp', replace
		capture decode `grp', generate(label)
		capture gen label = `grp'
		capture tostring label, force format(%9.0f) replace
		
		
		local g1=`grp' in 1
		local l1=label in 1
		
		local g2=`grp' in 2
		local l2=label in 2
		
		local g3=`grp' in 3
		local l3=label in 3
		
		local g4=`grp' in 4
		local l4=label in 4
		
		local g5=`grp' in 5
		local l5=label in 5
		
		local g6=`grp' in 6
		local l6=label in 6
		
		local g7=`grp' in 7
		local l7=label in 7
		
		local g8=`grp' in 8
		local l8=label in 8
		
		use `current', clear
		
		glm `varlist' c.`cont'##`grp' `covars' , family(`fam') link(`link') iterate(`itnum')
			margins, dydx(`cont') at(`grp'=(`g1' `g2' `g3' `g4' `g5' `g6' `g7' `g8'))  atmeans
				matrix s=r(b)
			margins, at(`cont'=(0) `grp'=(`g1' `g2' `g3' `g4' `g5' `g6' `g7' `g8'))  atmeans
				matrix i=r(b)
		
		glm `varlist' `cont' `covars'  if `grp'==`g1' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p1
			gen p1=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g2' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p2
			gen p2=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g3' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p3
			gen p3=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g4' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p4
			gen p4=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g5' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p5
			gen p5=r(p)
			
		glm `varlist' `cont' `covars'  if `grp'==`g6' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p6
			gen p6=r(p)	
			
		glm `varlist' `cont' `covars'  if `grp'==`g7' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p7
			gen p7=r(p)		
		
		glm `varlist' `cont' `covars'  if `grp'==`g8' [`weight'`exp'], family(`fam') link(`link') iterate(`itnum')
			test `cont'
			capture drop p8
			gen p8=r(p)					
			
		tostring p1 p2 p3 p4 p5 p6 p7 p8, force format(%9.4f) replace
			local p1=p1 in 1
			local p2=p2 in 1
			local p3=p3 in 1
			local p4=p4 in 1
			local p5=p5 in 1
			local p6=p6 in 1
			local p7=p7 in 1		
			local p8=p8 in 1
		
		twoway (function y = i[1,1] + s[1,1]*x, range(`cont') lcolor(gs12) lpattern(dash)) ///
				(function y = i[1,2] + s[1,2]*x, range(`cont') lcolor(gs10) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,3] + s[1,3]*x, range(`cont') lcolor(gs8) lwidth(medthick) lpattern(longdash_dot)) ///
				(function y = i[1,4] + s[1,4]*x, range(`cont') lcolor(gs6) lwidth(medthick) lpattern(dot)) ///
				(function y = i[1,5] + s[1,5]*x, range(`cont') lcolor(black) lpattern(solid)) ///
				(function y = i[1,6] + s[1,6]*x, range(`cont') lcolor(black) lpattern(dash)) ///
				(function y = i[1,7] + s[1,7]*x, range(`cont') lcolor(gs6) lpattern(shortdash_dot_dot)) ///
				(function y = i[1,8] + s[1,8]*x, range(`cont') lcolor(gs10) lpattern(solid)), ///
				ytitle(`varlist') xtitle(`cont') title(`varlist'= `cont' X `grp', size(medsmall)) ///
				note($_if) subtitle("`l1' = `p1',  `l2' = `p2',  `l3' = `p3', `l4' = `p4'"  "`l5' = `p5', `l6' = `p6', `l7' = `p7', `l8' = `p8'" , size(small)) ///
				legend(order(1 "`l1'" 2 "`l2'"  3 "`l3'" 4 "`l4'" 5 "`l5'" 6 "`l6'" 7 "`l7'" 8 "`l8'") rows(2)) scheme(s1mono)
		} /*If*/			
		
}/*Weight*/
		
		use `master', clear		
		
}	/*QUI*/
end
