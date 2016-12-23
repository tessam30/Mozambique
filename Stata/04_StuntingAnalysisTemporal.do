/*-------------------------------------------------------------------------------
# Name:		04_StuntingAnalysisTemporal
# Purpose:	Compare stunting results over time
# Author:	Tim Essam, Ph.D.
# Created:	2016/08/01
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/


clear
capture log close
log using "$pathlog/04_StuntingAnalysisTemporal.txt", replace

use "$pathout/DHS_2015_Stunting.dta", clear
ren district district2015
append using "$pathout\DHS_2010_Stunting.dta"

* Fix up districts
* 2010 district labels - 
label list shdistr

#delimit ;
recode district (1 =11 "Nyarugenge")
(2 =12 "Gasabo")
(3 =13 "Kicukiro")
(4 =21 "Nyanza")
(5 =22 "Gisagara")
(6 =23 "Nyaruguru")
(7 =24 "Huye")
(8 =25 "Nyamagabe")
(9 =26 "Ruhango")
(10 =27 "Muhanga")
(11 =28 "Kamonyi")
(12 =31 "Karongi")
(13 =32 "Rutsiro")
(14 =33 "Rubavu")
(15 =34 "Nyabihu")
(16 =35 "Ngororero")
(17 =36 "Rusizi")
(18 =37 "Nyamasheke")
(19 =41 "Rulindo")
(20 =42 "Gakenke")
(21 =43 "Musanze")
(22 =44 "Burera")
(23 =45 "Gicumbi")
(24 =51 "Rwamagana")
(25 =52 "Nyagatare")
(26 =53 "Gatsibo")
(27 =54 "Kayonza")
(28 =55 "Kirehe")
(29 =56 "Ngoma")
(30 =57 "Bugesera"), gen(district2010);
#delimit cr

drop district
g district = .
replace district = district2010 if year == 2010
replace district = district2015 if year == 2014
la val district SHDISTRI

* 2015 district labels
label list SHDISTRI

* Check data overtime by district/livelihood zone
foreach x of varlist stunting2 stunted2 extstunted2 improvedSanit {
	egen `x'_dist2010 = mean(`x') if year == 2010, by(district)
	egen `x'_dist2015 = mean(`x') if year == 2014, by(district)
	egen `x'_lvd2010 = mean(`x') if year == 2010, by(lvdzone)
	egen `x'_lvd2015 = mean(`x') if year == 2014, by(lvdzone)
}
*end

mean stunted2 if year == 2010 [aw=cweight] 
mean stunted2 if year == 2014 [aw=cweight] 

graph dot (mean) stunted2_dist2010 stunted2_dist2015, over(district, sort(2))
graph dot (mean) stunted2_lvd2010 stunted2_lvd2015, over(lvdzone, sort(2))
graph dot (mean) improvedSanit_lvd2010 improvedSanit_lvd2015, over(lvdzone, sort(2))

* Run regressions pooled and separately
* Create groups for covariates as they map into conceptual framework for stunting
global matchar "motherBWeight motherBMI motherEd femhead orsKnowledge"
global hhchar "wealth improvedSanit improvedWater bnetITNuse landless"
global hhchar2 "mobile bankAcount improvedSanit improvedWater bnetITNuse"
global hhag "tlutotal"
global hhag2 "cowtrad goat sheep chicken pig rabbit cowmilk cowbull"
global demog "hhsize agehead hhchildUnd5"
global chldchar "ageChild agechildsq birthOrder birthWgt"
global chldchar2 "birthOrder birthWgt"
global chealth "intParasites vitaminA diarrhea anemia"
global geog "altitude2 rural"
global geog2 "altitude2 ib(1).lvdzone "
global cluster "cluster(dhsclust)"
global cluster2 "cluster(hhgroup)"

* STOP: Check all globals for missing values!
sum $matchar $hhchar $hhag $demog female $chldchar $chealth

* Be continuous versus binary
est clear
eststo sted1_0: reg stunting2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog ib(1333).intdate if year == 2010, $cluster 
eststo sted1_1: reg stunting2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog ib(1381).intdate if year == 2014, $cluster 
eststo sted1_2: reg stunting2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog2 ib(1333).intdate if year == 2010, $cluster 
eststo sted1_3: reg stunting2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog2 ib(1381).intdate if year == 2014, $cluster 
eststo sted2_4: logit stunted2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog ib(1333).intdate if year == 2010, $cluster or 
eststo sted2_5: logit stunted2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog ib(1381).intdate if year == 2014, $cluster or 
eststo sted2_6: logit stunted2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog2 ib(1333).intdate if year == 2010, $cluster or
eststo sted2_7: logit stunted2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog2 ib(1381).intdate if year == 2014, $cluster or
eststo sted2_8: logit extstunted2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog ib(1333).intdate if year == 2010, $cluster or 
eststo sted2_9: logit extstunted2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog ib(1381).intdate if year == 2014, $cluster or 
eststo sted2_10: logit extstunted2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog2 ib(1333).intdate if year == 2010, $cluster or 
eststo sted2_11: logit extstunted2 $matchar $hhchar $hhag2 $demog female $chldchar $chealth $geog2 ib(1381).intdate if year == 2014, $cluster or 
esttab sted*, se star(* 0.10 ** 0.05 *** 0.01) label ar2 pr2 beta not /*eform(0 0 1 1 1)*/ compress
* export results to .csv
esttab sted* using "$pathout/`x'WideAll.csv", wide mlabels(none) ar2 pr2 beta label replace not
est clear

eststo sted1_3: reg stunting2 $matchar $hhchar $hhag $demog female $chldchar $chealth $geog2 ib(1381).intdate, $cluster 
eststo sted1_4: reg stunting2 $matchar $hhchar $hhag $demog female $chldchar2 $chealth $geog2 ib(1381).intdate, $cluster 
esttab sted*, se star(* 0.10 ** 0.05 *** 0.01) label ar2  beta  /*eform(0 0 1 1 1)*/ compress

* Compare the regions across time 
* Regional variations
est clear
local i = 0
levelsof adm1name, local(levels)
foreach x of local levels {
	forvalues j = 2010(4)2014 {		
		local name =  strtoname("`x'")
		eststo stunt_`name'`j', title("Stunted `x'"): reg stunting2 $matchar $hhchar /*
		*/ $hhag $demog female $chldchar $chealth $geog if adm1name == "`x'" & year == `j', $cluster 
		local i = `++i'
		}
	}
*end
		
esttab stunt_*, se star(* 0.10 ** 0.05 *** 0.01) label ar2 beta
esttab stunt_* using "$pathout/`x'WideAll.csv", append wide mlabels(none) ar2 pr2 beta label not

* Export cuts of data for WVU
preserve
keep latnum longnum $matchar $hhchar /*
	*/ $hhag $demog female $chldchar /*
	*/ $chealth $geog stunting2 stunted2 /*
	*/ extstunted2 eligChild dhscc dhsyear dhsclust year  
export delimited "$pathexport/RWA_2010_stunting.csv" if year == 2010 & eligChild == 1
export delimited "$pathexport/RWA_2014_stunting.csv" if year == 2014 & eligChild == 1
restore
bob


* Look at changing improved sanitation rates over time
mean improvedSanit [aw = hhweight] if year == 2010, over(district)
 	matrix plot = r(table)'
	matsort plot 1 "down"
	matrix plot = plot'
mean improvedSanit [aw = hhweight] if year == 2014, over(district)
 	matrix plot2 = r(table)'
	matsort plot2 1 "down"
	matrix plot2 = plot2'	
	coefplot (matrix(plot2[1,]), ci((plot2[5,] plot2[6,])))(matrix(plot[1,]), ci((plot[5,] plot[6,])))
	
	
	coefplot (matrix(plot[1,])), ci((plot[5,] plot[6,])) xline(`varmean')
