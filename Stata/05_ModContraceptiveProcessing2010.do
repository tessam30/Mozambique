/*-------------------------------------------------------------------------------
# Name:		05_ModernContraceptionProcessing2010
# Purpose:	Create model of modern contraceptive use
# Author:	Tim Essam, Ph.D.
# Created:	2016/08/01
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

capture log close
log using "$pathlog/05_ModConProcessing2010", replace
clear

* Women are unit of analysis so we will be using the IR file.
	use "$path2010\RWIR61FL.dta"

* Sampling weights and geography variables
	g wweight = v005 / 1000000	
	la var wweight "women's sampling weight"
	clonevar district 	= sdistr 
	clonevar altitude 	= v040
	clonevar strata 	= v022
	clonevar dhsclust 	= v001
	clonevar psu 		= v021
	clonevar province 	= v024
	g altitude2 = altitude/1000
	la var altitude2 "altitude divided by 1000"
	
	
* Clone original DHS variables and simply rename
	clonevar ageGroup 	= v013
	clonevar occupGroup = v717
	clonevar occupGroupHus = v705
	clonevar pregnant 	= v213
	clonevar educ		= v106
	clonevar educDetail = v107
	clonevar educYears	= v133
	clonevar bedNetUse	= v461

* Variables needing a bit of additional processing
* Need to determine categories for this
	clonevar moreChild = v605
	clonevar moreChildHus = v621
	
	g byte curUnion = (v502 == 1)
	g byte nevUnion = (v502 == 0)
	la var curUnion "Current in union/living w/ man"
	la var nevUnion "never in union"
	
	clonevar maritialStatus = v501
	g byte married = maritialStatus == 1
	la var married "married"

	g byte femhead = (v150 == 1)
	la var femhead "female head of household"
	
* Family planning knowledge or outreach
	clonevar visHCtoldFP = v395
	replace visHCtoldFP = . if visHCtoldFP == 9
	clonevar famPlanWorkVisit = v393
	replace famPlanWorkVisit = . if famPlanWorkVisit == 9 

* Family planning via media
	g byte famPlanRadio = inlist(1, v384a)
	la var famPlanRadio "heard family planning on radio in last few months"
	g byte famPlanTV = inlist(1, v384b)
	la var famPlanTV "heard family planning on tv in last few months"
	g byte famPlanPrint = inlist(1, v384c)
	la var famPlanPrint "read family planning in print media in last few months"
	g byte famPlanExp = inlist(1, v384c, v384b, v384a)
	la var famPlanExp "family planning exposure, all forms"

* Recodes to standardize variables and groups *
** Religion
	recode v130 (1 = 1 "Catholic")(2 = 2 "Protestant")(3 = 3 "Adventist")(4 = 4 "Mulsim") /*
	*/  (5 6 96 99 = 5 "Other"), gen(religion)

** Fecund
	recode v623 (0 = 1 "fecund")(1 3 = 0 "not-fecund")(2 = 2 "Breastfeeding"), gen(fecund) 
		
** Urban
	recode v025 (1 = 1 "Urban")(2 = 0 "Rural"), gen(urban)
	recode v467d (1 = 1 "access to health clinic difficult")(2 = 0 "not a problem"), gen(distanceHC)
	replace distanceHC = . if distanceHC == 9

** Residence status
	g byte residStatus = v504 == 1
	la var residStatus "currently residing with partner/husband"

** Fertility preference
	g byte moreKidsWanted = v602 == 1
	la var moreKidsWanted "would like to have another child"
	g byte sameNumKids = (v621 == 1)
	la var sameNumKids "husband and wife would llike same number of kids"

/* Parity parity is defined as the number of times that she has given 
	birth to a fetus with a gestational age of 24 weeks or more, 
	regardless of whether the child was born alive or was stillborn. */
	clonevar totChild = v201
	recode totChild (0 = 0 "no children")(1 2 = 1 "1-2 children")(3 4 = 2 "3-4 children") /*
	*/	(5 / 15 = 3 "5+ children"), gen(parity)
	clonevar totChildWanted = v613

* Household assets
	clonevar wealthGroup = v190
	clonevar wealth = v191
	replace wealth = (wealth / 100000)
	clonevar numChildUnd5 = v137

* Contraception Use
	g byte modernContra = v313 == 3
	la var modernContra "Use modern method of contraception (binary)"
	g byte unmodernContra = inlist(v313, 1, 2)
	la var unmodernContra "Use non-modern methods of contraception"
	g byte noContra = v313 == 0
	la var noContra "Do not use any form of contraception"
	clonevar intentionContra = v364
	recode v361 (1 2 3 = 0 "using or used")(4 = 1 "never used"), gen(contraPattern)

* Sexual activity
	clonevar sexActivity = v536
	g byte sexuallyActive = (sexActivity == 1)
	la var sexuallyActive "recent activity in last 4 weeks"
	
* Human Capital
	recode v701 (0 8 9 = 0 "no education")(1 = 1 "primary")(2 = 2 "secondary")/*
	*/(3 = 3 "higher"), gen(educPartner)
	
	g byte educSame = (educPartner == educ) if !missing(educPartner)
	g educGap = (educ - educPartner) if !missing(educPartner)
	g educGapDetail = v133 - v715 if !missing(v715) & inlist(v715, 98, 99)!=1
	g ageGap = v012 - v730 if (v730 != 99) 
	
	* add some labels to make things readable
	la var educSame "individuals in union have same education levels"
	la var educGap "gap between education levels"
	la var educGapDetail "detailed gap between education levels"
	la var ageGap "age gap between individuals in union"
		
* Occupation types
	g byte occupSame = v705 == v717 if !missing(v705) & inlist(v705, 98, 99)!=1
	g byte agLaborers = inlist(5, v717, v705) & !missing(v705)
	la var occupSame "same occupations"
	la var agLaborers "both are ag laborers"
	
* Women's empowerment in decision-making
	/* women can make decisions:
	1) alone
	2) together with partner
	3) only husband
	4) someone else */
	sum v743*
	g byte decisionHealth	= inlist(v743a, 1, 2) & curUnion == 1
	g byte decisionPurchase	= inlist(v743b, 1, 2) & curUnion == 1
	g byte decisionVisits	= inlist(v743d, 1, 2) & curUnion == 1
	g byte decisionMoney 	= inlist(v743f, 1, 2) & curUnion == 1
	egen empowerment = rowtotal(decisionHealth decisionPurchase  /*
	*/ decisionVisits decisionMoney)
	
	*labelling
	la var decisionHealth "women invovled in health care decisions"
	la var decisionPurchase "women invovled in purchase decisions"
	la var decisionVisits "women involved in family visit decisions"
	la var decisionMoney "women involved in how her earned money is spent"
	la var empowerment "female empowerment scale (0 = not empowered)"
		
* Filter data down to keep on the variables necessary for merging and analysis
	keep wweight - empowerment v000 v001 v002 v003 v005 v008 
			
	/* Community contextual variables per (Stephenson, R. et al. 2007
	"Contextual Influences on Modern Contraceptive Use in Sub-Saharan Africa")*/
	tab religion, gen(religDum)
	
	foreach x of varlist distanceHC totChild educYears religDum1 religDum2 religDum3 religDum4 religDum5 {
		egen dist_`x' = mean(`x'), by(dhsclust)
		}
	*end
	g byte catholic_dominant 	= (dist_religDum1 >= 0.5) & !missing(dist_religDum1)
	g byte protestant_dominant 	= (dist_religDum2 >= 0.5) & !missing(dist_religDum2)
	g byte adventist_dominant	= (dist_religDum3 >= 0.5) & !missing(dist_religDum3)
	g byte muslim_dominant 		= (dist_religDum4 >= 0.5) & !missing(dist_religDum4)
	
	drop religDum* dist_relig*

	* Label variables that were created above; make things readable
	la var dist_distanceHC "difficult to get to health facility - community average"
	la var dist_totChild "average number of children born in community"
	la var dist_educYears "average years of female education in community"
	la var catholic_dominant "catholic faith dominant religion in community"
	la var protestant_dominant "protestant faith dominant religion in community"
	la var adventist_dominant "adventist faith dominant religion in community"
	la var muslim_dominant "muslim faith dominant religion in community"
	
* Combine FEWS Net Livelihood zones
	merge m:1 v001 v002 using "$pathout/RWA_DHS2010_Livelihoods.dta", gen(_fertility)
	drop if _fertility == 2
	
	g byte flagContra = (curUnion == 1)
	la var flagContra "flag for filtering only women in a union"

* Change missing values from 99 to missing
foreach x of varlist occupGroup occupation occupationF occupationM occupGroupHus {
		replace `x' = . if inlist(`x', 98, 99)
		sum `x'
	}
*end

saveold "$pathout/contraceptionAnalysis2010.dta", replace
log close
	
	
