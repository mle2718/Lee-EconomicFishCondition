
/*
Code to plot prices
*/


#delimit;
version 15.1;
pause on;

timer on 1;

local  in_data ${data_main}/dealer_prices_full_${vintage_string}.dta ;
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;
local working_nespp3 509;
local relabelstr `"relabel(1 "J" 2 "F" 3 "M"  4 "A"  5 "M"  6 "J"  7 "J" 8 "A" 9 "S" 10 "O" 11 "N" 12 "D" 13 "J" 14 "F" 15 "M"  16 "A"  17 "M"  18 "J"  19 "J" 20 "A" 21 "S" 22 "O" 23 "N" 24 "D")"' ;

clear;
use `in_data' if inlist(nespp3, `working_nespp3'), clear;
merge m:1 nespp4 using `marketcats', keep(1 3);
assert _merge==3;
labmask nespp4, value(sp_mkt);
drop _merge;

gen price=value/landings;
drop if date==.;

gen priceR_GDPDEF=valueR_GDPDEF/landings;

label var priceR "Real Price per pound";
keep if price<=10;
bysort nespp4: egen mp=mean(price);

egen t=tag(date); 
label var daily_landings "daily landings ('000s)";

/* landings by DOW */
graph box daily_landings if t==1, over(dow) ytitle("Daily Silver Hake landings, 000s lbs");
graph export ${silverhake_images}/box509Q_dow_${vintage_string}.png, replace as(png);


/* landings by month */
graph box daily_landings if t==1, over(month) ytitle("Daily Silver Hake landings, 000s lbs");
graph export ${silverhake_images}/box509Q_month_${vintage_string}.png, replace as(png);


/* landings by week */
gen wofyear=week(date);
graph box daily_landings if t==1, over(wofyear, label(angle(45))) ytitle("Daily  Silver Hake  landings, 000s lbs");
graph export ${silverhake_images}/box509Q_weekly_${vintage_string}.png.png, replace as(png);


/*landings year*/
graph box daily_landings if t==1, over(year, label(angle(45))) ytitle("Daily Silver Hake  landings, 000s lbs");
graph export ${silverhake_images}/box509Q_year_${vintage_string}.png.png, replace as(png);


preserve;
keep if t==1;
cap drop monthly;
gen monthly=mofd(date);
collapse (sum) daily_landings, by(monthly);
rename daily_landings landings;
label var landings "landings ('000s)";

tsset monthly ;
format monthly %tm;
tsline landings, tlabel(#12, format(%tmCCYY) angle(45)) tmtick(##2, grid) ylabel(,nogrid)  title("Monthly  Silver Hake  Landings");
graph export ${silverhake_images}/tsline509_monthly_${vintage_string}.png, replace as(png);

gen year=yofd(dofm(monthly));
bysort year: egen tl=total(landings);
replace tl=tl/12;

gen lbar=landings-tl;
tsline lbar, tlabel(#12, format(%tmCCYY) angle(45)) tmtick(##2, grid) ylabel(,nogrid) title("Monthly Landings") subtitle("centered on average monthly landings in a year") ytitle("centered landings");

/*
egen tl2=total(landings);
replace tl2=tl2/_N;

gen lbar2=landings-tl2;
tsline lbar2, tlabel(#12, format(%tmCCYY) angle(45)) tmtick(##2, grid) ylabel(,nogrid) title("Monthly Landings") subtitle("centered on average monthly landings") ytitle("centered landings");
graph export ${silverhake_images}/silver_hake_Qbar2_monthly.png, replace as(png);
*/



restore;

collapse (sum) landings, by(nespp4 date);
tsset nespp4 date;
tsfill, full;
format date %td;
replace landings=0 if landings==.;
bysort date: egen tl=total(landings);

gen share=landings/tl;
xtline share;
graph export ${silverhake_images}/xtline509_daily_shares_${vintage_string}.png, replace as(png);



cap drop monthly;
gen monthly=mofd(date);
collapse (sum) landings, by(nespp4 monthly);
tsset nespp4 monthly;
tsfill, full;
replace landings=0 if landings==.;

format monthly %tm;
bysort monthly: egen tl=total(landings);

gen share=landings/tl;
xtline share, tline(528);
graph export ${silverhake_images}/xtline509_monthly_shares_${vintage_string}.png, replace as(png);

