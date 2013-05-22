program resout
syntax [, Error(name) PVALue exp CLean TRend ESTround(numlist max=1 integer) SEParate PRound(numlist max=1 integer)]
**05/22/2012: Revised to correct teh Obs numbers for the t statistics (regress and nl commands) Corrected the CI calculations for same
qui {

		matrix b=e(b)
		matrix se=e(V)
			local obser=e(df_r)
			
			if "`e(cmd)'" =="margins" {
				local num=colsof(b)
			}
			else {
				local num=colsof(b)-1
			}	
			local newnames : colfullnames e(b)
		
			clear
			set obs `num'
			gen var=""
				gen double b=.
				gen double se=.
				gen p=.
			tokenize `newnames'
			
			forvalues i=1(1)`num' {
				replace var="``i''" in `i'
				replace b=b[1, `i'] in `i'
				replace se=sqrt(se[`i', `i']) in `i'
			}
			split var, p(:)
			
			capture local varnames=var2 in 1 
				if "`varnames'"=="" {
					capture drop var1
				}
			
				if "`varnames'"!="" {
					capture drop var1 var
					capture rename var2 var
				}
			capture drop if var=="_cons"
			
			gen double score= abs(b/se)
			capture drop if score==.	
			
			*Generate P Values
			if "`e(cmd)'"=="regress" | "`e(cmd)'"=="nl" {
				replace p=2*ttail(`obser', score) 
				gen double  cilo=b-(se*invttail(`obser', .025))
				gen double cihi=b+(se*invttail(`obser', .025))
				
			}	
			else {
				replace p=2*(1-normal(score))
					gen double  cilo=b-(se*invnormal(0.975))
					gen double cihi=b+(se*invnormal(0.975))
			}
			
			drop score
			
			**Exponentiated Coefficients
			if "`exp'"!="" {
				replace b=exp(b)
				replace se=b*se
				replace cilo=exp(cilo)
				replace cihi=exp(cihi)
			}
			else {
			}
			
			**Rounding Estimates
			if "`estround'"=="" {
				local est1 =abs(b) in 1
					if `est1' >= 1000 {
						tostring b se ci*, force format(%9.0fc) replace
					}
					if `est1' >= 10 & `est1' <1000 {
						tostring b se ci*, force format(%9.1f) replace
					}
					if `est1' >=1 & `est1' <10 {
						tostring b se ci*, force format(%9.2f) replace
					}
					if `est1' <1 {
						tostring b se ci*, force format(%9.3f) replace
					}
			}
			else {
				tostring b se ci*, force format(%9.`estround'fc) replace
			}
			
			
			**Pvalues
			if "`pvalue'" != "" {
				if "`pround'" != "" {
					tostring p, force format(%12.`pround'f) replace
						replace p="<.01" if p=="0.00"
						replace p="<.001" if p=="0.000"
						replace p="<.0001" if p=="0.0000"
						replace p="<.00001" if p=="0.00000"
						replace p="<.000001" if p=="0.000000"
						replace p="<.0000001" if p=="0.0000000"
						replace p="<.00000001" if p=="0.00000000"
						replace p="<.000000001" if p=="0.000000000"
						replace p="<.0000000001" if p=="0.0000000000"
						replace p="<.00000000001" if p=="0.00000000000"
						replace p="<.000000000001" if p=="0.000000000000"
						replace p="<.0000000000001" if p=="0.0000000000000"
				}
				else {
					tostring p, force format(%9.4f) replace
					replace p="<.0001" if p=="0.0000"
				}
			}
			else {
				if "`trend'" != "" {
					gen star="‡" if p <=0.20
					replace star="†" if p <=0.10
					replace star="*" if p <=0.05
					replace star="**" if p <=0.01
					replace star="***" if p <=0.001
					replace star="****" if p <=0.0001
				}
				else {
					gen star="†" if p <=0.10
					replace star="*" if p <=0.05
					replace star="**" if p <=0.01
					replace star="***" if p <=0.001
				}
			}
		
			
			**Compile Results
			if "`error'" == "ci" {
				if "`pvalue'"== "" {
					gen est=star + b + " (" +  cilo + ", " + cihi +")"
					capture keep var est
					order var est
				}
				else {
					gen est=b + " (" +  cilo + ", " + cihi +")"
					capture keep var est p
					order var est p
				}
			}
			else {
				if "`pvalue'"== "" {
					gen est=star + b + " ± " + se
					capture keep var est
					order var est
				}
				else {
					gen est=b + " ± " + se
					capture keep var est p
					order var est p
				}
			}
			*
		
			if "`clean'"!="" {
				split est, p(* † ‡)
				drop est 
				gen new=""
				foreach var of varlist est* {
					replace new=`var' if `var'!=""
				}
				drop est*
				split new, p(" ")
				if "`pvalue'" !="" {
					capture keep var new1 p
				}
				else{
					capture keep var new1
				}
				rename new1 est
				order var est
			}
			*
			
			if "`separate'"!="" {
				gen new=""
				foreach var of varlist est* {
					replace new=`var' if `var'!=""
				}
				drop est*
				split new, p(± "(" ")")
				if "`pvalue'" !="" {
					capture keep var new1 new2 p
					order var new1 new2 p
				}
				else{
					capture keep var new1 new2
					order var new1 new2 
				}
				rename new1 est
				rename new2 error
			}
			*
}
end
exit

	
