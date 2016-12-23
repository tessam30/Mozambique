*! version 14.1  23dec2016
*Tim Essam, USAID GeoCenter (via Nick Cox)
program define copylabels
  foreach v of var * {
          local l`v' : variable label `v'
              if `"`l`v''"' == "" {
              local l`v' "`v'"
          }
  }
end
