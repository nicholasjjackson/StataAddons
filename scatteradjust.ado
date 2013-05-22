program scatteradjust
syntax varlist [if] [in] [, iv(varlist) adjust(string) ]
qui {
	tempfile master using
	save `using', replace

	foreach var of varlist `adjust' {
			inspect `var' $_if $_in
			local num=r(N_unique)
			if `num' >=3 & `num' <= 10 {
				display as error "Multicategorical Covariated Must have Dummy Codes Created"
			}
			else {
			}
	}
	
	*use `using', clear
	foreach var of varlist `varlist' {
			foreach iv in `iv' {
			
					if "`if'"=="" {
							regress `var' `adjust' if `iv' !=.
								capture drop y`var'_`iv'
								predict y`var'_`iv' if e(sample), resid
							label var y`var'_`iv' "`var' residuals for `iv' modeling"
							
						
							regress `iv' `adjust' if `var'!=.
								capture drop x`iv'_`var'
								predict x`iv'_`var' if e(sample), resid
							label var x`iv'_`var' "`iv' residuals for `var' modeling"
					}
					if "`if'" != "" {
							regress `var' `adjust' $_if  & `iv' !=.
								capture drop y`var'_`iv'
								predict y`var'_`iv' if e(sample), resid
							label var y`var'_`iv' "`var' residuals for `iv' modeling"
							
						
							regress `iv' `adjust' $_if & `var'!=.
								capture drop x`iv'_`var'
								predict x`iv'_`var' if e(sample), resid
							label var x`iv'_`var' "`iv' residuals for `var' modeling"
					}
			}
	}
}	
	end
	exit
		