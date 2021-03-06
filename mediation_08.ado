program mediation_08, rclass
syntax varlist [if] [in] [pweight] [, iv(varlist) mv(varlist) covars(string)]
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
			logit `mv' i.`iv' `covars' if `varlist'!=.

				capture drop new*
				tab `iv', gen(new)
				
					/****NOTE: NEED A WAY TO ESTIMATE SD of Categorical IV**/
				forvalues i=1(1)$max {
					local newnum=`i'+1
					sum new`newnum' if  `varlist' !=. & `mv'!=.
						local sdiv`i'=r(sd)
					local mvoutsd`i'=((_b[``i''.`iv']^2)*(`sdiv`i''^2)+(_pi^2/3) )
						local acoef`i'=_b[``i''.`iv']*`sdiv`i''/`mvoutsd`i''
						local avar`i'=(_se[``i''.`iv']*`sdiv`i''/`mvoutsd`i'')^2 
				  }
			
			/*Steps 3 and 4: MV related to DV and IV not related to DV*/
			sum `varlist' if `iv'!=. & `mv' !=.
				local sddv=r(sd)
					
				sum `mv' if `varlist'!=. & `iv' !=.
					local mvsd=r(sd)	
					
				logit `varlist' i.`iv' `mv' `covars' 

						local dvoutsd=sqrt((_b[`mv']^2)*(`mvsd'^2)+(_pi^2/3) )
						local bcoef=_b[`mv']*`mvsd'/`dvoutsd'
					
			}
			if "`weight'" != "" {
			/*Step 2: IV Related to MV (Path A)*/
			logit `mv' i.`iv' `covars' if `varlist'!=. [`weight' `exp']

				capture drop new*
				tab `iv', gen(new)
				
					/****NOTE: NEED A WAY TO ESTIMATE SD of Categorical IV**/
				forvalues i=1(1)$max {
					local newnum=`i'+1
					svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
					svy linearized : mean new`newnum' if  `varlist' !=. & `mv'!=.
						estat sd
						matrix sd=r(sd)
						local sdiv`i'=sd[1,1]
					logit `mv' i.`iv' `covars' if `varlist'!=. [`weight' `exp']	
					local mvoutsd`i'=((_b[``i''.`iv']^2)*(`sdiv`i''^2)+(_pi^2/3) )
						local acoef`i'=_b[``i''.`iv']*`sdiv`i''/`mvoutsd`i''
						local avar`i'=(_se[``i''.`iv']*`sdiv`i''/`mvoutsd`i'')^2 
				  }
			
			/*Steps 3 and 4: MV related to DV and IV not related to DV*/
			svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
			svy linearized : mean `varlist' if `iv'!=. & `mv' !=.
				estat sd
				matrix sd=r(sd)
				local sddv=sd[1,1]
					
			svy linearized : mean `mv' if `varlist'!=. & `iv' !=.
				estat sd
				matrix sd=r(sd)
					
				local mvsd=sd[1,1]	
					
				logit `varlist' i.`iv' `mv' `covars'  [`weight' `exp']

						local dvoutsd=sqrt((_b[`mv']^2)*(`mvsd'^2)+(_pi^2/3) )
						local bcoef=_b[`mv']*`mvsd'/`dvoutsd'
					
			}
			
			/*Estimate Indirect Effect**/		
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
