program bonfer
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

		/**Revised Significance Levels**/
		capture drop sig*
		gen sig10=0.10/`n'
		gen sig05=0.05/`n'
		gen sig01=0.01/`n'
		gen sig001=0.001/`n'
		gen sig0001=0.0001/`n'
		gen sig00001=0.00001/`n'
		gen sig000001=0.000001/`n'

		capture gen starBonfer=""
				replace starBonfer="†" if `varname' <= sig10
				replace starBonfer="*" if `varname' <= sig05
				replace starBonfer="**" if `varname' <= sig01
				replace starBonfer="***" if `varname' <= sig001
				replace starBonfer="‡" if `varname' <= sig0001
				replace starBonfer="*‡" if `varname' <= sig00001
				replace starBonfer="**‡" if `varname' <= sig000001

			sort origorder
			capture drop origorder 
			capture drop neworder 
			capture drop sig*
		move starBonfer `varname'
		move starBonfer `varname'
		label var starBonfer "Bonferroni Corrected P Value"
		
		noi: display "`varname' vlaues corrected for `n' Multipple Comparisons using Bonferroni"
		save output.dta, replace 
	}
	describe starBonfer
	
	end 
	exit
	