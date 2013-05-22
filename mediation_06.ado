program mediation_06, rclass
syntax varlist [if] [in]  [pweight] [, iv(varlist) mv(varlist) covars(string)]
		 tempfile using 
		 save `using', replace
		 
		 	table `iv' if `mv' !=., replace 
			 drop in 1
			 global max=_N
			 forvalues i=1(1)$max {
				local `i'=`iv' in `i'
			 }
			
		 use `using', clear
		if "`weight'" == "" {
			/*Step 2: IV Related to MV (Path A)*/
			sum `mv' if `iv'!=. & `varlist'!=.
				local mvsd=r(sd)
			sum `iv' if `mv'!=. & `varlist'!=.
				local ivsd=r(sd)	
						
			regress `mv' `iv' `covars' if `varlist'!=.
				testparm `iv'
				  local p2=r(p)
					local acoef=_b[`iv']*`ivsd'/`mvsd'
					local avar=(_se[`iv']*`ivsd'/`mvsd')^2

			
			/*Steps 3 and 4: MV related to DV and IV not related to DV*/
			logit `varlist' `iv' `mv' `covars' 
										
				local dvoutsd=sqrt(((_b[`mv']^2)*(`mvsd'^2)+(_pi^2/3)))
				local bcoef=_b[`mv']*`mvsd'/`dvoutsd'
		}
		if "`weight'" != "" {
			svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
			/*Step 2: IV Related to MV (Path A)*/
			svy linearized : mean `mv' if `iv'!=. & `varlist'!=.
				estat sd
				matrix sd=r(sd)
				local mvsd=sd[1,1]
			svy linearized : mean `iv' if `mv'!=. & `varlist'!=.
				estat sd
				matrix sd=r(sd)
				local ivsd=sd[1,1]	
						
			regress `mv' `iv' `covars' if `varlist'!=. [`weight' `exp']
				testparm `iv'
				  local p2=r(p)
					local acoef=_b[`iv']*`ivsd'/`mvsd'
					local avar=(_se[`iv']*`ivsd'/`mvsd')^2

			
			/*Steps 3 and 4: MV related to DV and IV not related to DV*/
			logit `varlist' `iv' `mv' `covars'  [`weight' `exp']
										
				local dvoutsd=sqrt(((_b[`mv']^2)*(`mvsd'^2)+(_pi^2/3)))
				local bcoef=_b[`mv']*`mvsd'/`dvoutsd'
		}								
					

			/*Estimate Indirect Effect**/		
			return scalar ind = (`acoef'*`bcoef')

end
