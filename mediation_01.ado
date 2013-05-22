program mediation_01, rclass
syntax varlist [if] [in] [pweight] [, iv(varlist) mv(varlist) covars(string)]
		 tempfile using 
		 save `using', replace
		 
		 	table `iv' if `mv' !=., replace 
			 drop in 1
			 global max=_N
			 forvalues i=1(1)$max {
				local `i'=`iv' in `i'
			 }
		
		if "`weight'" =="" {
		 use `using', clear
			/*Step 2: IV Related to MV*/
			regress `mv' i.`iv' `covars' if `varlist'!=.
				forvalues i=1(1)$max {
					local acoef`i'=_b[``i''.`iv']
					}
			/*Step 3*/						  
			regress `varlist' i.`iv' `mv' `covars' 
					local bcoef=_b[`mv']
			
		}
		if "`weight'" !="" {
		 use `using', clear
			/*Step 2: IV Related to MV*/
			regress `mv' i.`iv' `covars' if `varlist'!=. [`weight' `exp']
				forvalues i=1(1)$max {
					local acoef`i'=_b[``i''.`iv']
					}
			/*Step 3*/						  
			regress `varlist' i.`iv' `mv' `covars'  [`weight' `exp']
					local bcoef=_b[`mv']
			
		}
		
			capture drop new*
			forvalues i=1(1)$max {
				gen new`i'=`acoef`i''*`bcoef'
			}
			capture drop indirect
			egen indirect=rowtotal(new*)
					drop new*		
			local indirect=indirect
			
			return scalar ind = (`indirect')
end
