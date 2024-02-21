clear
cd "${user}\Data Directory\Census"

use "CensoDemografico2010.dta", clear 

*Keep necessary variables for migration analysis 
*Drop others to reduce size of dataset in memory 
keep v0001 v0002 v0010 v0601 v6036 v0618 v0624 v6254 v6252 v0626 v6262 v6264 v0633 v6471 v0660 v0648 v6511 v5030 v0640 v0627

*Create 7-digit municipality code 
rename v0002 munic_root
tostring v0001, replace 
egen munic_code = concat(v0001 munic_root)

rename v0001 UF_NO 
drop munic_root 
order munic_code UF_NO 
destring munic_code, replace
destring UF_NO, replace

rename v0010 survey_weight
rename v0601 sex
rename v6036 age
rename v0618 born_in_munic
rename v0624 time_lived_in_munic
rename v6254 former_municipality
rename v6252 former_state
rename v0626 uf_or_foreign_2005
rename v6262 state_resident_2005
rename v6264 munic_resident_2005
rename v0627 literate
rename v0633 highest_education
rename v6471 CNAE_2_activity
rename v0660 munic_of_employment
rename v0648 employment_type
rename v6511 total_income_monthly
rename v5030 household_type
rename v0640 civil_status

*******************************************************************************
*Perform basic cleaning operations 
gen female = 0
replace female = 1 if sex == 2
drop sex 

*Keep only adults of reasonable ages 
drop if age < 22
drop if age > 70

*Create single indicator 
gen single = 0
replace single = 1 if civil_status == 5

******************************************************************************
*Migration 

*Generate year of entry into municipality (values are missing for people born in municipality)
gen year_entry = 2010 - time_lived_in_munic

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010"
foreach i of local years {
gen entry_`i' = 0
replace entry_`i' = 1*survey_weight if year_entry == `i'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010"
foreach j of local years {
*Count number of entrants each year at municipality level 
bysort munic_code: egen munic_entry_`j' = sum(entry_`j')
}

*This produces a count of in-migrants to each municipality in years 2000-2010. 

*Now create some descriptive statistics about these entrants 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010"
foreach k of local years {
bysort munic_code: egen avg_migrant_ed_`k' = mean(highest_education) if year_entry == `k'
bysort munic_code: egen avg_migrant_female_`k' = mean(female) if year_entry == `k'
bysort munic_code: egen avg_migrant_single_`k' = mean(single) if year_entry == `k'
bysort munic_code: egen avg_migrant_age_`k' = mean(age) if year_entry == `k'
}

*Collapse to municipality level 
collapse (max) munic_entry_2000 munic_entry_2001 munic_entry_2002 munic_entry_2003 munic_entry_2004 munic_entry_2005 munic_entry_2006 munic_entry_2007 munic_entry_2008 munic_entry_2009 munic_entry_2010 avg_migrant_ed_2000 avg_migrant_ed_2001 avg_migrant_ed_2002 avg_migrant_ed_2003 avg_migrant_ed_2004 avg_migrant_ed_2005 avg_migrant_ed_2006 avg_migrant_ed_2007 avg_migrant_ed_2008 avg_migrant_ed_2009 avg_migrant_ed_2010 avg_migrant_female_2000 avg_migrant_female_2001 avg_migrant_female_2002 avg_migrant_female_2003 avg_migrant_female_2004 avg_migrant_female_2005 avg_migrant_female_2006 avg_migrant_female_2007 avg_migrant_female_2008 avg_migrant_female_2009 avg_migrant_female_2010 avg_migrant_single_2000 avg_migrant_single_2001 avg_migrant_single_2002 avg_migrant_single_2003 avg_migrant_single_2004 avg_migrant_single_2005 avg_migrant_single_2006 avg_migrant_single_2007 avg_migrant_single_2008 avg_migrant_single_2009 avg_migrant_single_2010 avg_migrant_age_2000 avg_migrant_age_2001 avg_migrant_age_2002 avg_migrant_age_2003 avg_migrant_age_2004 avg_migrant_age_2005 avg_migrant_age_2006 avg_migrant_age_2007 avg_migrant_age_2008 avg_migrant_age_2009 avg_migrant_age_2010, by(munic_code)

*Reshape into long panel 
reshape long munic_entry_ avg_migrant_ed_ avg_migrant_female_ avg_migrant_single_ avg_migrant_age_, i(munic_code) j(year)

rename munic_entry_ migrant_number
rename avg_migrant_ed_ migrant_avg_educ
rename avg_migrant_female_ migrant_avg_female
rename avg_migrant_single_ migrant_avg_single
rename avg_migrant_age_ migrant_avg_age

save "In_Migration_Panel", replace 

********************************************************************************
*Redo analysis to get descriptive statistics for non-migrant population for comparison 
use "CensoDemografico2010.dta", clear 

*Keep necessary variables for migration analysis 
*Drop others to reduce size of dataset in memory 
keep v0001 v0002 v0010 v0601 v6036 v0618 v0624 v6254 v6252 v0626 v6262 v6264 v0633 v6471 v0660 v0648 v6511 v5030 v0640 v0627

*Create 7-digit municipality code 
rename v0002 munic_root
tostring v0001, replace 
egen munic_code = concat(v0001 munic_root)

rename v0001 UF_NO 
drop munic_root 
order munic_code UF_NO 
destring munic_code, replace
destring UF_NO, replace

rename v0010 survey_weight
rename v0601 sex
rename v6036 age
rename v0618 born_in_munic
rename v0624 time_lived_in_munic
rename v6254 former_municipality
rename v6252 former_state
rename v0626 uf_or_foreign_2005
rename v6262 state_resident_2005
rename v6264 munic_resident_2005
rename v0627 literate
rename v0633 highest_education
rename v6471 CNAE_2_activity
rename v0660 munic_of_employment
rename v0648 employment_type
rename v6511 total_income_monthly
rename v5030 household_type
rename v0640 civil_status

*Perform basic cleaning operations 
gen female = 0
replace female = 1 if sex == 2
drop sex 

*Keep only adults of reasonable ages 
drop if age < 22
drop if age > 70

*Create single indicator 
gen single = 0
replace single = 1 if civil_status == 5

gen year_entry = 2010 - time_lived_in_munic
keep if year_entry == .

*Now only natives remain 
bysort munic_code: egen avg_native_ed = mean(highest_education)
bysort munic_code: egen avg_native_female = mean(female) 
bysort munic_code: egen avg_native_single = mean(single) 
bysort munic_code: egen avg_native_age = mean(age)

*Collapse to municipality level 
collapse (max) avg_native_ed avg_native_female avg_native_single avg_native_age, by(munic_code)

merge 1:m munic_code using "In_Migration_Panel"
drop _merge 

sort munic_code year 
order munic_code year 

save "In_Migration_with_NativeComparisons", replace 