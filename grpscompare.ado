*******************************************************************************************
*Title: GRPSCOMPARE.ADO
*Automatic DO File
*Statistical Programmer: Nick Jackson, Division of Sleep Medicine, University of Pennsylvania
*Stata Version 11
*******************************************************************************************
*Created 02/26/2011
*Version 2.2
program grpscompare 
version 11
set more off
syntax varlist [if] [in] [pweight] [, by(varname) med log num cat(numlist  missingokay max=1 integer) estround(numlist  missingokay max=1 integer)]

qui {
tempfile current output
	save `current', replace
	save current.dta, replace
	
/*Save results File*/
clear
set obs 1
gen var=""
save output.dta, replace
	
	if "`cat'"!="" {
			local cutpoint=`cat'
		}
		else {
			local cutpoint=9
		}


/****FOR NON-SURVEY DATA*****/	
if "`weight'" == "" {
	use `current', clear
	foreach var of varlist `varlist' {
		use `current', clear
			*determine if the variable is Categorical or Continuous*
			inspect `var' $_if $_in 
			local rows=r(N_unique)

		/*Overall Models*/
			*Categorical Overall
			if `rows' <=`cutpoint' & "`by'"=="" {	
				catoverall `var' $_if $_in , `nonum' estround(`estround')
			}
			
			*Continuous Overall-No Medians-no Log
			if `rows' >`cutpoint' & "`by'"=="" & "`med'"==""  & "`log'"=="" {
				conoverallnomed `var' $_if $_in , `nonum' estround(`estround')
			}
			
			*Continuous Overall-with Medians-no Log
			if `rows' >`cutpoint' & "`by'"=="" & "`med'"!="" & "`log'"=="" {
				conoverallmed `var' $_if $_in , `nonum'  estround(`estround')
			}
		
			*Continuous Overall-No Medians-With Log
			if `rows' >`cutpoint' & "`by'"=="" & "`med'"==""  & "`log'"!="" {
				sum `var'
				local min=r(min)
				if `min' < 0 {
						noi: display as error "Cannot Log Transform Variables with Negative Numbers"
				}
				if `min'>=0 & `min'<1 {
					replace `var'=log(`var' +1)
				}
				else {
					replace `var'=log(`var')
				}
				save current.dta, replace
				conoverallnomed `var' $_if $_in , `nonum'  estround(`estround')
			}
			
			*Continuous Overall-with Medians-With Log
			if `rows' >`cutpoint' & "`by'"=="" & "`med'"!="" & "`log'"!="" {
				sum `var'
				local min=r(min)
				if `min' < 0 {
						noi: display as error "Cannot Log Transform Variables with Negative Numbers"
				}
				if `min'>=0 & `min'<1 {
					replace `var'=log(`var' +1)
				}
				else {
					replace `var'=log(`var')
				}
				save current.dta, replace
				conoverallmed `var' $_if $_in , `nonum'  estround(`estround')
			}
		
		
		/*By Grp Models*/
			*Categorical by Grps
			if `rows' <=`cutpoint' & "`by'"!="" {	
				catbygrp `var' $_if $_in  , by(`by') `nonum'  estround(`estround')
			
			}
		
			*Continuous by Grps-No Medians-No Log
			if `rows' >`cutpoint' & "`by'"!=""  & "`med'"=="" & "`log'"==""{	
				tab `by' $_if $_in 
				local byrows=r(r)
				*Ttest
				if `byrows' <=2 {
					ttestnomed `var' $_if $_in , by(`by') `nonum'  estround(`estround')
				}
				*ANOVA
				else {
					anovanomed `var' $_if $_in , by(`by') `nonum'  estround(`estround')
				}
			}
			*Continuous by Grps-Medians-No Log
			if `rows' >`cutpoint' & "`by'"!=""  & "`med'"!="" & "`log'"==""{	
				tab `by' $_if $_in 
				local byrows=r(r)
				*Ttest
				if `byrows' <=2 { 
					ttestmed `var' $_if $_in , by(`by') `nonum'  estround(`estround')
				}
				*ANOVA
				else {
					anovamed `var' $_if $_in , by(`by') `nonum'  estround(`estround')
				}
			*
			}
			*Continuous by Grps-No Medians-Log
			if `rows' >`cutpoint' & "`by'"!=""  & "`med'"=="" & "`log'"!="" { 	
				tab `by' $_if $_in 
				local byrows=r(r)
					sum `var'
					local min=r(min)
					if `min' < 0 {
						noi: display as error "Cannot Log Transform Variables with Negative Numbers"
					}
					if `min'>=0 & `min'<1 {
						replace `var'=log(`var' +1)
					}
					else {
						replace `var'=log(`var')
					}
					save current.dta, replace
				*Ttest
				if `byrows' <=2 {
					ttestnomed `var' $_if $_in , by(`by') `nonum'  estround(`estround')
				}
				*ANOVA
				else {
					anovanomed `var' $_if $_in , by(`by') `nonum'  estround(`estround')
				}
			}
			*Continuous by Grps-Medians-Log
			if `rows' >`cutpoint' & "`by'"!=""  & "`med'"!="" & "`log'"!="" {	
				tab `by' $_if $_in 
				local byrows=r(r)
					sum `var'
					local min=r(min)
					if `min' < 0 {
						noi: display as error "Cannot Log Transform Variables with Negative Numbers"
					}
					if `min'>=0 & `min'<1 {
						replace `var'=log(`var' +1)
					}
					else {
						replace `var'=log(`var')
					}
					save current.dta, replace
				*Ttest
				if `byrows' <=2 {
					ttestmed `var' $_if $_in , by(`by') `nonum'  estround(`estround')
				}
				*ANOVA
				else {
					anovamed `var' $_if $_in , by(`by') `nonum'  estround(`estround')
				}
			*
			}
			
			
	*
	}
	*
}		

*Display median and Weighting Error
if "`med'"!="" & "`weight'" !=""  {
	noi:disp as error "Median Option cannot be Specified with Sample Weight"
}

*
/****FOR SURVEY DATA*****/	

if "`weight'" !="" {
	use `current', clear
	foreach var of varlist `varlist' {
		use `current', clear
			*determine if the variable is Categorical or Continuous*
			inspect `var' $_if $_in 
			local rows=r(N_unique)

		/*Overall Models*/
			*Categorical Overall
			if `rows' <=`cutpoint' & "`by'"=="" {	
				scatoverall `var' $_if $_in [`weight' `exp'],  estround(`estround')
			}
			
			*Continuous Overall-No Medians-No Log
			if `rows' >`cutpoint' & "`by'"=="" & "`med'"=="" & "`log'"=="" {
				sconoverall `var' $_if $_in [`weight' `exp'],  estround(`estround')
			}
						
			*Continuous Overall-No Medians-Log
			if `rows' >`cutpoint' & "`by'"=="" & "`med'"=="" & "`log'"!=""  {
					sum `var'
					local min=r(min)
					if `min' < 0 {
						noi: display as error "Cannot Log Transform Variables with Negative Numbers"
					}
					if `min'>=0 & `min'<1 {
						replace `var'=log(`var' +1)
					}
					else {
						replace `var'=log(`var')
					}
				save current.dta, replace
				sconoverall `var' $_if $_in [`weight' `exp'],  estround(`estround')
			}
			
		
		/*By Grp Models*/
			*Categorical by Grps
			if `rows' <=`cutpoint' & "`by'"!="" {	
				scatbygrp `var' $_if $_in [`weight' `exp'] , by(`by')  estround(`estround')
			
			}
		
			*Continuous by Grps-No Medians-No Log
			if `rows' >`cutpoint' & "`by'"!=""  & "`med'"=="" & "`log'"==""{	
				tab `by' $_if $_in 
				local byrows=r(r)
				*Ttest
				if `byrows' <=2 {
					sconttest `var' $_if $_in [`weight' `exp'], by(`by')  estround(`estround')
				}
				*ANOVA
				else {
					sconttest `var' $_if $_in [`weight' `exp'], by(`by')  estround(`estround')
				}
			}

			*Continuous by Grps-No Medians-Log
			if `rows' >`cutpoint' & "`by'"!=""  & "`med'"=="" & "`log'"!=""{	
				tab `by' $_if $_in 
				local byrows=r(r)
					sum `var'
					local min=r(min)
					if `min' < 0 {
						noi: display as error "Cannot Log Transform Variables with Negative Numbers"
					}
					if `min'>=0 & `min'<1 {
						replace `var'=log(`var' +1)
					}
					else {
						replace `var'=log(`var')
					}
				save current.dta, replace
				*Ttest
				if `byrows' <=2 {
					sconttest `var' $_if $_in [`weight' `exp'], by(`by') estround(`estround')
				}
				*ANOVA
				else {
					sconttest `var' $_if $_in [`weight' `exp'], by(`by')  estround(`estround')
				}
			}

	}
}
	drop if outcome==""
	erase output.dta
	erase current.dta
	order outcome var
	format var %-12s
	format outcome %-12s
capture label var p "Parametric P Value"
capture label var star "Parametric P Value-Star"
capture label var pNP "Non-Parametric P Value"
capture label var starNP "Non-Parametric P Value-Star"



if "`num'" != ""  {
	foreach var of varlist est* {
		split `var', p("(" ")") gen(new)
			drop `var'
			drop new1 new2
			rename new3 `var'
	}
}
order outcome var est*

}
end
****************************

/**BEGIN SUBROUTINE-NON SVY PROGRAMS***/

****************************
program catoverall
syntax varlist(max=1) [if] [in] [pweight] [, nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1
		drop if `varlist'==.
		capture decode `varlist', gen(new2)
		capture tostring `varlist', force format(%9.0f) gen(new1)
			drop `varlist'
		
		
		forvalues i=10(1)25 {
			replace new1="a_`i'" if new1=="`i'"
		}
			
		capture gen `varlist'= new1 + ":" + new2
		capture gen `varlist'=new1
		
		table `varlist' $_if $_in  , replace
		split `varlist', p("a_")
		drop `varlist'
			capture gen `varlist'=`varlist'1+`varlist'2
			capture gen `varlist'=`varlist'1
						
			egen total=total(table1)
			gen freq=(table1/total)*100
			tostring table1, force format(%9.0f) replace
			
		if "`estround'"!="" {
			tostring freq, force format(%9.`estround'f) replace
		}
		else {
			tostring freq, force format(%9.2f) replace
		}
			if "`nonum'" != "" {
				gen est = freq + "%"
			}
			else {
				gen est = "(" + table1 + ")  " + freq + "%"
			}
			
			rename `varlist' var
			capture tostring var, force replace
				keep var est
			gen outcome="`varlist'"
			order outcome var est
		save `temp1', replace
		use output.dta, clear
		append using `temp1'
		save output.dta, replace
	end
****************************	
	
program conoverallnomed
syntax varlist(max=1) [if] [in] [pweight] [, nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1
		sum `varlist' $_if $_in , detail
			local skew=r(skewness)
		clear
			set obs 1
			gen outcome="`varlist'"
			gen var="`varlist'"
				gen n=r(N)
				gen mean=r(mean)
				gen sd=r(sd)
				gen med=r(p50)
			tostring n, force format(%9.0f) replace
			local mean=abs(mean)
			
		if "`estround'"!="" {
			tostring mean sd med, force format(%9.`estround'fc) replace
		}
		else {
			if `mean' >=100 {
				tostring mean sd med, force format(%9.0fc) replace
			}
		
			if `mean' >=10 & `mean' <100 {
				tostring mean sd med, force format(%9.1f) replace
			}
			if `mean' >=1 & `mean' <10 {
				tostring mean sd med, force format(%9.2f) replace
			}
			if `mean' <1 {
				tostring mean sd med, force format(%9.3f) replace
			}
		}	
			
			if "`nonum'"!="" {
				gen est= mean + " ± " + sd
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd 
			}
			keep outcome var est
				gen skew=`skew' 
				tostring skew, force format(%9.1f) replace
			
			save `temp1', replace
			use output.dta, clear
				append using `temp1'
			save output.dta, replace
	end
****************************	
	
program conoverallmed
syntax varlist(max=1) [if] [in] [pweight] [, nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1
		sum `varlist' $_if $_in , detail
			local skew=r(skewness)
		clear
			set obs 1
			gen outcome="`varlist'"
			gen var="`varlist'"
				gen n=r(N)
				gen mean=r(mean)
				gen sd=r(sd)
				gen med=r(p50)
			tostring n, force format(%9.0f) replace
			local mean=abs(mean)
			if "`estround'"!="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
			}
			
		else {
			if `mean' >=100 {
				tostring mean sd med, force format(%9.0fc) replace
			}
		
			if `mean' >=10 & `mean' <100 {
				tostring mean sd med, force format(%9.1f) replace
			}
			if `mean' >=1 & `mean' <10 {
				tostring mean sd med, force format(%9.2f) replace
			}
			if `mean' <1 {
				tostring mean sd med, force format(%9.3f) replace
			}
		}
			
			if "`nonum'"!="" {
				gen est= mean + " ± " + sd + "  [" + med + "]"
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd + "  [" + med + "]"
			}
			keep outcome var est
				gen skew=`skew' 
				tostring skew, force format(%9.1f) replace
			save `temp1', replace
			use output.dta, clear
				append using `temp1'
			save output.dta, replace
	end
****************************	

program catbygrp
syntax varlist(max=1) [if] [in] [pweight] [, by(varname) nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1 temp2
	tempvar new1 new2
		*Running the overalls again
		drop if `varlist'==.
		drop if `by'==.
		capture decode `varlist', gen(`new2')
		capture tostring `varlist', force format(%9.0f) gen(`new1')
			drop `varlist'
		
		forvalues i=10(1)25 {
			replace `new1'="a_`i'" if `new1'=="`i'"
		}
			
		capture gen `varlist'= `new1' + ":" + `new2'
		capture gen `varlist'=`new1'
		
		table `varlist' $_if $_in  , replace
		split `varlist', p("a_")
		drop `varlist'
			capture gen `varlist'=`varlist'1+`varlist'2
			capture gen `varlist'=`varlist'1
		
			egen total=total(table1)
			gen freq=(table1/total)*100
			tostring table1, force format(%9.0f) replace
			
		if "`estround'" != "" {
			tostring freq, force format(%9.`estround'f) replace
		}
		else {
			tostring freq, force format(%9.2f) replace
		}
			if "`nonum'"!="" {
				gen est = freq + "%" 
			}
			else {
				gen est = "(" + table1 + ")  " + freq + "%" 
			}
			
			rename `varlist' var
			capture tostring var, force replace
				keep var est
			gen outcome="`varlist'"
			order outcome var est
		save `temp1', replace
		
		*Running the BY Grps
		use current.dta, clear
		
		tab `varlist' `by' $_if $_in , chi2 
		local chi2 =r(p)
			capture drop if `varlist'==.
			capture drop if `by'==.
			
		capture decode `varlist', gen(`new2')
		capture tostring `varlist', force format(%9.0f) gen(`new1')
			drop `varlist'
		capture gen `varlist'= `new1' + ":" + `new2'
		capture gen `varlist'=`new1'

		table `varlist' $_if $_in  , replace by(`by')
			bys `by' : egen total=total(table1)	
			gen freq=(table1/total)*100
			tostring table1, force format(%9.0f) replace
			
			
		if "`estround'" != "" {
			tostring freq, force format(%9.`estround'f) replace
		}
		else {
			tostring freq, force format(%9.2f) replace
		}
			
			if "`nonum'"!="" {
				gen est = freq + "%" 
			}
			else {
				gen est = "(" + table1 + ")  " + freq + "%" 
			}
						
			rename `varlist' var
			capture tostring var, force replace
				keep `by' var est
				reshape wide est, i(var) j(`by')
			gen outcome="`varlist'"
			order outcome var est*
		save `temp2', replace
		
		use `temp1', clear
		joinby outcome var using `temp2', unmatched(none)
		order outcome var est*
		gen p=`chi2'
				gen star="†" if p <=0.10
				replace star="*" if p<=0.05
				replace star="**" if p<=0.01
				replace star="***" if p<=0.001
		tostring p, force format(%9.4f) replace
		replace p = "<.0001" if p=="0.0000"
		save `temp1', replace
			
		
		use output.dta, clear
			append using `temp1'
		save output.dta, replace
	end
****************************
	
program ttestmed
syntax varlist(max=1) [if] [in] [pweight] [, by(varname) nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1 temp2
		
		/**Overall EST**/
		drop if `by'==.
		sum `varlist' $_if $_in , detail
			local skew=r(skewness)
		
		clear
			set obs 1
			gen outcome="`varlist'"
			gen var="`varlist'"
				gen n=r(N)
				gen mean=r(mean)
				gen sd=r(sd)
				gen med=r(p50)
			tostring n, force format(%9.0f) replace
			local mean=abs(mean)
			
			if "`estround'" !="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
			}
			else {
			if `mean' >=100 {
				tostring mean sd med, force format(%9.0fc) replace
			}
		
			if `mean' >=10 & `mean' <100 {
				tostring mean sd med, force format(%9.1f) replace
			}
			if `mean' >=1 & `mean' <10 {
				tostring mean sd med, force format(%9.2f) replace
			}
			if `mean' <1 {
				tostring mean sd med, force format(%9.3f) replace
			}
			}
			
			if "`nonum'"!="" {
				gen est=mean + " ± " + sd + "  [" + med + "]"
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd + "  [" + med + "]"
			}
			keep outcome var est
			save `temp1', replace
			
			
			/**ESTIMATES BY GROUPS*/
			use current.dta, clear
			drop if `by'==.
			ttest `varlist' $_if $_in , by(`by') unequal
				local p1=r(p)
			ranksum `varlist' $_if $_in , by(`by')
				local p2=2*(1-normal(abs(r(z))))
				
			collapse (count) n=`varlist' (mean) mean=`varlist' (sd) sd=`varlist' (median) med=`varlist' $_if $_in , by(`by')
			 tostring n, force format(%9.0f) replace
			 local mean=abs(mean)
			 if "`estround'" !="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
			}
			else {
				if `mean' >=100 {
					tostring mean sd med, force format(%9.0fc) replace
				}
				if `mean' >=10 & `mean' <100 {
					tostring mean sd med, force format(%9.1f) replace
				}
				if `mean' >=1 & `mean' <10 {
					tostring mean sd med, force format(%9.2f) replace
				}
				if `mean' <1 {
					tostring mean sd med, force format(%9.3f) replace
				}
			}
			if "`nonum'"!="" {
				gen est=mean + " ± " + sd + "  [" + med + "]"
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd + "  [" + med + "]"
			}
			gen outcome="`varlist'"
			gen var="`varlist'"
			keep `by' outcome var est
				reshape wide est, i(outcome var) j(`by')
			
			order outcome var est*
			save `temp2', replace

			use `temp1', clear
			joinby outcome var using `temp2', unmatched(none)
			order outcome var est*
				gen p=`p1'
				gen star="†" if p <=0.10
				replace star="*" if p<=0.05
				replace star="**" if p<=0.01
				replace star="***" if p<=0.001
				
				gen pNP=`p2'
				gen starNP="†" if pNP <=0.10
				replace starNP="*" if pNP<=0.05
				replace starNP="**" if pNP<=0.01
				replace starNP="***" if pNP<=0.001
				
			tostring p pNP, force format(%9.4f) replace
			replace p = "<.0001" if p=="0.0000"
			replace pNP = "<.0001" if pNP=="0.0000"
				gen skew=`skew' 
				tostring skew, force format(%9.1f) replace
			
			save `temp1', replace
				
			use output.dta, clear
				append using `temp1'
			save output.dta, replace
end
****************************

program ttestnomed
syntax varlist(max=1) [if] [in] [pweight] [, by(varname) nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1 temp2
		
		/**Overall EST**/
		drop if `by'==.
		sum `varlist' $_if $_in , detail
		local skew=r(skewness)
		clear
			set obs 1
			gen outcome="`varlist'"
			gen var="`varlist'"
				gen n=r(N)
				gen mean=r(mean)
				gen sd=r(sd)
				gen med=r(p50)
			tostring n, force format(%9.0f) replace
			local mean=abs(mean)
			if "`estround'" !="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
			}
			else {
			if `mean' >=100 {
				tostring mean sd med, force format(%9.0fc) replace
			}
		
			if `mean' >=10 & `mean' <100 {
				tostring mean sd med, force format(%9.1f) replace
			}
			if `mean' >=1 & `mean' <10 {
				tostring mean sd med, force format(%9.2f) replace
			}
			if `mean' <1 {
				tostring mean sd med, force format(%9.3f) replace
			}
		}
			if "`nonum'"!="" {
				gen est=mean + " ± " + sd
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd 
			}
		
			keep outcome var est
			save `temp1', replace
			
			
			/**ESTIMATES BY GROUPS*/
			use current.dta, clear
			drop if `by'==.
			ttest `varlist' $_if $_in , by(`by') unequal
				local p1=r(p)
			ranksum `varlist' $_if $_in , by(`by') 
				local p2=2*(1-normal(abs(r(z))))
				
			collapse (count) n=`varlist' (mean) mean=`varlist' (sd) sd=`varlist' (median) med=`varlist' $_if $_in , by(`by')
			 tostring n, force format(%9.0f) replace
			 local mean=abs(mean)
			if "`estround'" !="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
			}
			else {
				if `mean' >=100 {
					tostring mean sd med, force format(%9.0fc) replace
				}
				if `mean' >=10 & `mean' <100 {
					tostring mean sd med, force format(%9.1f) replace
				}
				if `mean' >=1 & `mean' <10 {
					tostring mean sd med, force format(%9.2f) replace
				}
				if `mean' <1 {
					tostring mean sd med, force format(%9.3f) replace
				}
			}
			if "`nonum'"!="" {
				gen est=mean + " ± " + sd 
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd 
			}
			gen outcome="`varlist'"
			gen var="`varlist'"
			keep `by' outcome var est
				reshape wide est, i(outcome var) j(`by')
			
			order outcome var est*
			save `temp2', replace

			use `temp1', clear
			joinby outcome var using `temp2', unmatched(none)
			order outcome var est*
				gen p=`p1'
				gen star="†" if p <=0.10
				replace star="*" if p<=0.05
				replace star="**" if p<=0.01
				replace star="***" if p<=0.001
				
				gen pNP=`p2'
				gen starNP="†" if pNP <=0.10
				replace starNP="*" if pNP<=0.05
				replace starNP="**" if pNP<=0.01
				replace starNP="***" if pNP<=0.001
				
			tostring p pNP, force format(%9.4f) replace
			replace p = "<.0001" if p=="0.0000"
			replace pNP = "<.0001" if pNP=="0.0000"

			save `temp1', replace
				
			use output.dta, clear
				append using `temp1'
			save output.dta, replace
end
****************************


program anovamed
syntax varlist(max=1) [if] [in] [pweight] [, by(varname) nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1 temp2
		
		/**Overall EST**/
		drop if `by'==.
		sum `varlist' $_if $_in , detail
		local skew=r(skewness)
		clear
			set obs 1
			gen outcome="`varlist'"
			gen var="`varlist'"
				gen n=r(N)
				gen mean=r(mean)
				gen sd=r(sd)
				gen med=r(p50)
			tostring n, force format(%9.0f) replace
			local mean=abs(mean)
		if "`estround'" !="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
		}
		else {
			if `mean' >=100 {
				tostring mean sd med, force format(%9.0fc) replace
			}
		
			if `mean' >=10 & `mean' <100 {
				tostring mean sd med, force format(%9.1f) replace
			}
			if `mean' >=1 & `mean' <10 {
				tostring mean sd med, force format(%9.2f) replace
			}
			if `mean' <1 {
				tostring mean sd med, force format(%9.3f) replace
			}
		}

			if "`nonum'"!="" {
				gen est=mean + " ± " + sd + "  [" + med + "]"
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd + "  [" + med + "]"
			}
			keep outcome var est
			save `temp1', replace
			
			
			/**ESTIMATES BY GROUPS*/
			use current.dta, clear
			drop if `by'==.
			oneway `varlist' `by' $_if $_in 
				local p1=Ftail(r(df_m), r(df_r), r(F))
			kwallis `varlist' $_if $_in , by(`by')
				local p2=chi2tail(r(df), r(chi2_adj))
				
			collapse (count) n=`varlist' (mean) mean=`varlist' (sd) sd=`varlist' (median) med=`varlist' $_if $_in , by(`by')
			 tostring n, force format(%9.0f) replace
			 local mean=abs(mean)
		if "`estround'" !="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
		}
		else {			
				if `mean' >=100 {
					tostring mean sd med, force format(%9.0fc) replace
				}
				if `mean' >=10 & `mean' <100 {
					tostring mean sd med, force format(%9.1f) replace
				}
				if `mean' >=1 & `mean' <10 {
					tostring mean sd med, force format(%9.2f) replace
				}
				if `mean' <1 {
					tostring mean sd med, force format(%9.3f) replace
				}
			}
			if "`nonum'"!="" {
				gen est=mean + " ± " + sd + "  [" + med + "]"
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd + "  [" + med + "]"
			}
			gen outcome="`varlist'"
			gen var="`varlist'"
			keep `by' outcome var est
				reshape wide est, i(outcome var) j(`by')
			
			order outcome var est*
			save `temp2', replace

			use `temp1', clear
			joinby outcome var using `temp2', unmatched(none)
			order outcome var est*
				gen p=`p1'
				gen star="†" if p <=0.10
				replace star="*" if p<=0.05
				replace star="**" if p<=0.01
				replace star="***" if p<=0.001
				
				gen pNP=`p2'
				gen starNP="†" if pNP <=0.10
				replace starNP="*" if pNP<=0.05
				replace starNP="**" if pNP<=0.01
				replace starNP="***" if pNP<=0.001
				
			tostring p pNP, force format(%9.4f) replace
			replace p = "<.0001" if p=="0.0000"
			replace pNP = "<.0001" if pNP=="0.0000"
				gen skew=`skew' 
				tostring skew, force format(%9.1f) replace
			
			save `temp1', replace
		
			use output.dta, clear
				append using `temp1'
			save output.dta, replace
end
****************************

program anovanomed
syntax varlist(max=1) [if] [in] [pweight] [, by(varname) nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1 temp2
		
		/**Overall EST**/
		drop if `by'==.
		sum `varlist' $_if $_in , detail
		local skew=r(skewness)
		clear
			set obs 1
			gen outcome="`varlist'"
			gen var="`varlist'"
				gen n=r(N)
				gen mean=r(mean)
				gen sd=r(sd)
				gen med=r(p50)
			tostring n, force format(%9.0f) replace
			local mean=abs(mean)
		if "`estround'" !="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
		}
		else {			
			if `mean' >=100 {
				tostring mean sd med, force format(%9.0fc) replace
			}
		
			if `mean' >=10 & `mean' <100 {
				tostring mean sd med, force format(%9.1f) replace
			}
			if `mean' >=1 & `mean' <10 {
				tostring mean sd med, force format(%9.2f) replace
			}
			if `mean' <1 {
				tostring mean sd med, force format(%9.3f) replace
			}
			
		}
			if "`nonum'"!="" {
				gen est=mean + " ± " + sd 
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd 
			}
			keep outcome var est
			save `temp1', replace
			
			
			/**ESTIMATES BY GROUPS*/
			use current.dta, clear
			drop if `by'==.
			oneway `varlist' `by' $_if $_in 
				local p1=Ftail(r(df_m), r(df_r), r(F))
			kwallis `varlist' $_if $_in , by(`by')
				local p2=chi2tail(r(df), r(chi2_adj))
				
			collapse (count) n=`varlist' (mean) mean=`varlist' (sd) sd=`varlist' (median) med=`varlist' $_if $_in , by(`by')
			 tostring n, force format(%9.0f) replace
			 local mean=abs(mean)
			if "`estround'" !="" {
				tostring mean sd med, force format(%9.`estround'fc) replace
			}
			else {
			
				if `mean' >=100 {
					tostring mean sd med, force format(%9.0fc) replace
				}
				if `mean' >=10 & `mean' <100 {
					tostring mean sd med, force format(%9.1f) replace
				}
				if `mean' >=1 & `mean' <10 {
					tostring mean sd med, force format(%9.2f) replace
				}
				if `mean' <1 {
					tostring mean sd med, force format(%9.3f) replace
				}
			}
			if "`nonum'"!="" {
				gen est=mean + " ± " + sd 
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd 
			}
			gen outcome="`varlist'"
			gen var="`varlist'"
			keep `by' outcome var est
				reshape wide est, i(outcome var) j(`by')
			
			order outcome var est*
			save `temp2', replace

			use `temp1', clear
			joinby outcome var using `temp2', unmatched(none)
			order outcome var est*
				gen p=`p1'
				gen star="†" if p <=0.10
				replace star="*" if p<=0.05
				replace star="**" if p<=0.01
				replace star="***" if p<=0.001
				
				gen pNP=`p2'
				gen starNP="†" if pNP <=0.10
				replace starNP="*" if pNP<=0.05
				replace starNP="**" if pNP<=0.01
				replace starNP="***" if pNP<=0.001
				
			tostring p pNP, force format(%9.4f) replace
			replace p = "<.0001" if p=="0.0000"
			replace pNP = "<.0001" if pNP=="0.0000"
				gen skew=`skew' 
				tostring skew, force format(%9.1f) replace
			save `temp1', replace
				
			use output.dta, clear
				append using `temp1'
			save output.dta, replace
end
****************************




/**BEGIN SUBROUTINE-SVY PROGRAMS***/

****************************
program scatoverall
syntax varlist(max=1) [if] [in] [pweight] [, nonum estround(numlist  missingokay max=1 integer)]
svyset _n [`weight'`exp'], vce(linearized) singleunit(missing)
	tempfile temp1
		drop if `varlist'==.
		capture decode `varlist', gen(new2)
		capture tostring `varlist', force format(%9.0f) gen(new1)
			drop `varlist'
		forvalues i=10(1)25 {
			replace new1="a_`i'" if new1=="`i'"
		}
			
		capture gen `varlist'= new1 + ":" + new2
		capture gen `varlist'=new1
		tab `varlist' $_if $_in
			local row=r(r)
		svy linearized : tabulate `varlist' $_if $_in, obs percent
			matrix p=e(Prop)
			matrix n=e(Obs)
		keep `varlist'
			duplicates drop
		gen outcome="`varlist'"
		rename `varlist' var
			sort var
		gen freq=.
		gen table1=.
		
		forvalues i=1(1)`row' {
			replace freq=p[`i',1] in `i'
			replace table1=n[`i',1] in `i'
		}
		
		replace freq=freq*100
		tostring table1, force format(%9.0f) replace
		
		split var, p("a_")
		drop var
			capture gen var=var1+var2
			capture gen var=var1
		
		
		
		if "`estround'" != "" {
			tostring freq, force format(%9.`estround'f) replace
		}
		
		else {
		 tostring freq, force format(%9.2f) replace
		}
		if "`nonum'" !="" {
			gen est = freq + "%" 
		}
		else {
			gen est = "(" + table1 + ")  " + freq + "%" 
		}
			keep var outcome est
			order outcome var est
		save `temp1', replace
		
			capture matrix drop _all
		use output.dta, clear
		append using `temp1'
		save output.dta, replace
	end
****************************	
	
program sconoverall
syntax varlist(max=1) [if] [in] [pweight] [, nonum estround(numlist  missingokay max=1 integer)]
	svyset _n [`weight'`exp'], vce(linearized) singleunit(missing)
	tempfile temp1
		sum `varlist' $_if $_in, detail
		local skew=r(skewness)
	
		svy linearized : mean `varlist' $_if $_in
			matrix mean=e(b)
			estat sd
			matrix sd=r(sd)
				local mean=mean[1,1]
				local n=e(N)
				local sd=sd[1,1]
		clear
			set obs 1
			gen outcome="`varlist'"
			gen var="`varlist'"
				gen n=`n'
				gen mean=`mean'
				gen sd=`sd'
			tostring n, force format(%9.0f) replace
		
		if "`estround'" !="" {
			tostring mean sd, force format(%9.`estround'fc) replace
		}
		
		
		else {
			if `mean' >=100 {
				tostring mean sd, force format(%9.0fc) replace
			}
		
			if `mean' >=10 & `mean' <100 {
				tostring mean sd, force format(%9.1f) replace
			}
			if `mean' >=1 & `mean' <10 {
				tostring mean sd, force format(%9.2f) replace
			}
			if `mean' <1 {
				tostring mean sd, force format(%9.3f) replace
			}
		}
			if "`nonum'"!="" {
				gen est=mean + " ± " + sd 
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd 
			}
			keep outcome var est
				gen skew=`skew' 
				tostring skew, force format(%9.1f) replace
			save `temp1', replace
				capture matrix drop _all
			use output.dta, clear
				append using `temp1'
			save output.dta, replace
	end
****************************	
	
****************************	

program scatbygrp
syntax varlist(max=1) [if] [in] [pweight] [, by(varname) nonum estround(numlist  missingokay max=1 integer)]
	tempfile temp1
	tempvar new1 new2
		*Running the overalls again
	svyset _n [`weight'`exp'], vce(linearized) singleunit(missing)
		drop if `varlist'==.
		capture decode `varlist', gen(new2)
		capture tostring `varlist', force format(%9.0f) gen(new1)
			drop `varlist'
		forvalues i=10(1)25 {
			replace new1="a_`i'" if new1=="`i'"
		}
			
		capture gen `varlist'= new1 + ":" + new2
		capture gen `varlist'=new1
		tab `varlist' $_if $_in
			local row=r(r)
		svy linearized : tabulate `varlist' $_if $_in, obs percent
			matrix p=e(Prop)
			matrix n=e(Obs)
		keep `varlist'
			duplicates drop
		gen outcome="`varlist'"
		rename `varlist' var
			sort var
		gen freq=.
		gen table1=.
		
		forvalues i=1(1)`row' {
			replace freq=p[`i',1] in `i'
			replace table1=n[`i',1] in `i'
		}
		
		replace freq=freq*100
		tostring table1, force format(%9.0f) replace
		
		split var, p("a_")
		drop var
			capture gen var=var1+var2
			capture gen var=var1
		
		
		if "`estround'" !="" {
			tostring freq, force format(%9.`estround'f) replace
		}
		
		
		else {
			tostring freq, force format(%9.2f) replace
		}
		if "`nonum'"!="" {
				gen est =  freq + "%" 
		}
		else {
			gen est = "(" + table1 + ")  " + freq + "%" 
		}
			keep var outcome est
			order outcome var est
				capture matrix drop _all
		save `temp1', replace
		
		*Running the BY Grps
		use current.dta, clear
		svyset _n [`weight'`exp'], vce(linearized) singleunit(missing)

		svy linearized : tabulate `varlist' `by' $_if $_in, obs column pearson
			local chi2 =e(p_Pear)
			matrix n=e(Obs)
			matrix p=e(Prop)
			local pop=e(N_pop)
		tab `by' $_if $_in 
			local col=r(r)
			
		use `temp1', clear
			local row=_N
			
			forvalues i=1(1)`col' {
				gen num`i' = .
				gen freq`i'=.
			}
			
		if "`nonum'" !="" {
			forvalues i=1(1)`row' {
				forvalues c=1(1)`col' {
					replace num`c' = n[`i', `c'] in `i'
					replace freq`c' = p[`i', `c'] in `i'
				}
			}
			
			gen pop=`pop'
			forvalues i=1(1)`col' {
				gen sub`i'=freq`i'*pop
				egen total`i'=total(sub`i')
				replace freq`i'=(sub`i'/total`i')*100
			}

			tostring num*, force format(%9.0f) replace
			
			if "`estround'" !="" {
				tostring freq*, force format(%9.`estround'fc) replace
			}
		
		
			else {
				tostring freq*, force format(%9.2f) replace
			}
			forvalues c=1(1)`col' {
				gen est`c' = freq`c' + "%" 
			}
		}
		else {
			forvalues i=1(1)`row' {
				forvalues c=1(1)`col' {
					replace num`c' = n[`i', `c'] in `i'
					replace freq`c' = p[`i', `c'] in `i'
				}
			}
			
			gen pop=`pop'
			forvalues i=1(1)`col' {
				gen sub`i'=freq`i'*pop
				egen total`i'=total(sub`i')
				replace freq`i'=(sub`i'/total`i')*100
			}

			tostring num*, force format(%9.0f) replace
		if "`estround'" !="" {
			tostring freq*, force format(%9.`estround'f) replace
		}
		else {
			tostring freq*, force format(%9.2f) replace
		}
			forvalues c=1(1)`col' {
				gen est`c' = "(" + num`c' + ")  " + freq`c' + "%" 
			}
		}
			keep outcome var est*
			gen p=`chi2'
				gen star="†" if p <=0.10
				replace star="*" if p<=0.05
				replace star="**" if p<=0.01
				replace star="***" if p<=0.001
		tostring p, force format(%9.4f) replace
		replace p = "<.0001" if p=="0.0000"
		save `temp1', replace
			capture matrix drop _all
		use output.dta, clear
			append using `temp1'
		save output.dta, replace
	end
****************************
program sconttest
syntax varlist(max=1) [if] [in] [pweight] [, by(varname) nonum estround(numlist  missingokay max=1 integer)]
	svyset _n [`weight'`exp'], vce(linearized) singleunit(missing)
	tempfile temp1 temp2
		sum `varlist' $_if $_in , detail
		local skew=r(skewness)
		svy linearized : mean `varlist' $_if $_in
			matrix mean=e(b)
			estat sd
			matrix sd=r(sd)
				local mean=mean[1,1]
				local n=e(N)
				local sd=sd[1,1]
		clear
			set obs 1
			gen outcome="`varlist'"
			gen var="`varlist'"
				gen n=`n'
				gen mean=`mean'
				gen sd=`sd'
			tostring n, force format(%9.0f) replace
	
			if "`estround'"!="" {
				tostring mean sd, force format(%9.`estround'fc) replace
			}
			else {
				if `mean' >=100 {
					tostring mean sd, force format(%9.0fc) replace
				}
			
				if `mean' >=10 & `mean' <100 {
					tostring mean sd, force format(%9.1f) replace
				}
				if `mean' >=1 & `mean' <10 {
					tostring mean sd, force format(%9.2f) replace
				}
				if `mean' <1 {
					tostring mean sd, force format(%9.3f) replace
				}
			}
			
			if "`nonum'" !="" {
				gen est=mean + " ± " + sd 
			}
			else {
				gen est="("+ n + ")  " + mean + " ± " + sd 
			}
			keep outcome var est
			save `temp1', replace
			
			
			/**ESTIMATES BY GROUPS*/
			use current.dta, clear
				svyset _n [`weight'`exp'], vce(linearized) singleunit(missing)
				drop if `by'==.
			svy linearized : mean `varlist' $_if $_in, over(`by')
				estat sd
				matrix mean=e(b)
				matrix sd=r(sd)
				matrix n=e(_N)
			
			regress   `varlist' i.`by' $_if $_in [`weight'`exp'] 
				local p=Ftail( e(df_m),  e(df_r), e(F))

			tab `by' $_if $_in
				local col=r(r)
			
			use `temp1', clear
			forvalues i=1(1)`col' {
				gen n`i'=n[1,`i']
				gen mean`i'=mean[1,`i']
				gen sd`i'=sd[1,`i']
			}
			tostring n*, force format(%9.0f) replace
			local mean=abs(mean1)
				
			if "`estround'"!="" {
				tostring mean* sd*, force format(%9.`estround'fc) replace
			}

			else {
				if `mean' >=100 {
					tostring mean* sd*, force format(%9.0fc) replace
				}
			
				if `mean' >=10 & `mean' <100 {
					tostring mean* sd*, force format(%9.1f) replace
				}
				if `mean' >=1 & `mean' <10 {
					tostring mean* sd*, force format(%9.2f) replace
				}
				if `mean' <1 {
					tostring mean* sd*, force format(%9.3f) replace
				}
			}
				if "`nonum'" != "" {
					forvalues i=1(1)`col' {
						gen est`i'=mean`i' + " ± " + sd`i'
					}
				}
				else {
					forvalues i=1(1)`col' {
						gen est`i'="("+ n`i' + ")  " + mean`i' + " ± " + sd`i'
					}
				}
				keep outcome var est*
		
				gen p=`p'
				gen star="†" if p <=0.10
					replace star="*" if p<=0.05
					replace star="**" if p<=0.01
					replace star="***" if p<=0.001
					
			tostring p, force format(%9.4f) replace
			replace p = "<.0001" if p=="0.0000"
				gen skew=`skew' 
				tostring skew, force format(%9.1f) replace
			save `temp1', replace
				capture matrix drop _all
			use output.dta, clear
				append using `temp1'
			save output.dta, replace
end




exit
