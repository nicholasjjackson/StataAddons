program winsorize
	syntax varlist [if] [, level(numlist >0 integer) dir(name) replace ]
qui {
	version 11
	set more off
	
	foreach var of varlist `varlist' {
	
	if "`replace'" =="" {
			if "`dir'" == "high" { 
				if `level' > 50 {
					sum `var' $_if , detail
					capture drop `var'_w
					capture drop temp
					capture gen temp=.
					replace temp= r(p`level') if  `var' >= r(p`level') & `var' !=.
					replace temp= `var' if temp ==.
					gen `var'_w=temp $_if
					drop temp
					noi: display " `var' winsorized high at `level' percentile"
				}/*if level >50*/
				if `level' < 50 {
					sum `var' $_if , detail
					capture drop `var'_w
					capture drop temp
					capture gen temp=.
					local levelnew=abs(100-`level')
					replace temp= r(p`levelnew') if  `var' >= r(p`levelnew') & `var' !=.
					replace temp= `var' if temp ==.
					gen `var'_w=temp $_if
					drop temp
					noi: display " `var' winsorized high at `level' percentile (`levelnew')"
				}/*if level <50*/
			}/*if: DIR: high*/
			
			if "`dir'" == "low" { 
				if `level' < 50 {
					sum `var' $_if , detail
					capture drop `var'_w
					capture drop temp
					capture gen temp=.
					replace temp= r(p`level') if  `var' <= r(p`level') & `var' !=.
					replace temp= `var' if temp ==.
					gen `var'_w=temp $_if
					drop temp
					noi: display " `var' winsorized low at `level' percentile"
				}/*if*/
				if `level' > 50 {
					sum `var' $_if , detail
					capture drop `var'_w
					capture drop temp
					capture gen temp=.
					local levelnew=abs(100-`level')
					replace temp= r(p`levelnew') if  `var' <= r(p`levelnew') & `var' !=.
					replace temp= `var' if temp ==.
					gen `var'_w=temp $_if
					drop temp
					noi: display " `var' winsorized low at `level' percentile (`levelnew')"
				}/*if*/
			}/*if: dir low*/
			
			else if "`dir'" == "" { 
					if `level' > 50 {
						sum `var' $_if , detail
						capture drop `var'_w
						capture drop temp
						capture gen temp=.
							local low=abs(100-`level')
							replace temp= r(p`level') if  `var' >= r(p`level') & `var' !=.
							replace temp= r(p`low') if  `var' <= r(p`low') & `var' !=.
							replace temp= `var' if temp ==.
							gen `var'_w=temp $_if
							drop temp
					noi: display " `var' winsorized both sides at `low'% to `level'% bounds"
					}/*level >50*/
					if `level' < 50 {
						sum `var' $_if , detail
						capture drop `var'_w
						capture drop temp
						capture gen temp=.
							local high=abs(100-`level')
							replace temp= r(p`level') if  `var' <= r(p`level') & `var' !=.
							replace temp= r(p`high') if  `var' >= r(p`high') & `var' !=.
							replace temp= `var' if temp ==.
							gen `var'_w=temp $_if
							drop temp
					noi: display " `var' winsorized both sides at `level'% to `high'% bounds"
					}/*level ><0*/
			}/*else*/
		}/*IF replace*/
		*
		if "`replace'" !="" {
			if "`dir'" == "high" { 
				if `level' > 50 {
					sum `var' $_if , detail
					capture drop `var'_w
					capture drop temp
					capture gen temp=.
					replace temp= r(p`level') if  `var' >= r(p`level') & `var' !=.
					replace temp= `var' if temp ==.
					replace  `var'=temp $_if
					drop temp
					noi: display " `var' winsorized high at `level' percentile"
				}/*if level >50*/
				if `level' < 50 {
					sum `var' $_if , detail
					capture drop `var'_w
					capture drop temp
					capture gen temp=.
					local levelnew=abs(100-`level')
					replace temp= r(p`levelnew') if  `var' >= r(p`levelnew') & `var' !=.
					replace temp= `var' if temp ==.
					replace  `var'=temp $_if
					drop temp
					noi: display " `var' winsorized high at `level' percentile (`levelnew')"
				}/*if level <50*/
			}/*if dir==high*/
			
			if "`dir'" == "low" { 
				if `level' < 50 {
					sum `var' $_if , detail
					capture drop `var'_w
					capture drop temp
					capture gen temp=.
					replace temp= r(p`level') if  `var' <= r(p`level') & `var' !=.
					replace temp= `var' if temp ==.
					replace  `var'=temp $_if
					drop temp
					noi: display " `var' winsorized low at `level' percentile"
				}/*if level >50*/
				if `level' > 50 {
					sum `var' $_if , detail
					capture drop `var'_w
					capture drop temp
					capture gen temp=.
					local levelnew=abs(100-`level')
					replace temp= r(p`levelnew') if  `var' <= r(p`levelnew') & `var' !=.
					replace temp= `var' if temp ==.
					replace  `var'=temp $_if
					drop temp
					noi: display " `var' winsorized low at `level' percentile (`levelnew')"
				}/*if level <50*/
				
				
			}/*if dir==low*/
			
			else if "`dir'" == "" { 
					if `level' > 50 {
						sum `var' $_if , detail
						capture drop `var'_w
						capture drop temp
						capture gen temp=.
							local low=abs(100-`level')
							replace temp= r(p`level') if  `var' >= r(p`level') & `var' !=.
							replace temp= r(p`low') if  `var' <= r(p`low') & `var' !=.
							replace temp= `var' if temp ==.
							replace  `var'=temp $_if
							drop temp
					noi: display " `var' winsorized both sides at `low'% to `level'% bounds"
					}/*if level >50*/
					if `level' < 50 {
						sum `var' $_if , detail
						capture drop `var'_w
						capture drop temp
						capture gen temp=.
							local high=abs(100-`level')
							replace temp= r(p`level') if  `var' <= r(p`level') & `var' !=.
							replace temp= r(p`high') if  `var' >= r(p`high') & `var' !=.
							replace temp= `var' if temp ==.
							replace  `var'=temp $_if
							drop temp
					noi: display " `var' winsorized both sides at `level'% to `high'% bounds"
					}/*if level <50*/
			}/*else dir==""*/
		}/*REplace*/
	}/*Varlist*/
}/*qui*/
end
exit
