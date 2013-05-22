program semgof
syntax [varlist] [, model(string)]		
qui {	
	local satdf=e(df_s)
		local moddf=e(df_m)
		local  sll=e(critvalue_s)
		local  mll=e(ll)
		local conv=e(converged) 
	estat gof, stats(all)
		
		local aic=r(aic)
		local bic=r(bic)
		local cfi=r(cfi)
		local tli=r(tli)
		local rmsea=r(rmsea)
		
	clear
	set obs 1
	capture gen model="`model'"
	foreach var in satdf sll moddf mll aic bic rmsea cfi tli conv {
		gen `var' = ``var''
	}
}
end
exit
