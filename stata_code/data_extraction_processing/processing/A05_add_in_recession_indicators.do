/* code to construct/merge the annual fish condition data */
version 15.1



cap drop monthly
gen monthly =ym(year, month)

merge m:1 monthly using $recession, keep(1 3)
drop _merge
cap drop monthly
