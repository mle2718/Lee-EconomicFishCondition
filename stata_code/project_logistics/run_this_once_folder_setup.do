version 15.1

#delimit ;


/*
global user minyang;
or 
global user minyangWin;
or
global user cameron;
*/

if strmatch("$user","minyang"){;
	global my_projdir "/home/mlee/Documents/projects/fishcondition";
};
if strmatch("$user","minyangWin"){;
	global my_projdir "C:/Users/Min-Yang.Lee/Documents/EconomicFishCondition";
};


/**************** 
Set your project directory using this template
if strmatch("$user","minyangWin"){;
	global my_projdir "C:/Users/Min-Yang.Lee/Documents/EconomicFishCondition";
};
**************/


/*These are the species, Add your species to this list to help automatically make folders */
local specieslist silverhake haddock winterflounder common;




cap mkdir $my_projdir;

global my_codedir "${my_projdir}/stata_code";
cap mkdir $my_codedir;


global extract_process "${my_codedir}/data_extraction_processing";
cap mkdir $extract_process;

global extraction_code "${my_codedir}/data_extraction_processing/extraction";
cap mkdir $extraction_code;

global processing_code "${my_codedir}/data_extraction_processing/processing";
cap mkdir $processing_code;

global analysis_code "${my_codedir}/analysis";
cap mkdir $analysis_code;

global my_adopath "${my_codedir}/fishcondition_ado";
cap mkdir $my_adopath;




global R_code "${my_projdir}/R_code";
cap mkdir $R_code;


/* setup data folder */
global my_datadir "${my_projdir}/data_folder";
cap mkdir $my_datadir;


global data_raw "${my_datadir}/raw";
cap mkdir $data_raw;


global data_internal "${my_datadir}/internal";
cap mkdir $data_internal;

global data_external "${my_datadir}/external";
cap mkdir $data_external;

global data_main "${my_datadir}/main";
cap mkdir $data_master;

global data_intermediate "${my_datadir}/intermediate";
cap mkdir $data_intermediate;

/* setup results folders */

global my_results "${my_projdir}/results";
cap mkdir $my_results;


/* setup images folders */

global my_images "${my_projdir}/images";
cap mkdir $my_images;

global exploratory "${my_images}/exploratory";
cap mkdir $exploratory;

global tables "${my_projdir}/tables";
cap mkdir $tables;


/* add subfolders */

foreach l of local specieslist{;
	cap mkdir ${my_results}/`l' ;
	cap mkdir ${my_images}/`l';
	cap mkdir ${my_images}/`l'/exploratory;
	cap mkdir ${tables}/`l';
	cap mkdir ${analysis_code}/`l';
};


