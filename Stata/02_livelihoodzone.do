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
log using "$pathlog/02_livelihoodzone.log", replace

* Save unmatched data as a .dta for merging later on
	
	* Check if FTF ZOI join exists, if not then download it
	cd $pathout
	local req_file MZGE61FL_FTFZOI_flagged 
		foreach x of local req_file {
			capture findfile `x'.txt
				if _rc == 601 {
				copy https://raw.githubusercontent.com/tessam30/Mozambique/master/tmpData/MZGE61FL_FTFZOI_flagged.txt/*
				*/ $pathout/MZGE61FL_FTFZOI_flagged.txt, replace 
								}
			else disp in yellow "`x' already exists in directory"
		}
		*end
	* Import the fews file	
	import delimited using "$pathout/MZGE61FL_FTFZOI_flagged.txt", clear
	save "$pathout/MZGE61FL_FTFZOI_flagged.dta", replace
		
	import delimited using "$pathout/MZGE61FL_FEWSnet_livelihoods.txt", clear
	
* Merge in FTF flags
	merge 1:1 dhsclust using "$pathout/MZGE61FL_FTFZOI_flagged", gen(_FTFflag)
	recode _FTFflag (1 = 0 "Not in FTF ZOI")(3 = 1 "In FTF ZOI"), gen(ftf_flag)
	drop _FTFflag
	save "$pathout/MZGE61FL_FEWSnet_livelihoods.dta", replace

* Add in the remaining 2015 DHS data
	merge 1:m dhsclust using "$pathout/DHS_hhvar.dta", gen(_lvd)

	saveold "$pathout/MZB_DHS_Livelihoods.dta", replace
	
	keep latnum longnum improvedSanit improvedWater wealth tlutotal dirtfloor handwashObs ftf_flag
	export delimited "$pathexport/MZB_DHS_krigingHH.txt", replace	

log close
