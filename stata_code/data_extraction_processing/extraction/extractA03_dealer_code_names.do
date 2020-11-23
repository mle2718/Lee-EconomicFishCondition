
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
gen sp_mkt=sppnm + " " + mktnm;

labmask nespp4, value(sp_mkt);
replace svspp=78 if nespp3==662;


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
rename species_itis itis_tsn;
rename common_name common_name_itis;
rename scientific_name scientific_name_itis;

destring, replace;
save $itis, replace;




clear;


odbc load,  exec("select * from svdbs.itis_lookup;") $mysole_conn;

renvarlab, lower;
destring, replace;
duplicates drop;

rename itisspp itis_tsn;
rename comname common_name_svdbs;
rename sciname sciname_svdbs;



destring, replace;
save $svdbs, replace;
/********************************************************************************************************/
/********************************************************************************************************/
/* At the end of this step, you have 3 keyfiles
1. The CFSPP keyfile
2. The ITIS TSNs from species_itis_ne
3. The Survey keyfile that contains the svspp and itis tsn.
*/
/********************************************************************************************************/
/********************************************************************************************************/



