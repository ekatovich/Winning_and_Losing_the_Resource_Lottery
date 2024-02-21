clear
cd "${user}\Data Directory\Treatment Variables"

*Output to R for did package
use "Munics_for_Matching_cleaned_outcomes", clear

*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement 
gen cvm_year = .
replace cvm_year = year if number_cvm_announcements != 0
bysort munic_code: egen first_CVM_year = min(cvm_year)

gen relative_time = .
replace relative_time = 0 if year == first_CVM_year 
replace relative_time = 1 if year == first_CVM_year + 1
replace relative_time = 2 if year == first_CVM_year + 2
replace relative_time = 3 if year == first_CVM_year + 3
replace relative_time = 4 if year == first_CVM_year + 4
replace relative_time = 5 if year == first_CVM_year + 5
replace relative_time = 6 if year == first_CVM_year + 6
replace relative_time = 7 if year == first_CVM_year + 7
replace relative_time = 8 if year == first_CVM_year + 8
replace relative_time = 9 if year == first_CVM_year + 9
replace relative_time = 10 if year == first_CVM_year + 10
replace relative_time = 11 if year == first_CVM_year + 11
replace relative_time = 12 if year == first_CVM_year + 12
replace relative_time = 13 if year == first_CVM_year + 13
replace relative_time = 14 if year == first_CVM_year + 14
replace relative_time = 15 if year == first_CVM_year + 15

replace relative_time = -1 if year == first_CVM_year - 1
replace relative_time = -2 if year == first_CVM_year - 2
replace relative_time = -3 if year == first_CVM_year - 3
replace relative_time = -4 if year == first_CVM_year - 4
replace relative_time = -5 if year == first_CVM_year - 5
replace relative_time = -6 if year == first_CVM_year - 6
replace relative_time = -7 if year == first_CVM_year - 7
replace relative_time = -8 if year == first_CVM_year - 8
replace relative_time = -9 if year == first_CVM_year - 9
replace relative_time = -10 if year == first_CVM_year - 10
replace relative_time = -11 if year == first_CVM_year - 11
replace relative_time = -12 if year == first_CVM_year - 12
replace relative_time = -13 if year == first_CVM_year - 13
replace relative_time = -14 if year == first_CVM_year - 14
replace relative_time = -15 if year == first_CVM_year - 15

*Set up relative time indicator 
*replace relative_time = -1 if relative_time == .
*Add 15 to make all values non-negative
replace relative_time = relative_time + 15
*Now, omitted period (-1) is represented by value 14

sort munic_code year

merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

*Replace missing alternate years in IDEB variable 
replace ideb = ideb[_n-1] if year == 2006 | year == 2008 | year == 2010 | year == 2012 | year == 2014 | year == 2016

*Set control units to zero
replace first_CVM_year = 0 if first_CVM_year == .

save "Analysis_for_R_SantAnna", replace 

keep if wells_completed_2000_2017 > 0

save "Analysis_for_R_SantAnna_WellsOnly_V2", replace 


***********************************************************************************
use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_med", clear

*Replace missing alternate years in IDEB variable 
replace ideb = ideb[_n-1] if year == 2006 | year == 2008 | year == 2010 | year == 2012 | year == 2014 | year == 2016

*Set control units to zero
drop first_CVM_year 
*Identify year of first CVM announcement 
gen cvm_year = .
replace cvm_year = year if number_cvm_announcements != 0
bysort munic_code: egen first_CVM_year = min(cvm_year)
replace first_CVM_year = 0 if first_CVM_year == .

*Create datasets that have only controls and disappointed, and controls and satisfied 
gen disappointed_plus_controls = 0
replace disappointed_plus_controls = 1 if control_disappointed == 1 | disappointed_analysis == 1
replace disappointed_plus_controls = 2 if control_satisfied == 1 | disappointed_analysis == 2

save "Analysis_for_R_SantAnna_Matched", replace 