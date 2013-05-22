*******************************************************************************************
*Title: DISTDESC.ADO
*Automatic DO File
*Statistical Programmer: Nick Jackson, Division of Sleep Medicine, University of Pennsylvania
*Stata Version 11
*******************************************************************************************
*Created 06/14/2011
*Version 1.0
*Version 1.5 02/20/2012: added minmax option

program distdesc 
set more off
syntax varlist [if] [in] [pweight] [, by(varname) bin(numlist max=1 integer) freq curve cat(numlist max=1 integer) estround(numlist  missingokay max=1 integer) minmax ]

tempfile current
qui {
save `current', replace

		if "`cat'"!="" {
			local cutpoint=`cat'
		}
		else {
			local cutpoint=9
		}
use `current', clear
foreach var in `varlist' {
use `current', clear		
		
		inspect `var' $_if $_in 
		local rows=r(N_unique)

		/*Continuous Variables*/
		if `rows' >`cutpoint' {	
			sum `var' $_if $_in, det
				local mean=r(mean)
				local med=r(p50)
				local min=r(min)
				local max=r(max)
				local sd=r(sd)
				local n=r(N)
				local skew=r(skewness)
				
			clear
			set obs 1
				gen mean=`mean'
				gen min=`min'
				gen max=`max'
				gen sd=`sd'
				gen skew=`skew'
				gen med=`med'
			
			if "`estround'" != "" {
					tostring min max mean sd med, force format(%9.`estround'fc) replace
			}
			
			else {
					if `mean' >=100 {
						tostring min max mean sd med, force format(%9.0fc) replace
					}
				
					if `mean' >=10 & `mean' <100 {
						tostring min max mean sd med, force format(%9.1f) replace
					}
					if `mean' >=1 & `mean' <10 {
						tostring min max mean sd med, force format(%9.2f) replace
					}
					if `mean' <1 {
						tostring  min max mean sd med, force format(%9.3f) replace
					}
			}
			
			tostring skew, force format(%9.1f) replace
						local mean=mean
						local min=min
						local max=max
						local med=med
						local sd=sd
						local skew=skew
			use `current', clear
			if "`minmax'"=="" {
				if "`freq'"!="" {
					if "`curve'" !="" {
							if "`bin'"!="" {
								histogram `var' $_if $_in, bin(`bin') norm frequency xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med', Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, norm frequency xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med', Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}
					else {
							if "`bin'"!="" {
								histogram `var' $_if $_in, bin(`bin') frequency xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med', Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, frequency xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med', Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}	
				}
				else {
					if "`curve'" !="" {
							if "`bin'"!="" {
								histogram `var' $_if $_in, bin(`bin') norm xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med', Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else { 
								histogram `var' $_if $_in, norm xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med', Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}
					else {
							if "`bin'"!="" {
								histogram `var' $_if $_in, bin(`bin') xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med', Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in,  xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med', Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}	
			
				}
			}/*MinMax*/
			else {
				if "`freq'"!="" {
					if "`curve'" !="" {
							if "`bin'"!="" {
								histogram `var' $_if $_in, bin(`bin') norm frequency xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med'" "[Min: `min', Max: `max'], Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, norm frequency xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med'" "[Min: `min', Max: `max'], Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}
					else {
							if "`bin'"!="" {
								histogram `var' $_if $_in, bin(`bin') frequency xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med'" "[Min: `min', Max: `max'], Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, frequency xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med'" "[Min: `min', Max: `max'], Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							} 
					}	
				}
				else {
					if "`curve'" !="" {
							if "`bin'"!="" {
								histogram `var' $_if $_in, bin(`bin') norm xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med'" "[Min: `min', Max: `max'], Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, norm xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med'" "[Min: `min', Max: `max'], Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}
					else {
							if "`bin'"!="" {
								histogram `var' $_if $_in, bin(`bin') xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med'" "[Min: `min', Max: `max'], Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in,  xtitle("`var'") xtitle(, margin(medsmall)) title("Distribution of `var'") subtitle("(`n')  `mean' ± `sd', Median=`med'" "[Min: `min', Max: `max'], Skew=`skew'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}	
			
				}
			}/*MinMax ELSE*/
		} /*Continuous Marker Tag*/
			
		
		/*Categorical Variables*/	
		if `rows' <=`cutpoint' {
				sum `var' $_if $_in
					local n=r(N)
	
				if "`freq'"!="" {
					if "`curve'" !="" {
							if "`bin'"!="" {
								histogram `var' $_if $_in, discrete gap(40) addlabel percent xtitle("`var'") xtitle(, margin(medsmall)) xlabel(#`rows', labels valuelabel) title("Distribution of `var'") subtitle("N=`n'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, discrete gap(40) addlabel percent xtitle("`var'") xtitle(, margin(medsmall)) xlabel(#`rows', labels valuelabel) title("Distribution of `var'") subtitle("N=`n'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}
					else {
							if "`bin'"!="" {
								histogram `var' $_if $_in, discrete gap(40) addlabel percent xtitle("`var'") xtitle(, margin(medsmall)) xlabel(#`rows', labels valuelabel) title("Distribution of `var'") subtitle("N=`n'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, discrete gap(40) addlabel percent xtitle("`var'") xtitle(, margin(medsmall)) xlabel(#`rows', labels valuelabel) title("Distribution of `var'") subtitle("N=`n'", size(small)) caption("$_if $_in") name(`var', replace)
							} 
					}	
				}
				else {
					if "`curve'" !="" {
							if "`bin'"!="" {
								histogram `var' $_if $_in, discrete gap(40) addlabel frequency  xtitle("`var'") xtitle(, margin(medsmall)) xlabel(#`rows', labels valuelabel) title("Distribution of `var'") subtitle("N=`n'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, discrete gap(40) addlabel frequency  xtitle("`var'") xtitle(, margin(medsmall)) xlabel(#`rows', labels valuelabel) title("Distribution of `var'") subtitle("N=`n'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}
					else {
							if "`bin'"!="" {
								histogram `var' $_if $_in, discrete gap(40) addlabel  frequency  xtitle("`var'") xtitle(, margin(medsmall)) xlabel(#`rows', labels valuelabel) title("Distribution of `var'") subtitle("N=`n'", size(small)) caption("$_if $_in") name(`var', replace)
							}
							else {
								histogram `var' $_if $_in, discrete gap(40) addlabel  frequency  xtitle("`var'") xtitle(, margin(medsmall)) xlabel(#`rows', labels valuelabel) title("Distribution of `var'") subtitle("N=`n'", size(small)) caption("$_if $_in") name(`var', replace)
							}
					}	
			
				}
			} /*Categorical Marker Tag*/
		/*Pause Insert*/			
			
	} /*For each Tag*/
	
	
			
} /*QUI Tag*/		
	end
	exit
