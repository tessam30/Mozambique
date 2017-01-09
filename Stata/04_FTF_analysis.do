/*-------------------------------------------------------------------------------
# Name:		04_FTF_analysis
# Purpose:	Determine key variables associated w/ FTF households
# Author:	Tim Essam, Ph.D.
# Created:	2017/01/09
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

clear
capture log close
use  "$pathout/MZB_DHS_Livelihoods.dta", clear

* Create a step-wise model to estimate characteristics of hh in ftf ZOI

	stepwise , pr(0.2): logit ftf_flag electricity radio tv refrig bike moto car /*
	*/ mobile cow goat sheep chicken pig altitude rural hhsize hhchildUnd5 /*
	*/toilet toiletShare handwashObs dirtfloor hhrooms roomPC agehead 	/*
	*/ treatwater improvedWater improvedSanit wealth livestock bankAcount smoker numWomen15_25 numWomen26_65, cluster(dhsclust) 
	
	

/*
	*/ 	/*
	*/ landowned livestock wealth bankAcount smoker femaleEduc/*
	*/ numWomen15_25 numWomen26_65 distHC
	predict p_treat if e(sample)

	
	sum 
