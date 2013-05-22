*Version 2.9
program define corrreport
syntax varlist [if] [in] [, iv(varlist) by(varname) bootstrap(numlist missingokay max=1) estround(numlist max=1 integer) bootcorr(name) pval log]
qui {
set more off
tempfile master using
save `master', replace

capture keep $_if
capture keep $_in
capture drop if `by'==.

if "`log'" =="log" {
	foreach var of varlist `varlist' {
		sum `var'
		local min=r(min)
		
		if `min' < 0 {
				noi: display as error "Cannot Log Transform Variables with Negative Numbers"
		}
		else {
			if `min'>=0 & `min'<1 {
				replace `var'=log(`var'+1)
			}
			else {
				replace `var'=log(`var')
		
			}
		}
	}
save `using', replace
}

else {
save `using', replace
}





tempfile output temp	
	clear
	set more off
	set obs 1
	gen var=""
	save `output', replace

	
	if "`by'" == "" & "`bootstrap'" ==""{
		use `using', clear
			foreach indv in `iv' {
				use `using', clear
					foreach var of varlist `varlist' {
						use `using', clear
					
							*Non Parametric
							spearman `var' `indv' 
								local srho=r(rho)
								local sn=r(N)
								local sp=r(p)
							
							*Parametric
							corr `var' `indv' 
								local prho=r(rho)
							regress `var' `indv' 
								local pn=e(N)
							test `indv'
								local pp=r(p)
								
								clear
								set obs 1
									gen var="`var'"
									gen iv="`indv'"
									gen N=`sn'
									gen spearman=`srho'
									gen spearman_p=`sp'
									gen pearson=`prho'
									gen pearson_p=`pp'
							if "`estround'" != "" {
								tostring spearman pearson, force format(%9.`estround'fc) replace
							}
							else {
								tostring spearman pearson, force format(%9.2fc) replace
							}
							tostring N, force format(%9.0f) replace
							if "`pval'" !="" {
								tostring spearman_p pearson_p, force format(%9.4f) replace
									replace  spearman_p = "<.0001" if  spearman_p =="0.0000"
									replace  pearson_p = "<.0001" if  pearson_p =="0.0000"
							}
							if "`pval'" =="" {
								gen sstar="†" if spearman_p <=0.10
									replace sstar="*" if spearman_p<=0.05
									replace sstar="**" if spearman_p<=0.01
									replace sstar="***" if spearman_p<=0.001
								gen pstar="†" if pearson_p <=0.10
									replace pstar="*" if pearson_p<=0.05
									replace pstar="**" if pearson_p<=0.01
									replace pstar="***" if pearson_p<=0.001
								
								replace spearman=sstar + spearman
								replace pearson=pstar+ pearson
								drop spearman_p pearson_p *star
							}
							
							save `temp', replace
							
							use `output', clear
								append using `temp'
								drop if var==""
							save `output', replace
					}/*var*/
			}/*iv*/
	}/*by*/
	
	if "`by'" != ""  & "`bootstrap'"==""{
		use `using', clear
			foreach indv in `iv' {
				use `using', clear
					foreach var of varlist `varlist' {
						use `using', clear
							
							table `by', replace
							local num=_N
							
							forvalues i=1(1)`num' {
								local grp`i'=`by' in `i'
							}
							
						use `using', clear
						forvalues i=1(1)`num' {
						use `using', clear
							*Non Parametric
								spearman `var' `indv' if `by'==`grp`i''
									local srho=r(rho)
									local sn=r(N)
									local sp=r(p)
							
							*Parametric
							corr `var' `indv' if `by'==`grp`i''
								local prho=r(rho)
							regress `var' `indv' if `by'==`grp`i''
								local pn=e(N)
							test `indv'
								local pp=r(p)
								
								clear
								set obs 1
									gen var="`var'"
									gen iv="`indv'"
									gen grp=`grp`i''
									gen N=`sn'
									gen spearman=`srho'
									gen spearman_p=`sp'
									gen pearson=`prho'
									gen pearson_p=`pp'
							if "`estround'" != "" {
								tostring spearman pearson, force format(%9.`estround'fc) replace
							}
							else {
								tostring spearman pearson, force format(%9.2fc) replace
							}
							tostring N, force format(%9.0f) replace
							
								tempfile temp`i'
								save `temp`i'', replace
							}
						use `temp1', clear
							forvalues i=2(1)`num' {
								append using `temp`i''
							}
						reshape wide N spearman* pearson*, i(var iv) j(grp)
					
							if "`pval'" !="" {
								tostring spearman_p* pearson_p*, force format(%9.4f) replace
								
								forvalues i=1(1)`num' {
									replace spearman_p`grp`i'' = "<.0001" if  spearman_p`grp`i''=="0.0000"
									replace pearson_p`grp`i'' = "<.0001" if  pearson_p`grp`i''=="0.0000"
								}
								
							}
							if "`pval'" =="" {
								forvalues i=1(1)`num' {
									gen sstar`grp`i''="†" if spearman_p`grp`i'' <=0.10
										replace sstar`grp`i''="*" if spearman_p`grp`i''<=0.05
										replace sstar`grp`i''="**" if spearman_p`grp`i''<=0.01
										replace sstar`grp`i''="***" if spearman_p`grp`i''<=0.001
									gen pstar`grp`i''="†" if pearson_p`grp`i'' <=0.10
										replace pstar`grp`i''="*" if pearson_p`grp`i''<=0.05
										replace pstar`grp`i''="**" if pearson_p`grp`i''<=0.01
										replace pstar`grp`i''="***" if pearson_p`grp`i''<=0.001
									
									replace spearman`grp`i''=sstar`grp`i'' + spearman`grp`i''
									replace pearson`grp`i''=pstar`grp`i''+ pearson`grp`i''
				
								}/*Forvalues*/
								drop spearman_p* pearson_p* *star*
							}
						
							save `temp', replace
							
							use `output', clear
								append using `temp'
								drop if var==""
							save `output', replace
					}/*var*/
			}/*iv*/
	}/*by*/
	
	
	
	
	if "`by'" =="" & "`bootstrap'" != "" {
		use `using', clear
			foreach indv in `iv' {
				use `using', clear
					foreach var of varlist `varlist' {
						use `using', clear
							tempfile `var' tempall
							
							if "`bootcorr'" == "spearman" {
								bootstrap `var'=r(rho), seed(`bootstrap') reps(`bootstrap') saving(``var'', replace) : spearman  `var' `indv'
								matrix x=e(b)
									local `var'rho=x[1,1]
								matrix y= e(ci_percentile)
									local `var'lo=y[1,1]
									local `var'hi=y[2,1]
								spearman `var' `indv'
									local `var'p=r(p)
							
							}
							if "`bootcorr'" == "pearson" {
								bootstrap `var'=r(rho), seed(`bootstrap') reps(`bootstrap') saving(``var'', replace) : corr  `var' `indv'
								matrix x=e(b)
									local `var'rho=x[1,1]
								matrix y= e(ci_percentile)
									local `var'lo=y[1,1]
									local `var'hi=y[2,1]
								regress `var' `indv'
									test `indv'
									local `var'p=r(p)
							}
							else {
								bootstrap `var'=r(rho), seed(`bootstrap') reps(`bootstrap') saving(``var'', replace) : corr  `var' `indv'
								matrix x=e(b)
									local `var'rho=x[1,1]
								matrix y= e(ci_percentile)
									local `var'lo=y[1,1]
									local `var'hi=y[2,1]
								regress `var' `indv'
									test `indv'
									local `var'p=r(p)
							}
								
								use ``var'', clear
									egen order=seq()
									
									
								save ``var'', replace
						}
				
							foreach var in `varlist' {
									use ``var'', clear
									save `tempall', replace
								}
								
							use `tempall', clear
							foreach var in `varlist'  {
								joinby order using ``var'', unmatched(none)
							}
							duplicates drop
						
							local threshold=_N/2
							
						foreach x of varlist `varlist' {
								gen `x'1= ``x'rho'
								gen `x'2= ``x'lo'
								gen `x'3= ``x'hi'
								gen `x'p=``x'p'
							
							if "`estround'" != "" {
								tostring `x'1 `x'2 `x'3, force format(%9.`estround'fc) replace
							}
							else {
								tostring `x'1 `x'2 `x'3, force format(%9.3f) replace
							}
								
									gen `x'star="†" if `x'p <=0.10
										replace `x'star="*" if `x'p<=0.05
										replace `x'star="**" if `x'p<=0.01
										replace `x'star="***" if `x'p<=0.001
					
								
								
								gen `x'rho=`x'star + `x'1 + " (" + `x'2 + ", " + `x'3 + ")"
									drop `x'1 `x'2 `x'3 `x'star `x'p
							
							capture label var `x'rho "Rho of `x' and IV"
							
							foreach y of varlist `varlist' {
									gen `x'_`y'_p= `x' >=`y'
										count if `x'_`y'_p ==1
									local n=r(N)
								if `n' >= `threshold' {
									replace `x'_`y'_p=2* (1-(`n'/`bootstrap'))
									replace `x'_`y'_p=0.9999 if `x'_`y'_p>=1
								}
								if `n' < `threshold' {
									replace `x'_`y'_p=2* (1-((`bootstrap'-`n')/`bootstrap'))
									replace `x'_`y'_p=0.9999 if `x'_`y'_p>=1
								}
								
								if "`y'" == "`x'" {
									capture drop `y'_`x'_p
									capture drop `x'_`y'_p
								}
								capture label var `x'_`y'_p "P value of Rho comparison of of `x' and IV to `y' and IV"
							}/*Y*/
						} /*X*/
							gen iv="`indv'"
							keep iv *_p *rho
							keep in 1
						
							if `bootstrap' <=100 {
								tostring *_p, force format(%9.2f) replace
								foreach x of varlist *_p {
									replace `x' ="<.01" if `x'=="0.00"
								}
							}
							if `bootstrap' >100 &  `bootstrap' <=1000{
								tostring *_p, force format(%9.3f) replace
								foreach x of varlist *_p {
									replace `x' ="<.001" if `x'=="0.000"
								}
							}
							if  `bootstrap' >1000  {
								tostring *_p, force format(%9.4f) replace
								foreach x of varlist *_p {
									replace `x' ="<.0001" if `x'=="0.0000"
								}
							}
					
					save `temp', replace
					
					use `output', clear
						append using `temp'
					save `output', replace
				} /*IV*/	
				drop var
				drop if iv==""
				order iv

	}/*BY*/
		
	if "`by'" !="" & "`bootstrap'" != "" {
		use `using', clear
			foreach indv in `iv' {
				use `using', clear
					foreach var of varlist `varlist' {
						use `using', clear
							tempfile tempall
							
							table `by', replace
							local num=_N
							
							forvalues i=1(1)`num' {
								local grp`i'=`by' in `i'
							}
							use `using', clear
							
						forvalues i=1(1)`num' {
							use `using', clear
			
							tempfile temp`i'
								if "`bootcorr'" == "spearman" {
									bootstrap v`grp`i''=r(rho), seed(`bootstrap') reps(`bootstrap') saving(`temp`i'', replace) : spearman  `var' `indv' if `by'==`grp`i''
									matrix x=e(b)
										local rho`i'=x[1,1]
									matrix y= e(ci_percentile)
										local lo`i'=y[1,1]
										local hi`i'=y[2,1]
									spearman `var' `indv' if `by'==`grp`i''
										local p`i'=r(p)
								}
								if "`bootcorr'" == "pearson" {
									bootstrap v`grp`i''=r(rho), seed(`bootstrap') reps(`bootstrap') saving(`temp`i'', replace) : corr  `var' `indv' if `by'==`grp`i''
									
									matrix x=e(b)
										local rho`i'=x[1,1]
									matrix y= e(ci_percentile)
										local lo`i'=y[1,1]
										local hi`i'=y[2,1]
									regress `var' `indv' if `by'==`grp`i''
										test `indv'
										local p`i'=r(p)					
								}
								else {
									bootstrap v`grp`i''=r(rho), seed(`bootstrap') reps(`bootstrap') saving(`temp`i'', replace) : corr  `var' `indv' if `by'==`grp`i''
								
									matrix x=e(b)
										local rho`i'=x[1,1]
									matrix y= e(ci_percentile)
										local lo`i'=y[1,1]
										local hi`i'=y[2,1]
									regress `var' `indv' if `by'==`grp`i''
										test `indv'
										local p`i'=r(p)
								}	
						
								
								
								use `temp`i'', clear
									egen order=seq()
									
									
								save `temp`i'', replace
						}
				
							use `temp1', clear
							forvalues i=1(1)`num' {
								joinby order using `temp`i'', unmatched(none)
							}
						
							local threshold=_N/2
							
						forvalues  i=1(1)`num' {
								gen rho`grp`i''= `rho`i''
								gen lo`grp`i''= `lo`i''
								gen hi`grp`i''= `hi`i''
								gen p`grp`i''=`p`i''
							
							
							if "`estround'" != "" {
								tostring rho* lo* hi*, force format(%9.`estround'fc) replace
							}
							else {
								tostring rho* lo* hi*, force format(%9.3f) replace
							}
							
									gen star`grp`i''="†" if p`grp`i'' <=0.10
										replace star`grp`i''="*" if p`grp`i''<=0.05
										replace star`grp`i''="**" if p`grp`i''<=0.01
										replace star`grp`i''="***" if p`grp`i''<=0.001
					
								
								
								gen rho_`grp`i''=star`grp`i'' + rho`grp`i'' + " (" + lo`grp`i'' + ", " + hi`grp`i'' + ")"
									drop rho`grp`i'' lo`grp`i'' hi`grp`i'' star`grp`i'' p`grp`i''
							
							capture label var rho_`grp`i'' "Rho of Var and IV in `by'==`grp`i''"
							
							forvalues y=2(1)`num'  {
									gen grp`grp`i''_`grp`y''_p=  v`grp`i'' >= v`grp`y''
										count if  grp`grp`i''_`grp`y''_p ==1
									local n=r(N)
								if `n' >= `threshold' {
									replace grp`grp`i''_`grp`y''_p=2* (1-(`n'/`bootstrap'))
									replace grp`grp`i''_`grp`y''_p=0.9999 if grp`grp`i''_`grp`y''_p>=1
								}
								if `n' < `threshold' {
									replace grp`grp`i''_`grp`y''_p=2* (1-((`bootstrap'-`n')/`bootstrap'))
									replace grp`grp`i''_`grp`y''_p=0.9999 if grp`grp`i''_`grp`y''_p>=1
								}
								
								if "`y'" == "`i'" {
									capture drop grp`grp`i''_`grp`y''_p
									capture drop grp`grp`y''_`grp`i''_p
								}
								if "`y'" > "`i'" {
									capture drop grp`grp`y''_`grp`i''_p
								}
								capture label var grp`grp`i''_`grp`y''_p  "P value of Rho comparison for `by' groups `grp`i'' vs `grp`y'"
							}/*Y*/
						} /*X*/
							gen var="`var'"
							gen iv="`indv'"
							keep iv var *_p rho*
							keep in 1
						
							if `bootstrap' <=100 {
								tostring *_p, force format(%9.2f) replace
								foreach x of varlist *_p {
									replace `x' ="<.01" if `x'=="0.00"
								}
							}
							if `bootstrap' >100 &  `bootstrap' <=1000{
								tostring *_p, force format(%9.3f) replace
								foreach x of varlist *_p {
									replace `x' ="<.001" if `x'=="0.000"
								}
							}
							if  `bootstrap' >1000  {
								tostring *_p, force format(%9.4f) replace
								foreach x of varlist *_p {
									replace `x' ="<.0001" if `x'=="0.0000"
								}
							}
					
					save `temp', replace
					
					use `output', clear
						append using `temp'
					save `output', replace
				} /*IV*/	
				drop if iv==""
				order iv var
		}/*VAR*/
	}/*BY*/		

}/*QUI*/
	end

	/*if "`by'" != ""  & "`bootstrap'"!=""{
		use `using', clear
			foreach indv in `iv' {
				use `using', clear
					foreach var of varlist `varlist' {
						use `using', clear
							
							table `by', replace
							local num=_N
							
							forvalues i=1(1)`num' {
								local grp`i'=`by' in `i'
							}
							
						use `using', clear
						forvalues i=1(1)`num' {
						use `using', clear
							*Non Parametric
								spearman `var' `indv' if `by'==`grp`i''
									local srho=r(rho)
									local sn=r(N)
									local sp=r(p)
							
							*Parametric
							corr `var' `indv' if `by'==`grp`i''
								local prho=r(rho)
							regress `var' `iv' if `by'==`grp`i''
								local pn=e(N)
							test `iv'
								local pp=r(p)
								
								clear
								set obs 1
									gen var="`var'"
									gen iv="`indv'"
									gen grp=`grp`i''
									gen N=`sn'
									gen spearman=`srho'
									gen spearman_p=`sp'
									gen pearson=`prho'
									gen pearson_p=`pp'
							tostring spearman pearson, force format(%9.3f) replace
							tostring N, force format(%9.0f) replace
							
								tempfile temp`i'
								save `temp`i'', replace
							}
						use `temp1', clear
							forvalues i=2(1)`num' {
								append using `temp`i''
							}
						reshape wide N spearman* pearson*, i(var iv) j(grp)
					
							if "`pval'" !="" {
								tostring spearman_p* pearson_p*, force format(%9.4f) replace
							}
							if "`pval'" =="" {
								forvalues i=1(1)`num' {
									gen sstar`grp`i''="†" if spearman_p`grp`i'' <=0.10
										replace sstar`grp`i''="*" if spearman_p`grp`i''<=0.05
										replace sstar`grp`i''="**" if spearman_p`grp`i''<=0.01
										replace sstar`grp`i''="***" if spearman_p`grp`i''<=0.001
									gen pstar`grp`i''="†" if pearson_p`grp`i'' <=0.10
										replace pstar`grp`i''="*" if pearson_p`grp`i''<=0.05
										replace pstar`grp`i''="**" if pearson_p`grp`i''<=0.01
										replace pstar`grp`i''="***" if pearson_p`grp`i''<=0.001
									
									replace spearman`grp`i''=sstar`grp`i'' + spearman`grp`i''
									replace pearson`grp`i''=pstar`grp`i''+ pearson`grp`i''
								}/*Forvalues*/
								drop spearman_p* pearson_p* *star*
							}
						
							save `temp', replace
							
							use `output', clear
								append using `temp'
								drop if var==""
							save `output', replace
					}/*var*/
			}/*iv*/
	}/*by*/
	
	
}/*qui*/
end

/*OLD CODE Prior to 07/29/2011
save faketemp.dta, replace


use faketemp.dta, clear
if "`pval'"=="" {
	corrreportnop `varlist' $_if, iv(`iv') bootstrap(`bootstrap')
}

if "`pval'"!="" {
	corrreportp `varlist' $_if, iv(`iv') bootstrap(`bootstrap')
}
		
	

	
	drop if var==""
	capture erase `temp'
	capture erase faketemp.dta
	capture label var bs_reps "Bootstrap Repititions"
	capture label var n "N"
	capture label var spearman "Spearman Rho"
	capture label var pearson "Pearson Rho"
	capture label var spearman_p "Spearman P Value"
	capture label var pearson_p "Pearson P Value"
	capture label var spearman_ci "Spearman Bootstrap Percentile CI"
	capture label var pearson_ci "Pearson Bootstrap Percentile CI"
	
}
list ,  noobs divider sepby(var) 

end



program corrreportnop
syntax varlist [if] [, iv(varlist) bootstrap(numlist missingokay max=1)]
qui {
tempfile output temp	
	clear
	set more off
	set obs 1
	gen var=""
	save `output', replace

if "`bootstrap'"=="" {

		use faketemp.dta, clear

		foreach iv in `iv' {
			use faketemp.dta, clear
		foreach var of varlist `varlist' {
			
			
			use faketemp.dta, clear
			/***Overall Adjusted means***/
			spearman `var' `iv' $_if
				local srho=r(rho)
				local sn=r(N)
				local sp=r(p)
			corr `var' `iv' $_if
				local prho=r(rho)
			regress `var' `iv' $_if
				local pn=e(N)
			test `iv'
				local pp=r(p)
				
				clear
				set obs 1
					gen srho=`srho'
					gen prho=`prho'
					gen sn=`sn'
					gen pn=`pn'
					gen sp=`sp'
					gen pp=`pp'
				
					gen sstar="†" if sp <=0.10
					replace sstar="*" if sp<=0.05
					replace sstar="**" if sp<=0.01
					replace sstar="***" if sp<=0.001
					
					capture gen pstar="†" if pp <=0.10
					capture replace pstar="*" if pp<=0.05
					capture replace pstar="**" if pp<=0.01
					capture replace pstar="***" if pp<=0.001
				tostring *rho, force format(%9.3f) replace
				tostring *n, force format(%9.0f) replace
				gen var="`var'"
				gen iv="`iv'"
				gen n="(" + sn + ")"
				gen spearman= sstar + srho 
				gen pearson= pstar + prho 
				keep var iv n spearman pearson
			
			save `temp', replace
			use `output', clear
			append using `temp'
			save `output', replace
			
		}
		}
	}

	if "`bootstrap'"!=""{
		
		
		use faketemp.dta, clear

		foreach iv in `iv' {
			use faketemp.dta, clear
		foreach var of varlist `varlist' {
			
			
			use faketemp.dta, clear
			/***Overall Adjusted means***/
				drop if `var'==.
				drop if `iv'==.
				capture keep $_if
			bootstrap r(rho), reps(`bootstrap') seed(`bootstrap'): spearman `var' `iv' $_if
				local srho=_b[_bs_1]
				matrix s=e(ci_percentile)
				local sn=e(N)
			test _bs_1
				local sp=r(p)
				
			bootstrap r(rho), reps(`bootstrap') seed(`bootstrap'): corr `var' `iv' $_if
				local prho=_b[_bs_1]
				local pn=e(N)
				matrix p=e(ci_percentile)
			test _bs_1
				local pp=r(p)
				
				clear
				set obs 1
					gen srho=`srho'
					gen prho=`prho'
					gen s_hi=s[2,1]
					gen s_lo=s[1,1]
					gen p_hi=p[2,1]
					gen p_lo=p[1,1]
					tostring p_* s_*, force format(%9.3f) replace
					gen pearson_ci=p_lo + " - " +p_hi
					gen spearman_ci=s_lo + " - " +s_hi
					gen sn=`sn'
					gen pn=`pn'
					gen sp=`sp'
					gen pp=`pp'	
					gen bs_reps=`bootstrap'
					
					
					gen sstar="†" if sp <=0.10
					replace sstar="*" if sp<=0.05
					replace sstar="**" if sp<=0.01
					replace sstar="***" if sp<=0.001
					
					capture gen pstar="†" if pp <=0.10
					capture replace pstar="*" if pp<=0.05
					capture replace pstar="**" if pp<=0.01
					capture replace pstar="***" if pp<=0.001
					
				tostring *rho, force format(%9.3f) replace
				tostring *n bs_reps, force format(%9.0f) replace
				gen var="`var'"
				gen iv="`iv'"
				gen n="(" + sn + ")"
				gen spearman= sstar + srho 
				gen pearson= pstar + prho 
				keep var iv bs_reps n spearman spearman_ci pearson pearson_ci
				order var iv bs_reps n spearman spearman_ci pearson pearson_ci
			save `temp', replace
			use `output', clear
			append using `temp'
			save `output', replace
			
		}
		}
	}
}
end


program corrreportp
syntax varlist [if] [, iv(varlist) bootstrap(numlist missingokay max=1)]

tempfile output temp	
	clear
	set more off
	set obs 1
	gen var=""
	save `output', replace

if "`bootstrap'"=="" {

		use faketemp.dta, clear

		foreach iv in `iv' {
			use faketemp.dta, clear
		foreach var of varlist `varlist' {
			
			
			use faketemp.dta, clear
			/***Overall Adjusted means***/
			spearman `var' `iv' $_if
				local srho=r(rho)
				local sn=r(N)
				local sp=r(p)
			corr `var' `iv' $_if
				local prho=r(rho)
			regress `var' `iv' $_if	
				local pn=e(N)
			test `iv'
				local pp=r(p)
				
				clear
				set obs 1
					gen srho=`srho'
					gen prho=`prho'
					gen sn=`sn'
					gen pn=`pn'
					gen spearman_p=`sp'
					gen pearson_p=`pp'
				

				tostring *rho, force format(%9.3f) replace
				tostring *n, force format(%9.0f) replace
				tostring *_p, force format(%9.4f) replace
				gen var="`var'"
				gen iv="`iv'"
				gen n="(" + sn + ")"
				gen spearman= srho 
				gen pearson= prho 
				keep var iv n spearman spearman_p pearson pearson_p
					order var iv n spearman spearman_p pearson pearson_p
			save `temp', replace
			use `output', clear
			append using `temp'
			save `output', replace
			
		}
		}
	}

	if "`bootstrap'"!=""{
		
		
		use faketemp.dta, clear

		foreach iv in `iv' {
			use faketemp.dta, clear
		foreach var of varlist `varlist' {
			
			
			use faketemp.dta, clear
			/***Overall Adjusted means***/
				drop if `var'==.
				drop if `iv'==.
				capture keep $_if
			bootstrap r(rho), reps(`bootstrap') seed(`bootstrap'): spearman `var' `iv' $_if
				local srho=_b[_bs_1]
				matrix s=e(ci_percentile)
				local sn=e(N)
			test _bs_1
				local sp=r(p)
				
			bootstrap r(rho), reps(`bootstrap') seed(`bootstrap'): corr `var' `iv' $_if
				local prho=_b[_bs_1]
				local pn=e(N)
				matrix p=e(ci_percentile)
			test _bs_1
				local pp=r(p)
				
			clear
				set obs 1
					gen srho=`srho'
					gen prho=`prho'
					gen s_hi=s[2,1]
					gen s_lo=s[1,1]
					gen p_hi=p[2,1]
					gen p_lo=p[1,1]
					tostring p_* s_*, force format(%9.3f) replace
					gen pearson_ci=p_lo + " - " +p_hi
					gen spearman_ci=s_lo + " - " +s_hi
					gen sn=`sn'
					gen pn=`pn'
					gen spearman_p=`sp'
					gen pearson_p=`pp'	
					gen bs_reps=`bootstrap'
				
				tostring *rho, force format(%9.3f) replace
				tostring *n bs_reps, force format(%9.0f) replace
				tostring *_p, force format(%9.4f) replace
				gen var="`var'"
				gen iv="`iv'"
				gen n="(" + sn + ")"
				gen spearman=srho 
				gen pearson= prho 
				keep var iv bs_reps n spearman spearman_p pearson pearson_p spearman_ci pearson_ci
					order var iv bs_reps n spearman spearman_ci spearman_p pearson pearson_ci pearson_p
			save `temp', replace
			use `output', clear
			append using `temp'
			save `output', replace
			
		}
		}
	}
end
exit
