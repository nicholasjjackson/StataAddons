program strstrip
syntax varlist [, Lcut(numlist integer max=1) Rcut(numlist integer max=1) ignore(string) noreplace nodestring RKeep(numlist integer max=1) LKeep(numlist integer max=1)]
*Nick Jackson, Department of Psychology, University of Southern California
*Version 05/20/2013 1.0 


qui {
set more off
version 12


if "`lcut'" == "" & "`rcut'" == "" & "`lkeep'" == "" & "`rkeep'" == "" {
	noi dis as error: "Error Must specify either lcut or rcut option (lowercase)"
}
*
if "`nodestring'" != "" {

	local destringcmd ""

}
if "`nodestring'" == "" {
	local destringcmd1 capture destring `var', replace ignore("`ignore'")
	local destringcmd2 capture destring `var'_R, replace ignore("`ignore'")
}


foreach var of varlist `varlist' {


	***ASSUMING WE ARE CUTTING ONLY
	*Left Cut, No Right
	if "`lcut'" != "" & "`rcut'" == "" {
		local cut1=`lcut' +1 
		if "`noreplace'" == "" {
			capture tostring `var', force replace 
				replace `var'=substr(`var', `cut1', .)
			`destringcmd1'
		}
		else {
			capture tostring `var', force gen(`var'_R)
				replace `var'_R=substr(`var'_R, `cut1', .)
			`destringcmd2'
		}
	}
	if "`lcut'" == "" & "`rcut'" != "" {
		local cut2=`rcut' +1 
		
		if "`noreplace'" == "" {
			capture tostring `var', force replace 
				replace `var'=reverse(substr(reverse(`var'), `cut2', .))
			`destringcmd1'
		}
		else {
			capture tostring `var', force gen(`var'_R)
			replace `var'_R=reverse(substr(reverse(`var'_R), `cut2', .))
			`destringcmd2'
		}
	}
	if "`lcut'" != "" & "`rcut'" != "" {
		local cut1=`lcut' +1 
		local cut2=`rcut' +1 
		if "`noreplace'" == "" {
			capture tostring `var', force replace 
				replace `var'=substr(`var', `cut1', .)
				replace `var'=reverse(substr(reverse(`var'), `cut2', .))
			`destringcmd1'
		}
		else {
			capture tostring `var', force gen(`var'_R)
				replace `var'_R=substr(`var'_R, `cut1', .)
				replace `var'_R=reverse(substr(reverse(`var'_R), `cut2', .))
			`destringcmd2'
		}
		
	}
	
	
	***ASSUMING WE ARE KEEPING ONLY
	*Left Cut, No Right
	if "`lkeep'" != "" & "`rkeep'" == "" {
		local keep1=-`lkeep'
		if "`noreplace'" == "" {
			capture tostring `var', force replace 
				replace `var'=reverse(substr(reverse(`var'), `keep1', .))
			`destringcmd1'
		}
		else {
			capture tostring `var', force gen(`var'_R)
				replace `var'_R=reverse(substr(reverse(`var'_R), `keep1', .))
			`destringcmd2'		
		}
	}
	if "`lkeep'" == "" & "`rkeep'" != "" {
		local keep2=-`rkeep' 
		if "`noreplace'" == "" {	
			capture tostring `var', force replace 
			replace `var'=substr(`var', `keep2', .)
			`destringcmd1'
		}
		else {
			capture tostring `var', force gen(`var'_R)
			replace `var'_R=substr(`var'_R, `keep2', .)
			`destringcmd2'
		}
	}
	if "`lkeep'" != "" & "`rkeep'" != "" {
		local keep1=-`lkeep'
		local keep2=-`rkeep'
		
		if "`noreplace'" == "" {
			capture tostring `var', force replace 
				
				capture drop new1 
				capture drop new2
				gen new2=substr(`var', `keep2', .)
				gen new1=reverse(substr(reverse(`var'), `keep1', .))
				replace `var'= new1 + new2
				drop new1 new2
			`destringcmd1'
		}
		else {
			capture tostring `var', force gen(`var'_R)
				
				capture drop new1 
				capture drop new2
				gen new2=substr(`var'_R, `keep2', .)
				gen new1=reverse(substr(reverse(`var'_R), `keep1', .))
				replace `var'_R= new1 + new2
				drop new1 new2
			`destringcmd2'
		
		}
	}
	
	
	
}

}
end 
exit
