program exout 
syntax [if] [, Vars(varlist) TABle(namelist) DIRectory(string) SHeet(namelist) OVERwrite replace]
*Version 1.0 12/19/2011, Nick Jackson, University of Pennsylvania
qui {
tempfile master current
version 12

save `master', replace

capture keep $if
capture keep $in


save `using', replace

local currdir=c(pwd)
	if "`currdir'" == "c:" {
		local currdir  c:\
	}
	else {
	}


if "`directory'" != "" {
	local newdir `directory'
	cd "`newdir'"
}
else {
}
*

if "`overwrite'" == "" {
	if "`replace'" == "" {	
		if "`vars'" == "" {
			if "`table'"==""{
				*Default Table Name, All Vars
				export excel _all using "results_$S_DATE" $_if, sheet("`sheet'") firstrow(variables) 
			}
			if "`table'"!=""{
				*Specified Table Name, All Vars
				export excel _all using "`table'" $_if, sheet("`sheet'") firstrow(variables) 
			}
		}
		if "`vars'" != "" {
			if "`table'"==""{
				*Default Table Name, All Vars
				export excel `vars' using "results_$S_DATE" $_if, sheet("`sheet'") firstrow(variables) 
			}
			if "`table'"!=""{
				*Specified Table Name, All Vars
				export excel `vars' using "`table'" $_if, sheet("`sheet'") firstrow(variables) 
			}
		}
	}
	else  {	
		if "`vars'" == "" {
			if "`table'"==""{
				*Default Table Name, All Vars
				export excel _all using "results_$S_DATE" $_if, sheet("`sheet'") firstrow(variables)  sheetreplace
			}
			if "`table'"!=""{
				*Specified Table Name, All Vars
				export excel _all using "`table'" $_if, sheet("`sheet'") firstrow(variables)  sheetreplace
			}
		}
		if "`vars'" != "" {
			if "`table'"==""{
				*Default Table Name, All Vars
				export excel `vars' using "results_$S_DATE" $_if, sheet("`sheet'") firstrow(variables)  sheetreplace
			}
			if "`table'"!=""{
				*Specified Table Name, All Vars
				export excel `vars' using "`table'" $_if, sheet("`sheet'") firstrow(variables)  sheetreplace
			}
		}
	}	
}
*

else {
	if "`replace'" == "" {	
		if "`vars'" == "" {
			if "`table'"==""{
				*Default Table Name, All Vars
				export excel _all using "results_$S_DATE" $_if, sheet("`sheet'") firstrow(variables) replace
			}
			if "`table'"!=""{
				*Specified Table Name, All Vars
				export excel _all using "`table'" $_if, sheet("`sheet'") firstrow(variables) replace
			}
		}
		if "`vars'" != "" {
			if "`table'"==""{
				*Default Table Name, All Vars
				export excel `vars' using "results_$S_DATE" $_if, sheet("`sheet'") firstrow(variables) replace
			}
			if "`table'"!=""{
				*Specified Table Name, All Vars
				export excel `vars' using "`table'" $_if, sheet("`sheet'") firstrow(variables) replace
			}
		}
	}
	else {	
		if "`vars'" == "" {
			if "`table'"==""{
				*Default Table Name, All Vars
				export excel _all using "results_$S_DATE" $_if, sheet("`sheet'") firstrow(variables) replace sheetreplace
			}
			if "`table'"!=""{
				*Specified Table Name, All Vars
				export excel _all using "`table'" $_if, sheet("`sheet'") firstrow(variables) replace sheetreplace
			}
		}
		if "`vars'" != "" {
			if "`table'"==""{
				*Default Table Name, All Vars
				export excel `vars' using "results_$S_DATE" $_if, sheet("`sheet'") firstrow(variables) replace sheetreplace
			}
			if "`table'"!=""{
				*Specified Table Name, All Vars
				export excel `vars' using "`table'" $_if, sheet("`sheet'") firstrow(variables) replace sheetreplace
			}
		}
	}
	
}

cd "`currdir'"
}
use `master', clear
end 
exit

