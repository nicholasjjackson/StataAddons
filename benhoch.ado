program benhoch 
args varname
qui{
	version 11
	set more off
	capture log close

	local n=_N
		/**Preserving Current Ordering***/
		capture drop origorder
		egen origorder=seq()
		/**Prepare P Values for sorting***/
		capture replace `varname'="0.0000" if `varname'=="<.0001"
		capture destring `varname', replace

		gsort  `varname'
		capture drop neworder 
		egen neworder=seq()
		
		replace `varname'=0.00009 if `varname'==0 
		gen pBENHOCH=(`n'/neworder)*`varname'
		replace pBENHOCH=0.9999 if pBENHOCH >=1
		
		
			
			
		/**Revised Significance Levels**/
		
		capture gen starBENHOCH=""
				replace starBENHOCH="†" if pBENHOCH <= 0.10
				replace starBENHOCH="*" if pBENHOCH <= 0.05
				replace starBENHOCH="**" if pBENHOCH <= 0.01
				replace starBENHOCH="***" if pBENHOCH <= 0.001
			sort origorder
			capture drop origorder 
			capture drop neworder 
		move starBENHOCH `varname'
		move starBENHOCH `varname'
		label var pBENHOCH "Benjamini-Hochberg Corrected P Value"
		label var starBENHOCH "Benjamini-Hochberg Corrected P Value"
		
		noi: display "`varname' vlaues corrected for `n' hypotheses tested using Benjamini-Hochberg"
		save output.dta, replace 
	}
	describe starBENHOCH

	end 
	exit
	