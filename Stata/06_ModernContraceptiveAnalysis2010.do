/*-------------------------------------------------------------------------------
# Name:		06_ModernContraceptionAnalysis2010
# Purpose:	Create model of modern contraceptive use for 2010 DHS
# Author:	Tim Essam, Ph.D.
# Created:	2016/12/01
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

capture log close
log using "$pathlog/06_ModConAnalysis2010", replace
clear

use "$pathout/contraceptionAnalysis2010.dta"

*ssc install blindschemes, replace all
*set scheme plottig, permanently

* Look at summary statistics and some basic plots
	graph dot (mean) modernContra if flagContra == 1, over(lvdzone, sort(1))
	graph dot (mean) modernContra [pw = wweight] if flagContra == 1, over(district, sort(1))
	graph dot (mean) modernContra [pw = wweight] if flagContra == 1, over(province, sort(1))
	graph dot (mean) modernContra [pw = wweight] if flagContra == 1, over(ageGroup)
	graph dot (mean) modernContra [pw = wweight] if flagContra == 1, over(educYears)
	graph dot (mean) modernContra [pw = wweight] if flagContra == 1, over(religion, sort(1))

* Loop over covariates to see how contraception use varies across different categories
local stats ageGroup educ educSame /*
	*/ fecund parity religion famPlanExp distanceHC /*
	*/ wealthGroup empowerment married residStatus numChildUnd5

	foreach x of local stats {
		mean noContra [iw = wweight] if flagContra == 1, over(`x') 
		}
*end


** Modern Contraceptive use across wealth distribution
	twoway (lpoly modernContra wealth if flagContra == 1  & wealth <= 6 [aweight = wweight]),  /*
	*/ylabel(0.40(0.05)0.55) ysca(alt) xsca(alt) xlabel(, grid gmax) /*
	*/ legend(off) saving(main, replace)
	
	twoway histogram wealth if flagContra == 1 & wealth <= 6 , fraction ysca(alt reverse) ylabel(, nogrid)/*
	*/ fysize(25) xlabel(, grid gmax) saving(hx, replace)
	
	graph combine main.gph hx.gph, hole(2 4) imargin(0 0 0 0) 
	

	twoway (lpoly modernContra ageGap if flagContra == 1 & inrange(ageGap, -20, 10) [aweight = wweight]),  /*
	*/ylabel(0.40(0.05)0.55) ysca(alt) xsca(alt) xlabel(, grid gmax) /*
	*/ legend(off) saving(main, replace)
	
	twoway histogram ageGap if flagContra == 1 & inrange(ageGap, -20, 10), fraction ysca(alt reverse) ylabel(, nogrid)/*
	*/ fysize(25) xlabel(, grid gmax) saving(hx, replace)
	graph combine main.gph hx.gph, hole(2 4) imargin(0 0 0 0) 
	
	*Occupations by wife 
	graph dot (mean) modernContra [pw = wweight] if flagContra == 1, over(occupGroup, sort(1)) saving(occF, replace)
	graph dot (mean) modernContra [pw = wweight] if flagContra == 1, over(occupGroupHus, sort(1)) saving(occM, replace)
	graph combine occF.gph occM.gph, hole(3 4) imargin(0 0 0 0 )
	
* Specify covariates for exploratory regression models
	/* Categorical bases are as follows:
		ib(4).ageGroup 	--> 30-34 cohort
		ib(2).parity 	--> 3-4 Children 
		ib(0).fecund 	--> not fecund
		ib(0).educ 		--> no education
		ib(0).educPartner --> no education
		ib(1).religion --> Catholic
		ib(5).lvdzone --> Central Plateau Cassava and Coffee

	*/

	global demog "ib(4).ageGroup married numChildUnd5 residStatus"
	global health "ib(2).parity ib(0).fecund moreKidsWanted sameNumKids bedNetUse"
	global social "ib(1).religion famPlanRadio famPlanTV famPlanPrint distanceHC"
	global social2 "ib(1).religion famPlanExp empowerment"
	global humcap "ib(0).educ ib(0).educPartner ageGap wealth"
	global comm "dist_distanceHC dist_totChild dist_educYears catholic_dominant protestant_dominant adventist_dominant muslim_dominant"
	global geog2 "altitude2 ib(5).lvdzone"
	global stderr "cluster(dhsclust)"

	* Double check to make sure you don't have 98 or 99 values influencing regression results
	sum $demog $health $social $social2 $humcap $comm $geog2 

	est clear
	eststo mcu_b1: logit modernContra $demog $health ib(1333).intdate if flagContra == 1, $stderr or
	eststo mcu_a1: reg modernContra $demog $health ib(1333).intdate if flagContra == 1, $stderr 
	eststo mcu_b2: logit modernContra $demog $health $social ib(1333).intdate if flagContra == 1, $stderr or
	eststo mcu_a2: reg modernContra $demog $health $social ib(1333).intdate if flagContra == 1, $stderr 
	eststo mcu_b3: logit modernContra $demog $health $social $humcap ib(1333).intdate if flagContra == 1, $stderr or
	eststo mcu_a3: reg modernContra $demog $health $social $humcap ib(1333).intdate if flagContra == 1, $stderr 
	eststo mcu_b4: logit modernContra $demog $health $social $humcap $comm ib(1333).intdate if flagContra == 1, $stderr or
	eststo mcu_a4: reg modernContra $demog $health $social $humcap $comm  ib(1333).intdate if flagContra == 1, $stderr 
	eststo mcu_b5: logit modernContra $demog $health $social $humcap $comm $geog2 ib(1333).intdate if flagContra == 1, $stderr or
	eststo mcu_a5: reg modernContra $demog $health $social $humcap $comm $geog2  ib(1333).intdate if flagContra == 1, $stderr 
	esttab mcu*, se star(* 0.10 ** 0.05 *** 0.01) label ar2 pr2 beta not /*eform(0 0 1 1 1)*/ compress
	esttab mcu_b* using "$pathreg/MCUwideAll_logit2010.csv", wide mlabels(none) ar2 pr2  eform label replace not
	esttab mcu_a* using "$pathreg/MCUwideAll_lpm2010.csv", wide mlabels(none) ar2 pr2  label replace not

	preserve
	# delimit;
		keep modernContra ageGroup married numChildUnd5 residStatus
		parity fecund moreKidsWanted sameNumKids bedNetUse
		religion famPlanRadio famPlanTV famPlanPrint distanceHC
		religion famPlanExp empowerment
		educ educPartner ageGap wealth
		dist_distanceHC dist_totChild dist_educYears catholic_dominant 
		altitude2 lvdzone
		adventist_dominant muslim_dominant
		v000 v001 v002 v003 v005 v008 wweight district altitude 
		strata psu province altitude2 dhsclust intdate longnum 
		latnum flagContra;
	# delimit cr
		keep if flagContra == 1
	
		* Export a .csv for the WVU folks to do spatial analysis on data
		export delimited "$pathexport/RWA_2010DHS_MCU.csv", replace
	restore
	
compress
save "$pathout/MCU_DHS2010.dta", replace


	
