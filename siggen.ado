

program siggen
syntax [,samplefreq(numlist max=1 integer) time(numlist max=1 integer) amp(numlist) freq(numlist) mixed error]
*Nick Jackson, Applied Statistician
*Version 1.0 05/20/2013

set more off
version 12

local numobs=`samplefreq'*`time'     

clear 
set obs `numobs'
gen t=1/`samplefreq'
replace t=0 in 1
replace t=sum(t)


if "`mixed'" == "" {
	local 0=1
	foreach f of local freq {
	foreach a of local amp {
		if "`error'"!= "" {
			gen sig`0'=`a'*sin(2*_pi*t*`f') + 0.1*runiform()
				label var sig`0' "Amp: `a' Freq: `f', + ERROR (`samplefreq'HZ)"
				local 0=`0'+1
		
		}	
		else {
			gen sig`0'=`a'*sin(2*_pi*t*`f') 
			label var sig`0' "Amp: `a' Freq: `f', NO ERROR (`samplefreq'HZ)"
			local 0=`0'+1
		}

	} /*a*/
	} /*f*/
} /*mixed==""*/

if "`mixed'" != "" {

			local maxf =wordcount("`freq'")
				tokenize `freq'
				forvalues i=1(1)`maxf' {
					local f`i'=``i''
				}
			local maxa=wordcount("`amp'")
				tokenize `amp'
				forvalues i=1(1)`maxa' {
					local a`i'=``i''
				}	
			
			local name ""
			forvalues i=1(1)`maxf' {
			
			forvalues x=1(1)`maxa' {
					
					local name1 `a`x''*sin(2*_pi*t*`f`i'') 
					local name `name' + `name1'
			}
			}
		
		
		if "`error'"!= "" {
			gen sig=`name' + 0.1*runiform()
				label var sig "Amp: `amp' Freq: `freq', + ERROR (`samplefreq'HZ)"
		
		}	
		else {
			gen sig=`name' + 0.1*runiform()
				label var sig "Amp: `amp' Freq: `freq', NO ERROR (`samplefreq'HZ)"
		}
} /*mixed!=""*/

end
exit

