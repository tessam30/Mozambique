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

/* Summary: Currenlty, DHS doesn't have a lot of agroecological or ag assets
	indicators that would be useful in predicting potential FTF households. Not
	sure if the proposed approach of trying to predict FTF and non-FTF hh is feasible
	given the data at hand. Will bounce off mission for feedback */

* Control for non-linear alititude 
	g altitude_sq = altitude^2

* Create a step-wise model to estimate characteristics of hh in ftf ZOI
	* Toilet share knocks out quite a few FTF hh
	sum ftf_flag electricity radio tv refrig bike moto car /*
	*/ mobile cow goat sheep chicken pig altitude rural hhsize hhchildUnd5 /*
	*/toilet toiletShare handwashObs dirtfloor hhrooms roomPC agehead 	/*
	*/ treatwater improvedWater improvedSanit wealth livestock bankAcount /*
	*/ mosqSpray animalCart femhead numWomen15_25 numWomen26_65 


	stepwise , pr(0.2): logit ftf_flag electricity radio tv refrig bike moto car /*
	*/ mobile cow goat sheep chicken pig altitude altitude_sq rural hhsize hhchildUnd5 /*
	*/toilet handwashObs dirtfloor hhrooms roomPC agehead 	/*
	*/ treatwater improvedWater improvedSanit livestock bankAcount /*
	*/ mosqSpray animalCart femhead  numWomen15_25 numWomen26_65 /*
	*/ , cluster(dhsclust) 
	lroc
	linktest
	
	logit ftf_flag electricity radio tv refrig bike moto car /*
	*/ mobile cow goat sheep chicken pig altitude rural hhsize hhchildUnd5 /*
	*/toilet handwashObs dirtfloor hhrooms roomPC agehead 	/*
	*/ treatwater improvedWater improvedSanit livestock bankAcount /*
	*/ mosqSpray animalCart femhead smoker numWomen15_25 numWomen26_65, cluster(dhsclust) 
	predict p_score if e(sample)
	
	

/*
	*/ 	/*
	*/ landowned livestock wealth bankAcount smoker femaleEduc/*
	*/ numWomen15_25 numWomen26_65 distHC
	predict p_treat if e(sample)

	
	sum 
