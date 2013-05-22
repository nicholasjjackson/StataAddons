program bholm 
syntax varlist (max=1) [if]
qui{
	version 11
	set more off
	capture log close
	
	capture keep $_if 
	
	local n=_N
		/**Preserving Current Ordering***/
		capture drop origorder
		egen origorder=seq()
		/**Prepare P Values for sorting***/
		capture replace `varlist'="0.00009" if `varlist'=="<.0001"
		capture replace `varlist'="0.000009" if `varlist'=="<.00001"
		capture replace `varlist'="0.0000009" if `varlist'=="<.000001"
		capture destring `varlist', replace

		gsort - `varlist'
		capture drop neworder 
		egen neworder=seq()
	
		/**Revised Significance Levels**/
		capture drop sig*
		gen sig10=0.10/neworder
		gen sig05=0.05/neworder
		gen sig01=0.01/neworder
		gen sig001=0.001/neworder
		gen sig0001=0.0001/neworder
		gen sig00001=0.00001/neworder
		gen sig000001=0.000001/neworder

		capture gen starBHOLM=""
				replace starBHOLM="†" if `varlist' <= sig10
				replace starBHOLM="*" if `varlist' <= sig05
				replace starBHOLM="**" if `varlist' <= sig01
				replace starBHOLM="***" if `varlist' <= sig001
				replace starBHOLM="‡" if `varlist' <= sig0001
				replace starBHOLM="*‡" if `varlist' <= sig00001
				replace starBHOLM="**‡" if `varlist' <= sig000001

			sort origorder
			capture drop origorder 
			
			capture drop pBHOLM
			capture gen pBHOLM=`varlist'*neworder
				replace pBHOLM=0.9999 if pBHOLM>=1
			
			capture drop neworder 
			capture drop sig*
		move starBHOLM `varlist'
		move starBHOLM `varlist'
		label var starBHOLM "Holm–Bonferroni Corrected P Value"
		label var pBHOLM "Holm–Bonferroni Corrected P Value"
		
		tostring `varlist' pBHOLM, force format(%9.4f) replace
			replace `varlist' ="<.0001" if `varlist'=="0.0000"
			replace pBHOLM ="<.0001" if pBHOLM=="0.0000"
		
		noi: display "`varlist' vlaues corrected for `n' hypotheses tested using Holm–Bonferroni"
		*save output.dta, replace 
	}
	describe starBHOLM 

	end 
	exit
	