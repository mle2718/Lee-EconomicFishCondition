/* code to merge in fish condition data  */




version 15.1
pause off

timer on 1

/* files for Relative condition data, which one are you using?*/



merge m:1 nespp3 year using $in_relcond, keep(1 3)
assert _merge==3
drop _merge



