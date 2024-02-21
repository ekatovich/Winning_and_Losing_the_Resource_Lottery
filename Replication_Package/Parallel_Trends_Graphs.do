clear
cd "${user}\Data Directory\Treatment Variables"

*All coastal state municipalities
use "Event_Analysis_Matching_FirstEvent", clear

drop first_CVM_year
gen first_CVM_year = .
replace first_CVM_year = year if first_CVM > 0

drop if first_CVM_year == .

keep first_CVM_year 
rename first_CVM_year year
gen id = _n 

save "First_Years_List", replace 

*Sample 3912 times from First_Years_List to create list of event years for control group 
use "First_Years_List", clear 
set seed 15
expand 100
bsample 3912
gen munic_id = _n
drop id
rename year yr_first_event_simul

save "First_Years_Controls", replace 

********************************************************************************

*All coastal state municipalities
use "Event_Analysis_Matching_FirstEvent", clear

*First analyze treated units 
keep if disappointed_pc_low == 1 | disappointed_pc_low == 2

*Create relative time indicator 
*First for treated units
drop relative_time
gen relative_time = .
replace relative_time = 0 if event_time_0 == 1
replace relative_time = 1 if event_time_1a == 1
replace relative_time = 2 if event_time_2a == 1
replace relative_time = 3 if event_time_3a == 1
replace relative_time = 4 if event_time_4a == 1
replace relative_time = 5 if event_time_5a == 1
replace relative_time = 6 if event_time_6a == 1
replace relative_time = 7 if event_time_7a == 1
replace relative_time = 8 if event_time_8a == 1
replace relative_time = 9 if event_time_9a == 1
replace relative_time = 10 if event_time_10a == 1
replace relative_time = 11 if event_time_11a == 1
replace relative_time = 12 if event_time_12a == 1
replace relative_time = 13 if event_time_13a == 1
replace relative_time = 14 if event_time_14a == 1
replace relative_time = 15 if event_time_15a == 1

replace relative_time = -1 if event_time_1b == 1
replace relative_time = -2 if event_time_2b == 1
replace relative_time = -3 if event_time_3b == 1
replace relative_time = -4 if event_time_4b == 1
replace relative_time = -5 if event_time_5b == 1
replace relative_time = -6 if event_time_6b == 1
replace relative_time = -7 if event_time_7b == 1
replace relative_time = -8 if event_time_8b == 1
replace relative_time = -9 if event_time_9b == 1
replace relative_time = -10 if event_time_10b == 1
replace relative_time = -11 if event_time_11b == 1
replace relative_time = -12 if event_time_12b == 1
replace relative_time = -13 if event_time_13b == 1
replace relative_time = -14 if event_time_14b == 1
replace relative_time = -15 if event_time_15b == 1

*Sum public goods spending 
gen spending_pubgoods = spending_edculture_I + spending_hlthsanit_I
gen spending_pubgoods_pc = spending_pubgoods / population_complete
gen ihs_spending_pubgoods = asinh(spending_pubgoods)
gen ihs_spending_pubgoods_pc = asinh(spending_pubgoods_pc)



*Keep key outcomes (absolute and ihs) and collapse to treatment group year level 
*collapse (mean) ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_invest_F_pc ihs_population ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc revenue_current_I revenue_current_I_pc oil_revenue_pc investment_F_pc population spending_edculture_I_pc spending_hlthsanit_I_pc oil_revenue investment_F spending_edculture_I spending_hlthsanit_I ihs_spending_pubgoods spending_pubgoods spending_pubgoods_pc ihs_spending_pubgoods_pc, by(relative_time disappointed_pc_med)
collapse (mean) ihs_gdp_pc ihs_gdp ihs_population_complete ihs_revenue_current_I ihs_investment_F ihs_spending_pubgoods ihs_rev_current_I_pc ihs_invest_F_pc ihs_spending_pubgoods_pc (sd) sd_ihs_gdp = ihs_gdp sd_ihs_gdp_pc = ihs_gdp_pc sd_ihs_rev_current_I_pc = ihs_rev_current_I_pc sd_ihs_invest_F_pc = ihs_invest_F_pc sd_ihs_spending_pubgoods_pc = ihs_spending_pubgoods_pc sd_ihs_population = ihs_population_complete sd_ihs_rev_current_I = ihs_revenue_current_I sd_ihs_invest_F = ihs_investment_F sd_ihs_spending_pubgoods = ihs_spending_pubgoods, by(relative_time disappointed_pc_med)


gen ub_ihs_rev_current_I_pc=ihs_rev_current_I_pc+1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))
gen lb_ihs_rev_current_I_pc=ihs_rev_current_I_pc-1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))

gen ub_ihs_invest_F_pc=ihs_invest_F_pc+1.96*(sd_ihs_invest_F_pc/sqrt(_N))
gen lb_ihs_invest_F_pc=ihs_invest_F_pc-1.96*(sd_ihs_invest_F_pc/sqrt(_N))

gen ub_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc+1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))
gen lb_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc-1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))

gen ub_ihs_population=ihs_population_complete+1.96*(sd_ihs_population/sqrt(_N))
gen lb_ihs_population=ihs_population_complete-1.96*(sd_ihs_population/sqrt(_N))

gen ub_ihs_gdp_pc =ihs_gdp_pc+1.96*(sd_ihs_gdp_pc/sqrt(_N))
gen lb_ihs_gdp_pc =ihs_gdp_pc-1.96*(sd_ihs_gdp_pc/sqrt(_N))

gen ub_ihs_gdp =ihs_gdp+1.96*(sd_ihs_gdp/sqrt(_N))
gen lb_ihs_gdp =ihs_gdp-1.96*(sd_ihs_gdp/sqrt(_N))

gen ub_ihs_rev_current_I=ihs_rev_current_I+1.96*(sd_ihs_rev_current_I/sqrt(_N))
gen lb_ihs_rev_current_I=ihs_rev_current_I-1.96*(sd_ihs_rev_current_I/sqrt(_N))

gen ub_ihs_invest_F=ihs_invest_F+1.96*(sd_ihs_invest_F/sqrt(_N))
gen lb_ihs_invest_F=ihs_invest_F-1.96*(sd_ihs_invest_F/sqrt(_N))

gen ub_ihs_spending_pubgoods=ihs_spending_pubgoods+1.96*(sd_ihs_spending_pubgoods/sqrt(_N))
gen lb_ihs_spending_pubgoods=ihs_spending_pubgoods-1.96*(sd_ihs_spending_pubgoods/sqrt(_N))


sort disappointed_pc_med relative_time 

save "Mean_Outcomes_AllCoastal_Treated", replace 

********************************************************************************
*Now create relative time indicators for untreated. Typically, they're all set at -1. 
*But for this exercise, center them at random integers between 2002 and 2016 following the distribution of real first announcements 
use "Event_Analysis_Matching_FirstEvent", clear

*First analyze control units 
keep if disappointed_pc_low == 0
sort munic_code year

egen munic_id = group(munic_code) 

merge m:1 munic_id using "First_Years_Controls"
drop if _merge != 3
drop _merge 

drop relative_time
gen relative_time = .
replace relative_time = 0 if year == yr_first_event_simul 
replace relative_time = 1 if year == yr_first_event_simul + 1 
replace relative_time = 2 if year == yr_first_event_simul + 2
replace relative_time = 3 if year == yr_first_event_simul + 3
replace relative_time = 4 if year == yr_first_event_simul + 4
replace relative_time = 5 if year == yr_first_event_simul + 5
replace relative_time = 6 if year == yr_first_event_simul + 6
replace relative_time = 7 if year == yr_first_event_simul + 7
replace relative_time = 8 if year == yr_first_event_simul + 8
replace relative_time = 9 if year == yr_first_event_simul + 9
replace relative_time = 10 if year == yr_first_event_simul + 10
replace relative_time = 11 if year == yr_first_event_simul + 11
replace relative_time = 12 if year == yr_first_event_simul + 12
replace relative_time = 13 if year == yr_first_event_simul + 13
replace relative_time = 14 if year == yr_first_event_simul + 14
replace relative_time = 15 if year == yr_first_event_simul + 15

replace relative_time = -1 if year == yr_first_event_simul -1
replace relative_time = -2 if year == yr_first_event_simul -2
replace relative_time = -3 if year == yr_first_event_simul -3
replace relative_time = -4 if year == yr_first_event_simul -4
replace relative_time = -5 if year == yr_first_event_simul -5
replace relative_time = -6 if year == yr_first_event_simul -6
replace relative_time = -7 if year == yr_first_event_simul -7
replace relative_time = -8 if year == yr_first_event_simul -8
replace relative_time = -9 if year == yr_first_event_simul -9
replace relative_time = -10 if year == yr_first_event_simul -10
replace relative_time = -11 if year == yr_first_event_simul -11
replace relative_time = -12 if year == yr_first_event_simul -12
replace relative_time = -13 if year == yr_first_event_simul -13
replace relative_time = -14 if year == yr_first_event_simul -14
replace relative_time = -15 if year == yr_first_event_simul -15

*keep if relative_time > -11 & relative_time < 8

*Sum public goods spending 
gen spending_pubgoods = spending_edculture_I + spending_hlthsanit_I
gen spending_pubgoods_pc = spending_pubgoods / population_complete
gen ihs_spending_pubgoods = asinh(spending_pubgoods)
gen ihs_spending_pubgoods_pc = asinh(spending_pubgoods_pc)

*Keep key outcomes (absolute and ihs) and collapse to treatment group year level 
*collapse (mean) ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_invest_F_pc ihs_population ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc revenue_current_I revenue_current_I_pc oil_revenue_pc investment_F_pc population spending_edculture_I_pc spending_hlthsanit_I_pc oil_revenue investment_F spending_edculture_I spending_hlthsanit_I ihs_spending_pubgoods spending_pubgoods spending_pubgoods_pc ihs_spending_pubgoods_pc, by(relative_time disappointed_pc_med)
collapse (mean) ihs_gdp_pc ihs_gdp ihs_population_complete ihs_revenue_current_I ihs_investment_F ihs_spending_pubgoods ihs_rev_current_I_pc ihs_invest_F_pc ihs_spending_pubgoods_pc (sd) sd_ihs_gdp = ihs_gdp sd_ihs_gdp_pc = ihs_gdp_pc sd_ihs_rev_current_I_pc = ihs_rev_current_I_pc sd_ihs_invest_F_pc = ihs_invest_F_pc sd_ihs_spending_pubgoods_pc = ihs_spending_pubgoods_pc sd_ihs_population = ihs_population_complete sd_ihs_rev_current_I = ihs_revenue_current_I sd_ihs_invest_F = ihs_investment_F sd_ihs_spending_pubgoods = ihs_spending_pubgoods, by(relative_time disappointed_pc_med)

gen ub_ihs_rev_current_I_pc=ihs_rev_current_I_pc+1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))
gen lb_ihs_rev_current_I_pc=ihs_rev_current_I_pc-1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))

gen ub_ihs_invest_F_pc=ihs_invest_F_pc+1.96*(sd_ihs_invest_F_pc/sqrt(_N))
gen lb_ihs_invest_F_pc=ihs_invest_F_pc-1.96*(sd_ihs_invest_F_pc/sqrt(_N))

gen ub_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc+1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))
gen lb_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc-1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))

gen ub_ihs_population=ihs_population_complete+1.96*(sd_ihs_population/sqrt(_N))
gen lb_ihs_population=ihs_population_complete-1.96*(sd_ihs_population/sqrt(_N))

gen ub_ihs_gdp_pc =ihs_gdp_pc+1.96*(sd_ihs_gdp_pc/sqrt(_N))
gen lb_ihs_gdp_pc =ihs_gdp_pc-1.96*(sd_ihs_gdp_pc/sqrt(_N))

gen ub_ihs_gdp =ihs_gdp+1.96*(sd_ihs_gdp/sqrt(_N))
gen lb_ihs_gdp =ihs_gdp-1.96*(sd_ihs_gdp/sqrt(_N))

gen ub_ihs_rev_current_I=ihs_rev_current_I+1.96*(sd_ihs_rev_current_I/sqrt(_N))
gen lb_ihs_rev_current_I=ihs_rev_current_I-1.96*(sd_ihs_rev_current_I/sqrt(_N))

gen ub_ihs_invest_F=ihs_invest_F+1.96*(sd_ihs_invest_F/sqrt(_N))
gen lb_ihs_invest_F=ihs_invest_F-1.96*(sd_ihs_invest_F/sqrt(_N))

gen ub_ihs_spending_pubgoods=ihs_spending_pubgoods+1.96*(sd_ihs_spending_pubgoods/sqrt(_N))
gen lb_ihs_spending_pubgoods=ihs_spending_pubgoods-1.96*(sd_ihs_spending_pubgoods/sqrt(_N))



sort disappointed_pc_med relative_time 

save "Mean_Outcomes_AllCoastal_Controls", replace 

append using "Mean_Outcomes_AllCoastal_Treated", force  


*******************************************************************************
graph drop _all 

*Restrict to ten years before and after 
drop if relative_time < -5
drop if relative_time > 10

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue 
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .4pt .4pt 1pt .4pt .4pt 1pt .4pt .4pt
twoway line ihs_rev_current_I_pc relative_time if disappointed_pc_med == 1 || line ub_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 1 || line lb_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 1 || line ihs_rev_current_I_pc relative_time if disappointed_pc_med == 2 || line ub_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 2 || line lb_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 2 || line ihs_rev_current_I_pc relative_time if disappointed_pc_med == 0 || line ub_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 0 || line lb_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 0, xline(0)  title("Revenue per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) yscale(r(7.5 9.5)) name(all_revpc)


grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .4pt .4pt 1pt .4pt .4pt 1pt .4pt .4pt
twoway line ihs_invest_F_pc relative_time if disappointed_pc_med == 1 || line ub_ihs_invest_F_pc relative_time if disappointed_pc_med == 1 || line lb_ihs_invest_F_pc relative_time if disappointed_pc_med == 1 || line ihs_invest_F_pc relative_time if disappointed_pc_med == 2 || line ub_ihs_invest_F_pc relative_time if disappointed_pc_med == 2 || line lb_ihs_invest_F_pc relative_time if disappointed_pc_med == 2 || line ihs_invest_F_pc relative_time if disappointed_pc_med == 0 || line ub_ihs_invest_F_pc relative_time if disappointed_pc_med == 0 || line lb_ihs_invest_F_pc relative_time if disappointed_pc_med == 0, xline(0)  title("Investment per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) yscale(r(4 7)) ylabel(4(1)7) name(all_investpc)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 1 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 1 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 1 || line ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 2 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 2 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 2 || line ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 0 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 0 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 0, xline(0)  title("Public Goods Spending per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) yscale(r(6.5 8.5)) name(all_spendpubpc)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_population relative_time if disappointed_pc_med == 0 || line ub_ihs_population relative_time if disappointed_pc_med == 0 || line lb_ihs_population relative_time if disappointed_pc_med == 0 || line ihs_population relative_time if disappointed_pc_med == 1 || line ub_ihs_population relative_time if disappointed_pc_med == 1 || line lb_ihs_population relative_time if disappointed_pc_med == 1 || line ihs_population relative_time if disappointed_pc_med == 2 || line ub_ihs_population relative_time if disappointed_pc_med == 2 || line lb_ihs_population relative_time if disappointed_pc_med == 2, xline(0)  title("Population", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(Population)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) name(all_pop)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_gdp_pc relative_time if disappointed_pc_med == 1 || line ub_ihs_gdp_pc relative_time if disappointed_pc_med == 1 || line lb_ihs_gdp_pc relative_time if disappointed_pc_med == 1 || line ihs_gdp_pc relative_time if disappointed_pc_med == 2 || line ub_ihs_gdp_pc relative_time if disappointed_pc_med == 2 || line lb_ihs_gdp_pc relative_time if disappointed_pc_med == 2 || line ihs_gdp_pc relative_time if disappointed_pc_med == 0 || line ub_ihs_gdp_pc relative_time if disappointed_pc_med == 0 || line lb_ihs_gdp_pc relative_time if disappointed_pc_med == 0, xline(0)  title("GDP per capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(GDP per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) yscale(r(2 6)) name(all_gdppc)


**************************************************************************************8
****************************************************************************************
*Matched sample 

*Sample 3912 times from First_Years_List to create list of event years for control group 
use "First_Years_List", clear 
set seed 15
expand 100
*Draw number matching number of units in control dataset 
bsample 1100
gen munic_id = _n
drop id
rename year yr_first_event_simul

save "First_Years_Controls_Match", replace 

********************************************************************************

*Matched municipalities (preferred sample)
use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_low", clear

*First analyze treated units 
keep if disappointed_analysis == 1 | disappointed_analysis == 2

*Create relative time indicator 
*First for treated units
drop relative_time
gen relative_time = .
replace relative_time = 0 if event_time_0 == 1
replace relative_time = 1 if event_time_1a == 1
replace relative_time = 2 if event_time_2a == 1
replace relative_time = 3 if event_time_3a == 1
replace relative_time = 4 if event_time_4a == 1
replace relative_time = 5 if event_time_5a == 1
replace relative_time = 6 if event_time_6a == 1
replace relative_time = 7 if event_time_7a == 1
replace relative_time = 8 if event_time_8a == 1
replace relative_time = 9 if event_time_9a == 1
replace relative_time = 10 if event_time_10a == 1
replace relative_time = 11 if event_time_11a == 1
replace relative_time = 12 if event_time_12a == 1
replace relative_time = 13 if event_time_13a == 1
replace relative_time = 14 if event_time_14a == 1
replace relative_time = 15 if event_time_15a == 1

replace relative_time = -1 if event_time_1b == 1
replace relative_time = -2 if event_time_2b == 1
replace relative_time = -3 if event_time_3b == 1
replace relative_time = -4 if event_time_4b == 1
replace relative_time = -5 if event_time_5b == 1
replace relative_time = -6 if event_time_6b == 1
replace relative_time = -7 if event_time_7b == 1
replace relative_time = -8 if event_time_8b == 1
replace relative_time = -9 if event_time_9b == 1
replace relative_time = -10 if event_time_10b == 1
replace relative_time = -11 if event_time_11b == 1
replace relative_time = -12 if event_time_12b == 1
replace relative_time = -13 if event_time_13b == 1
replace relative_time = -14 if event_time_14b == 1
replace relative_time = -15 if event_time_15b == 1

*Sum public goods spending 
gen spending_pubgoods = spending_edculture_I + spending_hlthsanit_I
gen spending_pubgoods_pc = spending_pubgoods / population_complete
gen ihs_spending_pubgoods = asinh(spending_pubgoods)
gen ihs_spending_pubgoods_pc = asinh(spending_pubgoods_pc)

*Keep key outcomes (absolute and ihs) and collapse to treatment group year level 
*collapse (mean) ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_invest_F_pc ihs_population ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc revenue_current_I revenue_current_I_pc oil_revenue_pc investment_F_pc population spending_edculture_I_pc spending_hlthsanit_I_pc oil_revenue investment_F spending_edculture_I spending_hlthsanit_I ihs_spending_pubgoods spending_pubgoods spending_pubgoods_pc ihs_spending_pubgoods_pc, by(relative_time disappointed_analysis)
collapse (mean) ihs_gdp_pc ihs_gdp ihs_population_complete ihs_revenue_current_I ihs_investment_F ihs_spending_pubgoods ihs_rev_current_I_pc ihs_invest_F_pc ihs_spending_pubgoods_pc (sd) sd_ihs_gdp = ihs_gdp sd_ihs_gdp_pc = ihs_gdp_pc sd_ihs_rev_current_I_pc = ihs_rev_current_I_pc sd_ihs_invest_F_pc = ihs_invest_F_pc sd_ihs_spending_pubgoods_pc = ihs_spending_pubgoods_pc sd_ihs_population = ihs_population_complete sd_ihs_rev_current_I = ihs_revenue_current_I sd_ihs_invest_F = ihs_investment_F sd_ihs_spending_pubgoods = ihs_spending_pubgoods, by(relative_time disappointed_analysis)

gen ub_ihs_rev_current_I_pc=ihs_rev_current_I_pc+1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))
gen lb_ihs_rev_current_I_pc=ihs_rev_current_I_pc-1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))

gen ub_ihs_invest_F_pc=ihs_invest_F_pc+1.96*(sd_ihs_invest_F_pc/sqrt(_N))
gen lb_ihs_invest_F_pc=ihs_invest_F_pc-1.96*(sd_ihs_invest_F_pc/sqrt(_N))

gen ub_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc+1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))
gen lb_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc-1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))

gen ub_ihs_population=ihs_population_complete+1.96*(sd_ihs_population/sqrt(_N))
gen lb_ihs_population=ihs_population_complete-1.96*(sd_ihs_population/sqrt(_N))

gen ub_ihs_gdp_pc =ihs_gdp_pc+1.96*(sd_ihs_gdp_pc/sqrt(_N))
gen lb_ihs_gdp_pc =ihs_gdp_pc-1.96*(sd_ihs_gdp_pc/sqrt(_N))

gen ub_ihs_gdp =ihs_gdp+1.96*(sd_ihs_gdp/sqrt(_N))
gen lb_ihs_gdp =ihs_gdp-1.96*(sd_ihs_gdp/sqrt(_N))


gen ub_ihs_rev_current_I=ihs_rev_current_I+1.96*(sd_ihs_rev_current_I/sqrt(_N))
gen lb_ihs_rev_current_I=ihs_rev_current_I-1.96*(sd_ihs_rev_current_I/sqrt(_N))

gen ub_ihs_invest_F=ihs_invest_F+1.96*(sd_ihs_invest_F/sqrt(_N))
gen lb_ihs_invest_F=ihs_invest_F-1.96*(sd_ihs_invest_F/sqrt(_N))

gen ub_ihs_spending_pubgoods=ihs_spending_pubgoods+1.96*(sd_ihs_spending_pubgoods/sqrt(_N))
gen lb_ihs_spending_pubgoods=ihs_spending_pubgoods-1.96*(sd_ihs_spending_pubgoods/sqrt(_N))



sort disappointed_analysis relative_time 

save "Mean_Outcomes_Matched_Treated", replace 

********************************************************************************
*Now create relative time indicators for untreated. Typically, they're all set at -1. 
*But for this exercise, center them at random integers between 2002 and 2016 following the distribution of real first announcements 
use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_med", clear

*First analyze treated units 
keep if control_disappointed == 1
sort munic_code year

egen munic_id = group(munic_code) 

merge m:1 munic_id using "First_Years_Controls_Match"
drop if _merge != 3
drop _merge 

drop relative_time 
gen relative_time = .
replace relative_time = 0 if year == yr_first_event_simul 
replace relative_time = 1 if year == yr_first_event_simul + 1 
replace relative_time = 2 if year == yr_first_event_simul + 2
replace relative_time = 3 if year == yr_first_event_simul + 3
replace relative_time = 4 if year == yr_first_event_simul + 4
replace relative_time = 5 if year == yr_first_event_simul + 5
replace relative_time = 6 if year == yr_first_event_simul + 6
replace relative_time = 7 if year == yr_first_event_simul + 7
replace relative_time = 8 if year == yr_first_event_simul + 8
replace relative_time = 9 if year == yr_first_event_simul + 9
replace relative_time = 10 if year == yr_first_event_simul + 10
replace relative_time = 11 if year == yr_first_event_simul + 11
replace relative_time = 12 if year == yr_first_event_simul + 12
replace relative_time = 13 if year == yr_first_event_simul + 13
replace relative_time = 14 if year == yr_first_event_simul + 14
replace relative_time = 15 if year == yr_first_event_simul + 15

replace relative_time = -1 if year == yr_first_event_simul -1
replace relative_time = -2 if year == yr_first_event_simul -2
replace relative_time = -3 if year == yr_first_event_simul -3
replace relative_time = -4 if year == yr_first_event_simul -4
replace relative_time = -5 if year == yr_first_event_simul -5
replace relative_time = -6 if year == yr_first_event_simul -6
replace relative_time = -7 if year == yr_first_event_simul -7
replace relative_time = -8 if year == yr_first_event_simul -8
replace relative_time = -9 if year == yr_first_event_simul -9
replace relative_time = -10 if year == yr_first_event_simul -10
replace relative_time = -11 if year == yr_first_event_simul -11
replace relative_time = -12 if year == yr_first_event_simul -12
replace relative_time = -13 if year == yr_first_event_simul -13
replace relative_time = -14 if year == yr_first_event_simul -14
replace relative_time = -15 if year == yr_first_event_simul -15

*keep if relative_time > -11 & relative_time < 8

*Sum public goods spending 
gen spending_pubgoods = spending_edculture_I + spending_hlthsanit_I
gen spending_pubgoods_pc = spending_pubgoods / population_complete
gen ihs_spending_pubgoods = asinh(spending_pubgoods)
gen ihs_spending_pubgoods_pc = asinh(spending_pubgoods_pc)

*Keep key outcomes (absolute and ihs) and collapse to treatment group year level 
*collapse (mean) ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_invest_F_pc ihs_population ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc revenue_current_I revenue_current_I_pc oil_revenue_pc investment_F_pc population spending_edculture_I_pc spending_hlthsanit_I_pc oil_revenue investment_F spending_edculture_I spending_hlthsanit_I ihs_spending_pubgoods spending_pubgoods spending_pubgoods_pc ihs_spending_pubgoods_pc, by(relative_time disappointed_analysis)
collapse (mean) ihs_gdp_pc ihs_gdp ihs_population_complete ihs_revenue_current_I ihs_investment_F ihs_spending_pubgoods ihs_rev_current_I_pc ihs_invest_F_pc ihs_spending_pubgoods_pc (sd) sd_ihs_gdp = ihs_gdp sd_ihs_gdp_pc = ihs_gdp_pc sd_ihs_rev_current_I_pc = ihs_rev_current_I_pc sd_ihs_invest_F_pc = ihs_invest_F_pc sd_ihs_spending_pubgoods_pc = ihs_spending_pubgoods_pc sd_ihs_population = ihs_population_complete sd_ihs_rev_current_I = ihs_revenue_current_I sd_ihs_invest_F = ihs_investment_F sd_ihs_spending_pubgoods = ihs_spending_pubgoods, by(relative_time control_disappointed)

gen ub_ihs_rev_current_I_pc=ihs_rev_current_I_pc+1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))
gen lb_ihs_rev_current_I_pc=ihs_rev_current_I_pc-1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))

gen ub_ihs_invest_F_pc=ihs_invest_F_pc+1.96*(sd_ihs_invest_F_pc/sqrt(_N))
gen lb_ihs_invest_F_pc=ihs_invest_F_pc-1.96*(sd_ihs_invest_F_pc/sqrt(_N))

gen ub_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc+1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))
gen lb_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc-1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))

gen ub_ihs_population=ihs_population_complete+1.96*(sd_ihs_population/sqrt(_N))
gen lb_ihs_population=ihs_population_complete-1.96*(sd_ihs_population/sqrt(_N))

gen ub_ihs_gdp_pc =ihs_gdp_pc+1.96*(sd_ihs_gdp_pc/sqrt(_N))
gen lb_ihs_gdp_pc =ihs_gdp_pc-1.96*(sd_ihs_gdp_pc/sqrt(_N))

gen ub_ihs_gdp =ihs_gdp+1.96*(sd_ihs_gdp/sqrt(_N))
gen lb_ihs_gdp =ihs_gdp-1.96*(sd_ihs_gdp/sqrt(_N))


gen ub_ihs_rev_current_I=ihs_rev_current_I+1.96*(sd_ihs_rev_current_I/sqrt(_N))
gen lb_ihs_rev_current_I=ihs_rev_current_I-1.96*(sd_ihs_rev_current_I/sqrt(_N))

gen ub_ihs_invest_F=ihs_invest_F+1.96*(sd_ihs_invest_F/sqrt(_N))
gen lb_ihs_invest_F=ihs_invest_F-1.96*(sd_ihs_invest_F/sqrt(_N))

gen ub_ihs_spending_pubgoods=ihs_spending_pubgoods+1.96*(sd_ihs_spending_pubgoods/sqrt(_N))
gen lb_ihs_spending_pubgoods=ihs_spending_pubgoods-1.96*(sd_ihs_spending_pubgoods/sqrt(_N))

sort control_disappointed relative_time 

save "Mean_Outcomes_Matched_Control_Disappointed", replace 

*************************
*Repeat for control_satisfied 
use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_med", clear

*First analyze treated units 
keep if control_satisfied == 1
sort munic_code year

egen munic_id = group(munic_code) 

merge m:1 munic_id using "First_Years_Controls_Match"
drop if _merge != 3
drop _merge 

drop relative_time 
gen relative_time = .
replace relative_time = 0 if year == yr_first_event_simul 
replace relative_time = 1 if year == yr_first_event_simul + 1 
replace relative_time = 2 if year == yr_first_event_simul + 2
replace relative_time = 3 if year == yr_first_event_simul + 3
replace relative_time = 4 if year == yr_first_event_simul + 4
replace relative_time = 5 if year == yr_first_event_simul + 5
replace relative_time = 6 if year == yr_first_event_simul + 6
replace relative_time = 7 if year == yr_first_event_simul + 7
replace relative_time = 8 if year == yr_first_event_simul + 8
replace relative_time = 9 if year == yr_first_event_simul + 9
replace relative_time = 10 if year == yr_first_event_simul + 10
replace relative_time = 11 if year == yr_first_event_simul + 11
replace relative_time = 12 if year == yr_first_event_simul + 12
replace relative_time = 13 if year == yr_first_event_simul + 13
replace relative_time = 14 if year == yr_first_event_simul + 14
replace relative_time = 15 if year == yr_first_event_simul + 15

replace relative_time = -1 if year == yr_first_event_simul -1
replace relative_time = -2 if year == yr_first_event_simul -2
replace relative_time = -3 if year == yr_first_event_simul -3
replace relative_time = -4 if year == yr_first_event_simul -4
replace relative_time = -5 if year == yr_first_event_simul -5
replace relative_time = -6 if year == yr_first_event_simul -6
replace relative_time = -7 if year == yr_first_event_simul -7
replace relative_time = -8 if year == yr_first_event_simul -8
replace relative_time = -9 if year == yr_first_event_simul -9
replace relative_time = -10 if year == yr_first_event_simul -10
replace relative_time = -11 if year == yr_first_event_simul -11
replace relative_time = -12 if year == yr_first_event_simul -12
replace relative_time = -13 if year == yr_first_event_simul -13
replace relative_time = -14 if year == yr_first_event_simul -14
replace relative_time = -15 if year == yr_first_event_simul -15

*keep if relative_time > -11 & relative_time < 8

*Sum public goods spending 
gen spending_pubgoods = spending_edculture_I + spending_hlthsanit_I
gen spending_pubgoods_pc = spending_pubgoods / population_complete
gen ihs_spending_pubgoods = asinh(spending_pubgoods)
gen ihs_spending_pubgoods_pc = asinh(spending_pubgoods_pc)

*Keep key outcomes (absolute and ihs) and collapse to treatment group year level 
*collapse (mean) ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_invest_F_pc ihs_population ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc revenue_current_I revenue_current_I_pc oil_revenue_pc investment_F_pc population spending_edculture_I_pc spending_hlthsanit_I_pc oil_revenue investment_F spending_edculture_I spending_hlthsanit_I ihs_spending_pubgoods spending_pubgoods spending_pubgoods_pc ihs_spending_pubgoods_pc, by(relative_time disappointed_analysis)
collapse (mean) ihs_gdp_pc ihs_gdp ihs_population_complete ihs_revenue_current_I ihs_investment_F ihs_spending_pubgoods ihs_rev_current_I_pc ihs_invest_F_pc ihs_spending_pubgoods_pc (sd) sd_ihs_gdp = ihs_gdp sd_ihs_gdp_pc = ihs_gdp_pc sd_ihs_rev_current_I_pc = ihs_rev_current_I_pc sd_ihs_invest_F_pc = ihs_invest_F_pc sd_ihs_spending_pubgoods_pc = ihs_spending_pubgoods_pc sd_ihs_population = ihs_population_complete sd_ihs_rev_current_I = ihs_revenue_current_I sd_ihs_invest_F = ihs_investment_F sd_ihs_spending_pubgoods = ihs_spending_pubgoods, by(relative_time control_satisfied)

gen ub_ihs_rev_current_I_pc=ihs_rev_current_I_pc+1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))
gen lb_ihs_rev_current_I_pc=ihs_rev_current_I_pc-1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))

gen ub_ihs_invest_F_pc=ihs_invest_F_pc+1.96*(sd_ihs_invest_F_pc/sqrt(_N))
gen lb_ihs_invest_F_pc=ihs_invest_F_pc-1.96*(sd_ihs_invest_F_pc/sqrt(_N))

gen ub_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc+1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))
gen lb_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc-1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))

gen ub_ihs_population=ihs_population_complete+1.96*(sd_ihs_population/sqrt(_N))
gen lb_ihs_population=ihs_population_complete-1.96*(sd_ihs_population/sqrt(_N))

gen ub_ihs_gdp_pc =ihs_gdp_pc+1.96*(sd_ihs_gdp_pc/sqrt(_N))
gen lb_ihs_gdp_pc =ihs_gdp_pc-1.96*(sd_ihs_gdp_pc/sqrt(_N))

gen ub_ihs_gdp =ihs_gdp+1.96*(sd_ihs_gdp/sqrt(_N))
gen lb_ihs_gdp =ihs_gdp-1.96*(sd_ihs_gdp/sqrt(_N))


gen ub_ihs_rev_current_I=ihs_rev_current_I+1.96*(sd_ihs_rev_current_I/sqrt(_N))
gen lb_ihs_rev_current_I=ihs_rev_current_I-1.96*(sd_ihs_rev_current_I/sqrt(_N))

gen ub_ihs_invest_F=ihs_invest_F+1.96*(sd_ihs_invest_F/sqrt(_N))
gen lb_ihs_invest_F=ihs_invest_F-1.96*(sd_ihs_invest_F/sqrt(_N))

gen ub_ihs_spending_pubgoods=ihs_spending_pubgoods+1.96*(sd_ihs_spending_pubgoods/sqrt(_N))
gen lb_ihs_spending_pubgoods=ihs_spending_pubgoods-1.96*(sd_ihs_spending_pubgoods/sqrt(_N))

sort control_satisfied relative_time 

save "Mean_Outcomes_Matched_Control_Satisfied", replace 
*********************************************************

use "Mean_Outcomes_Matched_Control_Disappointed", clear
append using "Mean_Outcomes_Matched_Control_Satisfied", force
append using "Mean_Outcomes_Matched_Treated", force  

replace disappointed_analysis = 3 if control_disappointed == 1
replace disappointed_analysis = 4 if control_satisfied == 1


*******************************************************************************

*Restrict to ten years before and after 
drop if relative_time < -5
drop if relative_time > 10

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue orange gold gold
grstyle set lpattern solid dash dash solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_rev_current_I_pc relative_time if disappointed_analysis == 1 || line ub_ihs_rev_current_I_pc relative_time if disappointed_analysis == 1 || line lb_ihs_rev_current_I_pc relative_time if disappointed_analysis == 1 || line ihs_rev_current_I_pc relative_time if disappointed_analysis == 2 || line ub_ihs_rev_current_I_pc relative_time if disappointed_analysis == 2 || line lb_ihs_rev_current_I_pc relative_time if disappointed_analysis == 2 || line ihs_rev_current_I_pc relative_time if disappointed_analysis == 3 || line ub_ihs_rev_current_I_pc relative_time if disappointed_analysis == 3 || line lb_ihs_rev_current_I_pc relative_time if disappointed_analysis == 3 || line ihs_rev_current_I_pc relative_time if disappointed_analysis == 4 || line ub_ihs_rev_current_I_pc relative_time if disappointed_analysis == 4 || line lb_ihs_rev_current_I_pc relative_time if disappointed_analysis == 4 ||, xline(0)  title("Revenue per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated (Match Disappointed)" 10 "Never Treated (Match Satisfied)") size(small)) xscale(r(-5 10)) name(match_revpc)


grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue orange gold gold
grstyle set lpattern solid dash dash solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_invest_F_pc relative_time if disappointed_analysis == 1 || line ub_ihs_invest_F_pc relative_time if disappointed_analysis == 1 || line lb_ihs_invest_F_pc relative_time if disappointed_analysis == 1 || line ihs_invest_F_pc relative_time if disappointed_analysis == 2 || line ub_ihs_invest_F_pc relative_time if disappointed_analysis == 2 || line lb_ihs_invest_F_pc relative_time if disappointed_analysis == 2 || line ihs_invest_F_pc relative_time if disappointed_analysis == 3 || line ub_ihs_invest_F_pc relative_time if disappointed_analysis == 3 || line lb_ihs_invest_F_pc relative_time if disappointed_analysis == 3 || line ihs_invest_F_pc relative_time if disappointed_analysis == 4 || line ub_ihs_invest_F_pc relative_time if disappointed_analysis == 4 || line lb_ihs_invest_F_pc relative_time if disappointed_analysis == 4 ||, xline(0)  title("Investment per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated (Match Disappointed)" 10 "Never Treated (Match Satisfied)") size(small)) xscale(r(-5 10)) name(match_investpc)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue orange gold gold
grstyle set lpattern solid dash dash solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 1 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 1 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 1 || line ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 2 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 2 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 2 || line ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 3 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 3 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 3 || line ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 4 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 4 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_analysis == 4 ||, xline(0)  title("Public Goods Spending per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated (Match Disappointed)" 10 "Never Treated (Match Satisfied)") size(small)) xscale(r(-5 10)) name(match_pubgoodspc)


grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue orange gold gold
grstyle set lpattern solid dash dash solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_population relative_time if disappointed_analysis == 1 || line ub_ihs_population relative_time if disappointed_analysis == 1 || line lb_ihs_population relative_time if disappointed_analysis == 1 || line ihs_population relative_time if disappointed_analysis == 2 || line ub_ihs_population relative_time if disappointed_analysis == 2 || line lb_ihs_population relative_time if disappointed_analysis == 2 || line ihs_population relative_time if disappointed_analysis == 3 || line ub_ihs_population relative_time if disappointed_analysis == 3 || line lb_ihs_population relative_time if disappointed_analysis == 3 || line ihs_population relative_time if disappointed_analysis == 4 || line ub_ihs_population relative_time if disappointed_analysis == 4 || line lb_ihs_population relative_time if disappointed_analysis == 4 ||, xline(0)  title("Population", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated (Match Disappointed)" 10 "Never Treated (Match Satisfied)") size(small)) xscale(r(-5 10)) name(match_population)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue orange gold gold
grstyle set lpattern solid dash dash solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_gdp_pc relative_time if disappointed_analysis == 1 || line ub_ihs_gdp_pc relative_time if disappointed_analysis == 1 || line lb_ihs_gdp_pc relative_time if disappointed_analysis == 1 || line ihs_gdp_pc relative_time if disappointed_analysis == 2 || line ub_ihs_gdp_pc relative_time if disappointed_analysis == 2 || line lb_ihs_gdp_pc relative_time if disappointed_analysis == 2 || line ihs_gdp_pc relative_time if disappointed_analysis == 3 || line ub_ihs_gdp_pc relative_time if disappointed_analysis == 3 || line lb_ihs_gdp_pc relative_time if disappointed_analysis == 3 || line ihs_gdp_pc relative_time if disappointed_analysis == 4 || line ub_ihs_gdp_pc relative_time if disappointed_analysis == 4 || line lb_ihs_gdp_pc relative_time if disappointed_analysis == 4 ||, xline(0)  title("GDP per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated (Match Disappointed)" 10 "Never Treated (Match Satisfied)") size(small)) xscale(r(-5 10)) name(match_gdppc)

******************************************************************************************
******************************************************************************************
*Wells Sample

*Sample 3912 times from First_Years_List to create list of event years for control group 
use "First_Years_List", clear 
set seed 15
expand 2
*Draw number matching number of units in control dataset 
bsample 53
gen munic_id = _n
drop id
rename year yr_first_event_simul

save "First_Years_Controls_Wells", replace 

********************************************************************************
*Wells sample
use "Event_Analysis_Wells_FirstEvent", clear

*First analyze treated units 
keep if disappointed_pc_med == 1 | disappointed_pc_med == 2

*Create relative time indicator 
*First for treated units
drop relative_time 
gen relative_time = .
replace relative_time = 0 if event_time_0 == 1
replace relative_time = 1 if event_time_1a == 1
replace relative_time = 2 if event_time_2a == 1
replace relative_time = 3 if event_time_3a == 1
replace relative_time = 4 if event_time_4a == 1
replace relative_time = 5 if event_time_5a == 1
replace relative_time = 6 if event_time_6a == 1
replace relative_time = 7 if event_time_7a == 1
replace relative_time = 8 if event_time_8a == 1
replace relative_time = 9 if event_time_9a == 1
replace relative_time = 10 if event_time_10a == 1
replace relative_time = 11 if event_time_11a == 1
replace relative_time = 12 if event_time_12a == 1
replace relative_time = 13 if event_time_13a == 1
replace relative_time = 14 if event_time_14a == 1
replace relative_time = 15 if event_time_15a == 1

replace relative_time = -1 if event_time_1b == 1
replace relative_time = -2 if event_time_2b == 1
replace relative_time = -3 if event_time_3b == 1
replace relative_time = -4 if event_time_4b == 1
replace relative_time = -5 if event_time_5b == 1
replace relative_time = -6 if event_time_6b == 1
replace relative_time = -7 if event_time_7b == 1
replace relative_time = -8 if event_time_8b == 1
replace relative_time = -9 if event_time_9b == 1
replace relative_time = -10 if event_time_10b == 1
replace relative_time = -11 if event_time_11b == 1
replace relative_time = -12 if event_time_12b == 1
replace relative_time = -13 if event_time_13b == 1
replace relative_time = -14 if event_time_14b == 1
replace relative_time = -15 if event_time_15b == 1

*Sum public goods spending 
gen spending_pubgoods = spending_edculture_I + spending_hlthsanit_I
gen spending_pubgoods_pc = spending_pubgoods / population_complete
gen ihs_spending_pubgoods = asinh(spending_pubgoods)
gen ihs_spending_pubgoods_pc = asinh(spending_pubgoods_pc)

*gen ihs_population_complete = asinh(population_complete)

*Keep key outcomes (absolute and ihs) and collapse to treatment group year level 
*collapse (mean) ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_invest_F_pc ihs_population ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc revenue_current_I revenue_current_I_pc oil_revenue_pc investment_F_pc population spending_edculture_I_pc spending_hlthsanit_I_pc oil_revenue investment_F spending_edculture_I spending_hlthsanit_I ihs_spending_pubgoods spending_pubgoods spending_pubgoods_pc ihs_spending_pubgoods_pc, by(relative_time disappointed_pc_med)
collapse (mean) ihs_gdp_pc ihs_gdp ihs_population_complete ihs_revenue_current_I ihs_investment_F ihs_spending_pubgoods ihs_rev_current_I_pc ihs_invest_F_pc ihs_spending_pubgoods_pc (sd) sd_ihs_gdp = ihs_gdp sd_ihs_gdp_pc = ihs_gdp_pc sd_ihs_rev_current_I_pc = ihs_rev_current_I_pc sd_ihs_invest_F_pc = ihs_invest_F_pc sd_ihs_spending_pubgoods_pc = ihs_spending_pubgoods_pc sd_ihs_population = ihs_population_complete sd_ihs_rev_current_I = ihs_revenue_current_I sd_ihs_invest_F = ihs_investment_F sd_ihs_spending_pubgoods = ihs_spending_pubgoods, by(relative_time disappointed_pc_med)

gen ub_ihs_rev_current_I_pc=ihs_rev_current_I_pc+1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))
gen lb_ihs_rev_current_I_pc=ihs_rev_current_I_pc-1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))

gen ub_ihs_invest_F_pc=ihs_invest_F_pc+1.96*(sd_ihs_invest_F_pc/sqrt(_N))
gen lb_ihs_invest_F_pc=ihs_invest_F_pc-1.96*(sd_ihs_invest_F_pc/sqrt(_N))

gen ub_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc+1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))
gen lb_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc-1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))

gen ub_ihs_population=ihs_population_complete+1.96*(sd_ihs_population/sqrt(_N))
gen lb_ihs_population=ihs_population_complete-1.96*(sd_ihs_population/sqrt(_N))

gen ub_ihs_gdp_pc =ihs_gdp_pc+1.96*(sd_ihs_gdp_pc/sqrt(_N))
gen lb_ihs_gdp_pc =ihs_gdp_pc-1.96*(sd_ihs_gdp_pc/sqrt(_N))

gen ub_ihs_gdp =ihs_gdp+1.96*(sd_ihs_gdp/sqrt(_N))
gen lb_ihs_gdp =ihs_gdp-1.96*(sd_ihs_gdp/sqrt(_N))

gen ub_ihs_rev_current_I=ihs_rev_current_I+1.96*(sd_ihs_rev_current_I/sqrt(_N))
gen lb_ihs_rev_current_I=ihs_rev_current_I-1.96*(sd_ihs_rev_current_I/sqrt(_N))

gen ub_ihs_invest_F=ihs_invest_F+1.96*(sd_ihs_invest_F/sqrt(_N))
gen lb_ihs_invest_F=ihs_invest_F-1.96*(sd_ihs_invest_F/sqrt(_N))

gen ub_ihs_spending_pubgoods=ihs_spending_pubgoods+1.96*(sd_ihs_spending_pubgoods/sqrt(_N))
gen lb_ihs_spending_pubgoods=ihs_spending_pubgoods-1.96*(sd_ihs_spending_pubgoods/sqrt(_N))


sort disappointed_pc_med relative_time 

save "Mean_Outcomes_Wells_Treated", replace 

********************************************************************************
*Now create relative time indicators for untreated. Typically, they're all set at -1. 
*But for this exercise, center them at random integers between 2002 and 2016 following the distribution of real first announcements 
use "Event_Analysis_Wells_FirstEvent", clear

*Now analyze control units 
keep if disappointed_pc_med == 0
sort munic_code year

egen munic_id = group(munic_code) 

merge m:1 munic_id using "First_Years_Controls"
drop if _merge != 3
drop _merge 

drop relative_time 
gen relative_time = .
replace relative_time = 0 if year == yr_first_event_simul 
replace relative_time = 1 if year == yr_first_event_simul + 1 
replace relative_time = 2 if year == yr_first_event_simul + 2
replace relative_time = 3 if year == yr_first_event_simul + 3
replace relative_time = 4 if year == yr_first_event_simul + 4
replace relative_time = 5 if year == yr_first_event_simul + 5
replace relative_time = 6 if year == yr_first_event_simul + 6
replace relative_time = 7 if year == yr_first_event_simul + 7
replace relative_time = 8 if year == yr_first_event_simul + 8
replace relative_time = 9 if year == yr_first_event_simul + 9
replace relative_time = 10 if year == yr_first_event_simul + 10
replace relative_time = 11 if year == yr_first_event_simul + 11
replace relative_time = 12 if year == yr_first_event_simul + 12
replace relative_time = 13 if year == yr_first_event_simul + 13
replace relative_time = 14 if year == yr_first_event_simul + 14
replace relative_time = 15 if year == yr_first_event_simul + 15

replace relative_time = -1 if year == yr_first_event_simul -1
replace relative_time = -2 if year == yr_first_event_simul -2
replace relative_time = -3 if year == yr_first_event_simul -3
replace relative_time = -4 if year == yr_first_event_simul -4
replace relative_time = -5 if year == yr_first_event_simul -5
replace relative_time = -6 if year == yr_first_event_simul -6
replace relative_time = -7 if year == yr_first_event_simul -7
replace relative_time = -8 if year == yr_first_event_simul -8
replace relative_time = -9 if year == yr_first_event_simul -9
replace relative_time = -10 if year == yr_first_event_simul -10
replace relative_time = -11 if year == yr_first_event_simul -11
replace relative_time = -12 if year == yr_first_event_simul -12
replace relative_time = -13 if year == yr_first_event_simul -13
replace relative_time = -14 if year == yr_first_event_simul -14
replace relative_time = -15 if year == yr_first_event_simul -15

*keep if relative_time > -11 & relative_time < 8

*Sum public goods spending 
gen spending_pubgoods = spending_edculture_I + spending_hlthsanit_I
gen spending_pubgoods_pc = spending_pubgoods / population_complete
gen ihs_spending_pubgoods = asinh(spending_pubgoods)
gen ihs_spending_pubgoods_pc = asinh(spending_pubgoods_pc)

*gen ihs_population_complete = asinh(population_complete)

*Keep key outcomes (absolute and ihs) and collapse to treatment group year level 
*collapse (mean) ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_invest_F_pc ihs_population ihs_spend_edculture_I_pc ihs_spend_housurban_I_pc ihs_spend_hlthsanit_I_pc revenue_current_I revenue_current_I_pc oil_revenue_pc investment_F_pc population spending_edculture_I_pc spending_hlthsanit_I_pc oil_revenue investment_F spending_edculture_I spending_hlthsanit_I ihs_spending_pubgoods spending_pubgoods spending_pubgoods_pc ihs_spending_pubgoods_pc, by(relative_time disappointed_pc_med)
collapse (mean) ihs_gdp_pc ihs_gdp ihs_population_complete ihs_revenue_current_I ihs_investment_F ihs_spending_pubgoods ihs_rev_current_I_pc ihs_invest_F_pc ihs_spending_pubgoods_pc (sd) sd_ihs_gdp = ihs_gdp sd_ihs_gdp_pc = ihs_gdp_pc sd_ihs_rev_current_I_pc = ihs_rev_current_I_pc sd_ihs_invest_F_pc = ihs_invest_F_pc sd_ihs_spending_pubgoods_pc = ihs_spending_pubgoods_pc sd_ihs_population = ihs_population_complete sd_ihs_rev_current_I = ihs_revenue_current_I sd_ihs_invest_F = ihs_investment_F sd_ihs_spending_pubgoods = ihs_spending_pubgoods, by(relative_time disappointed_pc_med)

gen ub_ihs_rev_current_I_pc=ihs_rev_current_I_pc+1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))
gen lb_ihs_rev_current_I_pc=ihs_rev_current_I_pc-1.96*(sd_ihs_rev_current_I_pc/sqrt(_N))

gen ub_ihs_invest_F_pc=ihs_invest_F_pc+1.96*(sd_ihs_invest_F_pc/sqrt(_N))
gen lb_ihs_invest_F_pc=ihs_invest_F_pc-1.96*(sd_ihs_invest_F_pc/sqrt(_N))

gen ub_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc+1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))
gen lb_ihs_spending_pubgoods_pc=ihs_spending_pubgoods_pc-1.96*(sd_ihs_spending_pubgoods_pc/sqrt(_N))

gen ub_ihs_population=ihs_population_complete+1.96*(sd_ihs_population/sqrt(_N))
gen lb_ihs_population=ihs_population_complete-1.96*(sd_ihs_population/sqrt(_N))

gen ub_ihs_gdp_pc =ihs_gdp_pc+1.96*(sd_ihs_gdp_pc/sqrt(_N))
gen lb_ihs_gdp_pc =ihs_gdp_pc-1.96*(sd_ihs_gdp_pc/sqrt(_N))

gen ub_ihs_gdp =ihs_gdp+1.96*(sd_ihs_gdp/sqrt(_N))
gen lb_ihs_gdp =ihs_gdp-1.96*(sd_ihs_gdp/sqrt(_N))


gen ub_ihs_rev_current_I=ihs_rev_current_I+1.96*(sd_ihs_rev_current_I/sqrt(_N))
gen lb_ihs_rev_current_I=ihs_rev_current_I-1.96*(sd_ihs_rev_current_I/sqrt(_N))

gen ub_ihs_invest_F=ihs_invest_F+1.96*(sd_ihs_invest_F/sqrt(_N))
gen lb_ihs_invest_F=ihs_invest_F-1.96*(sd_ihs_invest_F/sqrt(_N))

gen ub_ihs_spending_pubgoods=ihs_spending_pubgoods+1.96*(sd_ihs_spending_pubgoods/sqrt(_N))
gen lb_ihs_spending_pubgoods=ihs_spending_pubgoods-1.96*(sd_ihs_spending_pubgoods/sqrt(_N))

sort disappointed_pc_med relative_time 

save "Mean_Outcomes_Wells_Controls", replace 

append using "Mean_Outcomes_Wells_Treated", force  

*******************************************************************************
*Restrict to ten years before and after 
drop if relative_time < -5
drop if relative_time > 10

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_rev_current_I_pc relative_time if disappointed_pc_med == 1 || line ub_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 1 || line lb_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 1 || line ihs_rev_current_I_pc relative_time if disappointed_pc_med == 2 || line ub_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 2 || line lb_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 2 || line ihs_rev_current_I_pc relative_time if disappointed_pc_med == 0 || line ub_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 0 || line lb_ihs_rev_current_I_pc relative_time if disappointed_pc_med == 0, xline(0)  title("Revenue per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated")) xscale(r(-5 10)) yscale(r(7.5 9.5)) name(wells_revpc)


grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_invest_F_pc relative_time if disappointed_pc_med == 1 || line ub_ihs_invest_F_pc relative_time if disappointed_pc_med == 1 || line lb_ihs_invest_F_pc relative_time if disappointed_pc_med == 1 || line ihs_invest_F_pc relative_time if disappointed_pc_med == 2 || line ub_ihs_invest_F_pc relative_time if disappointed_pc_med == 2 || line lb_ihs_invest_F_pc relative_time if disappointed_pc_med == 2 || line ihs_invest_F_pc relative_time if disappointed_pc_med == 0 || line ub_ihs_invest_F_pc relative_time if disappointed_pc_med == 0 || line lb_ihs_invest_F_pc relative_time if disappointed_pc_med == 0, xline(0)  title("Investment per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) yscale(r(4 7)) ylabel(4(1)7) name(wells_investpc)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 1 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 1 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 1 || line ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 2 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 2 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 2 || line ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 0 || line ub_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 0 || line lb_ihs_spending_pubgoods_pc relative_time if disappointed_pc_med == 0, xline(0)  title("Public Goods Spending per Capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(R$ per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) yscale(r(6.5 8.5)) name(wells_spendpubpc)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_population relative_time if disappointed_pc_med == 0 || line ub_ihs_population relative_time if disappointed_pc_med == 0 || line lb_ihs_population relative_time if disappointed_pc_med == 0 || line ihs_population relative_time if disappointed_pc_med == 1 || line ub_ihs_population relative_time if disappointed_pc_med == 1 || line lb_ihs_population relative_time if disappointed_pc_med == 1 || line ihs_population relative_time if disappointed_pc_med == 2 || line ub_ihs_population relative_time if disappointed_pc_med == 2 || line lb_ihs_population relative_time if disappointed_pc_med == 2, xline(0)  title("Population", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(Population)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) name(wells_pop)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry erose erose green olive_teal olive_teal blue eltblue eltblue
grstyle set lpattern solid dash dash solid dash dash solid dash dash 
grstyle set linewidth 1pt .45pt .45pt 1pt .45pt .45pt 1pt .45pt .45pt
twoway line ihs_gdp_pc relative_time if disappointed_pc_med == 1 || line ub_ihs_gdp_pc relative_time if disappointed_pc_med == 1 || line lb_ihs_gdp_pc relative_time if disappointed_pc_med == 1 || line ihs_gdp_pc relative_time if disappointed_pc_med == 2 || line ub_ihs_gdp_pc relative_time if disappointed_pc_med == 2 || line lb_ihs_gdp_pc relative_time if disappointed_pc_med == 2 || line ihs_gdp_pc relative_time if disappointed_pc_med == 0 || line ub_ihs_gdp_pc relative_time if disappointed_pc_med == 0 || line lb_ihs_gdp_pc relative_time if disappointed_pc_med == 0, xline(0)  title("GDP per capita", size(medium)) xtitle("Years Relative to First Discovery Announcement", size(small)) ytitle("asinh(GDP per Capita)") legend(order(1 "Treated (Disappointed)" 4 "Treated (Satisfied)" 7 "Never Treated") size(small)) xscale(r(-5 10)) yscale(r(2 6)) name(wells_gdppc)


****************************************************************************************
*Graph together 
*grc1leg2 all_revpc match_revpc wells_revpc all_investpc match_investpc wells_investpc all_spendpubpc match_spendpubpc wells_spendpubpc all_pop match_pop wells_pop, holes(4 8 12 16)

*All coastal 
grc1leg2 all_revpc all_investpc all_spendpubpc all_gdppc, holes(3 6) title("Coastal State Municipalities", size(medsmall))
graph export "${output}\Descriptives\parallel_trends_coastal.pdf", replace

*Matched
grc1leg2 match_revpc match_investpc match_pubgoodspc match_gdppc, holes(3 6) title("Matched Municipalities", size(medsmall))
graph export "${output}\Descriptives\parallel_trends_matched.pdf", replace

*Wells
grc1leg2 wells_revpc wells_investpc wells_spendpubpc wells_gdppc, holes(3 6) title("Municipalities with Offshore Wells", size(medsmall))
graph export "${output}\Descriptives\parallel_trends_wells.pdf", replace
