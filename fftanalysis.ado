
program fftanalysis
syntax varlist [if] [in] [, epoch(numlist max=1) samplefreq(numlist max=1 integer) overlap(numlist max=1) window(string) pof2 bands(string) epochanal detrend(string) nophase density amplitude peak2peak]

qui {
noi :dis "Start Time: $S_TIME"
set more off
capture keep $_if
capture keep $_in
**Evaluate Overlap Validity
capture assert `overlap' >=0.5 & `overlap' < 1 | `overlap'==0
	if _rc==9 {
		dis as error "Overlap Value must be Between 0.5 and 1 OR 0"
	}
	else {
	}
*
*Set Number of Rows Per Sample
local length=`samplefreq'*`epoch'
*Set Shift 
if "`overlap'" != "" {
	local shift=`length'*(1-`overlap')
}
else {
	local shift=`length'
	local overlap=0
}
*Blocks
egen block=seq(), from(1) block(`length')


gen row=_n

*Number of Blocks to Analyses
sum block
local max=r(max)
sum row if block==`max'
local stop=r(min)
local blocknum=`max'*(1/(1-`overlap'))

drop block

**********************************************
/*	gen timenew=1
	replace timenew=0 in 1
	replace timenew=sum(timenew)
	
		if "`window'"=="hanning" | "`window'"=="" {
			gen leak=.5*(1-cos((2*_pi*timenew)/(_N-1)))
		}
		if "`window'"=="hamming" {
			gen leak=.54 + (.46)*cos((2*_pi*timenew)/(_N-1))
		}
		if "`window'"=="none" {
			gen leak=1
		}
		drop timenew*/
**********************************************		
		
tempfile master current
save `master', replace 

***Evaluate for Non Power of 2 Signal
if "`pof2'" != "" {
	clear 
	set obs 12
	gen val=.
	forvalues i=1(1)12 {
		replace val=2^`i' in `i'
	}
	gen freq=`samplefreq'
	drop if val<freq
	gen diff=abs(freq-val)*`epoch'
	local extra=diff in 1
	use `master', clear
}
else {
}

*****Begin Analysis

foreach var of varlist `varlist' {
	local start=0
	forvalues i=1(1)`blocknum' {

		local begin=`start'*`shift'
		local end=`begin'+`length'
		
		if `begin' <= `stop' {
				
				use `master', clear
					keep if row >`begin' & row <=`end'

						
					**Set to Power of 2 Length if pof2 option specified
					if "`pof2'" != "" {
						local new=`extra'+_N
						set obs `new'
						replace `var'=0 if `var'==.
					}
					else {
					}
						gen timenew=1
						replace timenew=0 in 1	
						replace timenew=sum(timenew)
						
						
						if "`detrend'" == "mean" | "`detrend'" == "" {
							sum `var'
							replace `var'=`var'-r(mean)
						}	
						if "`detrend'"=="linear" {	
							regress `var' time
							predict resid, resid
							replace `var'=resid
						}
							
						if "`detrend'" == "none" {
						}
						
						if "`window'"=="hanning" | "`window'"=="" {
							gen leak=.5*(1-cos((2*_pi*timenew)/(_N-1)))
							gen leak2=leak^2
							sum leak2
							local scale=1/r(mean)
						}
						if "`window'"=="hamming" {
							gen leak=.54 + (.46)*cos((2*_pi*timenew)/(_N-1))
							gen leak2=leak^2
							sum leak2
							local scale=1/r(mean)
							
						}
						if "`window'"=="none" {
							gen leak=1
							gen leak2=leak^2
							sum leak2
							local scale=1/r(mean)
						}
					
						gen signal=leak*`var'
						
						
						tsset timenew
						fft signal, gen(xr xi)
						
						gen freq=1/(_N/`samplefreq')
						replace freq=0 in 1
						replace freq=sum(freq)
						
						
						***Create Magnitude and Power from FFT
						*Correct Real and Imaginary Values for 2 Sided Analysis (except for DC value ie. freq==0)
						if "`nophase'" != "" {
							gen mag=abs(xr)
						}
						else {
							gen mag=sqrt(xr^2 + xi^2)
						}
						
						
						*Generate amplutide scaled to the number of data points
						gen power=(mag/_N)
						*Multiply amplitude by 2 except DC component (freq=0) to account for throwing out second half
						replace power=power*2 if freq!=0
						
						if "`peak2peak'" !="" {
							replace power=power*2
						}
						
						if "`density'" != "" & "`amplitude'"=="" {
							replace power=power/`samplefreq'
							replace power=`scale'*(power^2)
						}
						if "`density'" == "" & "`amplitude'"=="" {
							*Generate power by squaring amplitude
							replace power=`scale'*(power^2)
						}
						if "`density'" == "" & "`amplitude'"!="" {
							*Generate power by squaring amplitude
							replace power=sqrt(`scale'*(power^2))
						}

						
						
						
						drop if _n>_N/2
						
						
						gen block=ceil(`i'/(1/(1-`overlap')))
						gen group=`i'
						
						keep group block freq power
						
						tempfile temp`i'
						save `temp`i'',replace 
				
						local start=`start'+1
			}
	}/*BLocknum Loop*/
	use `temp1', clear
	local final=`blocknum'-((1/(1-`overlap'))-1)

	forvalues i=2(1)`final' {
		append using `temp`i''
	}
*	
	

	
	*Split Bands into Tokens for Automatic Naming
	tokenize `bands'
	local channels=wordcount("`bands'")
	
	forvalues i=1(2)`channels' {
		local newval=`i'+1
		gen band="``newval''"
		replace band=trim(band)
		split band, p(-) gen(v)
		destring v1 v2, replace
		gen ``i''_p=power if freq >=v1 & freq<v2
		capture drop v1 v2 band
	}
	
	
	********************************************************************
	*Determine if Summary to be Done At EPOCH level
	if "`epochanal'" != "" {
		collapse (sum) *_p, by(block group)
		collapse (mean) *_p, by(block)
	}
	else {
		collapse (sum) *_p, by(block group)
		collapse (mean) *_p, by(block)
		collapse *_p
	}
	********************************************************************
	
	gen channel="`var'"
	egen total=rowtotal(*_p)
	**Rename Power values and Compute Relative Powers
	forvalues i=1(2)`channels' {
		local newval=`i'+1
		rename ``i''_p ``i''
		label var ``i'' "``i'' Absolute Power: ``newval'' HZ"
		gen rel_``i''=(``i''/total)*100
		label var rel_``i'' "``i'' Relative Power: ``newval'' HZ"
	}
	drop total
	
	tempfile `var'
	save ``var'', replace
}/*Varlist Loop*/
*

**Merge Varlist Data Together
tokenize `varlist'
local stop=wordcount("`varlist'")

if `stop' >=2 {
	use ``1'', clear
	forvalues i=2(1)`stop' {
		append using ```i'''
	}
}
else {
	use ``1'', clear
}
*
order channel
noi :dis "End Time: $S_TIME"
}/*QUI*/
end
exit
