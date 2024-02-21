clear
cd "${user}\Data Directory\Treatment Variables"

use "Munics_for_Matching_cleaned_outcomes", clear

*******************************************************************************

*Create indicators for different samples 
gen wells_sample = 0
replace wells_sample = 1 if wells_completed_2000_2017 > 0
gen hydrocarbons_sample = 0
replace hydrocarbons_sample = 1 if hydrocarbon_detections_2000_2017 > 0
gen cvm_sample = 0
replace cvm_sample = 1 if cvm_announcements_2000_2017 > 0

*Merge in measures of disappointment 
merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

*Create satisfied indicator using preferred definition of disappointment 
gen satisfied = 0
replace satisfied = 1 if disappointed_pc_low == 2 

gen ihs_income_pc_2000 = asinh(income_capita_2000)

gen state_capital_indicator = 0
replace state_capital_indicator = 1 if dist_statecapital == 0


*Collapse to municipality level 
collapse (firstnm) municipality UF_NO (mean) satisfied wells_sample hydrocarbons_sample cvm_sample dist_brasilia ihs_dist_brasilia dist_statecapital state_capital_indicator ihs_dist_statecapital latitude ihs_pesotot_2000 ifdm_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 urban_share income_capita_2000 ihs_income_pc_2000 poverty_2000 GINI_2000 T_FUND18M_2000 T_MED18M_2000 T_SUPER25M_2000 P_EXTR_2000 P_FORMAL_2000 AGUA_ESGOTO_2000 PEA18M_2000 pesoRUR_2000 TRABPUB_2000 T_LUZ_2000 P_TRANSF_2000 pesourb_2000 coastal_indicator (firstnm) ihs_gdp_2002, by(munic_code)

save "Conditional_Random_Assignment_Sample", replace 

***************************************************************************************

local key_outcomes "ihs_pesotot_2000 ifdm_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 urban_share ihs_income_pc_2000 GINI_2000 P_EXTR_2000 P_FORMAL_2000 AGUA_ESGOTO_2000 T_LUZ_2000 TRABPUB_2000 ihs_gdp_2002"
foreach i of local key_outcomes {
*First, regress outcomes in 2000 on later indicator for getting wells
*Restrict to sample of coastal municipalities
use "Conditional_Random_Assignment_Sample", clear

keep if coastal_indicator == 1
reg `i' ihs_dist_brasilia ihs_dist_statecapital latitude wells_sample i.UF_NO, robust 

}

use "Conditional_Random_Assignment_Sample", clear

rename wells_sample w
keep if coastal_indicator == 1

*rwolf ihs_pesotot_2000 ihs_gdp_2002 ifdm_2000 urban_share ihs_income_pc_2000 GINI_2000 P_EXTR_2000 P_FORMAL_2000 AGUA_ESGOTO_2000 TRABPUB_2000, indepvar(w) controls(ihs_dist_brasilia ihs_dist_statecapital latitude i.UF_NO) reps(1000) seed(100)

use "Conditional_Random_Assignment_Sample", clear

rename wells_sample w
keep if w == 1

rename cvm_sample c 

*rwolf ihs_pesotot_2000 ihs_gdp_2002 ifdm_2000 urban_share ihs_income_pc_2000 GINI_2000 P_EXTR_2000 P_FORMAL_2000 AGUA_ESGOTO_2000 TRABPUB_2000, indepvar(c) controls(ihs_dist_brasilia ihs_dist_statecapital latitude i.UF_NO) reps(1000) seed(100)


use "Conditional_Random_Assignment_Sample", clear

rename cvm_sample c 
keep if c == 1

rename satisfied s 

*rwolf ihs_pesotot_2000 ihs_gdp_2002 ifdm_2000 urban_share ihs_income_pc_2000 GINI_2000 P_EXTR_2000 P_FORMAL_2000 AGUA_ESGOTO_2000 TRABPUB_2000, indepvar(s) controls(ihs_dist_brasilia ihs_dist_statecapital latitude i.UF_NO) reps(1000) seed(100)



****************************************************************************************
*Political alignment. Does alignment between municipal mayor and state governor or federal president predict who gets wells or discoveries? Or who is successful/unsuccessful.  

*Step 1: Create municipality panel of current mayors, current state governors, and federal presidents. 
*2. Create alignment indicators.
*3. Regress outcomes on alignment indicators and see if they're significant. Hopefully they're not. 

use "Party_Alignment_Panel_Munic_State_Fed", clear 

merge 1:1 munic_code year using "Munics_for_Matching_cleaned_outcomes"

drop if _merge != 3
drop _merge

sort municipality year 

*Generate event indicators
gen wells_completed = 0
replace wells_completed = 1 if number_of_wells_completed > 0

gen cvm_announcements = 0
replace cvm_announcements = 1 if number_cvm_announcements > 0

gen wells_ever_indicator = 0
replace wells_ever_indicator = 1 if wells_completed_2000_2017 > 0

gen state_capital_indicator = 0
replace state_capital_indicator = 1 if dist_statecapital == 0


*Discreet analysis of well drilling or cvm discovery regressed on geograpical controls and political alignent variables 
logit wells_completed ihs_dist_brasilia ihs_dist_statecapital latitude state_capital_indicator munic_state_align munic_fed_align i.UF_NO if coastal_indicator == 1, robust

logit cvm_announcements ihs_dist_brasilia ihs_dist_statecapital latitude state_capital_indicator munic_state_align munic_fed_align i.UF_NO if wells_ever_indicator == 1, robust

********************************************************************************
*Now find total alignment and collapse 

*Create indicators for different samples 
gen wells_sample = 0
replace wells_sample = 1 if wells_completed_2000_2017 > 0
gen hydrocarbons_sample = 0
replace hydrocarbons_sample = 1 if hydrocarbon_detections_2000_2017 > 0
gen cvm_sample = 0
replace cvm_sample = 1 if cvm_announcements_2000_2017 > 0

*Merge in measures of disappointment 
merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

*Create satisfied indicator using preferred definition of disappointment 
gen satisfied = 0
replace satisfied = 1 if disappointed_pc_low == 2 

gen ihs_income_pc_2000 = asinh(income_capita_2000)

*Collapse to municipality level 
collapse (firstnm) municipality UF_NO (sum) munic_state_align munic_fed_align (mean) satisfied wells_sample hydrocarbons_sample cvm_sample dist_brasilia ihs_dist_brasilia dist_statecapital state_capital_indicator ihs_dist_statecapital latitude ihs_pesotot_2000 ifdm_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 urban_share income_capita_2000 ihs_income_pc_2000 poverty_2000 GINI_2000 T_FUND18M_2000 T_MED18M_2000 T_SUPER25M_2000 P_EXTR_2000 P_FORMAL_2000 AGUA_ESGOTO_2000 PEA18M_2000 pesoRUR_2000 TRABPUB_2000 T_LUZ_2000 P_TRANSF_2000 pesourb_2000 coastal_indicator (firstnm) ihs_gdp_2002, by(munic_code)

save "Political_Alignment_Testing", replace 


use "Political_Alignment_Testing", clear

keep if coastal_indicator == 1
rename wells_sample w

*rwolf munic_state_align munic_fed_align state_capital_indicator, indepvar(w) controls(ihs_dist_brasilia ihs_dist_statecapital latitude i.UF_NO) reps(1000) seed(100)

use "Political_Alignment_Testing", clear

rename wells_sample w
keep if w == 1

rename cvm_sample c 

*rwolf munic_state_align munic_fed_align state_capital_indicator, indepvar(c) controls(ihs_dist_brasilia ihs_dist_statecapital latitude i.UF_NO) reps(1000) seed(100)


use "Political_Alignment_Testing", clear

rename cvm_sample c 
keep if c == 1

rename satisfied s 

*rwolf munic_state_align munic_fed_align state_capital_indicator, indepvar(s) controls(ihs_dist_brasilia ihs_dist_statecapital latitude i.UF_NO) reps(1000) seed(100)



























