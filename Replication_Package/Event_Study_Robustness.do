clear
cd "${user}\Data Directory\Treatment Variables"

graph drop _all
estimates clear
set seed 39627236

*local outcomes "ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_transf_nonoil_pc ihs_spend_current_I_pc ihs_invest_F_pc ihs_spend_edculture_I_pc ihs_spend_hlthsanit_I_pc ihs_gdp_pc ihs_population"
local outcomes "ihs_rev_current_I_pc ihs_spend_current_I_pc ihs_invest_F_pc ihs_gdp_pc score_educ score_health"
foreach i of local outcomes {
	
	*Main specification:
	use "Analysis_for_R_SantAnna_WellsOnly_V2", clear 	
	csdid `i' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_m")

	csdid `i' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_m")
	
	
	*Robustness 1: CS, MEDIUM forecast, WELLS  
	use "Analysis_for_R_SantAnna_WellsOnly_V2", clear 

	csdid `i' if disappointed_pc_med == 0 | disappointed_pc_med == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_1")

	csdid `i' if disappointed_pc_med == 0 | disappointed_pc_med == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_1")

	
	*Robustness 2: CS, MEDIUM forecast, MATCHED 
	use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_low", clear 
	replace first_CVM_year = 0 if first_CVM_year == .
	duplicates drop munic_code year, force
	
	csdid `i' if disappointed_pc_med == 0 | disappointed_pc_med == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_2")

	csdid `i' if disappointed_pc_med == 0 | disappointed_pc_med == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_2")
	

	*Robustness 3: CS, HIGH forecast, WELLS  
	use "Analysis_for_R_SantAnna_WellsOnly_V2", clear 

	csdid `i' if disappointed_pc_high == 0 | disappointed_pc_high == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_3")

	csdid `i' if disappointed_pc_high == 0 | disappointed_pc_high == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_3")

	
	*Robustness 2: CS, HIGH forecast, MATCHED 
	use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_low", clear 
	replace first_CVM_year = 0 if first_CVM_year == .
	duplicates drop munic_code year, force
	
	csdid `i' if disappointed_pc_high == 0 | disappointed_pc_high == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_4")

	csdid `i' if disappointed_pc_high == 0 | disappointed_pc_high == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_4")
	

	*Robustness 3: CS, LOW forecast, REVENUE MATCH 
	use "Event_Analysis_CEMDetailed_FirstEvent_disappointed_pc_low_altmatch", clear
	replace first_CVM_year = 0 if first_CVM_year == .
	duplicates drop munic_code year, force
	
	csdid `i' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_5")

	csdid `i' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_5")
	
	*Robustness 4: CS, PRODUCTION, WELLS 
	use "Analysis_for_R_SantAnna_WellsOnly_V2", clear 
	
	*Identify production at time of discovery 
	bysort munic_code: gen prod_at_discovery_tmp = prod_boe if first_CVM_year == year 
	bysort munic_code: egen prod_at_discovery = max(prod_at_discovery_tmp) 
	drop prod_at_discovery_tmp

	*Identify production in 2017
	bysort munic_code: gen prod_2017_tmp = prod_boe if year == 2017 
	bysort munic_code: egen prod_2017 = max(prod_2017_tmp) 
	drop prod_2017_tmp

	*Identify municipalities that are disappointed or satisfied purely in production outcome terms 
	gen disappointed_prod = 0
	replace disappointed_prod = 1 if prod_2017 < (2*prod_at_discovery) 
	replace disappointed_prod = 2 if prod_2017 >= (2*prod_at_discovery)

	csdid `i' if disappointed_prod == 0 | disappointed_prod == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_7")

	csdid `i' if disappointed_prod == 0 | disappointed_prod == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_7")		
	
	*Robustness 5: CS, Production, MATCHED 
	use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_low", clear 
	replace first_CVM_year = 0 if first_CVM_year == .
	duplicates drop munic_code year, force
	
	*Identify production at time of discovery 
	bysort munic_code: gen prod_at_discovery_tmp = prod_boe if first_CVM_year == year 
	bysort munic_code: egen prod_at_discovery = max(prod_at_discovery_tmp) 
	drop prod_at_discovery_tmp

	*Identify production in 2017
	bysort munic_code: gen prod_2017_tmp = prod_boe if year == 2017 
	bysort munic_code: egen prod_2017 = max(prod_2017_tmp) 
	drop prod_2017_tmp

	*Identify municipalities that are disappointed or satisfied purely in production outcome terms 
	gen disappointed_prod = 0
	replace disappointed_prod = 1 if prod_2017 < (2*prod_at_discovery) 
	replace disappointed_prod = 2 if prod_2017 >= (2*prod_at_discovery)
	
	csdid `i' if disappointed_prod == 0 | disappointed_prod == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_8")

	csdid `i' if disappointed_prod == 0 | disappointed_prod == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_8")	
	
	
	*Robustness 6: CS, Low forecast TOTAL, FULL SAMPLE
	use "Event_Analysis_FirstEvent", clear
	replace first_CVM_year = 0 if first_CVM_year == .
	duplicates drop munic_code year, force
	
	csdid `i' if disappointed_total_low == 0 | disappointed_total_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_9")

	csdid `i' if disappointed_total_low == 0 | disappointed_total_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_9")	
	
	*Robustness 7: CS, MEDIUM Forecast, FULL SAMPLE 
	csdid `i' if disappointed_total_high == 0 | disappointed_total_high == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`i'_10")

	csdid `i' if disappointed_total_high == 0 | disappointed_total_high == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`i'_10")	
	
	*Robustness: main specification with micro-region standard errors 
	use "Analysis_for_R_SantAnna_WellsOnly_V2", clear 	
	csdid `i' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year) cluster(micro_code)
	estat all 
	estat event, estore("d_`i'_11")

	csdid `i' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year) cluster(micro_code)
	estat all 
	estat event, estore("s_`i'_11")
	
	*Robustness: main specification with micro-region standard errors 
	use "Analysis_for_R_SantAnna_WellsOnly_V2", clear 	
	csdid `i' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year) cluster(meso_code)
	estat all 
	estat event, estore("d_`i'_12")

	csdid `i' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year) cluster(meso_code)
	estat all 
	estat event, estore("s_`i'_12")
	
}

graph drop _all 

*local outcomes "ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_transf_nonoil_pc ihs_spend_current_I_pc ihs_invest_F_pc ihs_spend_edculture_I_pc ihs_spend_hlthsanit_I_pc ihs_gdp_pc ihs_population"
local outcomes "ihs_rev_current_I_pc ihs_spend_current_I_pc ihs_invest_F_pc score_educ score_health ihs_gdp_pc"
foreach i of local outcomes {
	***************************
	*Graph results 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_`i'_1 d_`i'_2 d_`i'_3 d_`i'_4 d_`i'_5 d_`i'_7 d_`i'_8 d_`i'_9 d_`i'_10 d_`i'_11 d_`i'_12 d_`i'_m, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(horizontal)) nolabels title("Disappointed", size(medsmall)) name("g_`i'_d") legend(lab(2 "Medium Forecast, Wells Sample") lab(4 "Medium Forecast, CEM Characteristics") lab(6 "High Forecast, Wells Sample") lab(8 "High Forecast, CEM Characteristics") lab(10 "Preferred Forecast, CEM Finances") lab(12 "Production Definition, Wells Sample") lab(14 "Production Definition, CEM Characteristics") lab(16 "Tot. Discovery Val. (Low), Full Sample") lab(18 "Tot. Discovery Val. (High), Full Sample") lab(20 "Micro-Region SEs, Wells Sample") lab(22 "Meso-Region SEs, Wells Sample") lab(24 "Preferred Specification") size(vsmall))

	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot s_`i'_m s_`i'_1 s_`i'_2 s_`i'_3 s_`i'_4 s_`i'_5 s_`i'_7 s_`i'_8 s_`i'_9 s_`i'_10 s_`i'_11 s_`i'_12, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(horizontal)) nolabels title("Satisfied", size(medsmall)) name("g_`i'_s") legend(lab(2 "Medium Forecast, Wells Sample") lab(4 "Medium Forecast, CEM Characteristics") lab(6 "High Forecast, Wells Sample") lab(8 "High Forecast, CEM Characteristics") lab(10 "Preferred Forecast, CEM Finances") lab(12 "Production Definition, Wells Sample") lab(14 "Production Definition, CEM Characteristics") lab(16 "Tot. Discovery Val. (Low), Full Sample") lab(18 "Tot. Discovery Val. (High), Full Sample") lab(20 "Micro-Region SEs, Wells Sample") lab(22 "Meso-Region SEs, Wells Sample") lab(24 "Preferred Specification") size(vsmall))
	
}

grc1leg2 g_ihs_rev_current_I_pc_d g_ihs_rev_current_I_pc_s
graph export "${output}\Event_Studies\robustness_revenues.pdf", replace

grc1leg2 g_ihs_spend_current_I_pc_d g_ihs_spend_current_I_pc_s
graph export "${output}\Event_Studies\robustness_spending.pdf", replace

grc1leg2 g_ihs_invest_F_pc_d g_ihs_invest_F_pc_s
graph export "${output}\Event_Studies\robustness_investment.pdf", replace

grc1leg2 g_ihs_gdp_pc_d g_ihs_gdp_pc_s
graph export "${output}\Event_Studies\robustness_gdp.pdf", replace

grc1leg2 g_score_educ_d g_score_educ_s 
graph export "${output}\Event_Studies\robustness_education.pdf", replace

grc1leg2 g_score_health_d g_score_health_s
graph export "${output}\Event_Studies\robustness_health.pdf", replace
