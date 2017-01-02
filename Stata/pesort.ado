*! version 14.1  23dec2016
*Tim Essam, USAID GeoCenter 
* requires coefplot

capture program drop pesort
program pesort, properties(svyb svyj svyr mi)
         version 13.1
          
		 *syntax varlist [if] [in] 
		 *marksample touse
		 
		 tempname smean plot
		 /* Program takes two inputs, the variable to be estimated
			and a dimension variable over which the results are sorted
			TODO: Update to Stata syntax and add flexibility to incorporate
			more variables.			
			*/

		_svy_summarize mean `0'
		di "`e(wexp)' `e(wtype)'"
		*svy:mean `1'  if `touse', over(`2')
		matrix plot = r(table)'
		matsort plot 1 "down"
		matrix plot = plot'
		
		*Calculate the overall mean for the group
		mean `1' [`e(wtype)' `e(wexp)']
		matrix smean = r(table)
		local varmean = smean[1,1]
		local lb = smean[5, 1]
		local ub = smean[6, 1]
		
		* create a sorted plot		
		coefplot (matrix(plot[1,])), ci((plot[5,] plot[6,])) xline(`varmean' `lb' `ub')
		
		end
