
/*
Code to plot prices
*/


#delimit;
version 15.1;
pause on;

timer on 1;

local  in_data ${data_main}/dealer_prices_real_lags_condition${vintage_string}.dta ;
local  marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;


local relabelstr `"relabel(1 "J" 2 "F" 3 "M"  4 "A"  5 "M"  6 "J"  7 "J" 8 "A" 9 "S" 10 "O" 11 "N" 12 "D" 13 "J" 14 "F" 15 "M"  16 "A"  17 "M"  18 "J"  19 "J" 20 "A" 21 "S" 22 "O" 23 "N" 24 "D")"' ;

clear;
use `in_data', clear;
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

keep if nespp3==509;

egen t=tag(date); 
replace daily_landings=daily_landings/1000;
label var daily_landings "daily landings ('000s)";

/* landings by DOW */
graph box daily_landings if t==1, over(dow) ytitle("Daily landings, 000s lbs");
graph export ${my_images}/silver_hake_Q_dow.png, replace as(png);


/* landings by month */
graph box daily_landings if t==1, over(month) ytitle("Daily landings, 000s lbs");
graph export ${my_images}/silver_hake_Q_month.png, replace as(png);


/* landings by week */
gen wofyear=week(date);
graph box daily_landings if t==1, over(wofyear, label(angle(45))) ytitle("Daily landings, 000s lbs");
graph export ${my_images}/silver_hake_Q_week.png, replace as(png);


/*landings year*/
graph box daily_landings if t==1, over(year, label(angle(45))) ytitle("Daily landings, 000s lbs");
graph export ${my_images}/silver_hake_Q_year.png, replace as(png);


preserve;
keep if t==1;
cap drop monthly;
gen monthly=mofd(date);
collapse (sum) daily_landings, by(monthly);
rename daily_landings landings;
replace landings=landings/1000;
label var landings "landings ('000s)";

tsset monthly ;
format monthly %tm;
tsline landings, tlabel(#12, format(%tmCCYY) angle(45)) tmtick(##2, grid) ylabel(,nogrid)  title("Monthly Landings");
graph export ${my_images}/silver_hake_Q_monthly.png, replace as(png);

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
graph export ${my_images}/silver_hake_Qbar2_monthly.png, replace as(png);
*/



restore;

replace landings=landings/1000;
collapse (sum) landings, by(nespp4 date);
tsset nespp4 date;
tsfill, full;
format date %td;
replace landings=0 if landings==.;
bysort date: egen tl=total(landings);

gen share=landings/tl;
xtline share;
graph export ${my_images}/silver_hake_daily_nespp4_shares.png, replace as(png);



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
graph export ${my_images}/silver_hake_monthly_nespp4_shares.png, replace as(png);

