program mediation_07, rclass
syntax varlist [if] [in]  [pweight] [, iv(varlist) mv(varlist) cov(string)]
		 tempfile using 
		 save `using', replace
		 
		 	table `iv' if `mv' !=., replace 
			 drop in 1
			 global max=_N
			 forvalues i=1(1)$max {
				local `i'=`iv' in `i'
			 }
			
		 use `using', clear

		 if "`weight'"=="" {
			/*Step 2: IV Related to MV (Path A)*/
				sum `iv' if `varlist'!=. & `mv'!=.
					local ivsd=r(sd)
				sum `mv' if `varlist'!=. & `iv'!=.
					local mvsd=r(sd)	
					
				logit `mv' `iv' `cov' if `varlist'!=.
	
					*Compute SD of MV as an Outcome
					local mvoutsd=sqrt((_b[`iv']^2)*(`ivsd'^2)+(_pi^2/3) )
					*Scale the coefficient by multiplying by SD of the predictor divided by SD of outcome(MV)
					local acoef=_b[`iv']*`ivsd'/`mvoutsd'
					local avar=(_se[`iv']*`ivsd'/`mvoutsd')^2

			
			/*Steps 3 and 4: MV related to DV and IV not related to DV*/
				logit `varlist' `iv' `mv' `cov' 						
	
					local dvoutsd=sqrt(((_b[`mv']^2)*(`mvsd'^2)+(_pi^2/3)))
					local bcoef=_b[`mv']*`mvsd'/`dvoutsd'
					
			}
			if "`weight'"!="" {
			svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
			/*Step 2: IV Related to MV (Path A)*/
				svy linearized : mean  `iv' if `varlist'!=. & `mv'!=.
					estat sd 
					matrix sd=r(sd)
					
					local ivsd=sd[1,1]
				svy linearized : mean `mv' if `varlist'!=. & `iv'!=.
					estat sd
					matrix sd=r(sd)
					local mvsd=sd[1,1]	
					
				logit `mv' `iv' `cov' if `varlist'!=. [`weight' `exp']
	
					*Compute SD of MV as an Outcome
					local mvoutsd=sqrt((_b[`iv']^2)*(`ivsd'^2)+(_pi^2/3) )
					*Scale the coefficient by multiplying by SD of the predictor divided by SD of outcome(MV)
					local acoef=_b[`iv']*`ivsd'/`mvoutsd'
					local avar=(_se[`iv']*`ivsd'/`mvoutsd')^2

			
			/*Steps 3 and 4: MV related to DV and IV not related to DV*/
				logit `varlist' `iv' `mv' `cov' [`weight' `exp']						
	
					local dvoutsd=sqrt(((_b[`mv']^2)*(`mvsd'^2)+(_pi^2/3)))
					local bcoef=_b[`mv']*`mvsd'/`dvoutsd'
					
			}
			
			/*Estimate Indirect Effect**/	
			capture drop indirect
			gen indirect=(`acoef'*`bcoef')
			local indirect=indirect in 1
			
			return scalar ind = (`indirect')

end
