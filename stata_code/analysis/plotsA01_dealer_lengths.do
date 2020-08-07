
/*
Code to examine the lengths distribution of various market categories of fish.
*/


#delimit;
version 15.1;
pause off;

timer on 1;

global oracle_cxn " $mysole_conn lower";
local in_data ${data_raw}/raw_dealer_length_${vintage_string}.dta ;

clear;
use `in_data', clear;

/* this labeling by hand is a big hack and should be done by merging in the market category codes instead */
label define marketcats 5090 "Round" 5091 "King" 5092 "Small" 5093 "Dressed" 5094 "Juvenile" 5095 "Large" 5096 "Medium", replace;
label define marketcats 1470 "Large" 1471 "Extra Large" 1472 "Medium" 1473 "Market" 1474 "Roe" 1475 "Scrod" 1477 "Snapper" 1476 "Unc Round" 1479 "Unc", modify;
label define marketcats 1483 "Terminal Gutted" 1484 "Undersize Gutted" 1485 "Term Under Mix Gutted" 4856 "Terminal" 1487 "Undersize" 1488 "Term Under Mix", modify;
label define marketcats 0120 "Tails" 0121 "Large Tails" 0122 "Small Tails"  0123 "Livers" 0124 "Unc Round" 0126 "Peewee Tails" 0127 "Belly Flaps " 0128 "Head on Gutted" 0129 "Dressed",modify;

label values nespp4 marketcats;
drop if year>=2020;

gen period=1;
replace period=2 if year>=2011;
collapse (sum) numlen, by(nespp4 length period);

gen nespp3=floor(nespp4/10);
bysort nespp4 period: egen tt=total(numlen);
gen pdf=numlen/tt;

preserve;
keep if nespp3==509 & period==1;
tsset nespp4 length;
xtline pdf, overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("silver hake length by market category") subtitle("2005-2010");
graph export ${my_images}/silver_hake_length2005_2010.png, replace as(png);

restore;




preserve;
keep if nespp3==509 & period==2;
tsset nespp4 length;
xtline pdf, overlay legend(rows(2)) ttitle("cm") ytitle("fraction") tmtick(##4) title("silver hake length by market category") subtitle("2011-2019");
graph export ${my_images}/silver_hake_length2011_2019.png, replace as(png);


restore;


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
