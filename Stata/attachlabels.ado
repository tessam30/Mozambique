*! version 14.1  23dec2016
*Tim Essam, USAID GeoCenter (via Nick Cox)

program define attachlabels
  foreach v of var * {
          label var `v' "`l`v''"
  }
end
