
/*Code to extract itis and cfspp species codes.*/
#delimit;
version 15.1;
pause off;
clear;




odbc load,  exec("select sppnm, mktnm, sppnm3, nespp3, nespp4, svspp, necnv, washcnv from cfspp order by nespp3, nespp4;") $mysole_conn;
renvarlab, lower;

destring, replace;
drop if nespp3<=0;
bysort nespp4: assert _N==1;
gen sp_mkt=sppnm + mktnm;

save $nespp4, replace;



clear;


odbc load,  exec("select nespp4, species_itis, common_name, scientific_name from species_itis_ne ;") $mysole_conn;
renvarlab, lower;
destring, replace;
gen nespp3=floor(nespp4/10);
drop nespp4;
duplicates drop;
duplicates report nespp3;
sort nespp3;


destring, replace;
save $itis, replace;
