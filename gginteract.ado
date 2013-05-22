
program gginteract
syntax varlist (max=1) [if] [pweight] [, grp1(varname) grp2(varname) covars(string) fam(name) link(name) labsize(name) iterate(numlist max=1 integer)]
set more off
*Version 2.0
qui {
noi: display "Please ensure covariates are centered before beginning "
if "`iterate'" == "" {
	local itnum=500
}
if "`iterate'" != "" {
	local itnum=`iterate'
}


tempfile current master
save `master', replace
	capture keep $_if


	save `current', replace
*
		inspect `grp1' if `grp2'!=. & `varlist'!=.
			local row1=r(N_unique)
		sum `grp1' if `grp2'!=. & `varlist'!=.
			local min1=r(min)
			
		inspect `grp2' if `grp1'!=. & `varlist'!=.
			local row2=r(N_unique)
		sum `grp2' if `grp1'!=. & `varlist'!=.
			local min2=r(min)
			local max2=r(max)
	
		local num=`row1'*`row2'
		if "`weight'" =="" {
			glm `varlist' `grp1'##`grp2' `covars' , family(`fam') link(`link') iterate(`itnum')
		}
		else {
			glm `varlist' `grp1'##`grp2' `covars' [`weight'`exp'] , family(`fam') link(`link') iterate(`itnum')
		}
			
			
			margins `grp1'#`grp2', post  atmeans
			matrix x = e(b)
			
		clear
		set obs `num'
		gen mean=.
		forvalues i=1(1)`num' {
			replace mean=x[1, `i'] in `i'
		}
		egen order=seq()
		
		
		tempfile temp1 
		save `temp1', replace
		
		use `current', clear
			drop if `grp1'==.
			drop if `grp2'==.
		
			keep `grp1' `grp2' 
			duplicates drop
			sort `grp1' `grp2'
			egen order=seq()
			
		tempfile temp2
		save `temp2', replace
		
		use `temp1', clear
		joinby order  using `temp2', unmatched(none)
			
		if "`labsize'"	=="" {
			graph bar (mean) mean, over(`grp1', label(labsize(vsmall))) over(`grp2', label(labsize(medsmall))) ///
			bar(1, fcolor(gs10)) ytitle(`varlist') ytitle(, margin(medsmall)) title(`varlist' = `grp1' X `grp2', size(medsmall)) note($_if) scheme(s1mono)
		}
		if "`labsize'"	!="" {
			graph bar (mean) mean, over(`grp1', label(labsize(`labsize'))) over(`grp2', label(labsize(`labsize'))) ///
			bar(1, fcolor(gs10)) ytitle(`varlist') ytitle(, margin(medsmall)) title(`varlist' = `grp1' X `grp2', size(medsmall)) note($_if) scheme(s1mono)
		}
		
		
	use `master', clear
}		
end
