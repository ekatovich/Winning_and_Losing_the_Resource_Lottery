cd "${user}\Data Directory\Treatment Variables"

clear
graph drop _all
estimates clear

use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_low", clear 

replace first_CVM_year = 0 if first_CVM_year == .

duplicates drop munic_code year, force

*Finalize variables 
gen total_ed_transf_pc = FUNDEB_pc + FUNDEF_pc 
gen ihs_ed_transf_pc = asinh(total_ed_transf_pc)

gen pub_goods_spend_pc = spending_edculture_I_pc + spending_hlthsanit_I_pc
gen ihs_pubgoods_spend_pc = asinh(pub_goods_spend_pc)

local vars "AGRICULTURA COMERCIOESERVICOS PROMOCAOCOMERCIAL PROMOCAOINDUSTRIAL PROMOCAODAPRODUCAOVEGETAL PROMOCAODAPRODUCAOANIMAL PRODUCAOINDUSTRIAL PROPRIEDADEINDUSTRIAL"
foreach k of local vars {
	replace `k' = 0 if `k' == .
}
gen econ_dev_spend_pc = (AGRICULTURA + COMERCIOESERVICOS + PROMOCAOCOMERCIAL + PROMOCAOINDUSTRIAL + PROMOCAODAPRODUCAOVEGETAL + PROMOCAODAPRODUCAOANIMAL + PRODUCAOINDUSTRIAL + PROPRIEDADEINDUSTRIAL) / population_complete
gen ihs_econ_dev_spend_pc = asinh(econ_dev_spend_pc)

replace ideb = ideb[_n-1] if year == 2006 | year == 2008 | year == 2010 | year == 2012 | year == 2014 | year == 2016
gen ihs_infant_mort_perbirth = asinh(infant_mort_perbirth)
gen municipal_beds_per1000 = municipal_beds_pc * 1000
gen ihs_mun_beds_per1000 = asinh(municipal_beds_per1000)

*Define local disappointment definition of interest:
*local disappointed "disappointed_pc_low"

********************************************************************************
*Generate results 
estimates drop _all
graph drop _all

set seed 39627236

******************
*Revenues 
local outcomes "ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_rev_taxes_I_pc ihs_transf_nonoil_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("s_`j'")
}

graph drop _all 

*Graph results

*Total Revenue
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_revenue_current_I s_ihs_revenue_current_I, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total Revenue", size(medsmall)) name("g_ihs_revenue_current_I") yscale(r(-1.25 1.25)) ylabel(-1.25 (.5) 1.25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Revenue per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_rev_current_I_pc s_ihs_rev_current_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Revenue per capita", size(medsmall)) name("g_ihs_rev_current_I_pc") yscale(r(-1.25 1.25)) ylabel(-1.25 (.5) 1.25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Oil Revenue per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_oil_revenue_pc s_ihs_oil_revenue_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Oil Revenue per capita*", size(medsmall)) name("g_ihs_oil_revenue_pc") yscale(r(-2 8)) ylabel(-2 (2) 8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Tax Revenue per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_rev_taxes_I_pc s_ihs_rev_taxes_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Tax Revenue per capita", size(medsmall)) name("g_ihs_rev_taxes_I_pc") yscale(r(-1.25 1.25)) ylabel(-1.25 (.5) 1.25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Non-oil transfer revenue per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_transf_nonoil_pc s_ihs_transf_nonoil_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Non-Oil Transfer Revenue per capita*", size(medsmall)) name("g_ihs_transf_nonoil_pc") yscale(r(-0.25 0.25)) ylabel(-0.25 (.1) 0.25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
******************
*Expenditures 

local outcomes "ihs_spending_current_I ihs_spend_current_I_pc ihs_spend_admin_I_pc ihs_spend_personnel_I_pc ihs_mun_pubadmin_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*Total Spending
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spending_current_I s_ihs_spending_current_I, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total Spending", size(medsmall)) name("g_ihs_spending_current_I") yscale(r(-0.8 0.6)) ylabel(-0.8 (.2) 0.6) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Spending per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_current_I_pc s_ihs_spend_current_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Spending per capita", size(medsmall)) name("g_ihs_spend_current_I_pc") yscale(r(-0.8 0.6)) ylabel(-0.8 (.2) 0.6) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Admin spending
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_admin_I_pc s_ihs_spend_admin_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Administration Spending per capita*", size(medsmall)) name("g_ihs_spend_admin_I_pc") yscale(r(-1.5 3.5)) ylabel(-1.5 (.5) 3.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Personnel spending
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_personnel_I_pc s_ihs_spend_personnel_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Personnel Spending per capita", size(medsmall)) name("g_ihs_spend_personnel_I_pc") yscale(r(-0.8 0.6)) ylabel(-0.8 (.2) 0.6) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Municipal employees 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_mun_pubadmin_pc s_ihs_mun_pubadmin_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Municipal Employees per capita*", size(medsmall)) name("g_ihs_mun_pubadmin_pc") yscale(r(-0.03 0.07)) ylabel(-0.03 (.02) 0.07) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

	
******************
*Investment  

local outcomes "ihs_invest_F_pc ihs_econ_dev_spend_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*Investment
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_invest_F_pc s_ihs_invest_F_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Investment per capita", size(medsmall)) name("g_ihs_invest_F_pc") yscale(r(-3.5 3.5)) ylabel(-3.5 (1) 3.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Econ dev spending 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_econ_dev_spend_pc s_ihs_econ_dev_spend_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Economic Diversification Spending per capita", size(medsmall)) name("g_ihs_econ_dev_spend_pc") yscale(r(-3.5 3.5)) ylabel(-3.5 (1) 3.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	

******************
*Public Goods   

local outcomes "ihs_spend_edculture_I_pc ihs_spend_hlthsanit_I_pc score_educ score_health"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*Education Spending
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_edculture_I_pc s_ihs_spend_edculture_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Education and Culture Spending per capita", size(medsmall)) name("g_ihs_spend_edculture_I_pc") yscale(r(-1 1)) ylabel(-1 (.25) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Health Spending 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_hlthsanit_I_pc s_ihs_spend_hlthsanit_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Health and Sanitation Spending per capita", size(medsmall)) name("g_ihs_spend_hlthsanit_I_pc") yscale(r(-1 1)) ylabel(-1 (.25) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Education Index
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_score_educ s_score_educ, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Education Index (Provision and Outcomes)", size(medsmall)) name("g_score_educ") yscale(r(-.25 .1)) ylabel(-.25 (0.05) .1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Health Index 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_score_health s_score_health, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Health Index (Provision and Outcomes)", size(medsmall)) name("g_score_health") yscale(r(-.25 .1)) ylabel(-.25 (0.05) .1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
******************
*GDP and population   

local outcomes "ihs_gdp_pc ihs_population"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2 [weight=cem_weights], ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*GDp pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_gdp_pc s_ihs_gdp_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("GDP per capita", size(medsmall)) name("g_ihs_gdp_pc") yscale(r(-1 2.5)) ylabel(-1 (.5) 2.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Population 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color hue, n(3)
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_population s_ihs_population, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Population", size(medsmall)) name("g_ihs_population") yscale(r(-.2 .3)) ylabel(-.2 (0.1) .3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
	
	
*Combine results 

grc1leg2 g_ihs_revenue_current_I g_ihs_rev_current_I_pc g_ihs_oil_revenue_pc g_ihs_rev_taxes_I_pc g_ihs_transf_nonoil_pc
graph export "${output}\Event_Studies\matched_revenues.pdf", replace

grc1leg2 g_ihs_spending_current_I g_ihs_spend_current_I_pc g_ihs_spend_admin_I_pc g_ihs_spend_personnel_I_pc g_ihs_mun_pubadmin_pc
graph export "${output}\Event_Studies\matched_spending.pdf", replace

grc1leg2 g_ihs_invest_F_pc g_ihs_econ_dev_spend_pc
graph export "${output}\Event_Studies\matched_investment.pdf", replace

grc1leg2 g_ihs_spend_edculture_I_pc g_ihs_spend_hlthsanit_I_pc g_score_educ g_score_health
graph export "${output}\Event_Studies\matched_pubgoods.pdf", replace

grc1leg2 g_ihs_gdp_pc g_ihs_population
graph export "${output}\Event_Studies\matched_gdppop.pdf", replace

