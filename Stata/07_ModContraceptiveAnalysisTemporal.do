/*-------------------------------------------------------------------------------
# Name:		07_ModContraceptiveAnalysisTemporal.do
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

use "$pathout/MCU_DHS2014.dta", clear
ren district district2015
append using "$pathout\MCU_DHS2010.dta"

replace year = 2010 if year == 2011
replace year = 2014 if year == 2015

* Fix up districts
* 2010 district labels - 
label list shdistr SDISTRIC

#delimit ;
recode district (1 = 11 "Nyarugenge")
(2 = 12 "Gasabo")
(3 = 13 "Kicukiro")
(4 = 21 "Nyanza")
(5 = 22 "Gisagara")
(6 = 23 "Nyaruguru")
(7 = 24 "Huye")
(8 = 25 "Nyamagabe")
(9 = 26 "Ruhango")
(10 = 27 "Muhanga")
(11 = 28 "Kamonyi")
(12 = 31 "Karongi")
(13 = 32 "Rutsiro")
(14 = 33 "Rubavu")
(15 = 34 "Nyabihu")
(16 = 35 "Ngororero")
(17 = 36 "Rusizi")
(18 = 37 "Nyamasheke")
(19 = 41 "Rulindo")
(20 = 42 "Gakenke")
(21 = 43 "Musanze")
(22 = 44 "Burera")
(23 = 45 "Gicumbi")
(24 = 51 "Rwamagana")
(25 = 52 "Nyagatare")
(26 = 53 "Gatsibo")
(27 = 54 "Kayonza")
(28 = 55 "Kirehe")
(29 = 56 "Ngoma")
(30 = 57 "Bugesera"), gen(district2010);
#delimit cr

drop district
g district = .
replace district = district2010 if year == 2010
replace district = district2015 if year == 2014
la val district SHDISTRI

* 2015 district labels
label list SHDISTRI

global filter1 "flagContra == 1 [iw = wweight]"

foreach x of varlist religion lvdzone educ {
	mean modernContra if year == 2010 & $filter1, over(`x')
	mean modernContra if year == 2014 & $filter1, over(`x')
}


* Look at occupations over time and how mcu changed from year to year
eststo mcu2010: mean modernContra if year == 2010 & $filter1, over(district)
eststo mcu2014: mean modernContra if year == 2014 & $filter1, over(district)
coefplot mcu2010 mcu2014,  vertical cismooth bycoefs


