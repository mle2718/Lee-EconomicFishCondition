
/*
Code to examine the lengths distribution of various market categories of fish.
*/


#delimit;
version 15.1;
pause on;

timer on 1;

local in_data ${data_raw}/raw_dealer_length_${vintage_string}.dta ;

local marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;

clear;
use `in_data' , clear;
cap drop _merge;
merge m:1 nespp4 using `marketcats', keep(1 3);
drop if nespp4<5090;
drop if nespp4>=5099;
/* there some 5099 market category in 2008 */;
assert _merge==3;

drop _merge;
labmask nespp4, value(mktnm);

drop if year>=2020;

gen period=1;
replace period=2 if year>=2004;
replace period=3 if year>=2012;

collapse (sum) numlen, by(nespp4 length period);

gen nespp3=floor(nespp4/10);
bysort nespp4 period: egen tt=total(numlen);
gen pdf=numlen/tt;

preserve;
keep if period==1;
tsset nespp4 length;
xtline pdf if length<=200, overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("silver hake length by market category") subtitle("1994-2003");
graph export ${silverhake_images}/dealer_lengths_before2003_${vintage_string}.png, replace as(png);


xtline pdf if length<=200 & inlist(nespp4,5090, 5091, 5092), overlay  ttitle("") tscale(noline) tlabel(none)  ytitle("fraction") legend(off) name(sub1994,replace);




restore;




preserve;
keep if period==2;
tsset nespp4 length;
xtline pdf if length<=200,  overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("silver hake length by market category") subtitle("2004-2011");
graph export ${silverhake_images}/dealer_lengths2004_2011_${vintage_string}.png, replace as(png);

xtline pdf if length<=200 & inlist(nespp4,5090, 5091, 5092), overlay ttitle("") ytitle("fraction") tscale(noline) tlabel(none)   legend(off) name(sub2004,replace);

restore;




preserve;
keep if period==3;
tsset nespp4 length;
xtline pdf if length<=200,  overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("silver hake length by market category") subtitle("2012-2019");
graph export ${silverhake_images}/dealer_length2012_${vintage_string}.png, replace as(png);


xtline pdf if length<=200 & inlist(nespp4,5090, 5091, 5092), overlay ttitle("cm") ytitle("fraction") tmtick(##4) legend(rows(1)) name(sub2012,replace);


restore;

graph combine sub1994 sub2004 sub2012, cols(1) xcommon ycommon imargin(zero);
graph export ${silverhake_images}/dealer_lengths_subset_stack_${vintage_string}.png, replace as(png);
