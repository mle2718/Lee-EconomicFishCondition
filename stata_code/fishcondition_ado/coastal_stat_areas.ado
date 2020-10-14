/*
Syntax

first argument contains the name of the column with stock areas in it.  It must be numeric
Second argument contains the variable name you want to come out.

*/

cap program drop coastal_stat_areas

program coastal_stat_areas
	args areaname output 

	version 15.1
	cap drop `output'
	cap label drop coastal
	gen `output'=0
	replace `output'=1 if inlist(`areaname',463,465, 466, 467,511, 512, 513, 514, 521, 537,538, 539,611,612,613,614,615,621,625,631,635)
	replace `output'=1 if `areaname'>0 & `areaname'<=400 

	label define coastal 0 "Stat area does not touch land" 1 "stat area touches land" 
	label values `output' coastal
end
