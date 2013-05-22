

program define outliers
syntax varlist [if] 

qui {
preserve

version 11

save faketemp.dta, replace
	
clear
set more off
set obs 1
gen var=""
save output.dta, replace


use faketemp.dta, clear
foreach var of varlist `varlist' {
	use faketemp.dta, clear
	sum `var' $_if , detail
	local skew= r(skewness)
	local kurtosis=r(kurtosis)
	local mean=r(mean)
	local sd=r(sd)
	local med=r(p50)
	local min=r(min)
	local max=r(max)

	
		local total=r(N)
			capture drop temp
			gen temp=1 if `var' <= r(mean)+r(sd) & `var'>= r(mean)-r(sd)
			gen sd1=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(mean)+2*r(sd) & `var'>= r(mean)-2*r(sd)
			gen sd2=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(mean)+3*r(sd) & `var'>= r(mean)-3*r(sd)
			gen sd3=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(mean)+3.5*r(sd) & `var'>= r(mean)-3.5*r(sd)
			gen sd35=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(mean)+4*r(sd) & `var'>= r(mean)-4*r(sd)
			gen sd4=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(p50)+r(sd) & `var'>= r(p50)-r(sd)
			gen sdmed1=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(p50)+2*r(sd) & `var'>= r(p50)-2*r(sd)
			gen sdmed2=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(p50)+3*r(sd) & `var'>= r(p50)-3*r(sd)
			gen sdmed3=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(p50)+3.5*r(sd) & `var'>= r(p50)-3.5*r(sd)
			gen sdmed35=temp $_if 
			capture drop temp
			gen temp=1 if `var' <= r(p50)+4*r(sd) & `var'>= r(p50)-4*r(sd)
			gen sdmed4=temp $_if 
		collapse (count) sd1 sd2 sd3 sd35 sd4 sdmed1 sdmed2 sdmed3 sdmed35 sdmed4 $_if
		gen total=`total'
		replace sd1=(sd1/total)*100
		replace sd2=(sd2/total)*100
		replace sd3=(sd3/total)*100
		replace sd35=(sd35/total)*100
		replace sd4=(sd4/total)*100
		replace sdmed1=(sdmed1/total)*100
		replace sdmed2=(sdmed2/total)*100
		replace sdmed3=(sdmed3/total)*100
		replace sdmed35=(sdmed35/total)*100
		replace sdmed4=(sdmed4/total)*100
		
		drop total
		gen skew=`skew'
		gen kurtosis=`kurtosis'
		tostring sd* skew kurtosis, force format(%9.1f) replace
		gen var="`var'"
		gen mean=`mean'
		gen med=`med'
		gen sd=`sd'
		gen min=`min'
		gen max=`max'
		tostring min max mean med sd, force format(%9.2f) replace
		gen est=mean + " ± " + sd + "  [" + med + "]" + " (" + min + " - " + max + ")"
		drop mean sd med min max
		order var est skew sd1 sd2 sd3 sd35 sd4  sdmed1 sdmed2 sdmed3 sdmed35 sdmed4
			save temp.dta, replace
			use output.dta, clear
				append using temp.dta
			save output.dta, replace
	
	}
	drop if var==""
	label var est "Mean ± SD [Median] (Min-Max)"
	label var sd1 "% Data Within 1SD of Mean"
			label var sd2 "% Data Within 2SD of Mean"
				label var sd3 "% Data Within 3SD of Mean"
					label var sd35 "% Data Within 3.5SD of Mean"
						label var sd4 "% Data Within 4SD of Mean"
						
		label var sdmed1 "% Data Within 1SD of Median"
			label var sdmed2 "% Data Within 2SD of Median"
				label var sdmed3 "% Data Within 3SD of Median"
					label var sdmed35 "% Data Within 3.5SD of Median"
						label var sdmed4 "% Data Within 4SD of Median"
		noi: display "Outlier analysis of `var' completed"
	save output.dta, replace

	capture erase temp1.dta
	capture erase temp.dta
	capture erase faketemp.dta
	drop sdmed*
}
describe
list ,  noobs divider sepby(var)
restore 

end
exit
