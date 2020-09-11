
/*
Code to extract data from the CFDETS AA tables for the hedonic models.
*/
#delimit;
version 15.1;
pause off;
clear;







 forvalues yr=$yearstart/$yearend{;
	tempfile new5555;
	local dsp1 `"`dsp1'"`new5555'" "'  ;
	clear;
	odbc load,  exec("select link, nespp3, sum(spplndlb) as landings, sum(sppvalue) as value, nespp4, year, month, day, dealnum, vserial, vtripid, vgearid, alevel, elevel, permit, area, effind, fzone from cfdbs.cfdets`yr'aa 
		where spplndlb is not null and
		nespp3 in (${specieslist}) and
		spplndlb>=1 and sppvalue/spplndlb<=$upper_price  
		group by link, nespp3, nespp4, year, month, day, dealnum, vserial, vtripid, vgearid, alevel, elevel, permit, area, effind, fzone;") allstring $mysole_conn;

	quietly save `new5555';
};

clear;
append using `dsp1';
	renvarlab, lower;
	destring, replace;
	compress;
	
do "${extraction_code}/extractA01a_rebin_nespp3.do";
	
save $dealer_prices, replace;
