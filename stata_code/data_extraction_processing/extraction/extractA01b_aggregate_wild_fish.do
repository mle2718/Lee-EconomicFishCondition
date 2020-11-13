
/*
Code to extract data from the CFDETS AA tables for the hedonic models.
This is used to get total landings and value for "fish"
*/
#delimit;
version 15.1;
pause off;
clear;







 forvalues yr=$yearstart/$yearend{;
	tempfile new5555;
	local dsp1 `"`dsp1'"`new5555'" "'  ;
	clear;
	odbc load,  exec("select sum(spplndlb/1000) as aggregateL, sum(sppvalue/1000) as aggregateV, year, month, day from cfdbs.cfdets`yr'aa 
		where spplndlb is not null and
		nespp3 not in (${herrings},${salmons}) and nespp3<=700 and		
		spplndlb>=1 and sppvalue/spplndlb<=$upper_price  
		group by year, month, day;") allstring $mysole_conn;

	quietly save `new5555';
};

clear;
append using `dsp1';
	destring, replace;
	compress;
	
rename aggregatel aggregateL;
rename aggregatev aggregateV;
#delimit ;
label var aggregateL "000s of pounds ";
label var aggregateV "000s of nominal dollars ";


gen date=mdy(month, day, year);
tsset date;

gen ln_aggregateL=ln(aggregateL);
gen ln_aggregateV=ln(aggregateV);

gen ihs_aggregateL=asinh(aggregateL);
gen ihs_aggregateV=asinh(aggregateV);

foreach lag of numlist 1 7 14{;
gen aggregateL_lag`lag'=l`lag'.aggregateL;
gen aggregateV_lag`lag'=l`lag'.aggregateV;

gen ln_aggregateL_lag`lag'=l`lag'.ln_aggregateL;
gen ln_aggregateV_lag`lag'=l`lag'.ln_aggregateV;

gen ihs_aggregateL_lag`lag'=l`lag'.ihs_aggregateL;
gen ihs_aggregateV_lag`lag'=l`lag'.ihs_aggregateV;
};

save $aggregate_fishing, replace;
