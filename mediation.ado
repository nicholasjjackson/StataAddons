program mediation, rclass
syntax varlist [if] [in] [pweight] [, iv(varlist) mv(varlist) covars(string) cat(numlist max=1 integer) SOBel  bootstrap(numlist integer missingokay max=1)]
*Version 1.0: 01/24/2012
*Version 2.0: 05/13/2012: Added Pweight Options

qui {
version 12
set more off

tempfile temp output master using
save `master', replace

	capture keep $_if
	capture keep $_in

/*if "`covars'" != "" {
	
	foreach var of varlist `covars' {
		drop if `var'==.
	}
}
*/	
	
	
save `using', replace

/**Set determiner of having a Categorical IV*/
if "`cat'"!="" {
	local cutpoint=`cat'
}
else {
	local cutpoint=9
}
*

if "`weight'" =="" {

	clear
	set obs 1
		gen dv=""
		gen iv=""
		gen mv=""
	save `output', replace 

	use `using', clear
	foreach dv in `varlist' {
	use `using', clear
		foreach iv1 in `iv' {
		use `using', clear
			foreach mv1 in `mv' {
			use `using', clear
				
				/**determining if linear regression or logistic**/
				inspect `dv'
				  local dvnum=r(N_unique)
					
			*Logistic
			if 	`dvnum' ==2 {
						/**Determining if Categorical or Continuous IV**/
						inspect `iv1'
						  local ivnum=r(N_unique)
						 inspect `mv1'
						  local mvnum=r(N_unique)
						  
						  *Categorical IV-Continuous MV
						  if `ivnum' <= `cutpoint'  & `mvnum' >=3 {
									
								*determine levels in iv
								table `iv1' if `mv1' !=., replace 
								 drop in 1
								 global max=_N
								 forvalues i=1(1)$max {
									local `i'=`iv1' in `i'
								 }
								 use `using', clear
									
									/*Step 1: IV Related to DV (Path C)*/
									logit `dv' i.`iv1' `covars' if `mv1' !=.
										testparm i.`iv1'
										  local p1=r(p) 
											   
									/*Step 2: IV Related to MV (Path A)*/
									capture drop new*
									tab `iv1', gen(new)
									
									sum `mv1' if `dv'!=. & `iv1'!=.
										local mvsd=r(sd)
									
									regress `mv1' i.`iv1' `covars' if `dv'!=.
										testparm i.`iv1'
										  local p2=r(p)
										  forvalues i=1(1)$max {
											  local newnum=`i'+1
											  sum new`newnum' if  `dv' !=. & `mv1'!=.
													local sdiv`i'=r(sd)
										  
												 local acoef`i'=_b[``i''.`iv1']*`sdiv`i''/`mvsd'
												 local avar`i'=(_se[``i''.`iv1']*`sdiv`i''/`mvsd')^2
										  }
			
									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									sum `dv' if `iv1'!=. & `mv1'!=.
										local sddv=r(sd)
									
									logit `dv' i.`iv1' `mv1' `covars' 
										testparm `mv1'
										  local p3=r(p)
										testparm i.`iv1'
										  local p4=r(p) 
																			
										forvalues i=1(1)$max {
											local dvoutsd`i'=sqrt((_b[``i''.`iv1']^2)*(`sdiv`i''^2)+(_pi^2/3))
											local ccoef`i'=_b[``i''.`iv1']*`sdiv`i''/`dvoutsd`i''
										}
											local dvoutsd=sqrt((_b[`mv1']^2)*(`mvsd'^2)+(_pi^2/3) )
											local bcoef=_b[`mv1']*`mvsd'/`dvoutsd'
											local bvar=(_se[`mv1']*`mvsd'/`dvoutsd')^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
									capture drop new*
									 forvalues i=1(1)$max {
										gen new`i'=`acoef`i''*`bcoef'
									 }
									 egen indirect=rowtotal(new*)
										drop new*
									forvalues i=1(1)$max {
										gen new`i'=`ccoef`i''
									 }
										egen direct=rowtotal(new*)
											drop new*
									gen bvar=`bvar'
									gen bcoef=`bcoef'
									forvalues i=1(1)$max {
										gen acoef`i'=`acoef`i''
										gen avar`i'=`acoef`i''
									}
									
									forvalues i=1(1)$max {
										*gen new`i'=(`bcoef'^2)*`avar`i'' + (`acoef`i''^2)*`bvar'	
										gen new`i'=(bcoef^2)*avar`i' + (acoef`i'^2)*bvar		
									 
									 }		
										egen se=rowtotal(new*)
											drop *var* *coef* new*
											
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen sobel=(indirect)/sqrt(se)
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop se
									}/*Boot*/
									
									tempfile temp
									save `temp', replace
										
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_05 `dv', iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se) 
										
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  }/*Categorical IV-Continuous MV*/
						  
						  

						  
						  *Continuous IV-Continuous MV
						  if `ivnum' > `cutpoint' & `mvnum' >=3 {
								use `using', clear
									/*Step 1: IV Related to DV*/
									logit `dv' `iv1' `covars' if `mv1' !=.
										testparm `iv1'
										  local p1=r(p)
										   
									
									/*Step 2: IV Related to MV*/
									sum `mv1' if `iv1'!=. & `dv'!=.
										local mvsd=r(sd)
									sum `iv1' if `mv1'!=. & `dv'!=.
										local ivsd=r(sd)	
									
									regress `mv1' `iv1' `covars' if `dv'!=.
										testparm `iv1'
										  local p2=r(p)
											local acoef=_b[`iv1']*`ivsd'/`mvsd'
											local avar=(_se[`iv1']*`ivsd'/`mvsd')^2
										  
									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									logit `dv' `iv1' `mv1' `covars' 
										testparm `mv1'
										  local p3=r(p)
										testparm `iv1'
										  local p4=r(p) 
											
											local dvoutsd=sqrt(((_b[`iv1']^2)*(`ivsd'^2)+(_pi^2/3)))
											local ccoef=_b[`iv1']*`ivsd'/`dvoutsd'
											
											local dvoutsd=sqrt(((_b[`mv1']^2)*(`mvsd'^2)+(_pi^2/3)))
											local bcoef=_b[`mv1']*`mvsd'/`dvoutsd'
											local bvar=(_se[`mv1']*`mvsd'/`dvoutsd')^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
										gen indirect=`acoef'*`bcoef'
										gen direct=`ccoef'
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen avar=`avar'
										gen bvar=`bvar'
										gen bcoef=`bcoef'
										gen acoef=`acoef'
										gen se=sqrt(((bcoef^2)*avar + (acoef^2)*bvar))
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop *var* *coef* se
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_06 `dv', iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  
						  }/*Continuous IV-Continuous MV*/
					
		/**************************************BEGIN Binary MV***/			
		 
						  *Binary  DV- Continuous IV-Binary MV
						  if `ivnum' > `cutpoint' & `mvnum' <=3 {
								use `using', clear
									/*Step 1: IV Related to DV (Path C)*/
									logit `dv' `iv1' `covars' if `mv1' !=.
										testparm `iv1'
										  local p1=r(p)
										   

									/*Step 2: IV Related to MV (Path A)*/
											sum `iv1' if `dv'!=. & `mv1'!=.
												local ivsd=r(sd)
											logit `mv1' `iv1' `covars' if `dv'!=.
												testparm `iv1'
												  local p2=r(p)
												 
												*Compute SD of MV as an Outcome
												local mvoutsd=sqrt((_b[`iv1']^2)*(`ivsd'^2)+(_pi^2/3) )
												*Scale the coefficient by multiplying by SD of the predictor divided by SD of outcome(MV)
												local acoef=_b[`iv1']*`ivsd'/`mvoutsd'
												local avar=(_se[`iv1']*`ivsd'/`mvoutsd')^2

									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									sum `dv' if `iv1'!=. & `mv1' !=.
										local sddv=r(sd)
										
									sum `mv1' if `dv'!=. & `iv1' !=.
										local mvsd=r(sd)	
										
									logit `dv' `iv1' `mv1' `covars' 
										testparm `mv1'
										  local p3=r(p)
										testparm `iv1'
										  local p4=r(p) 

											local dvoutsd=sqrt(((_b[`iv1']^2)*(`ivsd'^2)+(_pi^2/3)))
											local ccoef=_b[`iv1']*`ivsd'/`dvoutsd'
											
											local dvoutsd=sqrt(((_b[`mv1']^2)*(`mvsd'^2)+(_pi^2/3)))
											local bcoef=_b[`mv1']*`mvsd'/`dvoutsd'
											local bvar=(_se[`mv1']*`mvsd'/`dvoutsd')^2
										  
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
										gen indirect=`acoef'*`bcoef'
										gen direct=`ccoef'
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen avar=`avar'
										gen bvar=`bvar'
										gen bcoef=`bcoef'
										gen acoef=`acoef'
										gen se=sqrt(((bcoef^2)*avar + (acoef^2)*bvar))
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop *var* *coef* se
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_07 `dv', iv(`iv1') mv(`mv1') cov(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  
						  
						  
						  }/*Binary DV -Continuous IV-Binary MV*/
						  
						  *Binary DV- Categorical IV-Binary MV
						  if `ivnum' <= `cutpoint' & `mvnum' <=3 {
							dis as error "Cannot Currently Perform Mediational Analysis on Binary MV and Categorical IV"

								*determine levels in iv
								table `iv1' if `mv1' !=., replace 
								 drop in 1
								 global max=_N
								 forvalues i=1(1)$max {
									local `i'=`iv1' in `i'
								 }
								
								use `using', clear
									
									/*Step 1: IV Related to DV (Path C)*/
									logit `dv' i.`iv1' `covars' if `mv1' !=.
										testparm i.`iv1'
										  local p1=r(p)
										   
									/*Step 2: IV Related to MV (Path A)*/
									logit `mv1' i.`iv1' `covars' if `dv'!=.
										testparm i.`iv1'
											local p2=r(p)
											
										capture drop new*
										tab `iv1', gen(new)
										
											/****NOTE: NEED A WAY TO ESTIMATE SD of Categorical IV**/
										forvalues i=1(1)$max {
											local newnum=`i'+1
											sum new`newnum' if  `dv' !=. & `mv1'!=.
												local sdiv`i'=r(sd)
											local mvoutsd`i'=((_b[``i''.`iv1']^2)*(`sdiv`i''^2)+(_pi^2/3) )
												local acoef`i'=_b[``i''.`iv1']*`sdiv`i''/`mvoutsd`i''
												local avar`i'=(_se[``i''.`iv1']*`sdiv`i''/`mvoutsd`i'')^2 
										  }

									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									sum `dv' if `iv1'!=. & `mv1' !=.
										local sddv=r(sd)
										
									sum `mv1' if `dv'!=. & `iv1' !=.
										local mvsd=r(sd)	
										
									logit `dv' i.`iv1' `mv1' `covars' 
										testparm `mv1'
										  local p3=r(p)
										testparm i.`iv1'
										  local p4=r(p) 
										forvalues i=1(1)$max {
											
											local dvoutsd`i'=sqrt(((_b[``i''.`iv1']^2)*(`sdiv`i''^2)+(_pi^2/3)))
											local ccoef`i'=_b[``i''.`iv1']*`sdiv`i''/`dvoutsd`i''
										}
										
											local dvoutsd=sqrt(((_b[`mv1']^2)*(`mvsd'^2)+(_pi^2/3)))
											local bcoef=_b[`mv1']*`mvsd'/`dvoutsd'
											local bvar=(_se[`mv1']*`mvsd'/`dvoutsd')^2
										
											
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
									 forvalues i=1(1)$max {
										gen new`i'=`acoef`i''*`bcoef'
									 }
									 egen indirect=rowtotal(new*)
										drop new*
									forvalues i=1(1)$max {
										gen new`i'=`ccoef`i''
									 }
										egen direct=rowtotal(new*)
											drop new*
									gen bvar=`bvar'
									gen bcoef=`bcoef'
									forvalues i=1(1)$max {
										gen acoef`i'=`acoef`i''
										gen avar`i'=`acoef`i''
									}
									
									forvalues i=1(1)$max {
										gen new`i'=(bcoef^2)*avar`i' + (acoef`i'^2)*bvar		
									 
									 }		
										egen se=rowtotal(new*)
											drop *var* *coef* new*

										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										capture drop *var* *coef*
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_08 `dv', iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
								*/		
						  
						  }/*Binary DV -Categorical IV-Binary MV*/						
						
					
					
			}/*Logistic*/
					
			*Linear Modeling
			if 	`dvnum' >=3 {
						/**Determining if Categorical or Continuous IV**/
						inspect `iv1'
						  local ivnum=r(N_unique)					  
						 inspect `mv1'
						  local mvnum=r(N_unique)
						  
						  *Categorical IV-Continuous MV
						  if `ivnum' <= `cutpoint'  & `mvnum' >=3 {
									
								*determine levels in iv
								table `iv1' if `mv1' !=., replace 
								 drop in 1
								 global max=_N
								 forvalues i=1(1)$max {
									local `i'=`iv1' in `i'
								 }
								 use `using', clear
									
									/*Step 1: IV Related to DV*/
									regress `dv' i.`iv1' `covars' if `mv1' !=.
										testparm i.`iv1'
										  local p1=r(p) 
											   
									/*Step 2: IV Related to MV*/
									regress `mv1' i.`iv1' `covars' if `dv'!=.
										testparm i.`iv1'
										  local p2=r(p)
										  forvalues i=1(1)$max {
												 local acoef`i'=_b[``i''.`iv1']
												 local avar`i'=_se[``i''.`iv1']^2
										  }
			
									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									regress `dv' i.`iv1' `mv1' `covars' 
										testparm `mv1'
										  local p3=r(p)
										testparm i.`iv1'
										  local p4=r(p) 
										
										forvalues i=1(1)$max {
											local ccoef`i'=_b[``i''.`iv1']
										}
											local bcoef=_b[`mv1']
											local bvar=_se[`mv1']^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
									 forvalues i=1(1)$max {
										gen new`i'=`acoef`i''*`bcoef'
									 }
									 egen indirect=rowtotal(new*)
										drop new*
									forvalues i=1(1)$max {
										gen new`i'=`ccoef`i''
									 }
										egen direct=rowtotal(new*)
											drop new*
									gen bvar=`bvar'
									gen bcoef=`bcoef'
									forvalues i=1(1)$max {
										gen acoef`i'=`acoef`i''
										gen avar`i'=`acoef`i''
									}
									
									forvalues i=1(1)$max {
										*gen new`i'=(`bcoef'^2)*`avar`i'' + (`acoef`i''^2)*`bvar'	
										gen new`i'=(bcoef^2)*avar`i' + (acoef`i'^2)*bvar		
									 
									 }		
										egen se=rowtotal(new*)
											drop *var* *coef* new*
											
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen sobel=(indirect)/sqrt(se)
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop se
									}/*Boot*/
									
									tempfile temp
									save `temp', replace
										
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_01 `dv', iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se) 
										
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  }/*Categorical IV-Continuous MV*/
						  
						  

						  
						  *Continuous IV-Continuous MV
						  if `ivnum' > `cutpoint' & `mvnum' >=3 {
								use `using', clear
									/*Step 1: IV Related to DV*/
									regress `dv' `iv1' `covars' if `mv1' !=.
										testparm `iv1'
										  local p1=r(p)
										   
									
									/*Step 2: IV Related to MV*/
									regress `mv1' `iv1' `covars' if `dv'!=.
										testparm `iv1'
										  local p2=r(p)
											local acoef=_b[`iv1']
											local avar=_se[`iv1']^2
										  
									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									regress `dv' `iv1' `mv1' `covars' 
										testparm `mv1'
										  local p3=r(p)
										testparm `iv1'
										  local p4=r(p) 
											local ccoef=_b[`iv1']
											
											local bcoef=_b[`mv1']
											local bvar=_se[`mv1']^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
										gen indirect=`acoef'*`bcoef'
										gen direct=`ccoef'
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen avar=`avar'
										gen bvar=`bvar'
										gen bcoef=`bcoef'
										gen acoef=`acoef'
										gen se=sqrt(((bcoef^2)*avar + (acoef^2)*bvar))
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop *var* *coef* se
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_02 `dv', iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  
						  }/*Continuous IV-Continuous MV*/
					
		/**************************************BEGIN Binary MV***/			
		 
						  *Continuous DV- Continuous IV-Binary MV
						  if `ivnum' > `cutpoint' & `mvnum' <=3 {
								use `using', clear
									/*Step 1: IV Related to DV (Path C)*/
									regress `dv' `iv1' `covars' if `mv1' !=.
										testparm `iv1'
										  local p1=r(p)
										   

									/*Step 2: IV Related to MV (Path A)*/
											sum `iv1' if `dv'!=. & `mv1'!=.
												local sdiv1=r(sd)
											logit `mv1' `iv1' `covars' if `dv'!=.
												testparm `iv1'
												  local p2=r(p)
												 
												*Compute SD of MV as an Outcome
												local mvoutsd=sqrt((_b[`iv1']^2)*(`sdiv1'^2)+(_pi^2/3) )
												*Scale the coefficient by multiplying by SD of the predictor divided by SD of outcome(MV)
												local acoef=_b[`iv1']*`sdiv1'/`mvoutsd'
												local avar=(_se[`iv1']*`sdiv1'/`mvoutsd')^2

									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									sum `dv' if `iv1'!=. & `mv1' !=.
										local sddv=r(sd)
										
									sum `mv1' if `dv'!=. & `iv1' !=.
										local sdmv1=r(sd)	
										
									regress `dv' `iv1' `mv1' `covars' 
										testparm `mv1'
										  local p3=r(p)
										testparm `iv1'
										  local p4=r(p) 

											local ccoef=_b[`iv1']*`sdiv1'/`sddv'
											
											local bcoef=_b[`mv1']*`sdmv1'/`sddv'
											local bvar=(_se[`mv1']*`sdmv1'/`sddv')^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
										gen indirect=`acoef'*`bcoef'
										gen direct=`ccoef'
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen avar=`avar'
										gen bvar=`bvar'
										gen bcoef=`bcoef'
										gen acoef=`acoef'
										gen se=sqrt(((bcoef^2)*avar + (acoef^2)*bvar))
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop *var* *coef* se
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_03 `dv', iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  
						  
						  
						  }/*Continuous DV -Continuous IV-Binary MV*/
						  
						  *Continuous DV- Categorical IV-Binary MV
						  if `ivnum' <= `cutpoint' & `mvnum' <=3 {
							dis as error "Cannot Currently Perform Mediational Analysis on Binary MV and Categorical IV"

								*determine levels in iv
								table `iv1' if `mv1' !=., replace 
								 drop in 1
								 global max=_N
								 forvalues i=1(1)$max {
									local `i'=`iv1' in `i'
								 }
								
								use `using', clear
									
									/*Step 1: IV Related to DV (Path C)*/
									regress `dv' i.`iv1' `covars' if `mv1' !=.
										testparm i.`iv1'
										  local p1=r(p)
										   
									/*Step 2: IV Related to MV (Path A)*/
									logit `mv1' i.`iv1' `covars' if `dv'!=.
										testparm i.`iv1'
											local p2=r(p)
											
										capture drop new*
										tab `iv1', gen(new)
										
											/****NOTE: NEED A WAY TO ESTIMATE SD of Categorical IV**/
										forvalues i=1(1)$max {
											local newnum=`i'+1
											sum new`newnum' if  `dv' !=. & `mv1'!=.
												local sdiv`i'=r(sd)
											local mvoutsd`i'=sqrt((_b[``i''.`iv1']^2)*(`sdiv`i''^2)+(_pi^2/3) )
												local acoef`i'=_b[``i''.`iv1']*`sdiv`i''/`mvoutsd`i''
												local avar`i'=(_se[``i''.`iv1']*`sdiv`i''/`mvoutsd`i'')^2 
										  }

									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									sum `dv' if `iv1'!=. & `mv1' !=.
										local sddv=r(sd)
										
									sum `mv1' if `dv'!=. & `iv1' !=.
										local sdmv1=r(sd)	
										
									regress `dv' i.`iv1' `mv1' `covars' 
										testparm `mv1'
										  local p3=r(p)
										testparm i.`iv1'
										  local p4=r(p) 
										forvalues i=1(1)$max {
											local ccoef`i'=_b[``i''.`iv1']*`sdiv`i''/`sddv'
										}
											
											local bcoef=_b[`mv1']*`sdmv1'/`sddv'
											local bvar=(_se[`mv1']*`sdmv1'/`sddv')^2
											
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
									 forvalues i=1(1)$max {
										gen new`i'=`acoef`i''*`bcoef'
									 }
									 egen indirect=rowtotal(new*)
										drop new*
									forvalues i=1(1)$max {
										gen new`i'=`ccoef`i''
									 }
										egen direct=rowtotal(new*)
											drop new*
									gen bvar=`bvar'
									gen bcoef=`bcoef'
									forvalues i=1(1)$max {
										gen acoef`i'=`acoef`i''
										gen avar`i'=`acoef`i''
									}
									
									forvalues i=1(1)$max {
										gen new`i'=(bcoef^2)*avar`i' + (acoef`i'^2)*bvar		
									 
									 }		
										egen se=rowtotal(new*)
											drop *var* *coef* new*

										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										capture drop *var* *coef*
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_04 `dv', iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
								*/		
						  
						  }/*Continuous DV -Categorical IV-Binary MV*/		
						  
					
					
			}/*Linear*/
					
			tempfile temp
			save `temp', replace
			use `output', clear
				append using `temp'
			save `output', replace	
					
					
			}/*MV*/		
		}/*IV*/
	}/*DV*/	
}/*weighting*/
************************************************************************************************************************************
******WEIGHTED ANALYSIS
************************************************************************************************************************************
if "`weight'" !="" {

	clear
	set obs 1
		gen dv=""
		gen iv=""
		gen mv=""
	save `output', replace 

	use `using', clear
	foreach dv in `varlist' {
	use `using', clear
		foreach iv1 in `iv' {
		use `using', clear
			foreach mv1 in `mv' {
			use `using', clear
				
				/**determining if linear regression or logistic**/
				inspect `dv'
				  local dvnum=r(N_unique)
					
			*Logistic
			if 	`dvnum' ==2 {
						/**Determining if Categorical or Continuous IV**/
						inspect `iv1'
						  local ivnum=r(N_unique)
						 inspect `mv1'
						  local mvnum=r(N_unique)
						  
						  *Categorical IV-Continuous MV
						  if `ivnum' <= `cutpoint'  & `mvnum' >=3 {
									
								*determine levels in iv
								table `iv1' if `mv1' !=., replace 
								 drop in 1
								 global max=_N
								 forvalues i=1(1)$max {
									local `i'=`iv1' in `i'
								 }
								 use `using', clear
									
									/*Step 1: IV Related to DV (Path C)*/
									logit `dv' i.`iv1' `covars' if `mv1' !=. [`weight' `exp']
										testparm i.`iv1'
										  local p1=r(p) 
											   
									/*Step 2: IV Related to MV (Path A)*/
									capture drop new*
									tab `iv1', gen(new)
									
									svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
									
									svy linearized: mean `mv1' if `dv'!=. & `iv1'!=.
										estat sd
										matrix sd=r(sd)
										
										local mvsd=sd[1,1]
									
									regress `mv1' i.`iv1' `covars' if `dv'!=. [`weight' `exp']
										testparm i.`iv1'
										  local p2=r(p)
										  forvalues i=1(1)$max {
											  local newnum=`i'+1
											 
											 svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
											 svy linearized: mean new`newnum' if  `dv' !=. & `mv1'!=.
												estat sd 
												matrix sd=r(sd)
													local sdiv`i'=sd[1,1]
												
												regress `mv1' i.`iv1' `covars' if `dv'!=. [`weight' `exp']
												 local acoef`i'=_b[``i''.`iv1']*`sdiv`i''/`mvsd'
												 local avar`i'=(_se[``i''.`iv1']*`sdiv`i''/`mvsd')^2
										  }
			
									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									 svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
									 svy linearized: mean `dv' if `iv1'!=. & `mv1'!=.
										estat sd 
										matrix sd=r(sd)
										local sddv=sd[1,1]
									
									logit `dv' i.`iv1' `mv1' `covars'   [`weight' `exp']
										testparm `mv1'
										  local p3=r(p)
										testparm i.`iv1'
										  local p4=r(p) 
																			
										forvalues i=1(1)$max {
											local dvoutsd`i'=sqrt((_b[``i''.`iv1']^2)*(`sdiv`i''^2)+(_pi^2/3))
											local ccoef`i'=_b[``i''.`iv1']*`sdiv`i''/`dvoutsd`i''
										}
											local dvoutsd=sqrt((_b[`mv1']^2)*(`mvsd'^2)+(_pi^2/3) )
											local bcoef=_b[`mv1']*`mvsd'/`dvoutsd'
											local bvar=(_se[`mv1']*`mvsd'/`dvoutsd')^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
									capture drop new*
									 forvalues i=1(1)$max {
										gen new`i'=`acoef`i''*`bcoef'
									 }
									 egen indirect=rowtotal(new*)
										drop new*
									forvalues i=1(1)$max {
										gen new`i'=`ccoef`i''
									 }
										egen direct=rowtotal(new*)
											drop new*
									gen bvar=`bvar'
									gen bcoef=`bcoef'
									forvalues i=1(1)$max {
										gen acoef`i'=`acoef`i''
										gen avar`i'=`acoef`i''
									}
									
									forvalues i=1(1)$max {
										*gen new`i'=(`bcoef'^2)*`avar`i'' + (`acoef`i''^2)*`bvar'	
										gen new`i'=(bcoef^2)*avar`i' + (acoef`i'^2)*bvar		
									 
									 }		
										egen se=rowtotal(new*)
											drop *var* *coef* new*
											
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen sobel=(indirect)/sqrt(se)
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop se
									}/*Boot*/
									
									tempfile temp
									save `temp', replace
										
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_05 `dv' [pw `exp'] , iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se) 
										
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  }/*Categorical IV-Continuous MV*/
						  
						  

						  
						  *Continuous IV-Continuous MV
						  if `ivnum' > `cutpoint' & `mvnum' >=3 {
								use `using', clear
									/*Step 1: IV Related to DV*/
									logit `dv' `iv1' `covars' if `mv1' !=. [`weight' `exp']
										testparm `iv1'
										  local p1=r(p)
										   
									
									/*Step 2: IV Related to MV*/
									 svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
									svy linearized : mean `mv1' if `iv1'!=. & `dv'!=.
										estat sd
										matrix sd=r(sd)
										local mvsd=sd[1,1]
									svy linearized : mean `iv1' if `mv1'!=. & `dv'!=.
										estat sd
										matrix sd=r(sd)
										
										local ivsd=sd[1,1]	
									
									regress `mv1' `iv1' `covars' if `dv'!=. [`weight' `exp']
										testparm `iv1'
										  local p2=r(p)
											local acoef=_b[`iv1']*`ivsd'/`mvsd'
											local avar=(_se[`iv1']*`ivsd'/`mvsd')^2
										  
									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									logit `dv' `iv1' `mv1' `covars'  [`weight' `exp']
										testparm `mv1'
										  local p3=r(p)
										testparm `iv1'
										  local p4=r(p) 
											
											local dvoutsd=sqrt(((_b[`iv1']^2)*(`ivsd'^2)+(_pi^2/3)))
											local ccoef=_b[`iv1']*`ivsd'/`dvoutsd'
											
											local dvoutsd=sqrt(((_b[`mv1']^2)*(`mvsd'^2)+(_pi^2/3)))
											local bcoef=_b[`mv1']*`mvsd'/`dvoutsd'
											local bvar=(_se[`mv1']*`mvsd'/`dvoutsd')^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
										gen indirect=`acoef'*`bcoef'
										gen direct=`ccoef'
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen avar=`avar'
										gen bvar=`bvar'
										gen bcoef=`bcoef'
										gen acoef=`acoef'
										gen se=sqrt(((bcoef^2)*avar + (acoef^2)*bvar))
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop *var* *coef* se
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_06 `dv' [pw `exp'], iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  
						  }/*Continuous IV-Continuous MV*/
					
		/**************************************BEGIN Binary MV***/			
		 
						  *Binary  DV- Continuous IV-Binary MV
						  if `ivnum' > `cutpoint' & `mvnum' <=3 {
								use `using', clear
									/*Step 1: IV Related to DV (Path C)*/
									logit `dv' `iv1' `covars' if `mv1' !=. [`weight' `exp']
										testparm `iv1'
										  local p1=r(p)
										   

									/*Step 2: IV Related to MV (Path A)*/
											svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
											svy linearized : mean `iv1' if `dv'!=. & `mv1'!=.
												estat sd
												matrix sd=r(sd)
												local ivsd=sd[1,1]
												
											logit `mv1' `iv1' `covars' if `dv'!=. [`weight' `exp']
												testparm `iv1'
												  local p2=r(p)
												 
												*Compute SD of MV as an Outcome
												local mvoutsd=sqrt((_b[`iv1']^2)*(`ivsd'^2)+(_pi^2/3) )
												*Scale the coefficient by multiplying by SD of the predictor divided by SD of outcome(MV)
												local acoef=_b[`iv1']*`ivsd'/`mvoutsd'
												local avar=(_se[`iv1']*`ivsd'/`mvoutsd')^2

									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
									svy linearized : mean `dv' if `iv1'!=. & `mv1' !=.
											estat sd
											matrix sd=r(sd)
										local sddv=sd[1,1]
										
									svy linearized : mean `mv1' if `dv'!=. & `iv1' !=.
											estat sd
											matrix sd=r(sd)										
										local mvsd=sd[1,1]	
										
									logit `dv' `iv1' `mv1' `covars'  [`weight' `exp']
										testparm `mv1'
										  local p3=r(p)
										testparm `iv1'
										  local p4=r(p) 

											local dvoutsd=sqrt(((_b[`iv1']^2)*(`ivsd'^2)+(_pi^2/3)))
											local ccoef=_b[`iv1']*`ivsd'/`dvoutsd'
											
											local dvoutsd=sqrt(((_b[`mv1']^2)*(`mvsd'^2)+(_pi^2/3)))
											local bcoef=_b[`mv1']*`mvsd'/`dvoutsd'
											local bvar=(_se[`mv1']*`mvsd'/`dvoutsd')^2
										  
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
										gen indirect=`acoef'*`bcoef'
										gen direct=`ccoef'
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen avar=`avar'
										gen bvar=`bvar'
										gen bcoef=`bcoef'
										gen acoef=`acoef'
										gen se=sqrt(((bcoef^2)*avar + (acoef^2)*bvar))
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop *var* *coef* se
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_07 `dv' [pw `exp'], iv(`iv1') mv(`mv1') cov(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  
						  
						  
						  }/*Binary DV -Continuous IV-Binary MV*/
						  
						  *Binary DV- Categorical IV-Binary MV
						  if `ivnum' <= `cutpoint' & `mvnum' <=3 {
							dis as error "Cannot Currently Perform Mediational Analysis on Binary MV and Categorical IV"

								*determine levels in iv
								table `iv1' if `mv1' !=., replace 
								 drop in 1
								 global max=_N
								 forvalues i=1(1)$max {
									local `i'=`iv1' in `i'
								 }
								
								use `using', clear
									
									/*Step 1: IV Related to DV (Path C)*/
									logit `dv' i.`iv1' `covars' if `mv1' !=. [`weight' `exp']
										testparm i.`iv1'
										  local p1=r(p)
										   
									/*Step 2: IV Related to MV (Path A)*/
									logit `mv1' i.`iv1' `covars' if `dv'!=. [`weight' `exp']
										testparm i.`iv1'
											local p2=r(p)
											
										capture drop new*
										tab `iv1', gen(new)
										
											/****NOTE: NEED A WAY TO ESTIMATE SD of Categorical IV**/
										forvalues i=1(1)$max {
											local newnum=`i'+1
											svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
											svy linearized : mean  new`newnum' if  `dv' !=. & `mv1'!=.
												estat sd
												matrix sd=r(sd)
												
												local sdiv`i'=sd[1,1]
												
											logit `mv1' i.`iv1' `covars' if `dv'!=. [`weight' `exp']
											
											local mvoutsd`i'=((_b[``i''.`iv1']^2)*(`sdiv`i''^2)+(_pi^2/3) )
												local acoef`i'=_b[``i''.`iv1']*`sdiv`i''/`mvoutsd`i''
												local avar`i'=(_se[``i''.`iv1']*`sdiv`i''/`mvoutsd`i'')^2 
										  }

									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
									svy linearized : mean `dv' if `iv1'!=. & `mv1' !=.
										estat sd
										matrix sd=r(sd)
						
										
										local sddv=sd[1,1]
										
									svy linearized : mean `mv1' if `dv'!=. & `iv1' !=.
										estat sd
										matrix sd=r(sd)
										local mvsd=sd[1,1]	
										
									logit `dv' i.`iv1' `mv1' `covars' [`weight' `exp']
										testparm `mv1'
										  local p3=r(p)
										testparm i.`iv1'
										  local p4=r(p) 
										forvalues i=1(1)$max {
											
											local dvoutsd`i'=sqrt(((_b[``i''.`iv1']^2)*(`sdiv`i''^2)+(_pi^2/3)))
											local ccoef`i'=_b[``i''.`iv1']*`sdiv`i''/`dvoutsd`i''
										}
										
											local dvoutsd=sqrt(((_b[`mv1']^2)*(`mvsd'^2)+(_pi^2/3)))
											local bcoef=_b[`mv1']*`mvsd'/`dvoutsd'
											local bvar=(_se[`mv1']*`mvsd'/`dvoutsd')^2
										
											
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
									 forvalues i=1(1)$max {
										gen new`i'=`acoef`i''*`bcoef'
									 }
									 egen indirect=rowtotal(new*)
										drop new*
									forvalues i=1(1)$max {
										gen new`i'=`ccoef`i''
									 }
										egen direct=rowtotal(new*)
											drop new*
									gen bvar=`bvar'
									gen bcoef=`bcoef'
									forvalues i=1(1)$max {
										gen acoef`i'=`acoef`i''
										gen avar`i'=`acoef`i''
									}
									
									forvalues i=1(1)$max {
										gen new`i'=(bcoef^2)*avar`i' + (acoef`i'^2)*bvar		
									 
									 }		
										egen se=rowtotal(new*)
											drop *var* *coef* new*

										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										capture drop *var* *coef*
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_08 `dv' [pw `exp'], iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
								*/		
						  
						  }/*Binary DV -Categorical IV-Binary MV*/						
						
					
					
			}/*Logistic*/
					
			*Linear Modeling
			if 	`dvnum' >=3 {
						/**Determining if Categorical or Continuous IV**/
						inspect `iv1'
						  local ivnum=r(N_unique)					  
						 inspect `mv1'
						  local mvnum=r(N_unique)
						  
						  *Categorical IV-Continuous MV
						  if `ivnum' <= `cutpoint'  & `mvnum' >=3 {
									
								*determine levels in iv
								table `iv1' if `mv1' !=., replace 
								 drop in 1
								 global max=_N
								 forvalues i=1(1)$max {
									local `i'=`iv1' in `i'
								 }
								 use `using', clear
									
									/*Step 1: IV Related to DV*/
									regress `dv' i.`iv1' `covars' if `mv1' !=. [`weight' `exp']
										testparm i.`iv1'
										  local p1=r(p) 
											   
									/*Step 2: IV Related to MV*/
									regress `mv1' i.`iv1' `covars' if `dv'!=. [`weight' `exp']
										testparm i.`iv1'
										  local p2=r(p)
										  forvalues i=1(1)$max {
												 local acoef`i'=_b[``i''.`iv1']
												 local avar`i'=_se[``i''.`iv1']^2
										  }
			
									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									regress `dv' i.`iv1' `mv1' `covars'  [`weight' `exp']
										testparm `mv1'
										  local p3=r(p)
										testparm i.`iv1'
										  local p4=r(p) 
										
										forvalues i=1(1)$max {
											local ccoef`i'=_b[``i''.`iv1']
										}
											local bcoef=_b[`mv1']
											local bvar=_se[`mv1']^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
									 forvalues i=1(1)$max {
										gen new`i'=`acoef`i''*`bcoef'
									 }
									 egen indirect=rowtotal(new*)
										drop new*
									forvalues i=1(1)$max {
										gen new`i'=`ccoef`i''
									 }
										egen direct=rowtotal(new*)
											drop new*
									gen bvar=`bvar'
									gen bcoef=`bcoef'
									forvalues i=1(1)$max {
										gen acoef`i'=`acoef`i''
										gen avar`i'=`acoef`i''
									}
									
									forvalues i=1(1)$max {
										*gen new`i'=(`bcoef'^2)*`avar`i'' + (`acoef`i''^2)*`bvar'	
										gen new`i'=(bcoef^2)*avar`i' + (acoef`i'^2)*bvar		
									 
									 }		
										egen se=rowtotal(new*)
											drop *var* *coef* new*
											
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen sobel=(indirect)/sqrt(se)
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop se
									}/*Boot*/
									
									tempfile temp
									save `temp', replace
										
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_01 `dv' [pw `exp'], iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se) 
										
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  }/*Categorical IV-Continuous MV*/
						  
						  

						  
						  *Continuous IV-Continuous MV
						  if `ivnum' > `cutpoint' & `mvnum' >=3 {
								use `using', clear
									/*Step 1: IV Related to DV*/
									regress `dv' `iv1' `covars' if `mv1' !=. [`weight' `exp']
										testparm `iv1'
										  local p1=r(p)
										   
									
									/*Step 2: IV Related to MV*/
									regress `mv1' `iv1' `covars' if `dv'!=. [`weight' `exp']
										testparm `iv1'
										  local p2=r(p)
											local acoef=_b[`iv1']
											local avar=_se[`iv1']^2
										  
									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									regress `dv' `iv1' `mv1' `covars'  [`weight' `exp']
										testparm `mv1'
										  local p3=r(p)
										testparm `iv1'
										  local p4=r(p) 
											local ccoef=_b[`iv1']
											
											local bcoef=_b[`mv1']
											local bvar=_se[`mv1']^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
										gen indirect=`acoef'*`bcoef'
										gen direct=`ccoef'
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen avar=`avar'
										gen bvar=`bvar'
										gen bcoef=`bcoef'
										gen acoef=`acoef'
										gen se=sqrt(((bcoef^2)*avar + (acoef^2)*bvar))
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop *var* *coef* se
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_02 `dv' [pw `exp'], iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  
						  }/*Continuous IV-Continuous MV*/
					
		/**************************************BEGIN Binary MV***/			
		 
						  *Continuous DV- Continuous IV-Binary MV
						  if `ivnum' > `cutpoint' & `mvnum' <=3 {
								use `using', clear
									/*Step 1: IV Related to DV (Path C)*/
									regress `dv' `iv1' `covars' if `mv1' !=. [`weight' `exp']
										testparm `iv1'
										  local p1=r(p)
										   

									/*Step 2: IV Related to MV (Path A)*/
									svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
											svy linearized : mean `iv1' if `dv'!=. & `mv1'!=.
												estat sd
												matrix sd=r(sd)
												local sdiv1=sd[1,1]
											logit `mv1' `iv1' `covars' if `dv'!=. [`weight' `exp']
												testparm `iv1'
												  local p2=r(p)
												 
												*Compute SD of MV as an Outcome
												local mvoutsd=sqrt((_b[`iv1']^2)*(`sdiv1'^2)+(_pi^2/3) )
												*Scale the coefficient by multiplying by SD of the predictor divided by SD of outcome(MV)
												local acoef=_b[`iv1']*`sdiv1'/`mvoutsd'
												local avar=(_se[`iv1']*`sdiv1'/`mvoutsd')^2

									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
									svy linearized : mean `dv' if `iv1'!=. & `mv1' !=.
										estat sd
										matrix sd=r(sd)
										local sddv=sd[1,1]
										
									svy linearized : mean  `mv1' if `dv'!=. & `iv1' !=.
										estat sd
										matrix sd=r(sd)
										local sdmv1=sd[1,1]	
										
									regress `dv' `iv1' `mv1' `covars'  [`weight' `exp']
										testparm `mv1'
										  local p3=r(p)
										testparm `iv1'
										  local p4=r(p) 

											local ccoef=_b[`iv1']*`sdiv1'/`sddv'
											
											local bcoef=_b[`mv1']*`sdmv1'/`sddv'
											local bvar=(_se[`mv1']*`sdmv1'/`sddv')^2
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
										gen indirect=`acoef'*`bcoef'
										gen direct=`ccoef'
										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen avar=`avar'
										gen bvar=`bvar'
										gen bcoef=`bcoef'
										gen acoef=`acoef'
										gen se=sqrt(((bcoef^2)*avar + (acoef^2)*bvar))
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										drop *var* *coef* se
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_03 `dv' [pw `exp'], iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
						  
						  
						  
						  }/*Continuous DV -Continuous IV-Binary MV*/
						  
						  *Continuous DV- Categorical IV-Binary MV
						  if `ivnum' <= `cutpoint' & `mvnum' <=3 {
							dis as error "Cannot Currently Perform Mediational Analysis on Binary MV and Categorical IV"

								*determine levels in iv
								table `iv1' if `mv1' !=., replace 
								 drop in 1
								 global max=_N
								 forvalues i=1(1)$max {
									local `i'=`iv1' in `i'
								 }
								
								use `using', clear
									
									/*Step 1: IV Related to DV (Path C)*/
									regress `dv' i.`iv1' `covars' if `mv1' !=. [`weight' `exp']
										testparm i.`iv1'
										  local p1=r(p)
										   
									/*Step 2: IV Related to MV (Path A)*/
									logit `mv1' i.`iv1' `covars' if `dv'!=. [`weight' `exp']
										testparm i.`iv1'
											local p2=r(p)
											
										capture drop new*
										tab `iv1', gen(new)
										
											/****NOTE: NEED A WAY TO ESTIMATE SD of Categorical IV**/
										forvalues i=1(1)$max {
											local newnum=`i'+1
											svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
											svy linearized : mean  new`newnum' if  `dv' !=. & `mv1'!=.
												estat sd
												matrix sd=r(sd)
												local sdiv`i'=sd[1,1]
												
											logit `mv1' i.`iv1' `covars' if `dv'!=. [`weight' `exp']
											local mvoutsd`i'=sqrt((_b[``i''.`iv1']^2)*(`sdiv`i''^2)+(_pi^2/3) )
												local acoef`i'=_b[``i''.`iv1']*`sdiv`i''/`mvoutsd`i''
												local avar`i'=(_se[``i''.`iv1']*`sdiv`i''/`mvoutsd`i'')^2 
										  }

									
									/*Steps 3 and 4: MV related to DV and IV not related to DV*/
									svyset _n [`weight' `exp'], vce(linearized) singleunit(missing)
									svy linearized : mean `dv' if `iv1'!=. & `mv1' !=.
										estat sd
										matrix sd=r(sd)
										local sddv=sd[1,1]
										
									svy linearized : mean `mv1' if `dv'!=. & `iv1' !=.
										estat sd
										matrix sd=r(sd)
										local sdmv1=sd[1,1] 	
										
									regress `dv' i.`iv1' `mv1' `covars' [`weight' `exp']
										testparm `mv1'
										  local p3=r(p)
										testparm i.`iv1'
										  local p4=r(p) 
										forvalues i=1(1)$max {
											local ccoef`i'=_b[``i''.`iv1']*`sdiv`i''/`sddv'
										}
											
											local bcoef=_b[`mv1']*`sdmv1'/`sddv'
											local bvar=(_se[`mv1']*`sdmv1'/`sddv')^2
											
									*Fill In Mediation Data
									clear
									set obs 1
										gen dv="`dv'"
										gen iv="`iv1'"
										gen mv="`mv1'"
										gen p_c=`p1'
										gen p_a=`p2'
										gen p_b=`p3'
										gen p_ab=`p4'
									*SOBEL METHOD
									 forvalues i=1(1)$max {
										gen new`i'=`acoef`i''*`bcoef'
									 }
									 egen indirect=rowtotal(new*)
										drop new*
									forvalues i=1(1)$max {
										gen new`i'=`ccoef`i''
									 }
										egen direct=rowtotal(new*)
											drop new*
									gen bvar=`bvar'
									gen bcoef=`bcoef'
									forvalues i=1(1)$max {
										gen acoef`i'=`acoef`i''
										gen avar`i'=`acoef`i''
									}
									
									forvalues i=1(1)$max {
										gen new`i'=(bcoef^2)*avar`i' + (acoef`i'^2)*bvar		
									 
									 }		
										egen se=rowtotal(new*)
											drop *var* *coef* new*

										gen ratio=indirect/direct
										gen proportion=indirect/(direct+indirect)
									if "`bootstrap'" == ""  { 
										gen sobel=indirect/se
										gen p_sobel= 2*(1-normal(abs(sobel)))
										capture drop *var* *coef*
									}/*Boot*/
									tempfile temp
									save `temp', replace
									if "`bootstrap'" != "" {
										use `using', clear
										bootstrap indirect=r(ind), reps(`bootstrap') seed(`bootstrap'): mediation_04 `dv' [pw `exp'], iv(`iv1') mv(`mv1') covars(`covars') 
											matrix b= e(b)
											matrix se= e(se)
										use `temp', clear
											gen z=b[1,1] / se[1,1]
											gen p_boot= 2*(1-normal(abs(z)))
											drop z
									}/*Boot*/		
										tostring p_*, force format(%9.4f) replace
										foreach p of varlist p_* {
											replace `p'="<.0001" if `p'=="0.0000"
										}/*p*/
								*/		
						  
						  }/*Continuous DV -Categorical IV-Binary MV*/		
						  
					
					
			}/*Linear*/
					
			tempfile temp
			save `temp', replace
			use `output', clear
				append using `temp'
			save `output', replace	
					
					
			}/*MV*/		
		}/*IV*/
	}/*DV*/	
}/*weight*/



use `output', clear
	drop if dv==""
	capture drop se
	
label var dv "Dependent Variable"
label var iv "Independent Variable"
label var mv "Mediator Variable"

label var p_c "P Value: Effect of IV on DV"
label var p_a "P Value: Effect of IV on MV"
label var p_b "P Value: Effect of MV on DV"
label var p_ab "P Value: Effect of IV on DV in the presence of MV"

label var indirect "Indirect Effect" 
label var direct "Direct Effect"
label var ratio "Ratio of Indirect to Direct Effect"
label var proportion "Proportion of total effect that is Indirect (Indirect/(Indirect+Direct))" 
capture label var sobel "Sobel Test Statistic"
capture label var p_sobel "P Value for Sobel Test of Indirect Effect"
capture label var p_boot "Bootstrap P Value for Indirect effect"  

}/*QUI*/	
end

exit	
