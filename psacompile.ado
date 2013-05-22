program psacompile
syntax [, DIRectory(string) rem(numlist  missingokay max=1) nrem(numlist  missingokay max=1) epoch(numlist  missingokay max=1) time(numlist  missingokay max=1) win(numlist  missingokay max=1) sleeponset(string) breject(string) ALTreject(string) soextract arexact correct(string) relaltcalc AVGSLPepoch remlogic ]

*Program written by Nick Jackson, Unniversity of Pennsylvania, Division of Sleep Medicine
*Revision Hx: 04/18/2012: Version 1.0 Created
*Revision Hx: 04/26/2012: Version 1.5: Add percentage eliminated by artifact rejection methods, recode stages for movement time and stage 4, allow epoch size to modify, extract rawdata from Lights out, Create overall Aggregate
*Revision Hx: 04/30/2012: Version 1.6: Add cyclecon option for using Consecutive NREM in NREM cycle
*Revision Hx: 05/06/2012: Version 1.7: remove cyclecon option (incorrectly specified, and modify how REM/NREM cycles are identified.
*Revision Hx: 05/11/2012: Version 2.0: Added in processing of Event Tags for arousal 
*Revision Hx: 05/16/2012: Version 2.1: Added in toggle for arousal identification (arexact) default now to tag entire epoch containing arousal, added arousal as stage in stage aggregate data. Round percentages to hundreths place.
*Revision Hx: 09/07/2012: Version 2.2: Added toggle for nocorrect (ie, no power value transformation of (2*old)^2 ), added assessment of if sleep stages present, toggle relaltcalc to allow for alternate calculation of relative power
*Revision Hx: 09/19/2012: Version 2.3: fixed issue with calculation of total delta
*Revision Hx: 09/20/2012: Version 2.4: fixed problem with version 2.3
*Revision Hx: 09/28/2012: Version 2.5: add option AVGSLPEPOCH to first average values within a sleep epoch and then accross sleep epochs (30 sec)
*Revision Hx: 10/27/2012: Version 2.6: Includes more diverse signal correction options of with the Correct() option. The nocorrect option removed. Remlogic option added for processing remlogic files
*Revision Hx: 01/03/2013: Version 3.0: Major Change in Program: Numerous bug fixes such as:
										*problems when there is no REM
										*preferential taking of staging from events files and overwriting of original files with new events
										*problems where there is no sleep onset
*Revision Hx: 01/08/2013: Version 3.1: Fixed bug causing Missing REM subjects to be skipped. Capture { } should not be used at all
*Revision Hx: 02/14/2013: Version 3.2: Fixed issue with names2 not being present for some extractions when defining the band names. Added, breject() option for when beta2 is not present
*Revision Hx: 04/16/2013: Version 3.3: Automatically assign band names as band1-banx if not present in file. Use the lowest band for the brunner method if breject is not specifiend and beta2 is absent. Allows band ranges to be specified for breject and altreject
*Revision Hx: 04/22/2013: Version 3.4 Lines 1204/1174 Fix issue with not labeling as all NREM or all REM when remvalid or nremvalid is not present

qui { /*qui*/


noi :dis "Start Time: $S_TIME"
set more off
/**Determine Current Directory to Return to After Analysis**/
local currdir=c(pwd)
if "`currdir'" == "c:" { /*currdir*/
	local currdir  c:\
} /*currdir*/
*
else { /*else*/
} /*else*/
*

/**Define Working Directory:
Make Sure Directory for analysis Defined, otherwise use current directory**/
	if "`directory'" == "" { /*if dir == ""*/
	  local workdir ="`currdir'"
	  dis "`workdir'"
	} /*if dir == ""*/
	*
	if "`directory'" != "" { /*if dir != ""*/
	  local workdir= "`directory'"
	  dis "`workdir'" 
	} /*if dir != "" */
	*

/***Define Values**/
	**EPOCH LENGTH
	if "`epoch'" != "" { /*if epoch != ""*/
		local epochnum=`epoch'
	} /*if epoch != ""*/
	else { /*else*/
		local epochnum=4
	} /*else*/

	**REM LENGTH
	if "`rem'" != "" { /*if rem != ""*/
		local remnum=`rem'
	} /*if rem != ""*/
	else { /*else*/
		local remnum=5
	} /*else*/

	**NREM LENGTH
	if "`nrem'" != "" { /*if nrem != "" */
		local nremnum=`nrem'
	} /*if nrem != "" */
	else { /*else*/
		local nremnum=15
	} /*else*/

	**TIME LENGTH
	if "`time'" != "" { /*if time != "" */
		local timenum=`time'
	} /*if time != "" */
	else { /*else*/
		local timenum=6
	} /*else*/	

	**WINDOW LENGTH
	if "`win'" != "" { /*if win != "" */
		local winnum=`win'
	} /*if time != "" */
	else { /*else*/
		local winnum=3
	} /*else*/

	
	*
***Set Output File for Entire Study Data
tempfile outputstage outputcycle outputraw eventsall outputstage_epoch outputcycle_epoch outputraw_epoch 
clear
set obs 1	
gen id=""
save `outputstage', replace 
save `outputcycle', replace 
save `outputraw', replace 
save `eventsall', replace
save `outputstage_epoch', replace 
save `outputcycle_epoch', replace 
save `outputraw_epoch', replace 





*****************************************************************************************************************************************
**************FIX REMLOGIC ISSUES******************************************************************************
if "`remlogic'" != "" { /*if remlogic != "" */

cd "`workdir'\\`folder'"
local fold: dir "`workdir'" dir *
*Loop Through Each folder name
	foreach folder of local fold {	/* foreach folder */ 
	
		tempfile logicscor logictemp logicsleep

			clear
			set obs 1
			gen id=""
			save `logicscor', replace 
			save `logicsleep', replace 
	
	
		local myfiles: dir "`workdir'\\`folder'" files "*.txt"
				
				****SCORING FILE
				*Loop through filnames
				foreach files of local myfiles { /**foreach files: EVENTS**/ 
					
					***Determine if Events or PSA File 
						clear
						set obs 1
							gen name="`files'"
							gen tag=1 if index(name, "event")
							replace tag=0 if tag==.
							sum tag
							local events=r(max)
							local anyevents=`anyevents'+`events'
							
									**Toggle Split-Events Files	
									if 	`events'==1 { /*If Events==1*/
										cd "`workdir'\\`folder'"
										insheet using "`files'", clear
											
											gen tag = 1 if  v2=="Wake" | v2=="Stage 1" | v2=="Stage 2" | v2=="Stage 3" | v2=="Stage 4" | v2=="Rem" | v2=="Unscored"
											replace v3="" if tag!=1
											replace v2="" if tag!=1
											replace v4="" if tag!=1
										
											*replace v4="30.00" if v2!="" & v4==""
								
											
											replace v3=v3[_n-1] if v3==""
											replace v2=v2[_n-1] if v2==""
											keep if v3!=""
												rename v1 epoch
												rename v2 event
												
												destring epoch v4, replace
		
											keep if event=="Wake" | event=="Stage 1" | event=="Stage 2" | event=="Stage 3" | event=="Stage 4" | event=="Rem" | event=="Wake"
											keep event epoch
											rename event stage
											duplicates drop 
											gen filename="`files'"
												split filename, p(_ .txt -)
												rename filename1 study 
												rename filename2 id 
												rename  filename3 night 
												rename filename4 cond_grp
												drop filename*
												save `logictemp', replace 
												
												use `logicscor', clear
												
													append using `logictemp'
													drop if id==""
												save `logicscor', replace 
									} /*If Events==1*/
				}/**foreach files: EVENTS**/

				***PSA FILE
				foreach files of local myfiles { /**foreach files: PSA File**/
					
					***Determine if Events or PSA File 
						clear
						set obs 1
							gen name="`files'"
							gen tag=1 if index(name, "event")
							replace tag=0 if tag==.
							sum tag
							local events=r(max)
							local anyevents=`anyevents'+`events'
							
								**Toggle Split-Events Files	
								if 	`events'==0 { /*if events==0*/	
										cd "`workdir'\\`folder'"
										insheet using "`files'", clear 
										*insheet using stress_034_02_02_c3-a2_remlogic.txt, clear 
										
										*Loop and remove non-string
										foreach var of varlist _all { /*foreach var*/
											capture assert `var' != ""
											if _rc==109 { /*rc=109*/
												drop `var'
											} /*rc=109*/
											
											capture assert `var'!="Wake" & `var'!="Stage 1" & `var'!="Stage 2" & `var'!="Rem" & `var'!="Stage 3" & `var'!="Stage 4"
											if _rc==9 { /*rc==9*/
												drop `var'
											} /*rc==9*/
											else { /*else*/
											} /*else*/		 
										
										} /*foreach var*/
										
										
										***NEED TO GENERATE REAL EPOCHS
										capture drop epoch stage
											gen n=_n
										tempfile fakemaster
										save `fakemaster', replace
										
											keep if v4!=""
											drop in 1 
											
												*local epochnum=4
												gen row=_n-1
												
												gen timenew=`epochnum'
												gen elapsed1=timenew*row
												
												local end=_N/`epochnum'
												gen epochbegin=.
												forvalues i=1(1)`end' { /*forvalues i*/
													local j=`i'-1
													replace epochbegin=`i' if elapsed1 >= `j'*30 & elapsed1 <`i'*30 & epochbegin==.
												} /*forvalues i*/
												rename epochbegin epoch
											
											
											keep epoch n
											tempfile fakeslave
											save `fakeslave', replace 
											
										use `fakemaster', clear	
											joinby n using `fakeslave', unmatched(both)
												drop _merge
											gen filename="`files'"
											split filename, p(_ .txt -)
												local study= filename1 in 1
												local id=filename2 in 1
												local night = filename3 in 1
												local cond_grp	=filename4 in 1
												drop filename*
										save `fakemaster', replace 
										
										use `logicscor', clear
											keep if study=="`study'" & id=="`id'" & night=="`night'" & cond_grp=="`cond_grp'"
											keep stage epoch
										tempfile fakeout
										save `fakeout', replace 
										
										use `fakemaster', clear
										joinby epoch using `fakeout', unmatched(both)
											sort n
											drop n epoch _merge
										
										outsheet using "`files'",  nonames noquote replace			
								}/*IF EVENT==0*/
					
				}/**foreach files: PSA File**/
				*	
										
			
	}/**FOLDER LOOP*/

}/*if remlogic != "" */	
*****************************************************************************************************************************************
*****************************************END REMLOGIC FIX**************************************************************************

******************************************************************************************************************************************
************************************CREATE PREFERENCE OF TAKING STAGING INFO***************************************************************
if "`remlogic'" == "" { /*if "`remlogic'" == ""*/



cd "`workdir'\\`folder'"
local fold: dir "`workdir'" dir *
*Loop Through Each folder name
	foreach folder of local fold {	 /*foreach folder*/
	
		tempfile psascor psatemp psasleep

			clear
			set obs 1
			gen id=""
			save `psascor', replace 
			save `psasleep', replace 
	
	
		local myfiles: dir "`workdir'\\`folder'" files "*.txt"
				
				****SCORING FILE
				*Loop through filnames 
				foreach files of local myfiles { /*Foreach files: */
					
					***Determine if Events or PSA File 
						clear
						set obs 1
							gen name="`files'"
							gen tag=1 if index(name, "event")
							replace tag=0 if tag==.
							sum tag
							local events=r(max)
							local anyevents=`anyevents'+`events'
							
									**Toggle Split-Events Files	
									if 	`events'==1 { /*`events'==1*/
										cd "`workdir'\\`folder'"
										*insheet using "C:\Users\Nick Jackson\Desktop\New folder\034\Stress_034_02_02_Events-Epoch.txt", clear
										insheet using "`files'", clear
											gen tag = 1 if  v2=="Wake" | v2=="Stage 1" | v2=="Stage 2" | v2=="Stage 3" | v2=="Stage 4" | v2=="Rem" | v2=="Unscored"
											replace v3="" if tag!=1
											replace v2="" if tag!=1
											replace v4="" if tag!=1
										
											*replace v4="30.00" if v2!="" & v4==""
								
											
											replace v3=v3[_n-1] if v3==""
											replace v2=v2[_n-1] if v2==""
											keep if v3!=""
												rename v1 epoch
												rename v2 event
												
												destring epoch v4, replace
			
											keep if event=="Wake" | event=="Stage 1" | event=="Stage 2" | event=="Stage 3" | event=="Stage 4" | event=="Rem" | event=="Wake"
											keep event epoch 
											rename event stage
											duplicates drop 

											gen filename="`files'"
												split filename, p(_ .txt -)
												rename filename1 study 
												rename filename2 id 
												rename  filename3 night 
												rename filename4 cond_grp
												drop filename*
												save `psatemp', replace 
												
												use `psascor', clear
												
													append using `psatemp'
													drop if id==""
												save `psascor', replace 
									}/*`events'==1*/
									
				}/**LOOP Over Files in the Folder**/

				
				
				***PSA FILE
				foreach files of local myfiles { /*Foreach files: PSA*/
					
					***Determine if Events or PSA File 
						clear
						set obs 1
							gen name="`files'"
							gen tag=1 if index(name, "event")
							replace tag=0 if tag==.
							sum tag
							local events=r(max)
							local anyevents=`anyevents'+`events'
							
								**Toggle Split-Events Files	
								if 	`events'==0 { /*if events==0*/
										cd "`workdir'\\`folder'"
										insheet using "`files'", clear 
										set more off
											duplicates drop
										*insheet using "C:\Users\Nick Jackson\Desktop\New folder\034\stress_034_01_02_c4-a1.txt", clear 
										
										*Loop and remove non-string
										foreach var of varlist _all { /*foreach var*/
											capture assert `var' != ""
											if _rc==109 { /*rc==109*/
 												drop `var'
											} /*rc==109*/
											
											capture assert `var'!="Wake" & `var'!="Stage 1" & `var'!="Stage 2" & `var'!="Rem" & `var'!="Stage 3" & `var'!="Stage 4"
											if _rc==9 { /*rc==9*/
												drop `var'
											}/*rc==9*/
											else { /*else*/
											}/*else*/		
										
										}/*foreach var*/
										
										
										***NEED TO GENERATE REAL EPOCHS
										capture drop epoch stage
											gen n=_n
										tempfile fakemaster
										save `fakemaster', replace
										
											capture keep if v4!=""
											capture keep if v7!=""
											capture keep if v8!=""
											
											drop in 1 
											
												*local epochnum=4
												gen row=_n-1
												gen timenew=`epochnum'
												gen elapsed1=timenew*row
												
												local end=_N/`epochnum'
												gen epochbegin=.
												forvalues i=1(1)`end' { /*forvalues i*/
													local j=`i'-1
													replace epochbegin=`i' if elapsed1 >= `j'*30 & elapsed1 <`i'*30 & epochbegin==.
												}/*forvalues i*/
												rename epochbegin epoch
											
											
											keep epoch n
											tempfile fakeslave
											save `fakeslave', replace 
											
										use `fakemaster', clear	
											joinby n using `fakeslave', unmatched(both)
												drop _merge
												drop if v1==""
												/*gen rowdiffs=n-epoch
												sum rowdiffs
												local correction=r(min)
												drop rowdiffs*/
												
												
											gen filename="`files'"
											split filename, p(_ .txt -)
												local study= filename1 in 1
												local id=filename2 in 1
												local night = filename3 in 1
												local cond_grp	=filename4 in 1
												drop filename*
										save `fakemaster', replace 
										
										
										***DETERMINE if EVENT FILES EXIST
										use `psascor', clear
										
											capture gen tag=1 if study=="`study'" & id=="`id'" & night=="`night'" & cond_grp=="`cond_grp'"
											if _rc==111 {
											}
											else {
											
													sum tag
													local tagnum=r(max)
													
													**If subject exists as event file
													if `tagnum'==1 { /*tagnum==1*/
															keep if study=="`study'" & id=="`id'" & night=="`night'" & cond_grp=="`cond_grp'"
															keep stage epoch
															drop if epoch==.
														tempfile fakeout
														save `fakeout', replace 
													
														use `fakemaster', clear
														*joinby epoch using c:\temp\epoch.dta, unmatched(both)
														joinby epoch using `fakeout', unmatched(both)
															sort n
															drop n epoch _merge
														outsheet using "`files'",  nonames noquote replace	
													}/*tagnum==1*/
													else { /*else*/
													} /*else*/
											}
								}/*IF EVENT==0*/
					
				}/*Foreach files: PSA*/
				*	
										
			
	}/*foreach folder*/

}/*if "`remlogic'" == ""*/	
*

******************************************************************************************************************************************
************************************END PREFERENCE OF TAKING STAGING INFO***************************************************************
******************************************************************************************************************************************

*Determine First Level of Folder Names	
local fold: dir "`workdir'" dir *
*Loop Through Each folder name
	foreach folder of local fold {	/*foreach folder*/
		noi: display "Processing Subject: `folder'"
		*Set Output Directory for Files within a folder
			tempfile temp output eventsout sleepout
			clear
			set obs 1	
			gen id=""
			save `output', replace 
			save `eventsout', replace 
			save `sleepout', replace 
	
			**events master marker
			local anyevents=0
	
		*Determine file names in the folder
		cd "`workdir'\\`folder'"
		local myfiles: dir "`workdir'\\`folder'" files "*.txt"
			
		
**************************************************************************************								
**************************************************************************************	
*START OF OVERALL FOLDER PROCESSING: Looping through files, identifying if event or psa files
**************************************************************************************				
**************************************************************************************	
		
		**STORE anyevents information for Later use.
		local anyevents=0
		foreach files of local myfiles { /*foreach files*/
					clear
					set obs 1
						gen name="`files'"
						gen tag=0
						replace tag=1 if index(name, "event")
						sum tag
						local events2=r(max)
						local anyevents=`anyevents'+`events2'				
		}/*foreach files*/

		*Begin Processing of all the Files
		foreach files of local myfiles { /*foreach files*/
				
				***Determine if Events or PSA File 
					clear
					set obs 1
						gen name="`files'"
						gen tag=0 
						replace tag=1 if index(name, "event")
						
						sum tag
						local events=r(max)
						*local anyevents=`anyevents'+`events'
						
						
**************************************************************************************								
**************************************************************************************	
*BEGIN PROCESS OF EVENTS Files
**************************************************************************************				
**************************************************************************************	
			if 	`events'==1 { /*events==1*/
				cd "`workdir'\\`folder'"
				insheet using "`files'", clear
					keep if v3!=""
						rename v3 time
						rename v1 epoch
						rename v2 event
						rename v4 dur
						rename v5 up
						drop in 1
					
						destring epoch, replace
						gen arousal=1 if event=="Arousal"
						split time, p(: AM PM)
							gen ampm="AM" if index(time, "AM")
							replace ampm="PM" if index(time, "PM")
						
						destring dur time1-time3, replace 
						replace time1=time1+12 if ampm=="AM" & time1 !=12

						gen elapsedstart=time1*3600 + time2*60 + time3
						gen elapsedend=time1*3600 + time2*60 + time3 + dur

						keep if arousal==1
						keep elapsed*
						
						capture set obs 1
						gen filename="`files'"
						split filename, p(_ .txt -)
						rename filename1 study 
						rename filename2 id 
						rename  filename3 night 
						rename filename4 cond_grp
						
						drop filename*
						tempfile temp
						save `temp', replace
						use `eventsout', clear
							append using `temp'
							drop if id==""
						save `eventsout', replace
				}/*EVENTS=1*/
				*
**************************************************************************************								
**************************************************************************************	
*BEGIN PROCESS OF PSA (Nonevents) Files
**************************************************************************************				
**************************************************************************************				
				
			**Toggle Split-PSA Files
			if `events'==0 { /*events==0*/
				*noi: dis "`files'"
				**Read IN data
				cd "`workdir'\\`folder'"
				insheet using "`files'", clear
			
				
				*Setup 3 Main Output Files, plus main Temp
				tempfile temp 
				save `temp', replace 
				
**************************************************************************************	
*Section for storing subject IDs and Date info
**************************************************************************************	
				use `temp', clear
				if "`remlogic'" =="" { /*"`remlogic'" ==""*/
					keep if v1=="Study Date:"
				} /*"`remlogic'" ==""*/
				if "`remlogic'" !="" { /*"`remlogic'" != ""*/
					keep if v1=="Date:"
				} /*"`remlogic'" !=""*/
					keep v1 v2
					split v2, p(" ")
					replace v21=trim(v21)
					local date=v21 in 1
		
					gen filename="`files'"
				
					
					split filename, p(_ .txt)
						local study=filename1 in 1 
						local id=filename2 in 1 
						local night=filename3 in 1 
						local state=filename4 in 1
						local channel=filename5 in 1
	
**************************************************************************************	
*Section for autmatically Assigning the band names and storing in local macro
**************************************************************************************	
				
				**ASSIGN NON-REM:LOGIC NAMES
				if "`remlogic'" == "" {	 /*REMLOGIC == "" */
					
					use `temp', clear
						drop in 1/14
						split v1, p(:) gen(new)
						capture destring new2, replace
							
							*Auto assign names if none given
							if _rc ==111 {
								local 0=0
								foreach var of varlist _all {
									capture gen tag=.
									replace tag=.
									replace tag=1 if index(`var', "Hz")
									replace tag=0 if tag==.
									sum tag
									local 0=`0'+r(max)
								}/*foreach var*/
								local num=`0'-1
								forvalues i=1(1)`num' { 
									local band`i'="band`i'"
								}/*forvalues i*/
							}/*if _rc != 111*/
							
						
							*If channels have names
							else {
								
								local num1=new2 in 1
								drop in 1/2
								keep in 1/`num1'
								rename v1 names
								replace names=lower(names)
								drop v*
								split names, p(-)
								replace names1="delta" if names1=="dellta"
								capture gen band=names1+names2
								capture gen band=names1
								replace band=trim(band)
								local num=_N
								
								forvalues i=1(1)`num' { /*forvalues i*/
									local band`i'=band in `i'
								} /*forvalues i*/
							}/*else*/
							
				} /*REMLOGIC == "" */
				
				**Assign REM LOGIC COLUMN NAMES
				if "`remlogic'" != "" { /*REMLOGIC != . */
					use `temp', clear
					drop if v3==""
					foreach var of varlist v* { /*foreach var*/
						capture assert `var' != ""
							if _rc==109 { /*rc=109*/
								drop `var'
							} /*rc=109*/
							
						capture assert `var'!="Wake" & `var'!="Stage 1" & `var'!="Stage 2" & `var'!="Rem" & `var'!="Stage 3"
							if _rc==9 { /*rc=9*/
								drop `var'
							}/*rc=9*/
							else { /*else*/
							}	/*else*/			
					} /*FOREACH VARLIST */
					describe
					local varnums=r(k)
					forvalues i=1(1)`varnums' { /*forvalues i*/
						local name`i' = v`i' in 1
					} /*forvalues i*/
					clear
					set obs `varnums'
					gen band=""
					forvalues i=1(1)`varnums' { /*forvalues i*/
						replace band="`name`i''" in `i'
					} /*forvalues i*/
					gen tag=1 if index(band, "[")
					keep if tag==1
					split band, p([ ])
					replace band=trim(lower(band1))
					local num=_N
					forvalues i=1(1)`num' { /*forvalues i*/
						local band`i'=band in `i'
					} /*forvalues i*/
					
				}/*REMLOGIC != . */
*
				
**************************************************************************************	
*Process EEG Data
**************************************************************************************	
					if "`remlogic'" == "" { /* "`remlogic'" == "" */   */
						use `temp', clear
						
						drop if v4=="" | v4=="Frequency (Hz)"
						local sample=v4 in 1
						drop in 1/2
						
						*Rename V-Variables
						if `anyevents'==0 { /*if `anyevents'==0 */

								*Determine if Stage Already Exists Somewhere and Name it
								foreach var of varlist _all { /*foreach var*/
									capture assert `var'!="Wake" & `var'!="Stage 1" & `var'!="Stage 2" & `var'!="Rem" & `var'!="Stage 3" & `var'!="Stage 4"
										if _rc==9 { /*rc==9*/
											rename `var' stage
											
											if "`var'"=="v7" {
												local sval=7
											}
											else {
												local sval=6
											}
											
										} /*rc==9*/
										else { /*else*/
										} /*else*/ 
								} /*FOREACH VARLIST*/
									
								rename v6 datacheck
								rename v2 start
								rename v3 epochtime
								rename v4 end
		
							forvalues i=1(1)`num' { /*forvalues i*/
								
								local newnum=`i'+`sval'
								destring v`newnum', replace 
								rename v`newnum' `band`i''
							} /*forvalues i*/
							
							snapshot save, label("inital labeling events0")
						} /*if `anyevents'==0 */
						
						*************************************************************
						
						*Rename V-Variables
						if `anyevents'!=0 { /*if `anyevents'!=0 */
								
								foreach var of varlist _all { /*foreach var*/
									capture assert `var'!="Wake" & `var'!="Stage 1" & `var'!="Stage 2" & `var'!="Rem" & `var'!="Stage 3" & `var'!="Stage 4"
										if _rc==9 { /*rc==9*/
											rename `var' stage
											
											if "`var'"=="v7" {
												local sval=7
											}
											else {
												local sval=6
											}
											
										} /*rc==9*/
										else { /*else*/
										} /*else*/ 
								} /*FOREACH VARLIST*/
								rename v6 datacheck
								rename v2 start
								rename v3 epochtime
								rename v4 end

			
							forvalues i=1(1)`num' { /*forvalues i*/
									
									local newnum=`i'+`sval'
									destring v`newnum', replace 
									rename v`newnum' `band`i''
							
							} /*forvalues i*/	
							snapshot save, label("inital labeling events1")
						}/*IF ANYEVENTS !=0 */
						
						forvalues i=1(1)`num' { /*forvalues i*/
							**Correct Values as 2 time value squared
							if "`correct'"=="2x^2" { /*if correct*/
								replace `band`i''=(2*`band`i'')^2
							}/*if correct*/
							if "`correct'"=="2x" { /*if correct*/
								replace `band`i''=(2*`band`i'')
							} /*if correct*/
							if "`correct'"=="x^2" { /*if correct*/
								replace `band`i''=(`band`i'')^2
							} /*if correct*/
							if "`correct'"=="x^.5" { /*if correct*/
								replace `band`i''=sqrt(`band`i'')
							} /*if correct*/
							else { /*else*/
							} /*else*/
						} /*forvalues i*/
						

							drop v*
						capture egen totdelta=rowtotal(delta*)
						capture gen totdelta=.
						tempfile analysis
						save `analysis', replace 
						snapshot save, label("Analysis")
				}/*If REMLOGIC ==""*/
	********************************************************	
					if "`remlogic'" != "" { /*"`remlogic'" != ""*/ 
						use `temp', clear
						drop if v4=="" 
						drop in 1
						*local sample=v4 in 1
						*drop in 1/2
						rename v2 start
						gen epochtime=start
						*rename v1 epoch
						rename v3 end
						forvalues i=1(1)`num' { /*forvalues i*/
							
							local newnum=`i'+3
							destring v`newnum', replace 
							rename v`newnum' `band`i''
							replace `band`i''=sqrt(`band`i'') * 1000000
							
							
							**Correct Values as 2 time value squared
							if "`correct'"=="2x^2" { /*correct*/
								replace `band`i''=(2*`band`i'')^2
							}/*correct*/
							if "`correct'"=="2x" { /*correct*/
								replace `band`i''=(2*`band`i'')
							}/*correct*/
							if "`correct'"=="x^2" { /*correct*/
								replace `band`i''=(`band`i'')^2
							} /*correct*/
							if "`correct'"=="x^.5" { /*correct*/
								replace `band`i''=sqrt(`band`i'')
							} /*correct*/
							else { /*else*/
							} /*else*/
						} /*Forvalues i*/
						local stagenum=`num'+4
						rename v`stagenum' stage 
						drop v*
						
						capture egen totdelta=rowtotal(delta*)
						capture gen totdelta=.
						tempfile analysis
						save `analysis', replace 
					} /*If remlogic != "" */
	*********************************************************	

					
					***Detemine Lights Out-Truncate file to LO time
					use `analysis', clear
					gen row=_n
					egen order=seq() if stage != ""
						sum row if order==1
						drop if row <r(mean)
						drop order row
					
					*Recode Stages as numerics(NEED TO ADD MOVEMENT TIME)
						replace stage="5" if stage=="Rem"
						replace stage="1" if stage=="Stage 1"
						replace stage="2" if stage=="Stage 2"
						replace stage="3" if stage=="Stage 3"
						replace stage="4" if stage=="Stage 4"
						replace stage="0" if stage=="Wake"
							destring stage, replace
					
					**Ensure Subject Has Sleep Stage Information 
						sum stage
						local obsnum =r(N)
						if `obsnum'==0 { /*obsnum==0*/
							dis as error "No Sleep Staging Present for `files', Cannot Continue"
							exit
						}/*obsnum==0*/
						else { /*else*/
						} /*else*/
					
					**Identify 30 Sec Epochs and Mixed Stages
							gen mixtag=.
							gen mixstage=""
							gen lagstage=stage[_n+1]
							gen row=_n-1
							gen timenew=`epochnum'
							gen elapsed1=timenew*row
							gen elapsed2=timenew*(row+1)
							
							local end=_N/`epochnum'
							gen epochbegin=.
							gen epochend=.
							forvalues i=1(1)`end' { /*forvalues i*/
								local j=`i'-1
								replace epochbegin=`i' if elapsed1 >= `j'*30 & elapsed1 <`i'*30 & epochbegin==.
								replace epochend=`i' if elapsed2 > `j'*30 & elapsed2 <=`i'*30 & epochend==.
							}/*forvalues i*/

						replace mixtag=1 if epochbegin!=epochend & stage!=lagstage
						
						tostring stage lagstage, force format(%9.0f) replace
						replace mixstage="("+ stage + "/" +lagstage + ")" if mixtag==1
							drop lagstage elapsed* timenew row
							destring stage, replace
										
						replace stage=. if mixtag ==1	
					
											
					*Determine Sleep Onest
						*First Instance of Stage 2
						if "`sleeponset'" == "" | "`sleeponset'"=="n2" { /*if sleeponset*/
								egen order=seq()
								egen seq=seq() if stage==2
								sum order if seq==1
								gen so=0 if order < r(mean)
									replace so=1 if order >= r(mean)
								drop seq order
						} /*if sleeponset*/
						*First Instance of Stage 1
						if "`sleeponset'"=="n1" { /*if sleeponset*/
								egen order=seq()
								egen seq=seq() if stage==1
								sum order if seq==1
								gen so=0 if order < r(mean)
									replace so=1 if order >= r(mean)
								drop seq order
						} /*if sleeponset*/
					
						*8of10 (4 Min of 5 min of Sleep/Any Stage)
						if "`sleeponset'"=="8of10" { /*if sleeponset*/
							capture drop sleep seq order tag
							gen sleep=1 
								replace sleep=0  if stage==0 | stage==. 
					
							egen seq=seq() if sleep==1
							egen order=seq()
							sum order if seq==1
								local startval=r(mean)
								drop seq order
							egen order=seq()
							
								*Determine at least 0.8% of sleep
								local end=_N
								set more off
								gen tag=.
														
								local y=`startval'
								local add=(300/`epochnum')-1
								forvalues i=`startval'(1)`end' {
										local j=`y'+`add'
										if `j' <=`end' { /*if j*/
												sum sleep in `i'/`j'
													local mean=r(mean)
													replace tag=1 if `mean' >=0.8 & `mean' !=. & order >=`i' & order <=`j' 
												sum tag
												local min=r(min)
												if `min'==1 { /*if min=1*/
													local y=`end'
												} /*if min=1*/
												else { /*else*/
													 local y=`i'
												} /*else*/
										}/*if `j' <=`end'*/
								}/*Forvalues*/
								egen seq=seq() if tag==1
								sum order if seq==1
								gen so=0 if order < r(mean)
									replace so=1 if order >= r(mean)
								drop sleep order tag seq
								
							}/*if "`sleeponset'"=="8of10"*/		
							*
							
					
					*Determine REM/NREM Cycles
						recode stage (0 6=0) (1 2 3 4=1) (5=2), gen(rem) 
						replace rem=1 if mixstage=="(1/2)" | mixstage=="(1/3)" | mixstage=="(1/4)" | mixstage=="(2/3)" | mixstage=="(2/4)"  | mixstage=="(3/4)"
						replace rem=1 if mixstage=="(2/1)" | mixstage=="(3/1)" | mixstage=="(4/1)" | mixstage=="(3/2)" | mixstage=="(4/2)"  | mixstage=="(4/3)"
	
							gen remcycle=.
							gen nremcycle=.
							egen row=seq()	
					
					
					snapshot save, label("REMS")
							*******************************************************
							
							
							/****REM: STEP 1-Tag Consequtive REM****/
								gen valid=1
									egen seq=seq() if stage==5 
									gen lag=seq[_n-1]
									egen remstop=seq() if lag!=. & seq==.
									egen remstart=seq() if lag==. & seq!=.
									replace valid=0 if seq==. 
								
								sum remstop 
								local rmax=r(max)
								local remwin=`remnum'*60	
								
							
							/****REM: STEP 2-Evaluate if Consequtive REM Meets Time criteria****/
							if `rmax' != . { /*if rmax*/
								**Within REM Cycles 					
								forvalues i=1(1)`rmax' {
									sum row if remstop==`i'
										local stop=r(mean)
									sum row if remstart==`i'
										local start=r(mean)
									local diff=`epochnum'*(`stop'-`start')
									replace valid=0 if `diff' < `remwin' & row >= `start' & row < `stop'
								}/*forvalues i rmax*/
									capture drop seq lag remstop remstart
						
							/****REM: STEP 3-Number Valid Blocks of REM****/
								egen seq=seq() if stage==5 & valid==1 
								gen lag=seq[_n-1]
								egen remstop=seq() if lag!=. & seq==.
								egen remstart=seq() if lag==. & seq!=.

							} /*if rmax*/
							else { /*else*/
								capture drop seq lag remstop remstart valid
							} /*else*/
								

							/****NREM: STEP 1-Tag Consequtive RREM****/
								capture drop valid lag seq
								gen valid=1
									egen seq=seq() if rem==1 
									gen lag=seq[_n-1]
									egen nremstop=seq() if lag!=. & seq==.
									egen nremstart=seq() if lag==. & seq!=.
									replace valid=0 if seq==. 
								
								sum nremstop 
								local nrmax=r(max)
								*local nremnum=15
								*local epochnum=4
								local nremwin=`nremnum'*60	
								
							
							/****NREM: STEP 2-Evaluate if Consequtive NREM Meets Time criteria****/
							if `nrmax' != . { /*if nrmax*/
								
								**Within RREM Cycles 					
								forvalues i=1(1)`nrmax' { /*forvalues i nrmax*/
									sum row if nremstop==`i'
										local stop=r(mean)
									sum row if nremstart==`i'
										local start=r(mean)
									local diff=`epochnum'*(`stop'-`start')
									replace valid=0 if `diff' < `nremwin' & row >= `start' & row < `stop'
								}/*forvalues i nrmax*/
									capture  drop seq lag nremstop nremstart
						
							/****NREM: STEP 3-Number Valid Blocks of NREM****/
								egen seq=seq() if rem==1 & valid==1
								gen lag=seq[_n-1]
								egen nremstop=seq() if lag!=. & seq==.
								egen nremstart=seq() if lag==. & seq!=.
							} /*if nrmax*/
							else { /*else*/
								capture drop seq lag nremstop nremstart valid
							} /*else*/
							
									
							/***REM: Step 4-Tag Valid Blocks of REM**/
							capture assert remstop
							if _rc!=111 { /*rc!=111*/
								sum remstop
								local rmax=r(max)
								
								if `rmax' !=. {	/*if rmax != . */
									capture drop valid lag seq				
									gen remvalid=.
									sum remstop
									local end=r(max)
									forvalues i=1(1)`end' { /*forvalues i*/ 
										sum row if remstart==`i'
											local start=r(mean)
										sum row if remstop==`i'
											local stop=r(mean)									
										replace remvalid=1 if row >=`start' & row <`stop'
									} /*forvalues i*/ 
									
								}/*if rmax != . */
								else { /*else*/
								} /*else*/
							}/*rc!=111*/
							else { /*else*/
								local rmax=.
								gen remvalid=.
							} /*else*/
							/***NREM: Step 4-Tag Valid Blocks of NREM**/
							capture assert nremstop
							if _rc!=111 { /*rc!=111*/
							
								sum nremstop
								local nrmax=r(max)
								
								if `nrmax' !=. {	/*nrmax !=. */
									gen nremvalid=.
									sum nremstop
									local end=r(max)
									forvalues i=1(1)`end' { /*forvalues i*/
										sum row if nremstart==`i'
											local start=r(mean)
										sum row if nremstop==`i'
											local stop=r(mean)									
										replace nremvalid=1 if row >=`start' & row <`stop'
									}/*forvalues i*/
								}/*nrmax !=. */
								else { /*else*/
								} /*else*/
							} /*rc!=111*/
							else { /*else*/
								local nrmax=.
								gen nremvalid=.
							} /*else*/
								
							/***REM: Step 5-Identify Potential REM Cycles-Ending them if valid NREM occurs between**/
							if `rmax' !=. { /*rmax !=. */
								sum remstop
								local end=r(max)
								forvalues i=1(1)`end' { /*forvalues i*/
									local j=`i'+1
									sum row if remstart==`i'
										local start=r(mean)			
									sum row if remstop==`i'
										local stopsame=r(mean)
									sum row if remstop==`j'
										local stopnext=r(mean)
										if `stopnext'==. {
											local stopnext=_N
										}
										else {
										}
									capture gen nremvalid=.	
									sum nremvalid if row>=`start' & row<`stopnext'
									local value=r(max)
										if `value'==1 { /*if value==1*/
											replace remcycle=1 if row>=`start' & row <`stopsame' 
										} /*if value==1*/
										else { /*else*/
											replace remcycle=1 if row>=`start' & row <`stopnext' 
										} /*else*/
								}/*forvalues i*/
							} /*rmax !=. */
							else { /*else*/
							} /*else*/
							
								
							/***NREM: Step 5-Identify Potential NREM Cycles-Ending them if valid REM occurs between**/
							if `nrmax' !=. { /*nrmax !=. */
								sum nremstop
								local end=r(max)
								forvalues i=1(1)`end' { /*forvalues i*/
									local j=`i'+1
									sum row if nremstart==`i'
										local start=r(mean)
									sum row if nremstop==`i'
										local stopsame=r(mean)
									sum row if nremstop==`j'
										local stopnext=r(mean)
										if `stopnext'==. {
											local stopnext=_N
										}
										else {
										}
									capture gen remvalid=.	
									sum remvalid if row>=`start' & row<`stopnext'
									local value=r(max)
										if `value'==1 { /*value==1*/
											replace nremcycle=1 if row>=`start' & row <`stopsame' & nremcycle==.
										} /*value==1*/
										else { /*else*/
											replace nremcycle=1 if row>=`start' & row <`stopnext' & nremcycle==.
										} /*else*/
								} /*forvalues i*/
								capture drop *stop *start *valid
							}/*nrmax != . */
							else { /*else*/
							} /*else*/
							
							/***REM/NREM Step 6-Fill in the missing gaps so that wake does not break up the rem/nrem cycles***/ 
							if `nrmax' !=. | `rmax' != . { /*`nrmax' !=. | `rmax' != .*/
								gen cycle=""
								capture replace cycle ="NREM" if nremcycle==1
								capture replace cycle ="REM" if remcycle==1
								replace cycle=cycle[_n-1] if cycle==""
								capture drop lag
								gen lag=cycle[_n-1]
								capture egen nremstart=seq() if cycle=="NREM" & lag=="" | cycle=="NREM" & lag=="REM" 
								capture egen nremstop=seq() if cycle=="REM" & lag=="NREM" 
								
								capture  egen remstart=seq() if cycle=="REM" & lag=="" | cycle=="REM" & lag=="NREM" 
								capture egen remstop=seq() if  cycle=="NREM" & lag=="REM" 
								
								
								sum remstart
								capture assert r(max) != .
								if _rc==9 { /*rc==9*/
									local maxcode1=1
								} /*rc==9*/
								else { /*else*/
									local maxcode1=0
								} /*else*/
								
								sum nremstart 
								capture assert r(max) != .
								if _rc==9 { /*rc==9*/	
									local maxcode2=1
								} /*rc==9*/
								else { /*else*/
									local maxcode2=0
								} /*else*/
								
								
								*has rem and nrem
								if `maxcode1' !=1 & `maxcode2' !=1 { /*`maxcode1' != 1 & `maxcode2' != 1 */ 	
										sum remstop
										local max1=r(max)
										
										sum nremstop
										local max2=r(max)
										
									if `max1' >`max2' { /*max1*/
										local end=`max1' 
									} /*max1*/
									if `max2' >`max1' { /*max2*/
										local end=`max2' 
									} /*max2*/
									if `max1' == . {
										local end=`max2' 
									}
									if `max2' == . {
										local end=`max1' 
									}
									if `max2' == `max1' {
										local end=`max1' 
									}
										forvalues i=1(1)`end' { /*forvalues*/
											sum row if nremstart==`i'
												local start=r(mean)
											sum row if nremstop==`i'
												local stop=r(mean)
												
											replace nremcycle=`i' if row >=`start' & row <`stop'
											
											sum row if remstart==`i'
												local start=r(mean)
											sum row if remstop==`i'
												local stop=r(mean)		
											replace remcycle=`i' if row >=`start' & row <`stop'
										}/*forvalues*/
									capture drop cycle lag *start *stop	
								} /*`maxcode1' != 1 & `maxcode2' != 1 */
								
								
								*missing rem
								if `maxcode1' ==1  { 	 /*if maxcode1==1*/
	
										sum nremstop
										local max2=r(max)
										
										local end=`max2' 

										if `end' != . {
											forvalues i=1(1)`end' { /*forvalues*/
												
													capture sum row if nremstart==`i'
														local start=r(mean)
													sum row if nremstop==`i'
														local stop=r(mean)
														
													replace nremcycle=`i' if row >=`start' & row <`stop'
												
											}/*forvalues*/
										}
										else { 
										}
									capture drop cycle lag *start *stop	
								} /*if maxcode1==1*/					
								
								*has nrem
								if `maxcode2' ==1 { 	/*maxcode2==1*/
										sum remstop
										local max1=r(max)
										
										local end=`max1' 
								
										if `end'!=. {
											forvalues i=1(1)`end' { /*forvalues i*/
													
													sum row if remstart==`i'
														local start=r(mean)
													sum row if remstop==`i'
														local stop=r(mean)		
													replace remcycle=`i' if row >=`start' & row <`stop'
												
											}/*forvalues i*/
										}
										else {
										}
									capture drop cycle lag *start *stop	
								} /*maxcode2==1*/
								
							}/*IF nremax != . |  remax !=.*/
							else { /*else*/
							} /*else*/

					***************************************************************		

					*******************************************************			
					**Generate Relative Frequencies
						egen total=rowtotal(`band1'-`band`num'')
						foreach var of varlist `band1'-`band`num'' totdelta { /*foreach var*/ 
							gen rel_`var'=`var'/total
						}/*foreach var*/
						drop total
						capture drop row
						
					*******************************************************	
					*Set elapsed time from sleep onset variable (seconds)
					
					
						gen row=_n
						gen time=`epochnum'
						gen lotime=sum(time)-`epochnum'
						gen sotime=sum(time)-`epochnum' if so==1
							sum row if sotime==0
							replace sotime=-1*(`epochnum'*(r(mean)-row)) if sotime==.
						drop time
						local timelimit=`timenum'*60*60
						
						snapshot save, label("SOTIMES")
					*******************************************************	
					
					
					
					*******************************************************	
					**Define Winfow Length	for Artifact Rejection
					local window=((`winnum'*60)/`epochnum')-1
					local rowmax=_N
					
					/*****Run Artifact Rejecttion****/
					*Loop through Rows for Median Artifact rejection
					
					/**Define highest frew Band for Alternate Method Artifact Rejection***/
						if "`altreject'" == "" { /*"`altreject'" == "" */
							*Define almost highest Freq Band
							local next=`num'-1
							local bandalt `band`next''
							egen brunneralt=rowtotal(`bandalt')
						} /*"`altreject'" == "" */
						if "`altreject'" != "" { /* "`altreject'" != "" */
							local bandalt "`altreject'"
							egen brunneralt=rowtotal(`bandalt')
						} /* "`altreject'" != "" */
					
						if "`breject'" == "" { /*"`breject'" == "" */							
							capture assert beta2!=.
							if _rc==111{								
								local bandb "`band1'"
								egen brunner=rowtotal(`bandb')
							}
							*Define based on Beta2
							else {
								local bandb "beta2"
								egen brunner=rowtotal(`bandb')
							}	
						} /*"`altreject'" == "" */
						if "`breject'" != "" { /* "`breject'" != "" */
							local bandb "`breject'"
							egen brunner=rowtotal(`bandb')
						} /* "`breject'" != "" */
					
						gen bart=0
						gen mart=0
						
						forvalues i=1(1)`rowmax' { /*forvalues i*/
							local end=`i'+`window'
							
							if `end' <=`rowmax' { /* end <= rowmax */
								*bart Moving Median
								sum brunner in `i'/`end', det
									replace bart=1 if brunner > 4*r(p50) in `i'/`end'
								*Alternante Definitiion Moving Median
								sum brunneralt in `i'/`end', det
									replace  mart=1 if brunneralt > 4*r(p50) in `i'/`end'
							}/*if `end' <=`rowmax'*/
							
							*
							else { /*else*/
							} /*else*/
							*	
						}/*forvalues i*/
						*
						
					*******************************************************	
					/***Input Identifying Characteristics***/
					foreach x in id study night state channel date { /*foreach x*/
						gen `x'="``x''"
					} /*foreach x*/
					rename state cond_grp
					capture drop bin
					tempfile data
					save `data', replace 
					use `output', clear
						drop if id==""
					append using `data'
					order study id night cond_grp channel date 	
					
					*Drop Out LO data if not needed
					if "`soextract'"=="" { /*"`soextract'"=="" */
						local timevar lotime
					} /*"`soextract'"=="" */
					else { /*else*/
						drop if sotime<0
						local timevar sotime
					} /*else*/
					capture drop maxpower
					capture drop datacheck
					capture drop brunner brunneralt
					drop  so end  row
					order study id night cond_grp channel date epoch* stage remcycle nremcycle rem mixtag mixstage lotime sotime bart mart
					replace mixtag=0 if mixtag==.
					sort night channel lotime
					save `output', replace 
				
			
		}/*if events==0*/
	}/*foreach files*/		
***********************************************************************************************************		
/***ADD in Event Tags***/
	*noi: dis "Start event tags"
	*Those with at least 1 Event file
	if `anyevents' != 0 { /*if `anyevents' != 0 */ 
		use `output', clear
			
			if "`remlogic'" != "" { /* "`remlogic'" != "" */
				gen ampm="PM" if index(epochtime, "PM")
				replace ampm="AM" if ampm==""
				
				split epochtime, p(: . AM PM)
				destring epochtime1-epochtime3, replace 
				replace epochtime1=epochtime1+12 if ampm=="PM" & epochtime1!=12
				
			} /* "`remlogic'" != "" */	
			if "`remlogic'" == "" { /* "`remlogic'" == "" */
				split epochtime, p(: .)
				destring epochtime1-epochtime3, replace 
				
				gen ampm="AM" if epochtime1 >=0 & epochtime1 <=12
				replace ampm="PM" if epochtime1 >=13
			} /* "`remlogic'" == "" */
			replace epochtime1=epochtime1-12 if ampm=="PM"
			replace epochtime1=epochtime1+12 if ampm=="AM"
			gen elapsed=epochtime1*3600 + epochtime2*60 + epochtime3
			drop epochtime1-epochtime4 ampm
			capture drop epochtime5
			
		keep study id night cond_grp elapsed epochtime 
		
		*Bring in Events File
		joinby study id night cond_grp using `eventsout', unmatched(both)
			capture drop _merge
		gen arousal=1 if elapsed>=elapsedstart & elapsed<=elapsedend 
			keep if arousal==1
			local arpresent=_N
			
			
			*If there are qualifying arousals, then bring in....otherwise skip	
			if `arpresent'==0 {
				use `output', clear
					*drop if sotime==.
					gen arousal=0 if sotime !=.
					order study id night cond_grp channel date epochtime epochbegin epochend stage remcycle nremcycle rem mixtag mixstage lotime sotime bart mart arousal	
					sort night channel lotime
				save `output', replace 
			}
			if `arpresent'!=0 {
				keep study id night cond_grp epochtime	
					duplicates drop
					*This has to be redone becuase there are duplicate tags otherwise
					gen arousal=1
				tempfile temp
				save `temp', replace 
				
				**Join with Master Data
				use `output', clear
				capture joinby study id night cond_grp epochtime using `temp', unmatched(both)
					drop _merge
				order study id night cond_grp channel date epochtime epochbegin epochend stage remcycle nremcycle rem mixtag mixstage lotime sotime bart mart arousal	
				recode arousal (.=0) if sotime!=.
					*drop if sotime==.
				sort night channel lotime	
				save `output', replace 
			}
		
		**TOGGLE Arousals tagged for entire epoch
		if "`arexact'"=="" { /*arexact == "" */
			use `output', clear
			
				bys study id night cond_grp channel date epochbegin: egen armax1=max(arousal)
				bys study id night cond_grp channel date epochend: egen armax2=max(arousal)
					egen armax=rowmax(armax1 armax2)
				replace arousal=armax
				drop armax*
				sort night channel lotime
			save `output', replace 
		} /*arexact == "" */
		if "`arexact'" != ""{ /*arexact != "" */
		}	/*arexact != "" */	 
}/*if anyevents != 0 */
	
	*Those without Any Events Files
	if `anyevents'==0 { /* `anyevents'==0 */
		use `output', clear
			gen arousal=0
			order study id night cond_grp channel date epochtime epochbegin epochend stage remcycle nremcycle rem mixtag mixstage lotime sotime bart mart arousal	
			sort night channel lotime
		save `output', replace
	} /* `anyevents'==0 */
	
	*
	
	
	
	
**********************************************************************************************************************
			
			/**Export Data For Each Subject**/
			capture mkdir results
			cd results
	
			***********************************************************************						
			**RAW DATA
				***Outsheet Subject RAW Data
				use `output', clear
				
				*Determine if rem and nrem cycle data is present
				sum nremcycle if `timevar' <= `timelimit'
				local nremcy=r(max)
				
				sum remcycle if `timevar' <= `timelimit'
				local remcy=r(max)
				
				
				outsheet using `id'_RAW_`timevar'`timenum'.txt, replace 
				
				/*Add to Overall Raw Data
				use `outputraw', clear
					append using `output'
				save `outputraw', replace 	
				*/
			***********************************************************************		
			
			
		/***TOGGLE Average accross Sleep Epochs*/	
		if "`avgslpepoch'" == "" {	/*if AVGslpepoch*/
			*Stage Data
				tempfile counts raw raw1 raw2 bart bart1 bart2 mart mart1 mart2 arousal
					**Extract Stage Info for those without Arousals
					if `anyevents'==0 { /*`anyevents'==0 */
						use `output', clear		
							collapse `band1'-`band`num'' totdelta rel* bart mart arousal if  stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' r_`var'
								}
							save `raw', replace 
						
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  bart!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' b_`var'
								}
							save `bart', replace 
						
						
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  mart!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' m_`var'
								}
							save `mart', replace 
							
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  arousal!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' a_`var'
								}
							save `arousal', replace 					
				
					} /*`anyevents'==0 */
					*
					**Create arousal as a stage and extract Stage Info for those with Arousals
					if `anyevents'!=0 { /*if `anyevents'!=0*/
						
						***RAW
						use `output', clear		
							collapse `band1'-`band`num'' totdelta rel* bart mart arousal if  stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' r_`var'
								}
							save `raw1', replace 
						
						*Has Arousals
						if `arpresent' != 0 {
							use `output', clear		
								collapse `band1'-`band`num'' totdelta rel* bart mart arousal if arousal==1 & `timevar' <= `timelimit', by(study id night cond_grp channel date)
									foreach var of varlist `band1'-`band`num'' totdelta rel* {
										rename `var' r_`var'
									}
								gen stage=9	
								save `raw2', replace 
						}	
							use `raw1', clear
							capture append using `raw2'
						
							save `raw', replace
						
						
						**BART
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  bart!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' b_`var'
								}
							save `bart1', replace 
						
						*Has Arousals
						if `arpresent' != 0 {
							use `output', clear
								collapse `band1'-`band`num'' totdelta rel* if  bart!=1 & arousal==1 & `timevar' <= `timelimit', by(study id night cond_grp channel date)
									foreach var of varlist `band1'-`band`num'' totdelta rel* {
										rename `var' b_`var'
									}
								gen stage=9
								save `bart2', replace 
						}
							use `bart1', clear
							capture append using `bart2'
						
							save `bart', replace
						
						**MART
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  mart!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' m_`var'
								}
							save `mart1', replace 

						*Has Arousals
						if `arpresent' != 0 {							
							use `output', clear
								collapse `band1'-`band`num'' totdelta rel* if  mart!=1 & arousal==1 & `timevar' <= `timelimit', by(study id night cond_grp channel date)
									foreach var of varlist `band1'-`band`num'' totdelta rel* {
										rename `var' m_`var'
									}
								gen stage=9
								save `mart2', replace 
						}		
							use `mart1', clear
							capture append using `mart2'
						
							save `mart', replace
						
						**Arousal
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  arousal!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' a_`var'
								}
							save `arousal', replace 					
				
					} /*if `anyevents'!=0*/
				
				
				use `raw', clear
				joinby study id night cond_grp channel date stage using `bart'
				joinby study id night cond_grp channel date stage using `mart'
				joinby study id night cond_grp channel date stage using `arousal', unmatched(both)
					drop _merge
								
				order study id night cond_grp channel date stage bart mart arousal
				foreach var of varlist *rel* bart mart arousal {
					replace `var'=`var'*100
				}
				foreach var in bart mart arousal {
					replace `var'=round(`var', 0.01)
					rename `var' per`var'
				}
				
				**Calculate Relative Frequency Differently
				if "`relaltcalc'" != "" { /*relalt calc*/
						drop *rel*
						drop *totdelta
						foreach x in r b m a { /*foreach x */
							egen `x'_total=rowtotal(`x'_*)
							capture egen `x'_totdelta=rowtotal(`x'_delta*)
							capture gen `x'_totdelta=.
						
							foreach var of varlist `x'_* { /*foreach var */
								gen rel_`var'=(`var'/`x'_total)*100
							} /*foreach var */	
						} /*foreach x */
				order study id night cond_grp channel date stage perbart permart perarousal r_* rel_r_* b_* rel_b_* m_* rel_m_* a_* rel_a_*		
				} /*relalt calc*/
						capture drop *total
						capture drop row
						
				
				tempfile stage
				save `stage', replace 
				
				outsheet using `id'_stage_`timevar'`timenum'.txt, replace 
				
				*Add to Overall Stage Data
				use `outputstage', clear
					append using `stage'
				save `outputstage', replace 	
			
			***********************************************************************				
			*Cycle Data
			tempfile nremraw remraw nrembart rembart  nremmart remmart raw  bart mart remarousal nremarousal arousal

				

			if `nremcy' != . & `remcy' != . {
				
						****NREM Raw
						use `output', clear
							recode rem (. 2 0 =0) (1=1), gen(efficiency)
							collapse efficiency if `timevar' <= `timelimit' , by(study id night cond_grp channel date nremcycle)
							tostring nremcycle, force format(%9.0g) replace 	
							gen cycle="NREM" +	nremcycle
								drop nremcycle
							tempfile efficiency
							save `efficiency', replace 
						
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* bart mart arousal if `timevar' <= `timelimit' & rem==1 , by(study id night cond_grp channel date nremcycle)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' r_`var'
								}
							tostring nremcycle, force format(%9.0g) replace 	
							gen cycle="NREM" +	nremcycle
								drop nremcycle
							joinby study id night cond_grp channel date	cycle using `efficiency'
							save `nremraw', replace 
							
						
						****REM Raw
						use `output', clear
							recode rem (. 1 0 =0) (2=1), gen(efficiency)
							collapse efficiency if `timevar' <= `timelimit' , by(study id night cond_grp channel date remcycle)
							tostring remcycle, force format(%9.0g) replace 	
							gen cycle="REM" +	remcycle
								drop remcycle
							tempfile efficiency
							save `efficiency', replace 
						
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* bart mart arousal  if   `timevar' <= `timelimit' & rem==2 , by(study id night cond_grp channel date remcycle)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' r_`var'
								}
							tostring remcycle, force format(%9.0g) replace 	
							gen cycle="REM" +	remcycle
								drop remcycle
							joinby study id night cond_grp channel date	cycle using `efficiency'
							save `remraw', replace 
						
						use `remraw', clear
						append using `nremraw'
						
						save `raw', replace
			}
			if `nremcy' != . & `remcy' == . {
				
						****NREM Raw
						use `output', clear
							recode rem (. 2 0 =0) (1=1), gen(efficiency)
							collapse efficiency if `timevar' <= `timelimit' , by(study id night cond_grp channel date nremcycle)
							tostring nremcycle, force format(%9.0g) replace 	
							gen cycle="NREM" +	nremcycle
								drop nremcycle
							tempfile efficiency
							save `efficiency', replace 
						
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* bart mart arousal if `timevar' <= `timelimit' & rem==1 , by(study id night cond_grp channel date nremcycle)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' r_`var'
								}
							tostring nremcycle, force format(%9.0g) replace 	
							gen cycle="NREM" +	nremcycle
								drop nremcycle
							joinby study id night cond_grp channel date	cycle using `efficiency'
							save `nremraw', replace 
							
						
						
						use `nremraw', clear
						
						save `raw', replace
			}
				
			if `nremcy' == . & `remcy' != . {
													
						****REM Raw
						use `output', clear
							recode rem (. 1 0 =0) (2=1), gen(efficiency)
							collapse efficiency if `timevar' <= `timelimit' , by(study id night cond_grp channel date remcycle)
							tostring remcycle, force format(%9.0g) replace 	
							gen cycle="REM" +	remcycle
								drop remcycle
							tempfile efficiency
							save `efficiency', replace 
						
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* bart mart arousal  if   `timevar' <= `timelimit' & rem==2 , by(study id night cond_grp channel date remcycle)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' r_`var'
								}
							tostring remcycle, force format(%9.0g) replace 	
							gen cycle="REM" +	remcycle
								drop remcycle
							joinby study id night cond_grp channel date	cycle using `efficiency'
							save `remraw', replace 
						
						use `remraw', clear
						
						save `raw', replace
			}
			
			*NO REM or NREM Cycles
			if `nremcy' == . & `remcy' == . {
			
			}
			
				****NREM BART
			if `nremcy' != . {
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==1  & bart!=1 , by(study id night cond_grp channel date nremcycle)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' b_`var'
						}
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle

					save `nrembart', replace 
			}	
				
				****REM BART
			if `remcy' != . {	
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==2 & bart!=1 , by(study id night cond_grp channel date remcycle)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' b_`var'
						}
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle

					save `rembart', replace 
			}	
			
			if `nremcy' != . & `remcy' != . {
				use `rembart', clear
				append using `nrembart'
				save `bart', replace
			}
			if `nremcy' == . & `remcy' != . {
				use `rembart', clear
				save `bart', replace
			}	
			if `remcy' == . & `nremcy' != . {
				use `nrembart', clear
				save `bart', replace
			}	
			if `remcy' == . & `nremcy' == . {
			}
								
			
			if `nremcy' != . {
				****NREM MART
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==1  & mart!=1 , by(study id night cond_grp channel date nremcycle)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' m_`var'
						}
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle

					save `nremmart', replace 
			}		
			
			if `remcy' != . {
				****REM MART
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==2 & mart!=1 , by(study id night cond_grp channel date remcycle)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' m_`var'
						}
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle

					save `remmart', replace 
			}	
			
			if `nremcy' != . & `remcy' != . {
				use `remmart', clear
				append using `nremmart'
				save `mart', replace
			}
			if `nremcy' == . & `remcy' != . {
				use `remmart', clear
				save `mart', replace
			}	
			if `remcy' == . & `nremcy' != . {
				use `nremmart', clear
				save `mart', replace
			}	
			if `remcy' == . & `nremcy' == . {
			}
							
					
				****NREM Arosual
			if `nremcy' != . {	
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==1  & arousal!=1 , by(study id night cond_grp channel date nremcycle)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' a_`var'
						}
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle

					save `nremarousal', replace 
			}		
				
			if `remcy' != . {	
				****REM Arosual
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==2 & arousal!=1 , by(study id night cond_grp channel date remcycle)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' a_`var'
						}
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle

					save `remarousal', replace 
			}	
				
			if `nremcy' != . & `remcy' != . {
				use `remarousal', clear
				append using `nremarousal'
				save `arousal', replace	
			}
			if `nremcy' == . & `remcy' != . {
				use `remarousal', clear
				save `arousal', replace	
			}	
			if `remcy' == . & `nremcy' != . {
				use `nremarousal', clear
				save `arousal', replace	
			}	
			if `remcy' == . & `nremcy' == . {
			}
			
			
			*Process if there is a REM OR NREM Cycle
			if `remcy' != . | `nremcy' != . {
				use `raw', clear
				joinby study id night cond_grp channel date cycle using `bart'
				joinby study id night cond_grp channel date cycle using `mart'
				joinby study id night cond_grp channel date cycle using `arousal'

				order study id night cond_grp channel date cycle efficiency bart mart arousal
				foreach var of varlist *rel* bart mart arousal efficiency {
					replace `var'=`var'*100
				}
				
				foreach var in efficiency bart mart arousal {
					replace `var'=round(`var', 0.01)
					rename `var' per`var'
				}
				
				drop if cycle=="REM." | cycle=="NREM."
				
				if "`relaltcalc'" != "" {
						drop *rel*
						drop *totdelta
						foreach x in r b m a {
							egen `x'_total=rowtotal(`x'_*)
							capture egen `x'_totdelta=rowtotal(`x'_delta*)
							capture gen `x'_totdelta=.
						
						
							foreach var of varlist `x'_* {
								gen rel_`var'=(`var'/`x'_total)*100
							}	
						}
				order study id night cond_grp channel date cycle perefficiency perbart permart perarousal r_* rel_r_* b_* rel_b_* m_* rel_m_* a_* rel_a_*		
				}
						capture drop *total
						capture drop row
				
				sort study id night cond_grp channel date cycle
					
				tempfile cycle
				save `cycle', replace 	
					
	
				outsheet using `id'_cycle_`timevar'`timenum'.txt, replace 
	
				*Add to Overall Cycle Data
				use `outputcycle', clear
					append using `cycle'
				save `outputcycle', replace
			} /* if `remcy' != . | `nremcy' != . { Process forward if there is cycle data*/
	}/* avgslpepoch == "" */		
	*
	
	/***TOGGLE Average accross Sleep Epochs*/	
	if "`avgslpepoch'" != "" {	
			**Create Epoch Level Tagged Data adjusted for Overlapped Epochs
			use `output', clear
					bys epochbegin: egen length1=count(epochbegin)
					bys epochend: egen length2=count(epochend)
					tempfile master_epochlev
					save `master_epochlev', replace 
					
					use `master_epochlev', clear
						egen max=max(length1)
						keep if length1==max
						drop epochend
						rename epochbegin epoch
						drop length1 length2 max
						
						tempfile epoch1
						save `epoch1', replace 
						
					use `master_epochlev', clear
						egen max=max(length2)
						keep if length2==max
						drop epochbegin
						rename epochend epoch
						drop length1 length2 max
						
						tempfile epoch2
						save `epoch2', replace 	
					
					use `epoch1', clear
					append using `epoch2'
				save `output', replace 
			
		
			*Stage Data
				tempfile counts raw raw1 raw2 bart bart1 bart2 mart mart1 mart2 arousal counts_epoch raw_epoch raw1_epoch raw2_epoch bart_epoch bart1_epoch bart2_epoch mart_epoch mart1_epoch mart2_epoch arousal_epoch
					**Extract Stage Info for those without Arousals
					if `anyevents'==0 {
						use `output', clear		
							collapse `band1'-`band`num'' totdelta rel* bart mart arousal if  stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage epoch)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' r_`var'
								}
							
							save `raw_epoch', replace 
							collapse r_* bart mart arousal, by(study id night cond_grp channel date stage)
							save `raw', replace 
						
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  bart!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage epoch)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' b_`var'
								}
							
							save `bart_epoch', replace 
							collapse b_*  , by(study id night cond_grp channel date stage)
							save `bart', replace 
						
						
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  mart!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage epoch)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' m_`var'
								}
							save `mart_epoch', replace 
							collapse m_*, by(study id night cond_grp channel date stage)
							save `mart', replace 
							
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  arousal!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage epoch)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' a_`var'
								}
							save `arousal_epoch', replace
							collapse a_*  , by(study id night cond_grp channel date stage)
							save `arousal', replace 					
				
					}
					**Create arousal as a stage and extract Stage Info for those with Arousals
					if `anyevents'!=0 {
						
						***RAW
						use `output', clear		
							collapse `band1'-`band`num'' totdelta rel* bart mart arousal if  stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage epoch)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' r_`var'
								}
							save `raw1_epoch', replace 
							collapse r_* bart mart arousal, by(study id night cond_grp channel date stage)
							save `raw1', replace 
						*Has Arousals	
						if `arpresent' != 0 {
							use `output', clear		
								collapse `band1'-`band`num'' totdelta rel* bart mart arousal if arousal==1 & `timevar' <= `timelimit', by(study id night cond_grp channel date epoch)
									foreach var of varlist `band1'-`band`num'' totdelta rel* {
										rename `var' r_`var'
									}
								gen stage=9	
								save `raw2_epoch', replace
								collapse r_* bart mart arousal , by(study id night cond_grp channel date stage)
								save `raw2', replace 
						}
							
							**Aggregate Raw
							use `raw1', clear
							capture append using `raw2'
						
							save `raw', replace
						
							**Aggregate Raw Epoch
							use `raw1_epoch', clear
							capture append using `raw2_epoch'
						
							save `raw_epoch', replace
						
						
						**BART
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  bart!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage epoch)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' b_`var'
								}
							save `bart1_epoch', replace 
							collapse b_* , by(study id night cond_grp channel date stage)
							save `bart1', replace 
						
						*Has Arousals	
						if `arpresent' != 0 {
							use `output', clear
								collapse `band1'-`band`num'' totdelta rel* if  bart!=1 & arousal==1 & `timevar' <= `timelimit', by(study id night cond_grp channel date epoch)
									foreach var of varlist `band1'-`band`num'' totdelta rel* {
										rename `var' b_`var'
									}
								gen stage=9
								save `bart2_epoch', replace 
								collapse b_* , by(study id night cond_grp channel date stage)
								save `bart2', replace 
						}	
						
							**Aggregate BART
							use `bart1', clear
							capture append using `bart2'
						
							save `bart', replace
							
							**Aggregate BART Epoch
							use `bart1_epoch', clear
							capture append using `bart2_epoch'
						
							save `bart_epoch', replace
						
						**MART
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  mart!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date stage epoch)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' m_`var'
								}
							save `mart1_epoch', replace 
							collapse m_* , by(study id night cond_grp channel date stage)
							save `mart1', replace 
						
						*Has Arousals	
						if `arpresent' != 0 {						
							use `output', clear
								collapse `band1'-`band`num'' totdelta rel* if  mart!=1 & arousal==1 & `timevar' <= `timelimit', by(study id night cond_grp channel date epoch)
									foreach var of varlist `band1'-`band`num'' totdelta rel* {
										rename `var' m_`var'
									}
								gen stage=9
								save `mart2_epoch', replace 
								collapse m_* , by(study id night cond_grp channel date)
								save `mart2', replace 
						}
						
							**Aggregare MART
							use `mart1', clear
							capture append using `mart2'
						
							save `mart', replace
						
							**Aggregare MART Epoch
							use `mart1_epoch', clear
							capture append using `mart2_epoch'
						
							save `mart_epoch', replace
						
						
						**Arousal
						use `output', clear
							collapse `band1'-`band`num'' totdelta rel* if  arousal!=1 & stage!=. & `timevar' <= `timelimit', by(study id night cond_grp channel date epoch stage)
								foreach var of varlist `band1'-`band`num'' totdelta rel* {
									rename `var' a_`var'
								}
							save `arousal_epoch', replace 					
							collapse a_*, by(study id night cond_grp channel date stage)
							save `arousal', replace 
					}
				
				
				
				*Combine and Outsheet Stage (Overall)
					use `raw', clear
					joinby study id night cond_grp channel date stage using `bart'
					joinby study id night cond_grp channel date stage using `mart'
					joinby study id night cond_grp channel date stage using `arousal', unmatched(both)
						drop _merge
									
					order study id night cond_grp channel date stage bart mart arousal
					foreach var of varlist *rel* bart mart arousal {
						replace `var'=`var'*100
					}
					foreach var in bart mart arousal {
						replace `var'=round(`var', 0.01)
						rename `var' per`var'
					}
					
					**Calculate Relative Frequency Differently
					if "`relaltcalc'" != "" {
							drop *rel*
							drop *totdelta
							foreach x in r b m a {
								egen `x'_total=rowtotal(`x'_*)
								capture egen `x'_totdelta=rowtotal(`x'_delta*)
								capture gen `x'_totdelta=.
							
								foreach var of varlist `x'_* {
									gen rel_`var'=(`var'/`x'_total)*100
								}	
							}
					order study id night cond_grp channel date stage perbart permart perarousal r_* rel_r_* b_* rel_b_* m_* rel_m_* a_* rel_a_*		
					}
							capture drop *total
							capture drop row
							
					
					tempfile stage
					save `stage', replace 
					
					outsheet using `id'_stage_`timevar'`timenum'.txt, replace 
					
					
				*Combine and Outsheet Stage (BY Epoch)
					use `raw_epoch', clear
					joinby study id night cond_grp channel date epoch stage using `bart_epoch'
					joinby study id night cond_grp channel date epoch stage using `mart_epoch'
					joinby study id night cond_grp channel date epoch stage using `arousal_epoch', unmatched(both)
						drop _merge
									
					order study id night cond_grp channel date epoch stage bart mart arousal
					foreach var of varlist *rel* bart mart arousal {
						replace `var'=`var'*100
					}
					foreach var in bart mart arousal {
						replace `var'=round(`var', 0.01)
						rename `var' per`var'
					}
					
					**Calculate Relative Frequency Differently
					if "`relaltcalc'" != "" {
							drop *rel*
							drop *totdelta
							foreach x in r b m a {
								egen `x'_total=rowtotal(`x'_*)
								capture egen `x'_totdelta=rowtotal(`x'_delta*)
								capture gen `x'_totdelta=.
							
								foreach var of varlist `x'_* {
									gen rel_`var'=(`var'/`x'_total)*100
								}	
							}
					order study id night cond_grp channel date epoch stage perbart permart perarousal r_* rel_r_* b_* rel_b_* m_* rel_m_* a_* rel_a_*		
					}
							capture drop *total
							capture drop row
							
					
					tempfile stage_epoch
					save `stage_epoch', replace 
					
					outsheet using `id'_stageEpoch_`timevar'`timenum'.txt, replace 	
					
				
				*Add to Overall Stage Data
				use `outputstage', clear
					append using `stage'
				save `outputstage', replace 	
				
				*Add to Overall Stage Data by EPOCH
				use `outputstage_epoch', clear
					append using `stage_epoch'
				save `outputstage_epoch', replace 
			
			
			***********************************************************************				
			***********************************************************************				
			***********************************************************************				
			*Cycle Data
				tempfile nremraw remraw nrembart rembart  nremmart remmart raw  bart mart remarousal nremarousal arousal_epoch nremraw_epoch remraw_epoch nrembart_epoch rembart_epoch _epoch nremmart_epoch remmart_epoch raw_epoch _epoch bart_epoch mart_epoch remarousal_epoch nremarousal_epoch arousal_epoch
			
			if `nremcy' != .  {
			
				****NREM Raw Efficiency
				use `output', clear
					recode rem (. 2 0 =0) (1=1), gen(efficiency)
					collapse efficiency if `timevar' <= `timelimit'  , by(study id night cond_grp channel date nremcycle epoch)
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle				
					tempfile efficiency_epoch
					save `efficiency_epoch', replace 
					
					collapse efficiency, by(study id night cond_grp channel date cycle)
					tempfile efficiency
					save `efficiency', replace 
				
				**Epoch NREM Raw
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* bart mart arousal if `timevar' <= `timelimit' & rem==1 , by(study id night cond_grp channel date nremcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' r_`var'
						}
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle
					joinby study id night cond_grp channel date	epoch cycle using `efficiency_epoch'
					save `nremraw_epoch', replace 
				
				**NREM Raw
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* bart mart arousal if `timevar' <= `timelimit' & rem==1 , by(study id night cond_grp channel date nremcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' r_`var'
						}
					collapse r_* bart mart arousal, by(study id night cond_grp channel date nremcycle)
					
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle
					joinby study id night cond_grp channel date cycle using `efficiency'
					save `nremraw', replace 	
			}
				
			if `remcy' != .  {	
				****REM Raw Efficiency
				use `output', clear
					recode rem (. 1 0 =0) (2=1), gen(efficiency)
					collapse efficiency if `timevar' <= `timelimit' , by(study id night cond_grp channel date remcycle epoch)
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle
					tempfile efficiency_epoch
					save `efficiency_epoch', replace 
					
					collapse efficiency, by(study id night cond_grp channel date cycle)
					tempfile efficiency
					save `efficiency', replace 
				
				****Epoch REM Raw
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* bart mart arousal  if   `timevar' <= `timelimit' & rem==2 , by(study id night cond_grp channel date remcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' r_`var'
						}
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle
					joinby study id night cond_grp channel date	cycle epoch using `efficiency_epoch'
					save `remraw_epoch', replace 
				
				****REM Raw
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* bart mart arousal  if   `timevar' <= `timelimit' & rem==2 , by(study id night cond_grp channel date remcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' r_`var'
						}
					collapse r_* bart mart arousal, by(study id night cond_grp channel date remcycle)
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle
					joinby study id night cond_grp channel date	cycle using `efficiency'
					save `remraw', replace 
			}
				
				
		if `nremcy' != . & `remcy' != .  {
				***AGGREGATE Raw
				use `remraw', clear
				append using `nremraw'
				
				save `raw', replace
				
				***AGGREGATE Epoch Raw
				use `remraw_epoch', clear
				append using `nremraw_epoch'
				
				save `raw_epoch', replace
		}		
		if `nremcy' != . & `remcy' == .  {
				***AGGREGATE Raw
				use `nremraw', clear
				
				save `raw', replace
				
				***AGGREGATE Epoch Raw
				use `nremraw_epoch', clear
				
				save `raw_epoch', replace
		}		
		if `nremcy' == . & `remcy' != .  {
				***AGGREGATE Raw
				use `remraw', clear
				
				save `raw', replace
				
				***AGGREGATE Epoch Raw
				use `remraw_epoch', clear
				
				save `raw_epoch', replace
		}			
		if `nremcy' == . & `remcy' == .  {
		}
		
				****NREM BART
			if `nremcy' != .  {	
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==1  & bart!=1 , by(study id night cond_grp channel date nremcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' b_`var'
						}
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle
					save `nrembart_epoch', replace 
					collapse b_*, by(study id night cond_grp channel date cycle)
					save `nrembart', replace 
			}
				
			
			
				****REM BART
			if `remcy' != .  {		
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==2 & bart!=1 , by(study id night cond_grp channel date remcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' b_`var'
						}
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle
					save `rembart_epoch', replace
					collapse b_*, by(study id night cond_grp channel date cycle)
					save `rembart', replace 
			}
			
			if `remcy' != . & `nremcy' != .  {		
				***AGGREGATE BART
				use `rembart', clear
				append using `nrembart'
				
				save `bart', replace				
				
				***AGGREGATE Epoch BART
				use `rembart_epoch', clear
				append using `nrembart_epoch'
				
				save `bart_epoch', replace
			}
			if `remcy' != . & `nremcy' == .{		
				***AGGREGATE BART
				use `rembart', clear
				
				save `bart', replace				
				
				***AGGREGATE Epoch BART
				use `rembart_epoch', clear
				
				save `bart_epoch', replace
			}	
			if `remcy' == . & `nremcy' != .{		
				***AGGREGATE BART
				use `nrembart', clear
				
				save `bart', replace				
				
				***AGGREGATE Epoch BART
				use `nrembart_epoch', clear
				
				save `bart_epoch', replace
			}	
			if `nremcy' == . & `remcy' == .  {
			}
				
				****NREM MART
			if `nremcy' != .{
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==1  & mart!=1 , by(study id night cond_grp channel date nremcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' m_`var'
						}
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle
					save `nremmart_epoch', replace 
					collapse m_*,  by(study id night cond_grp channel date cycle)
					save `nremmart', replace 
			}
				
				****REM MART
			if `remcy' != .{
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==2 & mart!=1 , by(study id night cond_grp channel date remcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' m_`var'
						}
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle
					save `remmart_epoch', replace 
					collapse m_*,  by(study id night cond_grp channel date cycle)
					save `remmart', replace 
			}
				
			if `nremcy' != . & `remcy' != .{
				***AGGREGATE MART
				use `remmart', clear
				append using `nremmart'
				
				save `mart', replace			
					
				***AGGREGATE Epoch MART
				use `remmart_epoch', clear
				append using `nremmart_epoch'
				
				save `mart_epoch', replace
			}
			if `nremcy' == . & `remcy' != .{
				***AGGREGATE MART
				use `remmart', clear
				
				save `mart', replace			
					
				***AGGREGATE Epoch MART
				use `remmart_epoch', clear
				
				save `mart_epoch', replace
			}
			if `nremcy' != . & `remcy' == .{
				***AGGREGATE MART
				use `nremmart', clear
				
				save `mart', replace			
					
				***AGGREGATE Epoch MART
				use `nremmart_epoch', clear
				
				save `mart_epoch', replace
			}	
			if `nremcy' == . & `remcy' == .  {
			}
			
			
				****NREM Arosual
			if `nremcy' != . {
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==1  & arousal!=1 , by(study id night cond_grp channel date nremcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' a_`var'
						}
					tostring nremcycle, force format(%9.0g) replace 	
					gen cycle="NREM" +	nremcycle
						drop nremcycle
					save `nremarousal_epoch', replace 
					collapse a_*, by(study id night cond_grp channel date cycle)
					save `nremarousal', replace 
			}		
				
				****REM Arosual
			if `remcy' != . {	
				use `output', clear
					collapse `band1'-`band`num'' totdelta rel* if  `timevar' <= `timelimit' & rem==2 & arousal!=1 , by(study id night cond_grp channel date remcycle epoch)
						foreach var of varlist `band1'-`band`num'' totdelta rel* {
							rename `var' a_`var'
						}
					tostring remcycle, force format(%9.0g) replace 	
					gen cycle="REM" +	remcycle
						drop remcycle
					save `remarousal_epoch', replace 
					collapse a_*, by(study id night cond_grp channel date cycle)
					save `remarousal', replace 
			}	
				
			if `nremcy' != . & `remcy' != . {	
				***AGGREGATE AROUSAL
				use `remarousal', clear
				append using `nremarousal'
				
				save `arousal', replace		
					
				***AGGREGATE Epoch AROUSAL
				use `remarousal_epoch', clear
				append using `nremarousal_epoch'
				
				save `arousal_epoch', replace			
			}	
			if `nremcy' == . & `remcy' != . {	
				***AGGREGATE AROUSAL
				use `remarousal', clear
				
				save `arousal', replace		
					
				***AGGREGATE Epoch AROUSAL
				use `remarousal_epoch', clear
				
				save `arousal_epoch', replace			
			}	
			if `nremcy' != . & `remcy' == . {	
				***AGGREGATE AROUSAL
				use `nremarousal', clear
				
				save `arousal', replace		
					
				***AGGREGATE Epoch AROUSAL
				use `nremarousal_epoch', clear
				
				save `arousal_epoch', replace			
			}	
			if `nremcy' == . & `remcy' == .  {
			}
			
			
			if `nremcy' != . | `remcy' != .  {
				*Combine and Outsheet Cycle (Overall)
				use `raw', clear
				joinby study id night cond_grp channel date cycle using `bart'
				joinby study id night cond_grp channel date cycle using `mart'
				joinby study id night cond_grp channel date cycle using `arousal'

				order study id night cond_grp channel date cycle efficiency bart mart arousal
				foreach var of varlist *rel* bart mart arousal efficiency {
					replace `var'=`var'*100
				}
				
				foreach var in efficiency bart mart arousal {
					replace `var'=round(`var', 0.01)
					rename `var' per`var'
				}
				
				drop if cycle=="REM." | cycle=="NREM."
				
				if "`relaltcalc'" != "" {
						drop *rel*
						drop *totdelta
						foreach x in r b m a {
							egen `x'_total=rowtotal(`x'_*)
							capture egen `x'_totdelta=rowtotal(`x'_delta*)
							capture gen `x'_totdelta=.
						
						
							foreach var of varlist `x'_* {
								gen rel_`var'=(`var'/`x'_total)*100
							}	
						}
				order study id night cond_grp channel date cycle perefficiency perbart permart perarousal r_* rel_r_* b_* rel_b_* m_* rel_m_* a_* rel_a_*		
				}
						capture drop *total
						capture drop row
				
				sort study id night cond_grp channel date cycle
					
				tempfile cycle
				save `cycle', replace 	
				
	
				outsheet using `id'_cycle_`timevar'`timenum'.txt, replace 
	
				
				*Combine and Outsheet Cycle (Epoch)
				use `raw_epoch', clear
				joinby study id night cond_grp channel date epoch cycle using `bart_epoch'
				joinby study id night cond_grp channel date epoch cycle using `mart_epoch'
				joinby study id night cond_grp channel date epoch cycle using `arousal_epoch'

				order study id night cond_grp channel date epoch cycle efficiency bart mart arousal
				foreach var of varlist *rel* bart mart arousal efficiency {
					replace `var'=`var'*100
				}
				
				foreach var in efficiency bart mart arousal {
					replace `var'=round(`var', 0.01)
					rename `var' per`var'
				}
				
				drop if cycle=="REM." | cycle=="NREM."
				
				if "`relaltcalc'" != "" {
						drop *rel*
						drop *totdelta
						foreach x in r b m a {
							egen `x'_total=rowtotal(`x'_*)
							capture egen `x'_totdelta=rowtotal(`x'_delta*)
							capture gen `x'_totdelta=.
						
						
							foreach var of varlist `x'_* {
								gen rel_`var'=(`var'/`x'_total)*100
							}	
						}
				order study id night cond_grp channel date epoch cycle perefficiency perbart permart perarousal r_* rel_r_* b_* rel_b_* m_* rel_m_* a_* rel_a_*		
				}
						capture drop *total
						capture drop row
				
				sort study id night cond_grp channel date epoch  cycle
					
				tempfile cycle_epoch
				save `cycle_epoch', replace 	
					
	
				outsheet using `id'_cycleEpoch_`timevar'`timenum'.txt, replace 

				
				
				*Add to Overall Cycle Data
				use `outputcycle', clear
					append using `cycle'
				save `outputcycle', replace 
				
				
				*Add to Overall Cycle Data (Epoch)
				use `outputcycle_epoch', clear
					append using `cycle_epoch'
				save `outputcycle_epoch', replace 				
		} /*if `nremcy' == . | `remcy' == .  {	Process forward if there is cycle data*/
	}/*avgslpepoch!=""*/	
	*		
}/*FOLDER LOOP*/
*

***Export Entire Study Results
cd "`workdir'"

	*Export Overall Cycle
	use `outputcycle', clear
		drop if id==""
	outsheet using `study'_cycle_`timevar'`timenum'.txt, replace 

	*Export Overall Stage
	use `outputstage', clear
		drop if id==""
	outsheet using `study'_stage_`timevar'`timenum'.txt, replace 
	

	
	
cd "`currdir'"
noi :dis "End Time: $S_TIME"

}
*

end
exit
