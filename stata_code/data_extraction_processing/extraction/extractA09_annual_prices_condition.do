/* code to merge in fish condition data  */




version 15.1
pause off

#delimit;

/* files for Relative condition data, which one are you using?*/

use  ${out_dataYear},clear;
levelsof nespp3, local(specieslist2) sep(",");

clear;



 forvalues yr=$yearstart/$yearend{;
	tempfile new5555;
	local dsp1 `"`dsp1'"`new5555'" "'  ;
	clear;
	odbc load,  exec("select nespp3, sum(spplndlb) as landings, sum(sppvalue) as value, nespp4 from cfdbs.cfdets`yr'aa 
		where spplndlb is not null and
		nespp3 in (`specieslist2', 11,148,082,119,167,154,270) 
		group by nespp3, nespp4;") allstring $mysole_conn;
	gen year=`yr';
	quietly save `new5555';
};

clear;
append using `dsp1';
	renvarlab, lower;
	destring, replace;
	compress;
	
do "${extraction_code}/extractA01a_rebin_nespp3.do";
	

bysort nespp4: egen tv=total(value);
bysort nespp3: egen max=max(tv);
gen flag=tv+1>=max;
bysort nespp3 year: egen tmax=total(flag);

bysort nespp3 year: assert tmax<=1;
drop tmax tv max;
label var flag "most valuable market category";
save ${out_species_cond}, replace;
