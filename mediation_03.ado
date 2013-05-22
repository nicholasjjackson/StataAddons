program mediation_03, rclass
syntax varlist [if] [in] [pweight] [, iv(varlist) mv(varlist) covars(string)]

		if "`weight'"=="" {
			/*Step 2: IV Related to MV*/
			sum `iv' if `varlist'!=. & `mv'!=.
				local sdiv=r(sd)
			logit `mv' `iv' `covars' if `varlist'!=.
											 
				*Compute SD of MV as an Outcome
				local mvoutsd=sqrt((_b[`iv']^2)*(`sdiv'^2)+(_pi^2/3) )
				*Scale the coefficient by multiplying by SD of the predictor divided by SD of outcome(MV)
				local acoef=_b[`iv']*`sdiv'/`mvoutsd'
				
				
			/*Step 3*/						  
			sum `varlist' if `iv1'!=. & `mv1' !=.
				local sddv=r(sd)
									
			sum `mv1' if `varlist'!=. & `mv1' !=.
				local sdmv=r(sd)	
	
			regress `varlist' `iv' `mv' `covars' 
				local bcoef=_b[`mv']*`sdmv'/`sddv'
		}
		if "`weight'"!="" {
		svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
			/*Step 2: IV Related to MV*/
			svy linearized : mean `iv' if `varlist'!=. & `mv'!=.
				estat sd
				matrix sd=r(sd)
				local sdiv=sd[1,1]
				
			logit `mv' `iv' `covars' if `varlist'!=. [`weight' `exp']
											 
				*Compute SD of MV as an Outcome
				local mvoutsd=sqrt((_b[`iv']^2)*(`sdiv'^2)+(_pi^2/3) )
				*Scale the coefficient by multiplying by SD of the predictor divided by SD of outcome(MV)
				local acoef=_b[`iv']*`sdiv'/`mvoutsd'
				
				
			/*Step 3*/						  
			svy linearized : mean `varlist' if `iv1'!=. & `mv1' !=.
				estat sd
				matrix sd=r(sd)
				local sddv=sd[1,1]
									
			svy linearized : mean `mv1' if `varlist'!=. & `mv1' !=.
				estat sd
				matrix sd=r(sd)
			
				local sdmv=sd[1,1]	
	
			regress `varlist' `iv' `mv' `covars'  [`weight' `exp']
				local bcoef=_b[`mv']*`sdmv'/`sddv'
		}		
		
			return scalar ind = (`acoef'*`bcoef')
end	
