clear
cd "${user}\Data Directory\Treatment Variables"

*Import and organize discovery distances 
import delimited "${user}\Data Directory\Shapefiles\distance_disappointed.csv", varnames(1) clear 

rename location location_disappointed 
rename distance distance_disappointed

save "distance_disappointed", replace 

import delimited "${user}\Data Directory\Shapefiles\distance_satisfied.csv", varnames(1) clear 

rename location location_satisfied
rename distance distance_satisfied

save "distance_satisfied", replace 

********************************************************************************
*Organize and merge 
use "distance_disappointed", clear

merge 1:1 code_muni using "distance_satisfied"
drop _merge 
rename code_muni munic_code 

gen dist_discovery = .
replace dist_discovery = distance_satisfied if distance_satisfied < distance_disappointed 
replace dist_discovery = distance_disappointed if distance_disappointed < distance_satisfied

gen location_discovery = .
replace location_discovery = location_disappointed if dist_discovery == distance_disappointed
replace location_discovery = location_satisfied if dist_discovery == distance_satisfied

sort munic_code 
order munic_code location_disappointed distance_disappointed location_satisfied distance_satisfied location_discovery dist_discovery

save "Distance_to_Discoveries", replace 

**********************************************************************************

*Create dataset of treated munics and discoveries by year 
use "Munics_for_Matching_cleaned_outcomes", clear

keep munic_code municipality year number_cvm_announcements cum_cvm_announcements cvm_announcements_2000_2017

*Keep only treated munics 
keep if cvm_announcements_2000_2017 > 0

rename munic_code location_discovery
rename cum_cvm_announcements cum_cvm_nearest
rename cvm_announcements_2000_2017 cvm_2000_2017_nearest
rename number_cvm_announcements num_near_announcements

*Merge in disappointment 
merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

drop disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3

save "Treated_Munics_CVM", replace 

**********************************************************************************
*Merge distances with main outcomes dataset 
use "Munics_for_Matching_cleaned_outcomes", clear

merge m:1 munic_code using "Distance_to_Discoveries"

drop if _merge != 3
drop _merge

*********************************************************************************
*Create distance bins 
*THIS IS IMPORTANT
*ADJUST FOR DIFFERENT BINS
gen near_discovery = 0
replace near_discovery = 1 if dist_discovery <= 40
replace near_discovery = 2 if dist_discovery > 40 & dist_discovery < 80
*********************************************************************************

*Now merge in discovery histories for treated units 
merge m:1 location_discovery year using "Treated_Munics_CVM"
drop _merge 
sort munic_code year

********************************************************************************
*Set up relative time indicators. 
*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_nearest if cum_cvm_nearest != 0 & L1.cum_cvm_nearest == 0 & near_discovery == 1
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred in nearest treated munic

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (15 years in either direction).
forvalues i = 1(1)15 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)15 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Events are now totally saturated.

*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & num_near_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.num_near_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017

*Save dataset for analysis 
save "Spatial_Spillovers_Analysis", replace 

*********************************************************************************

use "Spatial_Spillovers_Analysis", clear 

*Drop actually treated units to focus solely on neighbors 
drop if dist_discovery == 0

*For main outcomes, plot graphs with properly centered event line
graph drop _all
estimates clear

*First, revenues 
local outcomes "ihs_rev_current_I_pc ihs_rev_taxes_I_pc ihs_oil_revenue_pc ihs_AFM_AFE_pc ihs_CIDE_fuel_pc ihs_FEX_pc ihs_FPM_pc ihs_FUNDEB_pc ihs_FUNDEF_pc ihs_ITR_pc ihs_LeiKandir_pc ihs_transf_nonoil_pc"
foreach i of local outcomes {
reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Discovery (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Spending
local outcomes "ihs_spend_current_I_pc ihs_invest_F_pc ihs_spend_personnel_I_pc ihs_spend_admin_I_pc ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc ihs_spend_labor_I_pc"
foreach i of local outcomes {
reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Discovery (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*FIRJAN
local outcomes "spending_personnel_share investment_share_F investment_share_I debt_stock_share tax_share_revenue_F oil_share_rev_transf oil_share_rev_ANP"
foreach i of local outcomes {
reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Discovery (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Other outcomes 
local outcomes "ihs_gdp_pc ihs_gdp ihs_population ihs_tot_formalempl_pc ihs_tot_hrscontract_pc score_educ ihs_rank_educ score_health ihs_rank_health score_empl ihs_rank_empl"
foreach i of local outcomes {
reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Discovery (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Private sector
local outcomes "ihs_n_empl_ag ihs_n_empl_const ihs_n_empl_extr ihs_n_empl_mfg ihs_n_empl_othserv ihs_n_empl_ret ihs_n_empl_tot ihs_n_empl_trade ihs_n_empl_oil ihs_n_firms_ag ihs_n_firms_nm_ag ihs_n_firms_const ihs_n_firms_nm_const ihs_n_firms_extr ihs_n_firms_nm_extr ihs_n_firms_mfg ihs_n_firms_nm_mfg ihs_n_firms_othserv ihs_n_firms_nm_othserv ihs_n_firms_ret ihs_n_firms_nm_ret ihs_n_firms_tot ihs_n_firms_nm_tot ihs_n_firms_trade ihs_n_firms_nm_trade"
foreach i of local outcomes {
reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Discovery (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

***************************************************************************************
***************************************************************************************
*Now explore differences in spillovers depending on whether munic is neighbor of disappointed versus satisfied
*Try to put both on same graph  

************************************************************************************
*FIRST, DISAPPOINTED 
*Organize and merge 
use "distance_disappointed", clear
 
rename code_muni munic_code 

sort munic_code 
order munic_code location_disappointed distance_disappointed 

save "Distance_to_Disappointed", replace 

**********************************************************************************
*Create dataset of treated munics and discoveries by year 
use "Munics_for_Matching_cleaned_outcomes", clear

keep munic_code municipality year number_cvm_announcements cum_cvm_announcements cvm_announcements_2000_2017

*Keep only treated munics 
keep if cvm_announcements_2000_2017 > 0

rename munic_code location_disappointed 
rename cum_cvm_announcements cum_cvm_nearest
rename cvm_announcements_2000_2017 cvm_2000_2017_nearest
rename number_cvm_announcements num_near_announcements

*Merge in disappointment 
merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

*Keep only disappointed units 
keep if disappointed_pc_med == 1

drop disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3

save "Treated_Munics_CVM_Disappointed", replace 
***********************************************************************************

*Merge distances with main outcomes dataset 
use "Munics_for_Matching_cleaned_outcomes", clear

merge m:1 munic_code using "Distance_to_Disappointed"

drop if _merge != 3
drop _merge

*********************************************************************************
*Create distance bins 
*THIS IS IMPORTANT
*ADJUST FOR DIFFERENT BINS
gen near_discovery = 0
replace near_discovery = 1 if distance_disappointed <= 50
replace near_discovery = 2 if distance_disappointed > 50 & distance_disappointed < 100
*********************************************************************************

*Now merge in discovery histories for treated units 
merge m:1 location_disappointed year using "Treated_Munics_CVM_Disappointed"
drop _merge 
sort munic_code year

********************************************************************************
*Set up relative time indicators. 
*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_nearest if cum_cvm_nearest != 0 & L1.cum_cvm_nearest == 0 & near_discovery == 1
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred in nearest treated munic

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (15 years in either direction).
forvalues i = 1(1)15 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)15 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Events are now totally saturated.

*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & num_near_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.num_near_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017

*Save dataset for analysis 
save "Spatial_Spillovers_Analysis_Disappointed", replace 

*******************************************************************************
*******************************************************************************
*Now, SATISFIED
*Organize and merge 
use "distance_satisfied", clear
 
rename code_muni munic_code 

sort munic_code 
order munic_code location_satisfied distance_satisfied 

save "Distance_to_Satisfied", replace 

**********************************************************************************
*Create dataset of treated munics and discoveries by year 
use "Munics_for_Matching_cleaned_outcomes", clear

keep munic_code municipality year number_cvm_announcements cum_cvm_announcements cvm_announcements_2000_2017

*Keep only treated munics 
keep if cvm_announcements_2000_2017 > 0

rename munic_code location_satisfied
rename cum_cvm_announcements cum_cvm_nearest
rename cvm_announcements_2000_2017 cvm_2000_2017_nearest
rename number_cvm_announcements num_near_announcements

*Merge in disappointed/satisfied
merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

*Keep only satisfied units 
keep if disappointed_pc_med == 2

drop disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3

save "Treated_Munics_CVM_Satisfied", replace 
***********************************************************************************

*Merge distances with main outcomes dataset 
use "Munics_for_Matching_cleaned_outcomes", clear

merge m:1 munic_code using "Distance_to_Satisfied"

drop if _merge != 3
drop _merge

*********************************************************************************
*Create distance bins 
*THIS IS IMPORTANT
*ADJUST FOR DIFFERENT BINS
gen near_discovery = 0
replace near_discovery = 1 if distance_satisfied <= 50
replace near_discovery = 2 if distance_satisfied > 50 & distance_satisfied < 100
*********************************************************************************

*Now merge in discovery histories for treated units 
merge m:1 location_satisfied year using "Treated_Munics_CVM_Satisfied"
drop _merge 
sort munic_code year

********************************************************************************
*Set up relative time indicators. 
*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_nearest if cum_cvm_nearest != 0 & L1.cum_cvm_nearest == 0 & near_discovery == 1
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred in nearest treated munic

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (15 years in either direction).
forvalues i = 1(1)15 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)15 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Events are now totally saturated.

*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & num_near_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.num_near_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017

*Save dataset for analysis 
save "Spatial_Spillovers_Analysis_Satisfied", replace 

*******************************************************************************
*Now plot results for spillovers from disappointed and satisfied onto neighbors on same graph 

*For main outcomes, plot graphs with properly centered event line
graph drop _all
estimates clear

*First, revenues 
local outcomes "ihs_rev_current_I_pc ihs_rev_taxes_I_pc ihs_oil_revenue_pc ihs_AFM_AFE_pc ihs_CIDE_fuel_pc ihs_FEX_pc ihs_FPM_pc ihs_FUNDEB_pc ihs_FUNDEF_pc ihs_ITR_pc ihs_LeiKandir_pc ihs_transf_nonoil_pc"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Spending 
local outcomes "ihs_spend_current_I_pc ihs_invest_F_pc ihs_spend_personnel_I_pc ihs_spend_admin_I_pc ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc ihs_spend_labor_I_pc"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Fiscal Health
local outcomes "spending_personnel_share investment_share_F investment_share_I debt_stock_share tax_share_revenue_F oil_share_rev_transf oil_share_rev_ANP"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Other
local outcomes "ihs_gdp_pc ihs_gdp ihs_population ihs_tot_formalempl_pc ihs_tot_hrscontract_pc score_educ ihs_rank_educ score_health ihs_rank_health score_empl ihs_rank_empl"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(8, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Private Sector 
local outcomes "ihs_n_empl_ag ihs_n_empl_const ihs_n_empl_extr ihs_n_empl_mfg ihs_n_empl_othserv ihs_n_empl_ret ihs_n_empl_tot ihs_n_empl_trade ihs_n_empl_oil ihs_n_firms_ag ihs_n_firms_nm_ag ihs_n_firms_const ihs_n_firms_nm_const ihs_n_firms_extr ihs_n_firms_nm_extr ihs_n_firms_mfg ihs_n_firms_nm_mfg ihs_n_firms_othserv ihs_n_firms_nm_othserv ihs_n_firms_ret ihs_n_firms_nm_ret ihs_n_firms_tot ihs_n_firms_nm_tot ihs_n_firms_trade ihs_n_firms_nm_trade"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}



**********************************************************************************************
**********************************************************************************************

*Repeat analysis, but only for units that are exposed to ONLY disappointed or ONLY satisfied 
*********************************************************************************
*Merge distances with main outcomes dataset 
use "Munics_for_Matching_cleaned_outcomes", clear

merge m:1 munic_code using "Distance_to_Discoveries"

drop if _merge != 3
drop _merge

*********************************************************************************
*Create distance bins 
*THIS IS IMPORTANT
*ADJUST FOR DIFFERENT BINS
gen near_discovery = 0
replace near_discovery = 1 if distance_disappointed <= 50 & distance_satisfied > 50
replace near_discovery = 2 if distance_disappointed > 50 & distance_disappointed <= 100 & distance_satisfied > 50

*********************************************************************************

*Now merge in discovery histories for treated units (disappointed)
merge m:1 location_disappointed year using "Treated_Munics_CVM_Disappointed"
drop _merge 
sort munic_code year

********************************************************************************
*Set up relative time indicators. 
*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_nearest if cum_cvm_nearest != 0 & L1.cum_cvm_nearest == 0 & near_discovery == 1
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred in nearest treated munic

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (15 years in either direction).
forvalues i = 1(1)15 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)15 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Events are now totally saturated.

*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & num_near_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.num_near_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017

*Save dataset for analysis 
save "Spatial_Spillovers_Analysis_Disappointed_Only", replace 

**********************************************************************************
*REPEAT FOR SATISFIED
*Merge distances with main outcomes dataset 
use "Munics_for_Matching_cleaned_outcomes", clear

merge m:1 munic_code using "Distance_to_Discoveries"

drop if _merge != 3
drop _merge

*********************************************************************************
*Create distance bins 
*THIS IS IMPORTANT
*ADJUST FOR DIFFERENT BINS
gen near_discovery = 0
replace near_discovery = 1 if distance_satisfied <= 50 & distance_disappointed > 50
replace near_discovery = 2 if distance_satisfied > 50 & distance_satisfied <= 100 & distance_disappointed > 50

*********************************************************************************

*Now merge in discovery histories for treated units (disappointed)
merge m:1 location_satisfied year using "Treated_Munics_CVM_Satisfied"
drop _merge 
sort munic_code year

********************************************************************************
*Set up relative time indicators. 
*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_nearest if cum_cvm_nearest != 0 & L1.cum_cvm_nearest == 0 & near_discovery == 1
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred in nearest treated munic

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (15 years in either direction).
forvalues i = 1(1)15 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)15 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Events are now totally saturated.

*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & num_near_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.num_near_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017

*Save dataset for analysis 
save "Spatial_Spillovers_Analysis_Satisfied_Only", replace 


****************************************************************************************
*ANALYSIS
*Now plot results for spillovers from disappointed and satisfied onto neighbors on same graph 

*For main outcomes, plot graphs with properly centered event line
graph drop _all
estimates clear

*First, revenues 
local outcomes "ihs_rev_current_I_pc ihs_rev_taxes_I_pc ihs_oil_revenue_pc ihs_AFM_AFE_pc ihs_CIDE_fuel_pc ihs_FEX_pc ihs_FPM_pc ihs_FUNDEB_pc ihs_FUNDEF_pc ihs_ITR_pc ihs_LeiKandir_pc ihs_transf_nonoil_pc"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed_Only", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied_Only", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Spending 
local outcomes "ihs_spend_current_I_pc ihs_invest_F_pc ihs_spend_personnel_I_pc ihs_spend_admin_I_pc ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc ihs_spend_labor_I_pc"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed_Only", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied_Only", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Fiscal Health
local outcomes "spending_personnel_share investment_share_F investment_share_I debt_stock_share tax_share_revenue_F oil_share_rev_transf oil_share_rev_ANP"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed_Only", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied_Only", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(10, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Other
local outcomes "ihs_gdp_pc ihs_gdp ihs_population ihs_tot_formalempl_pc ihs_tot_hrscontract_pc score_educ ihs_rank_educ score_health ihs_rank_health score_empl ihs_rank_empl"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed_Only", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied_Only", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Private Sector 
local outcomes "ihs_n_empl_ag ihs_n_empl_const ihs_n_empl_extr ihs_n_empl_mfg ihs_n_empl_othserv ihs_n_empl_ret ihs_n_empl_tot ihs_n_empl_trade ihs_n_empl_oil ihs_n_firms_ag ihs_n_firms_nm_ag ihs_n_firms_const ihs_n_firms_nm_const ihs_n_firms_extr ihs_n_firms_nm_extr ihs_n_firms_mfg ihs_n_firms_nm_mfg ihs_n_firms_othserv ihs_n_firms_nm_othserv ihs_n_firms_ret ihs_n_firms_nm_ret ihs_n_firms_tot ihs_n_firms_nm_tot ihs_n_firms_trade ihs_n_firms_nm_trade"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Disappointed_Only", clear
*Drop directly treated units  
drop if distance_disappointed == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Satisfied_Only", clear
*Drop directly treated units  
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 2 | near_discovery == 1, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (< 50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}



********************************************************************************
*Generate datasets with different spillover definitions 

*First, simple distance bands 
use "Spatial_Spillovers_Analysis_Disappointed", clear
keep munic_code near_discovery
rename near_discovery near_disappointed 
collapse (firstnm) near_disappointed, by(munic_code)
rename munic_code code_muni
save "Near_Disappointed_forMapping", replace


use "Spatial_Spillovers_Analysis_Satisfied", clear
keep munic_code near_discovery
rename near_discovery near_satisfied 
collapse (firstnm) near_satisfied, by(munic_code)
rename munic_code code_muni
save "Near_Satisfied_forMapping", replace

use "Near_Disappointed_forMapping", clear 
merge 1:1 code_muni using "Near_Satisfied_forMapping"

save "Near_Discoveries_SimpleDistance", replace 

********************************************************************************
********************************************************************************
*REPEAT WITH THREE GROUPS: NEAR DISAPPOINTED, NEAR SATISFIED, AND NEAR BOTH 
gen near_discovery = 0
replace near_discovery = 1 if distance_disappointed <= 50 
replace near_discovery = 2 if distance_disappointed > 50 & distance_disappointed <= 100 
replace near_discovery = 3 if distance_disappointed <= 50 & distance_satisfied <= 50
replace near_discovery = 4 if distance_disappointed > 50 & distance_disappointed <= 100 & distance_satisfied > 50 & distance_satisfied <= 100



**********************************************************************************
*Merge distances with main outcomes dataset 
use "Munics_for_Matching_cleaned_outcomes", clear

merge m:1 munic_code using "Distance_to_Discoveries"

drop if _merge != 3
drop _merge

*********************************************************************************
*Create distance bins 
*THIS IS IMPORTANT
*ADJUST FOR DIFFERENT BINS
gen near_disappointed = 0
replace near_disappointed = 1 if distance_disappointed <= 50 // close to disappointed
replace near_disappointed = 2 if distance_disappointed > 50 & distance_disappointed <= 100 // far from disappointed

gen near_satisfied = 0
replace near_satisfied = 1 if distance_satisfied <= 50 // close to satisfied
replace near_satisfied = 2 if distance_satisfied > 50 & distance_satisfied <= 100 // far from satisfied


gen near_discovery = 0
replace near_discovery = 1 if near_disappointed == 1 & near_satisfied != 1  // close to disappointed, not close to satisfied 
replace near_discovery = 2 if near_disappointed == 2 & near_satisfied != 1 // far from disappointed, not close to satisfied
replace near_discovery = 3 if near_satisfied == 1 & near_disappointed != 1  // close to satisfied but not close to disappointed
replace near_discovery = 4 if near_satisfied == 2 & near_disappointed != 1 // far from satisfied,  not close to disappointed
replace near_discovery = 5 if near_disappointed == 1 & near_satisfied == 1 // close to both
replace near_discovery = 6 if near_disappointed == 2 & near_satisfied == 2 // far from both 


*Save intermediate datasets 
preserve 
keep if near_discovery == 1 | near_discovery == 2
save "Spillovers_Intermediate_Disappointed", replace
restore

preserve 
keep if near_discovery ==  3 | near_discovery == 4
replace near_discovery = 1 if near_discovery == 3
replace near_discovery = 2 if near_discovery == 4
save "Spillovers_Intermediate_Satisfied", replace
restore

preserve 
keep if near_discovery == 5 | near_discovery == 6
replace near_discovery = 1 if near_discovery == 5
replace near_discovery = 2 if near_discovery == 6
save "Spillovers_Intermediate_Both", replace
restore

*********************************************************************************
use "Spillovers_Intermediate_Disappointed", clear

*Now merge in discovery histories for treated units 
merge m:1 location_discovery year using "Treated_Munics_CVM"
drop _merge 
sort munic_code year

********************************************************************************
*Set up relative time indicators. 
*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_nearest if cum_cvm_nearest != 0 & L1.cum_cvm_nearest == 0 & near_discovery == 1
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred in nearest treated munic

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (15 years in either direction).
forvalues i = 1(1)15 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)15 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Events are now totally saturated.

*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & num_near_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.num_near_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017

*Save dataset for analysis 
save "Spatial_Spillovers_Analysis_Combined_Disappointed", replace 


********************************************************************************8
*Repeat for satisfied 
use "Spillovers_Intermediate_Satisfied", clear

*Now merge in discovery histories for treated units 
merge m:1 location_discovery year using "Treated_Munics_CVM"
drop _merge 
sort munic_code year

********************************************************************************
*Set up relative time indicators. 
*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_nearest if cum_cvm_nearest != 0 & L1.cum_cvm_nearest == 0 & near_discovery == 1
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred in nearest treated munic

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (15 years in either direction).
forvalues i = 1(1)15 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)15 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Events are now totally saturated.

*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & num_near_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.num_near_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017

*Save dataset for analysis 
save "Spatial_Spillovers_Analysis_Combined_Satisfied", replace

**********************************************************************************
*Repeat for Both 
use "Spillovers_Intermediate_Both", clear

*Now merge in discovery histories for treated units 
merge m:1 location_discovery year using "Treated_Munics_CVM"
drop _merge 
sort munic_code year

********************************************************************************
*Set up relative time indicators. 
*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_nearest if cum_cvm_nearest != 0 & L1.cum_cvm_nearest == 0 & near_discovery == 1
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred in nearest treated munic

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (15 years in either direction).
forvalues i = 1(1)15 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)15 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Events are now totally saturated.

*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & num_near_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.num_near_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017

*Save dataset for analysis 
save "Spatial_Spillovers_Analysis_Combined_Both", replace


*********************************************************************************
*Collapse for mapping in R
keep munic_code near_discovery 
collapse (firstnm) near_discovery, by(munic_code)
rename munic_code code_muni 
save "Near_Discovery_forMapping_Combined", replace 

********************************************************************************
*Analysis

*For main outcomes, plot graphs with properly centered event line
graph drop _all
estimates clear


*First, revenues 
local outcomes "ihs_rev_current_I_pc ihs_rev_taxes_I_pc ihs_oil_revenue_pc ihs_AFM_AFE_pc ihs_CIDE_fuel_pc ihs_FEX_pc ihs_FPM_pc ihs_FUNDEB_pc ihs_FUNDEF_pc ihs_ITR_pc ihs_LeiKandir_pc ihs_transf_nonoil_pc"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Combined_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Combined_Satisfied", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

use "Spatial_Spillovers_Analysis_Combined_Both", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'3

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2 `i'3, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (<50km.)") lab(6 "Near Both Types (<50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Spending 
local outcomes "ihs_spend_current_I_pc ihs_invest_F_pc ihs_spend_personnel_I_pc ihs_spend_admin_I_pc ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc ihs_spend_labor_I_pc"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Combined_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Combined_Satisfied", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

use "Spatial_Spillovers_Analysis_Combined_Both", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'3

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2 `i'3, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (<50km.)") lab(6 "Near Both Types (<50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Fiscal Health
local outcomes "spending_personnel_share investment_share_F investment_share_I debt_stock_share tax_share_revenue_F oil_share_rev_transf oil_share_rev_ANP"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Combined_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Combined_Satisfied", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

use "Spatial_Spillovers_Analysis_Combined_Both", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'3

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2 `i'3, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (<50km.)") lab(6 "Near Both Types (<50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Other
local outcomes "ihs_gdp_pc ihs_gdp ihs_population ihs_tot_formalempl_pc ihs_tot_hrscontract_pc score_educ ihs_rank_educ score_health ihs_rank_health score_empl ihs_rank_empl"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Combined_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Combined_Satisfied", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

use "Spatial_Spillovers_Analysis_Combined_Both", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'3

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2 `i'3, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (<50km.)") lab(6 "Near Both Types (<50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

*Private Sector 
local outcomes "ihs_n_empl_ag ihs_n_empl_const ihs_n_empl_extr ihs_n_empl_mfg ihs_n_empl_othserv ihs_n_empl_ret ihs_n_empl_tot ihs_n_empl_trade ihs_n_empl_oil ihs_n_firms_ag ihs_n_firms_nm_ag ihs_n_firms_const ihs_n_firms_nm_const ihs_n_firms_extr ihs_n_firms_nm_extr ihs_n_firms_mfg ihs_n_firms_nm_mfg ihs_n_firms_othserv ihs_n_firms_nm_othserv ihs_n_firms_ret ihs_n_firms_nm_ret ihs_n_firms_tot ihs_n_firms_nm_tot ihs_n_firms_trade ihs_n_firms_nm_trade"
foreach i of local outcomes {

use "Spatial_Spillovers_Analysis_Combined_Disappointed", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'1

use "Spatial_Spillovers_Analysis_Combined_Satisfied", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'2

use "Spatial_Spillovers_Analysis_Combined_Both", clear
*Drop directly treated units  
drop if distance_disappointed == 0
drop if distance_satisfied == 0

reghdfe `i' event_time_15b event_time_14b event_time_13b event_time_12b event_time_11b event_time_10b event_time_9b event_time_8b event_time_7b event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a event_time_11a event_time_12a event_time_13a event_time_14a event_time_15a if near_discovery == 1 | near_discovery == 2, absorb(munic_code year) cluster(munic_code)
estimates store `i'3

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(3)
grstyle set symbol, n(4)
grstyle set compact
coefplot `i'1 `i'2 `i'3, coeflabels(event_time_10b="-10" event_time_9b="-9" event_time_8b="-8" event_time_7b="-7" event_time_6b="-6" event_time_5b="-5" event_time_4b="-4" event_time_3b="-3" event_time_2b="-2" event_time_0="0" event_time_1a="+1" event_time_2a="+2" event_time_3a="+3" event_time_4a="+4" event_time_5a="+5" event_time_6a="+6" event_time_7a="+7" event_time_8a="+8" event_time_9a="+9" event_time_10a="+10" event_time_11a="+11" event_time_12a="+12" event_time_13a="+13" event_time_14a="+14" event_time_15a="+15", notick labsize(medlarge)) keep(event_time_6b event_time_5b event_time_4b event_time_3b event_time_2b event_time_0 event_time_1a event_time_2a event_time_3a event_time_4a event_time_5a event_time_6a event_time_7a event_time_8a event_time_9a event_time_10a) vertical yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) legend(lab(2 "Near Disappointed Municipality (< 50km.)") lab(4 "Near Satisfied Municipality (<50km.)") lab(6 "Near Both Types (<50km.)")) xtitle("Years from CVM Discovery Announcement") ytitle("Coefficient Estimate") title("`i'") name(graph_`i') xlabel(,labsize(small))
}

grc1leg2 graph_ihs_rev_current_I_pc graph_ihs_oil_revenue_pc graph_ihs_spend_current_I_pc graph_ihs_invest_F_pc graph_ihs_gdp_pc graph_ihs_population


grc1leg2 graph_ihs_n_empl_ag graph_ihs_n_empl_const graph_ihs_n_empl_mfg graph_ihs_n_empl_ret graph_ihs_n_empl_tot graph_ihs_n_empl_trade 

grc1leg2 graph_ihs_n_firms_nm_ag graph_ihs_n_firms_nm_const graph_ihs_n_firms_nm_mfg graph_ihs_n_firms_nm_ret graph_ihs_n_firms_nm_tot graph_ihs_n_firms_nm_trade







******************************************************************************
*Next, exclusive distance bands 

*First, simple distance bands 
use "Spatial_Spillovers_Analysis_Disappointed_Only", clear
keep munic_code near_discovery
rename near_discovery near_disappointed 
collapse (firstnm) near_disappointed, by(munic_code)
rename munic_code code_muni
save "Near_Disappointed_forMapping_Exclusive", replace


use "Spatial_Spillovers_Analysis_Satisfied_Only", clear
keep munic_code near_discovery
rename near_discovery near_satisfied 
collapse (firstnm) near_satisfied, by(munic_code)
rename munic_code code_muni
save "Near_Satisfied_forMapping_Exclusive", replace

use "Near_Disappointed_forMapping_Exclusive", clear 
merge 1:1 code_muni using "Near_Satisfied_forMapping_Exclusive"

save "Near_Discoveries_ExclusiveDistance", replace 






