program tabgraph
syntax varlist (max=1) [if] [in] [pweight] [, by(varlist min=1 max=8)  SAMe bw xnolab colors(namelist) xlabsize(name) ylabsize(name) OUTline(name) OUTColor(name) ytitle(namelist) YTITLESize(name) intensity(numlist  missingokay max=5) width(numlist  missingokay max=1) height(numlist  missingokay max=1) NOBYname legend(passthru) ]
*04/15/2012: Version 2.0 

set more off
qui { 
tempfile master using temp output
save `master', replace

/**Restricting Sample**/
	capture keep $_if
	capture keep $_in
	*keep `varlist' `by' `weight'
	
inspect `varlist'
local num=r(N_unique)
	
save `using', replace

clear
set obs 1
gen var=""
save `output', replace

use `using', clear
	foreach by of varlist `by' {
	use `using', clear
	
	if "`weight'" != "" {
		svyset _n [`weight'`exp'], vce(linearized) singleunit(missing)
		svy linearized : tabulate `varlist' `by' $_if $_in, column
		matrix p=e(b)
		local pop=e(N_pop)
	}
	
	table `varlist' `by', replace
	egen sortorder=seq()	
		gen var="`by'"
		
	
	**IN CASE the BY variable is not labeled
		
			capture  decode `by', generate(labels) 
			capture  gen labels=`by'
			capture  tostring labels, force format(%9.0f) replace
		
		rename `by' labelnum
		gen total=.
		bys labelnum: egen val=total(table1)
		replace total =table1/val
		
		sort labelnum `varlist'
		
		if "`weight'" !="" {
			sort sortorder
			local nummax=_N
			gen new=.
			forvalues i=1(1)`nummax' {
				replace new=p[1,`i'] in `i'
			}
			gen pop=`pop'
			gen sub=pop*new
			bys labelnum: egen coltot=total(sub)
			replace total=sub/coltot
		}
		
		keep labels labelnum var `varlist' total
		
		save `temp',replace
		
		use `output', clear
			append using `temp'
			drop if var==""
		save `output', replace
	}
	label values labelnum
	
	egen tag = tag(var)
	egen seq=seq() if tag==1
	
	forvalues i=1(1)100 {
		gen seqlag=seq[_n-`i']
		gen varlag=var[_n-`i']
		
		replace seq=seqlag if seq==. & varlag==var
			capture drop varlag
			capture drop seqlag
	}
	
	replace labels=var + ": " + labels
	tostring seq, force format(%9.0f) gen(seqstr)	
	gen labelord= seqstr+var 
	
	drop tag var seqstr
	reshape wide total , i(labelnum `varlist' labels)  j(seq)
	foreach var of varlist total* {
		rename `var' `var'_
	}
	
	reshape wide total*, i(labelnum labels) j(`varlist')
	
	gen order=substr( labelord,1,1)
		destring order, replace
		sort order labelnum
	/***determining Bar Colors***/
	*Number of Variables used
	sum order
	local max=r(max)
	
	if "`nobyname'" !="" {
		split labels, p(:)
		replace labels=trim(labels2)
	}
	*

	
/**Choosing Colors*/
if "`same'" == "" {		
	if "`colors'" != ""  {
		tokenize "`colors'"
			local c1="`1'"
			local c2="`2'"
			local c3="`3'"
			local c4="`4'"
			local c5="`5'"
			local c6="`6'"
			local c7="`7'"
			local c8="`8'"
	}
		
	if "`colors'" == "" & "`bw'" =="" {	
		local c1="gs10"
		local c2="navy"
		local c3="cranberry"
		local c4="purple"
		local c5="green"
		local c6="dkorange"
		local c7="eltblue"
		local c8="stone"
		/*
		local c1="navy"
		local c2="dkgreen"
		local c3="maroon"
		local c4="gold"
		local c5="sienna"
		local c6="purple"
		local c7="emerald"
		local c8="teal"*/
	}
		
	if "`colors'" == "" & "`bw'" !="" {	
		local c1="black"
		local c2="gs12"
		local c3="gs4"
		local c4="gs10"
		local c5="gs6"
		local c6="gs8"
		local c7="black"
		local c8="gs12"
	}	
}			

if "`same'" != "" {		
	if "`colors'" != ""  {
		tokenize "`colors'"
			local c1="`1'"
			local c2="`1'"
			local c3="`1'"
			local c4="`1'"
			local c5="`1'"
			local c6="`1'"
			local c7="`1'"
			local c8="`1'"
	}
		
	if "`colors'" == "" & "`bw'" =="" {	
		local c1="navy"
		local c2="navy"
		local c3="navy"
		local c4="navy"
		local c5="navy"
		local c6="navy"
		local c7="navy"
		local c8="navy"
	}
		
	if "`colors'" == "" & "`bw'" !="" {	
		local c1="gs8"
		local c2="gs8"
		local c3="gs8"
		local c4="gs8"
		local c5="gs8"
		local c6="gs8"
		local c7="gs8"
		local c8="gs8"
	}	
}		
/**Specifying additional Options and Defaults*/
if "`ytitle'" == "" {
	local tit="% of `varlist'"
}
if "`ytitle'" != "" {
	local tit="`ytitle'"
}

if "`ytitlesize'"=="" {
	local ytit="medsmall"
}
if "`ytitlesize'"!="" {
	local ytit="`ytitlesize'"
}
		
/***LABEL SIZES***/	
	*X Axis
	if "`xlabsize'"!="" {
		local xsize="`xlabsize'"
	}
	else {
		local xsize="medsmall"
	}
	*Y Axis
	if "`ylabsize'"!="" {
		local ysize="`ylabsize'"
	}
	else {
		local ysize="medsmall"
	}	

*Outline 
	if "`outline'"!="" {
		local outl="`outline'"
	}
	else {
		local outl="vvthin"
	}

if "`outcolor'"=="" {
	local outc="black"
}
else {
	local outc="`outcolor'"
}
		
*Graph Size
	if "`width'"!="" {
		local wide=`width'
	}
	if "`height'"!="" {
		local tall=`height'
	}
	

**X axis Labeling
	if "`xnolab'" != "" {
		local xlabeling nolabel
	}	
	else {
		local xlabeling  angle(forty_five) labsize(`xsize')
	}
	*

***Legend
if `"`legend'"'==""  {
	local leg legend(off)
}
else {
	local leg `"`legend'"'
	*noi:dis "`leg'"
}	

	
/**BEGIN GRAPHS***/		
	if `num' == 5 {
		**Intensity
		if "`intensity'" =="" {
			local inten 15 30 60 90 175 
			tokenize `inten' 
			forvalues i=1(1)5 {
				local int`i'=``i''
			}
		}
		else {
			tokenize `intensity' 
			forvalues i=1(1)5 {
				capture local int`i'=``i''
			}
		}
	

		if `max'==8 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* (mean) total7* (mean) total8*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(5, fcolor(`c1') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(6, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(10, fcolor(`c2') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(13, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(15, fcolor(`c3') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(20, fcolor(`c4') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(25, fcolor(`c5') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(26, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(29, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(30, fcolor(`c6') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(31, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(33, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(34, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(35, fcolor(`c7') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(36, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(37, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(38, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(39, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(40, fcolor(`c8') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' ,margin(medsmall) size(`ytit')) `leg' graphregion(fcolor(white))
		}
		if `max'==7 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* (mean) total7*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(5, fcolor(`c1') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(6, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(10, fcolor(`c2') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(13, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(15, fcolor(`c3') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(20, fcolor(`c4') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(25, fcolor(`c5') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(26, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(29, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(30, fcolor(`c6') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(31, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(33, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(34, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(35, fcolor(`c7') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(36, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(37, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(38, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(39, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(40, fcolor(`c8') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' ,margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==6 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(5, fcolor(`c1') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(6, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(10, fcolor(`c2') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(13, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(15, fcolor(`c3') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(20, fcolor(`c4') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(25, fcolor(`c5') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(26, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(29, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(30, fcolor(`c6') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(31, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(33, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(34, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(35, fcolor(`c7') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(36, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(37, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(38, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(39, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(40, fcolor(`c8') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' ,margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==5 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(5, fcolor(`c1') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(6, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(10, fcolor(`c2') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(13, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(15, fcolor(`c3') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(20, fcolor(`c4') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(25, fcolor(`c5') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(26, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(29, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(30, fcolor(`c6') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(31, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(33, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(34, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(35, fcolor(`c7') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(36, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(37, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(38, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(39, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(40, fcolor(`c8') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' ,margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==4 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(5, fcolor(`c1') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(6, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(10, fcolor(`c2') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(13, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(15, fcolor(`c3') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(20, fcolor(`c4') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(25, fcolor(`c5') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(26, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(29, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(30, fcolor(`c6') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(31, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(33, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(34, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(35, fcolor(`c7') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(36, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(37, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(38, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(39, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(40, fcolor(`c8') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' ,margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==3 {
			graph bar (mean) total1* (mean) total2* (mean) total3* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(5, fcolor(`c1') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(6, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(10, fcolor(`c2') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(13, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(15, fcolor(`c3') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(20, fcolor(`c4') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(25, fcolor(`c5') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(26, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(29, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(30, fcolor(`c6') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(31, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(33, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(34, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(35, fcolor(`c7') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(36, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(37, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(38, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(39, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(40, fcolor(`c8') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' ,margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}		
		if `max'==2 {
			graph bar (mean) total1* (mean) total2* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(5, fcolor(`c1') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(6, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(10, fcolor(`c2') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(13, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(15, fcolor(`c3') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(20, fcolor(`c4') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(25, fcolor(`c5') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(26, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(29, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(30, fcolor(`c6') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(31, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(33, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(34, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(35, fcolor(`c7') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(36, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(37, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(38, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(39, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(40, fcolor(`c8') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' ,margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}	
		if `max'==1 {
			graph bar (mean) total1* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(5, fcolor(`c1') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(6, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(10, fcolor(`c2') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(13, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(15, fcolor(`c3') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(20, fcolor(`c4') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(25, fcolor(`c5') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(26, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(29, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(30, fcolor(`c6') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(31, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(33, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(34, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(35, fcolor(`c7') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				bar(36, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(37, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(38, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(39, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl'))  bar(40, fcolor(`c8') fintensity(`int5') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' ,margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}				
				
				
	}
	if `num' == 4 {
		**Intensity
		if "`intensity'" =="" {
			local inten 30 60 90 175
			tokenize `inten' 
			forvalues i=1(1)4 {
				local int`i'=``i''
			}
		}
		else {
			tokenize `intensity' 
			forvalues i=1(1)4 {
				capture local int`i'=``i''
			}
		}
	
		if `max'==8 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* (mean) total7* (mean) total8*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(5, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(17, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(25, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(26, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(29, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(30, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(31, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==7 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* (mean) total7*  , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(5, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(17, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(25, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(26, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(29, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(30, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(31, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==6 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(5, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(17, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(25, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(26, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(29, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(30, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(31, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==5 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(5, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(17, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(25, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(26, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(29, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(30, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(31, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==4 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(5, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(17, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(25, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(26, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(29, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(30, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(31, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==3 {
			graph bar (mean) total1* (mean) total2* (mean) total3* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(5, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(17, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(25, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(26, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(29, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(30, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(31, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}		
		if `max'==2 {
			graph bar (mean) total1* (mean) total2* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(5, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(17, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(25, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(26, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(29, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(30, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(31, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}	
		if `max'==1 {
			graph bar (mean) total1* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c1') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(5, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(7, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c2') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c3') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c4') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(17, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(19, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c5') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(21, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(22, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c6') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(25, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(26, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(27, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(28, fcolor(`c7') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				bar(29, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(30, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(31, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl')) bar(32, fcolor(`c8') fintensity(`int4') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}				
	}
	if `num' == 3 {
		**Intensity
		if "`intensity'" =="" {
			local inten 30 60 90 
			tokenize `inten' 
			forvalues i=1(1)3 {
				local int`i'=``i''
			}
		}
		else {
			tokenize `intensity' 
			forvalues i=1(1)3 {
				capture local int`i'=``i''
			}
		}	
		if `max'==8 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* (mean) total7* (mean) total8*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(4, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(5, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(10, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(13, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(19, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(21, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(21, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
	
		if `max'==7 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* (mean) total7* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(4, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(5, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(10, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(13, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(19, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(21, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(21, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==6 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(4, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(5, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(10, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(13, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(19, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(21, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(21, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==5 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(4, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(5, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(10, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(13, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(19, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(21, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(21, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==4 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4*  , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(4, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(5, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(10, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(13, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(19, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(21, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(21, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==3 {
			graph bar (mean) total1* (mean) total2* (mean) total3* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(4, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(5, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(10, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(13, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(19, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(21, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(21, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}		
		if `max'==2 {
			graph bar (mean) total1* (mean) total2* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(4, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(5, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(10, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(13, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(19, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(21, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(21, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}	
		if `max'==1 {
			graph bar (mean) total1*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(3, fcolor(`c1') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(4, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(5, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c2') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(9, fcolor(`c3') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(10, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(11, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c4') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(13, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(15, fcolor(`c5') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(16, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(17, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(18, fcolor(`c6') fintensity(`int3') lcolor(black) lwidth(`outl')) ///
				bar(19, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(20, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(21, fcolor(`c7') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				bar(21, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(23, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) bar(24, fcolor(`c8') fintensity(`int3') lcolor(black) lwidth(`outl'))  ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}				
	}	
	if `num' == 2 {
		**Intensity
		if "`intensity'" =="" {
			local inten 60 90 
			tokenize `inten' 
			forvalues i=1(1)2 {
				local int`i'=``i''
			}
		}
		else {
			tokenize `intensity' 
			forvalues i=1(1)2 {
				capture local int`i'=``i''
			}
		}	
		if `max'==8 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* (mean) total7* (mean) total8*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(3, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl'))   ///
				bar(5, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(15, fcolor(`c8') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(16, fcolor(`c8') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
	
		if `max'==7 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6* (mean) total7*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(3, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl'))   ///
				bar(5, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==6 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5*  (mean) total6*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(3, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl'))   ///
				bar(5, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==5 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4* (mean) total5* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(3, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl'))   ///
				bar(5, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==4 {
			graph bar (mean) total1* (mean) total2* (mean) total3*  (mean) total4*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(3, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl'))   ///
				bar(5, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}
		if `max'==3 {
			graph bar (mean) total1* (mean) total2* (mean) total3* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(3, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl'))   ///
				bar(5, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}		
		if `max'==2 {
			graph bar (mean) total1* (mean) total2* , over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(3, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl'))   ///
				bar(5, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}	
		if `max'==1 {
			graph bar (mean) total1*, over(labels, sort(order) label(`xlabeling')) percentages stack bargap(0) outergap(0) xsize(`wide') ysize(`tall') ylabel(#10, labsize(`ysize') angle(horizontal)) ///
				bar(1, fcolor(`c1') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(2, fcolor(`c1') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(3, fcolor(`c2') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(4, fcolor(`c2') fintensity(`int2') lcolor(black) lwidth(`outl'))   ///
				bar(5, fcolor(`c3') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(6, fcolor(`c3') fintensity(`int2') lcolor(black) lwidth(`outl'))  ///
				bar(7, fcolor(`c4') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(8, fcolor(`c4') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(9, fcolor(`c5') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(10, fcolor(`c5') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(11, fcolor(`c6') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(12, fcolor(`c6') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				bar(13, fcolor(`c7') fintensity(`int1') lcolor(black) lwidth(`outl')) bar(14, fcolor(`c7') fintensity(`int2') lcolor(black) lwidth(`outl')) ///
				ytitle(`tit' , margin(medsmall) size(`ytit')) `leg'  graphregion(fcolor(white))
		}				
	}	
**

use `master', clear
}
end
exit
	
