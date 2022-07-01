/* code to extract trade data related to whiting*/
/* modified from 
https://github.com/cameronspeir/NOAA-Foreign-Fishery-Trade-Data-API
*/



#delimit ;
clear;
pause off;
global kg_to_lbs 2.20462;


**** Don't forget that you need two packages

*ssc install insheetjson;
*ssc install libjson;


**** set up an empty data set with names of the columns that we will import;
* define a local macro, called invars, with the column names;
local invars year month hts_number name cntry_code fao cntry_name district_code 
			 district_name edible_code kilos val source association rfmo 
			 nmfs_region_code;

* Define a local macro, called quote_invars, that contains nothing.;
* We will use this to contain the elements of invars, but wrapped in double quotations;

local quote_invars ;

* loop through each varname and create an empty string variable;
* Add the double quoted name to the quoted local macro. 	;		 
foreach l of local invars {;
	gen str60 `l'="";
	local quote_invars `" `quote_invars' "`l'" "' ;

};

local chunksize 5000;

/*
This is the business of the query. Get all rows with
1. Name like WHITING
2. Years 1992 to present

Notably, this will include blue whiting and does not screen on product forms
*/
local url_root https://apps-st.fisheries.noaa.gov/ods/foss/trade_data;
local url_subset ?q={%22year%22:{%22%24gte%22:1992},%22name%22:{%22%24like%22:%22%25WHITING%25%22}};
local url_offset &offset=0;
local url_limit &limit=`chunksize';
local url_request `url_root'`url_subset'`url_offset'`url_limit';
mac list _url_request;

local keep_going="true";
while "`keep_going'"=="true"{;
qui count;
local nobs=r(N);
local url_offset &offset=`nobs';
local url_request `url_root'`url_subset'`url_offset'`url_limit';
mac list _url_request;
insheetjson `invars' using "`url_request'",	column(`quote_invars') tableselector("items") offset(`nobs') topscalars;
local keep_going="`r(hasMore)'";
};
* take a look at the result;
describe;

* convert some of the string variables to numeric;
destring year month cntry_code fao district_code kilos val, replace;
*might not want to destring the hts code;

compress;
assert edible_code=="E";
drop edible_code;

collapse (sum) kilos val, by(year month hts_number name district_code district_name source);

/* this is 'merica, and in 'merica, we use pounds. Except when we use metric tons. */

replace kilos=round(kilos*$kg_to_lbs);
rename kilos pounds;
rename val nominal_value;

/* You might want to filter out  
	Frozen?
	Blue Whiting?
	Mainland US, East Coast US? Northeast Region?
	Re-Exports?
	*/
save	$whiting_trade, replace ;





/********************************************************************************************************/
/********************************************************************************************************/
/* At the end of this step, you will end up with a dataset of 
monthly whiting imports at the district level
*/
/********************************************************************************************************/
/********************************************************************************************************/


