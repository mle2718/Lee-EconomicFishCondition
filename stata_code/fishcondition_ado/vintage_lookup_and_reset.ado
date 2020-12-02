
/* a small program that looks into the data folder to find the most recent vintage string*/
cap program drop vintage_lookup_and_reset
program vintage_lookup_and_reset
	
	di "The vintage_string macro is currently set as: $vintage_string"


	local data_vintage : dir "${data_main}" files "dealer_prices_full_*.dta" 
	local data_vintage: subinstr local data_vintage "dealer_prices_full_" ""
	local data_vintage: subinstr local data_vintage ".dta" ""
	di "The most recent data vintage found in the data_main folder is:" `data_vintage'.
	di "If you want to use this data vintage, type it here. Otherwise, press <Enter>" _request(_vintage_string_bypass)
	di "`vintage_string_bypass'"
	local bypass_length: strlen local vintage_string_bypass
		if `bypass_length'==0  {
			di "Keeping existing global vintage_string of $vintage_string"
		} 
		else{
			di "Existing vintage string overwritten with user -specified data vintage of `vintage_string_bypass'"
			global vintage_string `vintage_string_bypass'

		}

end
