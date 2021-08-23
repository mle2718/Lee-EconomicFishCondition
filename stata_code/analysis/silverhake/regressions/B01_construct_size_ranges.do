
/*
Code to examine the lengths distribution of various market categories of fish.
*/


#delimit;
version 15.1;
pause on;

timer on 1;

local in_data ${data_raw}/raw_dealer_length_${vintage_string}.dta ;
local marketcats ${data_raw}/dealer_nespp4_codes${vintage_string}.dta ;
local  in_relcond_leng ${data_raw}/annual_condition_indexEPU_length_${vintage_string}.dta ;


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
qui summ year;
local first =`r(min)';
local last =`r(max)';
local cut1 2004;
gen period=1;
replace period=2 if year>=`cut1';

expand numlen;

egen p25y_len=pctile(length), p(25) by(nespp4 year);

egen p75y_len=pctile(length), p(75) by(nespp4 year);

egen p25p_len=pctile(length), p(25) by(nespp4 period);

egen p75p_len=pctile(length), p(75) by(nespp4 period);

egen t=tag(nespp3 nespp4 period year);
keep if t==1;


keep year nespp3 nespp4 period year p25* p75*;

sort year nespp3 nespp4 period year p25* p75*;
gen temp_id=_n;


/* Rangejoin this to the condition data that has lengths
*/

preserve;
use `in_relcond_leng', clear;
keep species length meancond_EPU_length nespp3 year;

tempfile temp_merge;
save `temp_merge', replace;

restore;

preserve;

/* this computes mean condition using the yearly range variables I don't think it's really okay to average like this, but I'm doing it for now.*/
rangejoin length p25y_len p75y_len using `temp_merge', by(nespp3 year);
collapse (mean) meancond_EPU_length, by(p25y_len p75y_len nespp3 year nespp4 species temp_id);
rename meancond_EPU_length meancond_EPU_year_length_bin; 

tempfile mm;
save `mm';

restore;

rangejoin length p25p_len p75p_len using `temp_merge', by(nespp3 year);
collapse (mean) meancond_EPU_length, by(p25p_len p75p_len nespp3 year nespp4 species temp_id);
rename meancond_EPU_length meancond_EPU_period_length_bin; 

merge 1:1 temp_id using `mm' ;
assert _merge==3;
drop _merge temp_id;

sort year nespp3 nespp4 ;
order year nespp3 species nespp4 meancond_EPU_year_length_bin meancond_EPU_period_length_bin;



