program mediation_02, rclass
syntax varlist [if] [in] [pweight] [, iv(varlist) mv(varlist) covars(string)]

		if "`weight'"=="" {

			/*Step 2: IV Related to MV*/
			regress `mv' `iv' `covars' if `varlist'!=.
					local acoef=_b[`iv']
			/*Step 3*/						  
			regress `varlist' `iv' `mv' `covars' 
					local bcoef=_b[`mv']
		}
		if "`weight'"!="" {

			/*Step 2: IV Related to MV*/
			regress `mv' `iv' `covars' if `varlist'!=. [`weight' `exp']
					local acoef=_b[`iv']
			/*Step 3*/						  
			regress `varlist' `iv' `mv' `covars'  [`weight' `exp']
					local bcoef=_b[`mv']
		}		
			return scalar ind = (`acoef'*`bcoef')
end	
