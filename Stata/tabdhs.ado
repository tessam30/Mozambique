*! version 14.1  23dec2016
*Tim Essam, USAID GeoCenter 
* Tab DHS variables twice, once w/ labels once w/out
capture program drop tabdhs
program define tabdhs
	tab `1' `2', mi
	tab `1' `2', mi nol
	local upname = upper("`1'")
	local upname2 = upper("`2'")
	label list `upname' `upname2'
end
	