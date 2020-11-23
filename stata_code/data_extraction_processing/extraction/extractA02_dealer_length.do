/*Code to extract length data from CFLEN for the hedonic models */
#delimit;
version 15.1;
pause off;
clear;





 forvalues yr=$yearstart/$yearend{;
	tempfile new5555;
	local dsp1 `"`dsp1'"`new5555'" "'  ;
	clear;
	odbc load,  exec("select year, month, day, link, nespp4, wgtsamp, numsamp, length, numlen from cfdbs.cflen`yr' 
		where nespp3 in (${specieslist} );") $mysole_conn;
	renvarlab, lower;
	compress;

	quietly save `new5555';
};
clear;
append using `dsp1';
	destring, replace;

save $length_data, replace;


/********************************************************************************************************/
/********************************************************************************************************/
/* At the end of this step, you have of fish length and weights. But we're not using this for anything right now
*/
/********************************************************************************************************/
/********************************************************************************************************/
