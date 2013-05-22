program transfertools
qui {
set more off

global uscpsych \\FSC_V7_SERVER\V7\PSYC\Baker Lab Shared Data\Nick Jackson\Programs
global tools C:\Dropbox\Statistics Resources\Nicks Toolbox
global shared C:\Dropbox\Shared Stata AddOns\Stata Addons


****USC to DROPBOX

**Find USC Files to COPY
capture log close
cd "$uscpsych"
log using c:\temp\usc.txt, replace 
	noi dir 
log close 

insheet using c:\temp\usc.txt, clear
	keep if index(v1, "ado") |  index(v1, "do") | index(v1, "bat")
	split v1, p("  ")
	replace v14=v13 if v14==""
	
	gen new="copy " + v14 + `" ""' + "$tools\\USC\" + v14  + `"""' + + ", replace"
	keep new
	outsheet using "c:\temp\copyit.txt", nonames noquote replace
	
	*COPY USC PROGRAMS TO DROPBOX
	cd "$uscpsych"
	do c:\temp\copyit.txt
	

**Find TOOLD Files to COPY
capture log close
cd "$tools"
log using c:\temp\tools.txt, replace 
	noi dir 
log close 


insheet using c:\temp\tools.txt, clear
	keep if index(v1, "ado") |  index(v1, "do") | index(v1, "bat") | index(v1, "doc") | index(v1, "docx")  | index(v1, "sthlp")
	drop if index(v1, "transfertools.ado")
	split v1, p("  ")
	replace v14=v13 if v14==""
	
		gen new="copy " + `"""' + v14 +  `"""' + `" ""' + "$shared\" + v14  + `"""' + ", replace"
	keep new
	outsheet using "c:\temp\copyit.txt", nonames noquote replace
	
	*COPY TOOLS PROGRAMS TO SHARED
	cd "$tools"
	do c:\temp\copyit.txt
	
	clear
	cd c:\temp
	erase tools.txt
	erase usc.txt
	erase copyit.txt
}
	
end
exit

