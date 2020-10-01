/*
Syntax

No_arguments

first argument contains the name of the column with stock areas in it.  It must be numeric
Second argument contains the variable name you want to come out.

*/
program silver_hake_bsa
	args areaname output 

	version 15.1
	cap drop `output'
	cap label drop bsas
	gen `output'=0
	replace `output'=1 if inlist(`areaname',511, 512, 513, 514, 515, 521, 522, 561, 551, 465, 464)
	replace `output'=2 if `areaname'>=562 & `areaname'<=640
	replace `output'=2 if inlist(`areaname',538, 539, 525, 526, 537, 541, 542, 543,552)


	label define bsas 0 "unknown" 1 "Northern" 2 "Southern"
	label values `output' bsas
end
