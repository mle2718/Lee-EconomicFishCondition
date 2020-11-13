
/*
Code to examine the lengths distribution of various market categories of fish.
*/


#delimit;
version 15.1;
pause on;

timer on 1;

global oracle_cxn " $mysole_conn lower";
local in_data ${data_raw}/raw_dealer_length_${vintage_string}.dta ;

local marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;

clear;
use `in_data', clear;
cap drop _merge;
merge m:1 nespp4 using `marketcats', keep(1 3);
drop if nespp4==5099;
/* there some 5099 market category in 2008 */;
assert _merge==3;

drop _merge;
labmask nespp4, value(mktnm);

drop if year>=2020;

gen period=1;
replace period=2 if year>=2003;
replace period=3 if year>=2012;

collapse (sum) numlen, by(nespp4 length period);

gen nespp3=floor(nespp4/10);
bysort nespp4 period: egen tt=total(numlen);
gen pdf=numlen/tt;

preserve;
keep if nespp3==509 & period==1;
tsset nespp4 length;
xtline pdf if length<=200, overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("silver hake length by market category") subtitle("1994-2003");
graph export ${my_images}/silver_hake_length_before2003.png, replace as(png);


xtline pdf if length<=200 & inlist(nespp4,5090, 5091, 5092), overlay  ttitle("") tscale(noline) tlabel(none)  ytitle("fraction") legend(off) name(sub1994,replace);




restore;




preserve;
keep if nespp3==509 & period==2;
tsset nespp4 length;
xtline pdf if length<=200,  overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("silver hake length by market category") subtitle("2004-2011");
graph export ${my_images}/silver_hake_length2004_2011.png, replace as(png);

xtline pdf if length<=200 & inlist(nespp4,5090, 5091, 5092), overlay ttitle("") ytitle("fraction") tscale(noline) tlabel(none)   legend(off) name(sub2004,replace);

restore;




preserve;
keep if nespp3==509 & period==3;
tsset nespp4 length;
xtline pdf if length<=200,  overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("silver hake length by market category") subtitle("2012-2019");
graph export ${my_images}/silver_hake_length2012.png, replace as(png);


xtline pdf if length<=200 & inlist(nespp4,5090, 5091, 5092), overlay ttitle("cm") ytitle("fraction") tmtick(##4) legend(rows(1)) name(sub2012,replace);


restore;

graph combine sub1994 sub2004 sub2012, cols(1) xcommon ycommon imargin(zero);
graph export ${my_images}/silver_hake_subset_stack.png, replace as(png);

/*Comment out, I'm just doing silver hake for now.

preserve;
keep if nespp3==12 & period==1;
tsset nespp4 length;
xtline pdf, overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("monkfish length by market category") subtitle("2005-2010");
graph export ${my_images}/monkfish_length2005_2010.png, replace as(png);

restore;



preserve;
keep if nespp3==12 & period==2;
tsset nespp4 length;
xtline pdf, overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("monkfish length by market category") subtitle("2005-2010");
graph export ${my_images}/monkfish_length2011_2019.png, replace as(png);

restore;



preserve;
keep if inlist(nespp3,147,148) & period==1;
tsset nespp4 length;
xtline pdf, overlay legend(rows(1)) ttitle("cm") ytitle("fraction") tmtick(##4) title("haddock length by market category") subtitle("2005-2010");
graph export ${my_images}/haddock_length2005_2010.png, replace as(png);

restore;


preserve;
keep if inlist(nespp3,147,148) & period==2;
tsset nespp4 length;
xtline pdf, overlay legend(rows(1)) ttitle("cm") ytitle("fraction") tmtick(##4) title("haddock length by market category") subtitle("2011-2019");
graph export ${my_images}/haddock_length2011_2019.png, replace as(png);

restore;
*/
