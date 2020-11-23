/* code to construct/merge the annual fish condition data */




version 15.1
pause off

timer on 1



merge m:1 year month day using $daily, keep(1 3)
drop _merge
