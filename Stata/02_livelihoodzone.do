/*-------------------------------------------------------------------------------
# Name:		02_livelihoodzone
# Purpose:	Import and recode livelihoods zone 
# Author:	Tim Essam, Ph.D.
# Created:	2016/08/01
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

clear
capture log close

* Save unmatched data as a .dta for merging later on
	import delimited using "$pathin/DHS2011/MZGE61FL_FEWSnet_livelihoods.txt", clear
	save "$pathout/MZGE61FL_FEWSnet_livelihoods.dta", replace



* Add in the remaining 2015 DHS data
	merge 1:m dhsclust using "$pathout/DHS_hhvar.dta", gen(_lvd)
	saveold "$pathout/RWA_DHS_Livelihoods.dta", replace
