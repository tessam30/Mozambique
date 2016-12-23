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
	import delimited using "$pathgit/RWA_DHS2015_LivelihoodsUnmatched.csv", clear
	save "$pathout/2015_lvdunmatch.dta", replace

* Import DHS spatial data with health facility information
	import delimited using "$pathout/RWGE71FL_healthfacjoin.csv", clear	
	foreach x of varlist dhsyear alt_gps alt_dem near_fid near_dist near_x near_y {
		destring `x', ignore(",") gen(num_`x')
		}
*end
	rename(num_dhsyear num_alt_dem num_alt_gps num_near_dist)(yearDHS altitude_DEM altitude_GPS dist_nearest_HealthFac)
	save "$pathout/healthFacDist.dta", replace
	
	import delimited using "$pathgit/RWA_DHS2015_Livelihoods.csv", clear
	log using "$pathlog/04_livelihoodzone.txt", replace

* Import unmatched clusters and backfill data
	append using "$pathout\2015_lvdunmatch.dta"

	replace lznamee = "Lake Kivu Coffee" if inlist(dhsclust, 418, 161, 296, 81, 171)
	replace lznamee = "Central Plateau Cassava and Coffee" if inlist(dhsclust, 101, 317)

* Encode the livelihood zone names and match to CSFVA numerical system
	encode lznamee, gen(lvhood_zone2015)

/* These DHS cluster offsets fall outside of livelihood zones or within
	National Park boundaries. We use the nearest livelihood zone (from FEWSNET)
	as the replacement value 
	dhsclust 347 --> Western Congo
	dhsclust 281 --> Western Congo
	dhsclust 199 --> Western Congo */
	
	replace lvhood_zone2015 = 15 if inlist(dhsclust, 281, 347, 199)	
	tab lvhood_zone2015, mi

* Recode zones to match those from FEWS NET
* https://github.com/tessam30/RwandaLAM/blob/master/Datain/LivelihoodZones_FEWS.csv
/*
| FEWS | Livelihood Zone                                             | CSFVA |
|------|-------------------------------------------------------------|-------|
| 14   | Urban Area                                                  | 0     |
| 8    | Lake Kivu Coffee                                            | 1     |
| 15   | Western Congo-Nile Crest Tea                                | 2     |
| 11   | Northwestern Volcanic Irish Potato                          | 3     |
| 5    | Eastern Congo-Nile Highland Subsistence Farming             | 4     |
| 2    | Central Plateau Cassava and Coffee                          | 5     |
| 10   | Northern Highland Beans and Wheat                           | 6     |
| 3    | Central-Northern Highland Irish Potato Beans and Vegetables | 7     |
| 1    | Bugesera Cassava                                            | 8     |
| 6    | Eastern Plateau Mixed Agricultural                          | 9     |
| 13   | Southeastern Plateau Banana                                 | 10    |
| 4    | Eastern Agropastoral                                        | 11    |
| 7    | Eastern Semi-Arid Agropastoral                              | 12    |
| 9    | Mukura Forest Reserve                                       | NA    |
| 12   | Nyungwe Forest National Park                                | NA    |
*/

	#delimit ;
	recode lvhood_zone (14 = 0 "Urban Area")
					   (8 = 1 "Lake Kivu Coffee")
					   (15 = 2 "Western Congo-Nile Crest Tea")
					   (11 = 3 "Northwestern Volcanic Irish Potato")
					   (5 = 4 "Eastern Congo-Nile Highland Subsistence Farming")
					   (2 = 5 "Central Plateau Cassava and Coffee")
					   (10 = 6 "Northern Highland Beans and Wheat")
					   (3 = 7 "Central-Northern Highland Irish Potato, Beans and Vegetables")
					   (1 = 8 "Bugesera Cassava")
					   (6 = 9 "Eastern Plateau Mixed Agricultural")
					   (13 = 10 "Southeastern Plateau Banana")
					   (4 = 11 "Eastern Agropastoral")
					   (7 = 12 "Eastern Semi-Arid Agropastoral"),
					   gen(lvdzone);
	#delimit cr

* Fix lznumbers to align with lvdzone names
	tab lvdzone lznum, mi
	replace lznum = 2 if lznum == 13 & lvdzone == 2	
	replace lznum = 1 if lznum == . & lvdzone == 1
	replace lznum = 5 if lznum == . & lvdzone == 5
	drop lvhood_zone				   
	la var lvdzone "livelihood zones (from FEWSNET)"

* Add in the remaining 2015 DHS data
	merge 1:m dhsclust using "$pathout/DHS_hhvar.dta", gen(_lvd)
	merge m:1 dhsclust using "$pathout/healthFacDist.dta", gen(_hcDist)
	saveold "$pathout/RWA_DHS_Livelihoods.dta", replace

* Import 2010 data and perform similar jooin
	import delimited using "$pathgit/RWA_DHS2010_Livelihoods.csv", clear
	encode lznamee, gen(lvhood_zone2010)

/* These DHS cluster offsets fall outside of livelihood zones or within
	National Park boundaries. We use the nearest livelihood zone (from FEWSNET)
	as the replacement value 
	dhsclust 386 --> Western Congo
	dhsclust 181, 117, 116 --> lake kivu
	*/
	
	replace lvhood_zone2010 = 9 if inlist(dhsclust, 181, 117, 116)
	replace lvhood_zone2010 = 15 if inlist(dhsclust, 386)

/*
| FEWS2010 | LivelihoodZone                                   | CSFVA |
|----------|--------------------------------------------------|-------|
| 14       | Urban Area                                       | 0     |
| 9        | Lake Kivu Coffee                                 | 1     |
| 15       | Western Congo-Nile Crest Tea                     | 2     |
| 11       | Northwestern Volcanic Irish Potato               | 3     |
| 5        | Eastern Congo-Nile Highland Subsistence Farming  | 4     |
| 2        | Central Plateau Cassava and Coffee               | 5     |
| 10       | Northern Highland Beans and Wheat                | 6     |
| 3        | Central-Northern Highland Irish Potato Vegetable | 7     |
| 1        | Bugesera Cassava                                 | 8     |
| 6        | Eastern Plateau Mixed Agricultural               | 9     |
| 13       | Southeastern Plateau Banana                      | 10    |
| 4        | Eastern Agropastoral                             | 11    |
| 7        | Eastern Semi-Arid Agropastoral                   | 12    |
| 8        | Gishwati Forest Reserve                          | NA    |
| 12       | Nyungwe Forest National Park                     | NA    |
*/

	#delimit ;
	recode lvhood_zone2010 (14 = 0 "Urban Area")
					   (9 = 1 "Lake Kivu Coffee")
					   (15 = 2 "Western Congo-Nile Crest Tea")
					   (11 = 3 "Northwestern Volcanic Irish Potato")
					   (5 = 4 "Eastern Congo-Nile Highland Subsistence Farming")
					   (2 = 5 "Central Plateau Cassava and Coffee")
					   (10 = 6 "Northern Highland Beans and Wheat")
					   (3 = 7 "Central-Northern Highland Irish Potato, Beans and Vegetables")
					   (1 = 8 "Bugesera Cassava")
					   (6 = 9 "Eastern Plateau Mixed Agricultural")
					   (13 = 10 "Southeastern Plateau Banana")
					   (4 = 11 "Eastern Agropastoral")
					   (7 = 12 "Eastern Semi-Arid Agropastoral"),
					   gen(lvdzone);
	#delimit cr
	drop lvhood_zone2010				   
	la var lvdzone "livelihood zones (from FEWSNET)"

	tab lvdzone lznum, mi
	replace lznum = 1 if lznum == 13 & lvdzone == 1
	replace lznum = 2 if lznum == 13 & lvdzone == 2

* Add in the remaining 2010 DHS data
	merge 1:m dhsclust using "$pathout/DHS_hhvar2010.dta", gen(_lvd2010)
saveold "$pathout/RWA_DHS2010_Livelihoods.dta", replace

