clear
cd "${user}\Data Directory\Treatment Variables"


**********************************************************************************
**********************************************************************************
*local disappointment_vars "disappointed_temp disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high"
local disappointment_vars "disappointed_total_med disappointed_total_low disappointed_pc_low disappointed_pc_med"
foreach k of local disappointment_vars {

*COARSENED EXACT MATCHING
*Now try coarsened exact matching (Detailed Match, many vars and groups, but lose some unmatched)

use "Event_Analysis_FirstEvent", clear 
*use "Event_Analysis_Matching_MultipleEvents", replace 

sort municipality year

*Keep only coastal state munics 
keep if UF_NO == 27 | UF_NO == 16 | UF_NO == 29 |UF_NO == 23 |UF_NO == 32 |UF_NO == 21 |UF_NO == 33 |UF_NO == 15 |UF_NO == 25 |UF_NO == 41 |UF_NO == 26 |UF_NO == 22 |UF_NO == 24 |UF_NO == 43 |UF_NO == 42 | UF_NO == 35 | UF_NO == 28

*First, match disappointed = 1 
gen treatment_disappointed = 0
replace treatment_disappointed = 1 if `k' == 1

*Drop other treateds
drop if `k' == 2

*cem ihs_dist_statecapital (#5) latitude (#5) ihs_gdp_2002 (#5) ihs_pesotot_2000 (#5) urban_share (#5) ifdm_2000 (#5) hdi_income_2000 (#5) hdi_lifeexpect_2000 (#5) hdi_education_2000 (#5) P_EXTR_2000 (#5) P_FORMAL_2000 (#5), treatment(treatment_disappointed)

*Try with coarser bins
*cem ihs_dist_statecapital (#5) latitude (#5) ihs_gdp_2002 (#5) ihs_pesotot_2000 (#5) ifdm_2000 (#5) TRABPUB_2000 (#4) GINI_2000 (#4), treatment(treatment_disappointed) 

*Match on revenue per capita 
*Take values of matching vars in 2000-2001
bysort munic_code: gen ihs_rev_current_I_pc_2000_t = ihs_rev_current_I_pc if year == 2000
bysort munic_code: gen ihs_spend_current_I_pc_2000_t = ihs_spend_current_I_pc if year == 2000
bysort munic_code: gen ihs_invest_F_pc_2000_t = ihs_invest_F_pc if year == 2000
bysort munic_code: gen ihs_rev_taxes_I_pc_2000_t = ihs_rev_taxes_I_pc if year == 2000
bysort munic_code: gen ihs_rev_current_I_pc_2001_t = ihs_rev_current_I_pc if year == 2001
bysort munic_code: gen ihs_spend_current_I_pc_2001_t = ihs_spend_current_I_pc if year == 2001
bysort munic_code: gen ihs_invest_F_pc_2001_t = ihs_invest_F_pc if year == 2001
bysort munic_code: gen ihs_rev_taxes_I_pc_2001_t = ihs_rev_taxes_I_pc if year == 2001

bysort munic_code: egen ihs_rev_current_I_pc_2000 = max(ihs_rev_current_I_pc_2000_t)
bysort munic_code: egen ihs_spend_current_I_pc_2000 = max(ihs_spend_current_I_pc_2000_t)
bysort munic_code: egen ihs_invest_F_pc_2000 = max(ihs_invest_F_pc_2000_t)
bysort munic_code: egen ihs_rev_taxes_I_pc_2000 = max(ihs_rev_taxes_I_pc_2000_t)
bysort munic_code: egen ihs_rev_current_I_pc_2001 = max(ihs_rev_current_I_pc_2001_t)
bysort munic_code: egen ihs_spend_current_I_pc_2001 = max(ihs_spend_current_I_pc_2001_t)
bysort munic_code: egen ihs_invest_F_pc_2001 = max(ihs_invest_F_pc_2001_t)
bysort munic_code: egen ihs_rev_taxes_I_pc_2001 = max(ihs_rev_taxes_I_pc_2001_t)
drop ihs_rev_current_I_pc_2000_t ihs_spend_current_I_pc_2000_t ihs_invest_F_pc_2000_t ihs_rev_taxes_I_pc_2000_t ihs_rev_current_I_pc_2001_t ihs_spend_current_I_pc_2001_t ihs_invest_F_pc_2001_t ihs_rev_taxes_I_pc_2001_t

cem ihs_rev_current_I_pc_2000 (#4) ihs_spend_current_I_pc_2000 (#4) ihs_invest_F_pc_2000 (#4) ihs_rev_taxes_I_pc_2000 (#4) ihs_rev_current_I_pc_2001 (#4) ihs_spend_current_I_pc_2001 (#4) ihs_invest_F_pc_2001 (#4) ihs_rev_taxes_I_pc_2001 (#4), treatment(treatment_disappointed)

keep if cem_matched == 1
gen control_disappointed = 0
replace control_disappointed = 1 if cem_matched == 1 & treatment_disappointed == 0

save "Event_Analysis_CEMDisappointedDetailed_FirstEvent_`k'_altmatch", replace 

*********************************************************************************
*Next, satisfied with CEM 

use "Event_Analysis_Matching_FirstEvent", clear
*use "Event_Analysis_Matching_MultipleEvents", replace 

sort municipality year

*Keep only coastal state munics 
keep if UF_NO == 27 | UF_NO == 16 | UF_NO == 29 |UF_NO == 23 |UF_NO == 32 |UF_NO == 21 |UF_NO == 33 |UF_NO == 15 |UF_NO == 25 |UF_NO == 41 |UF_NO == 26 |UF_NO == 22 |UF_NO == 24 |UF_NO == 43 |UF_NO == 42 | UF_NO == 35 | UF_NO == 28

*For now, find NN matches for munics that are disappointed, and satisfied by big discovery announcements 

*First, match disappointed = 1 
gen treatment_satisfied = 0
replace treatment_satisfied = 1 if `k' == 2

*Drop other treateds
drop if `k' == 1

*cem ihs_dist_statecapital (#5) latitude (#5) ihs_gdp_2002 (#5) ihs_pesotot_2000 (#5) urban_share (#5) ifdm_2000 (#5) hdi_income_2000 (#5) hdi_lifeexpect_2000 (#5) hdi_education_2000 (#5) P_EXTR_2000 (#5) P_FORMAL_2000 (#5), treatment(treatment_disappointed)

*Try with coarser bins
*cem ihs_dist_statecapital (#5) latitude (#5) ihs_gdp_2002 (#5) ihs_pesotot_2000 (#5) ifdm_2000 (#5) TRABPUB_2000 (#4) GINI_2000 (#4), treatment(treatment_satisfied)

*Match on revenue per capita 
*Take values of matching vars in 2000-2001
bysort munic_code: gen ihs_rev_current_I_pc_2000_t = ihs_rev_current_I_pc if year == 2000
bysort munic_code: gen ihs_spend_current_I_pc_2000_t = ihs_spend_current_I_pc if year == 2000
bysort munic_code: gen ihs_invest_F_pc_2000_t = ihs_invest_F_pc if year == 2000
bysort munic_code: gen ihs_rev_taxes_I_pc_2000_t = ihs_rev_taxes_I_pc if year == 2000
bysort munic_code: gen ihs_rev_current_I_pc_2001_t = ihs_rev_current_I_pc if year == 2001
bysort munic_code: gen ihs_spend_current_I_pc_2001_t = ihs_spend_current_I_pc if year == 2001
bysort munic_code: gen ihs_invest_F_pc_2001_t = ihs_invest_F_pc if year == 2001
bysort munic_code: gen ihs_rev_taxes_I_pc_2001_t = ihs_rev_taxes_I_pc if year == 2001

bysort munic_code: egen ihs_rev_current_I_pc_2000 = max(ihs_rev_current_I_pc_2000_t)
bysort munic_code: egen ihs_spend_current_I_pc_2000 = max(ihs_spend_current_I_pc_2000_t)
bysort munic_code: egen ihs_invest_F_pc_2000 = max(ihs_invest_F_pc_2000_t)
bysort munic_code: egen ihs_rev_taxes_I_pc_2000 = max(ihs_rev_taxes_I_pc_2000_t)
bysort munic_code: egen ihs_rev_current_I_pc_2001 = max(ihs_rev_current_I_pc_2001_t)
bysort munic_code: egen ihs_spend_current_I_pc_2001 = max(ihs_spend_current_I_pc_2001_t)
bysort munic_code: egen ihs_invest_F_pc_2001 = max(ihs_invest_F_pc_2001_t)
bysort munic_code: egen ihs_rev_taxes_I_pc_2001 = max(ihs_rev_taxes_I_pc_2001_t)
drop ihs_rev_current_I_pc_2000_t ihs_spend_current_I_pc_2000_t ihs_invest_F_pc_2000_t ihs_rev_taxes_I_pc_2000_t ihs_rev_current_I_pc_2001_t ihs_spend_current_I_pc_2001_t ihs_invest_F_pc_2001_t ihs_rev_taxes_I_pc_2001_t
cem ihs_rev_current_I_pc_2000 (#4) ihs_spend_current_I_pc_2000 (#4) ihs_invest_F_pc_2000 (#4) ihs_rev_taxes_I_pc_2000 (#4) ihs_rev_current_I_pc_2001 (#4) ihs_spend_current_I_pc_2001 (#4) ihs_invest_F_pc_2001 (#4) ihs_rev_taxes_I_pc_2001 (#4), treatment(treatment_satisfied)
*Try with fewer vars
*cem ihs_dist_statecapital (#5) latitude (#5) ihs_gdp_2002 (#5) ihs_pesotot_2000 (#5) ifdm_2000 (#5), treatment(treatment_satisfied)


*cem ihs_dist_statecapital (#4) latitude (#4) ihs_gdp_2002 (#4) ihs_pesotot_2000 (#4) hdi_income_2000 (#4) hdi_lifeexpect_2000 (#4) hdi_education_2000 (#4), treatment(treatment_disappointed)

keep if cem_matched == 1
gen control_satisfied = 0
replace control_satisfied = 1 if cem_matched == 1 & treatment_satisfied == 0

save "Event_Analysis_CEMSatisfiedDetailed_FirstEvent_`k'_altmatch", replace 

use "Event_Analysis_CEMDisappointedDetailed_FirstEvent_`k'_altmatch", clear 
append using "Event_Analysis_CEMSatisfiedDetailed_FirstEvent_`k'_altmatch", force 

rename `k' disappointed_analysis

save "Event_Analysis_CEMDetailed_FirstEvent_`k'_altmatch", replace 
