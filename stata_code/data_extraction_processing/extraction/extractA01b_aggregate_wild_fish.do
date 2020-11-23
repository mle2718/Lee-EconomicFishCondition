
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
		${exclude_me} and		
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
drop if date==.;
tsset date;
tsfill, full;
format date %td;

/*take logs and inverse hyperbolic sine */
foreach var of varlist aggregateL aggregateV{;
	replace `var'=0 if `var'==.;
	gen ln_`var'=ln(`var');
	gen ihs_`var'=asinh(`var');
};

/*construct lags of those 6 variables */
foreach lag of numlist 1 7 14{;
	foreach var of varlist aggregateL aggregateV ln_aggregateL ln_aggregateV ihs_aggregateL ihs_aggregateV{;
		gen `var'_lag`lag'=l`lag'.`var';
	};
};
quietly compress;
save $aggregate_fishing, replace;



/********************************************************************************************************/
/********************************************************************************************************/
/* At the end of this step, you have a dataset of landings and value, grouped at the 
year, month, day, dealnum

You also have log and inverse hyperbolic sine transforms
And you have 1st 7th and 14th lags. 
You have excluded transactions with missing month or day fields.
*/
/********************************************************************************************************/
/********************************************************************************************************/
