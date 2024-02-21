cd "${user}\Data Directory\Treatment Variables"

use "Analysis_for_R_SantAnna_WellsOnly_V2", clear 

graph drop _all
estimates clear

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

********************************************************************************
*Generate results 
estimates drop _all
graph drop _all

set seed 39627236

******************
*Revenues 
local outcomes "ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_rev_taxes_I_pc ihs_transf_nonoil_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year) 
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year) 
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
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_revenue_current_I s_ihs_revenue_current_I, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total Revenue", size(medsmall)) name("g_ihs_revenue_current_I") yscale(r(-1.25 1.25)) ylabel(-1.25 (.5) 1.25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Revenue per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_rev_current_I_pc s_ihs_rev_current_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Revenue per capita", size(medsmall)) name("g_ihs_rev_current_I_pc") yscale(r(-1.25 1.25)) ylabel(-1.25 (.5) 1.25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Oil Revenue per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_oil_revenue_pc s_ihs_oil_revenue_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Oil Revenue per capita*", size(medsmall)) name("g_ihs_oil_revenue_pc") yscale(r(-2 8)) ylabel(-2 (2) 8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Tax Revenue per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_rev_taxes_I_pc s_ihs_rev_taxes_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Tax Revenue per capita", size(medsmall)) name("g_ihs_rev_taxes_I_pc") yscale(r(-1.25 1.25)) ylabel(-1.25 (.5) 1.25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Non-oil transfer revenue per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_transf_nonoil_pc s_ihs_transf_nonoil_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Non-Oil Transfer Revenue per capita*", size(medsmall)) name("g_ihs_transf_nonoil_pc") yscale(r(-0.25 0.25)) ylabel(-0.25 (.1) 0.25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
******************
*Expenditures 

local outcomes "ihs_spending_current_I ihs_spend_current_I_pc ihs_spend_admin_I_pc ihs_spend_personnel_I_pc ihs_mun_pubadmin_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*Total Spending
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spending_current_I s_ihs_spending_current_I, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total Spending", size(medsmall)) name("g_ihs_spending_current_I") yscale(r(-0.8 0.6)) ylabel(-0.8 (.2) 0.6) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Spending per capita
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_current_I_pc s_ihs_spend_current_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Spending per capita", size(medsmall)) name("g_ihs_spend_current_I_pc") yscale(r(-0.8 0.6)) ylabel(-0.8 (.2) 0.6) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Admin spending
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_admin_I_pc s_ihs_spend_admin_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Administration Spending per capita*", size(medsmall)) name("g_ihs_spend_admin_I_pc") yscale(r(-1.5 3.5)) ylabel(-1.5 (.5) 3.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Personnel spending
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_personnel_I_pc s_ihs_spend_personnel_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Personnel Spending per capita", size(medsmall)) name("g_ihs_spend_personnel_I_pc") yscale(r(-0.8 0.6)) ylabel(-0.8 (.2) 0.6) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Municipal employees 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_mun_pubadmin_pc s_ihs_mun_pubadmin_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Municipal Employees per capita*", size(medsmall)) name("g_ihs_mun_pubadmin_pc") yscale(r(-0.03 0.07)) ylabel(-0.03 (.02) 0.07) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

	
******************
*Investment  

local outcomes "ihs_invest_F_pc ihs_econ_dev_spend_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*Investment
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_invest_F_pc s_ihs_invest_F_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Investment per capita", size(medsmall)) name("g_ihs_invest_F_pc") yscale(r(-3.5 3.5)) ylabel(-3.5 (1) 3.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Econ dev spending 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_econ_dev_spend_pc s_ihs_econ_dev_spend_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Economic Diversification Spending per capita", size(medsmall)) name("g_ihs_econ_dev_spend_pc") yscale(r(-3.5 3.5)) ylabel(-3.5 (1) 3.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	

******************
*Public Goods   
*/
local outcomes "ihs_spend_edculture_I_pc ihs_spend_hlthsanit_I_pc score_educ score_health"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*Education Spending
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_edculture_I_pc s_ihs_spend_edculture_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Education and Culture Spending per capita", size(medsmall)) name("g_ihs_spend_edculture_I_pc") yscale(r(-1 1)) ylabel(-1 (.25) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Health Spending 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_spend_hlthsanit_I_pc s_ihs_spend_hlthsanit_I_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Health and Sanitation Spending per capita", size(medsmall)) name("g_ihs_spend_hlthsanit_I_pc") yscale(r(-1 1)) ylabel(-1 (.25) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*Education Index
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_score_educ s_score_educ, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Education Index (Provision and Outcomes)", size(medsmall)) name("g_score_educ") yscale(r(-.25 .1)) ylabel(-.25 (0.05) .1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Health Index 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_score_health s_score_health, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Health Index (Provision and Outcomes)", size(medsmall)) name("g_score_health") yscale(r(-.25 .1)) ylabel(-.25 (0.05) .1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
******************
*GDP and population   

local outcomes "ihs_gdp_pc ihs_population"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*GDp pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_gdp_pc s_ihs_gdp_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("GDP per capita", size(medsmall)) name("g_ihs_gdp_pc") yscale(r(-1 2.5)) ylabel(-1 (.5) 2.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*Population 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_population s_ihs_population, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Population", size(medsmall)) name("g_ihs_population") yscale(r(-.2 .3)) ylabel(-.2 (0.1) .3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
******************
*Federal and State transfers   

rename ihs_oil_revenue_pc ihs_oil_revenue_pc2
local outcomes "ihs_ed_transf_pc ihs_FPM_pc ihs_oil_revenue_pc2 ihs_LeiKandir_pc ihs_FEX_pc ihs_ITR_pc ihs_AFM_AFE_pc ihs_CIDE_fuel_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*ihs_ed_transf_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_ed_transf_pc s_ihs_ed_transf_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("FUNDEF/FUNDEB", size(medsmall)) name("g_ihs_ed_transf_pc") yscale(r(-.6 .6)) ylabel(-.6 (.3) .6) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_FPM_pc 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_FPM_pc s_ihs_FPM_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("FPM", size(medsmall)) name("g_ihs_FPM_pc") yscale(r(-.2 .1)) ylabel(-.2 (0.1) .1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_oil_revenue_pc2
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_oil_revenue_pc2 s_ihs_oil_revenue_pc2, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Oil and Gas Royalties", size(medsmall)) name("g_ihs_oil_revenue_pc2") yscale(r(-2 8)) ylabel(-2 (2) 8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_LeiKandir_pc 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_LeiKandir_pc s_ihs_LeiKandir_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Lei Kandir", size(medsmall)) name("g_ihs_LeiKandir_pc") yscale(r(-.75 .5)) ylabel(-.75 (0.25) .5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_FEX_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_FEX_pc s_ihs_FEX_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("FEX", size(medsmall)) name("g_ihs_FEX_pc") yscale(r(-1 3)) ylabel(-1 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_ITR_pc 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_ITR_pc s_ihs_ITR_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("ITR", size(medsmall)) name("g_ihs_ITR_pc") yscale(r(-.5 1)) ylabel(-.5 (0.5) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_AFM_AFE_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_AFM_AFE_pc s_ihs_AFM_AFE_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm5 Tm4 Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(4, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("AFM", size(medsmall)) name("g_ihs_AFM_AFE_pc") yscale(r(-4 2)) ylabel(-4 (2) 2) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_CIDE_fuel_pc 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_CIDE_fuel_pc s_ihs_CIDE_fuel_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("CIDE Fuel", size(medsmall)) name("g_ihs_CIDE_fuel_pc") yscale(r(-.2 .6)) ylabel(-.2 (0.2) .6) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
******************
*Fiscal Health Measures   

local outcomes "spending_personnel_share investment_share_F debt_stock_share tax_share_revenue_F"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*personnel
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_spending_personnel_share s_spending_personnel_share, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Personnel Share of Revenue", size(medsmall)) name("g_spending_personnel_share") yscale(r(-.25 .25)) ylabel(-.25 (.1) .25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*investment_share_F 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_investment_share_F s_investment_share_F, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Investment Share of Revenue", size(medsmall)) name("g_investment_share_F") yscale(r(-.25 .25)) ylabel(-.25 (.1) .25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*debt_stock_share
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_debt_stock_share s_debt_stock_share, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Debt Management Share of Revenue", size(medsmall)) name("g_debt_stock_share") yscale(r(-.25 .25)) ylabel(-.25 (.1) .25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*tax_share_revenue_F 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_tax_share_revenue_F s_tax_share_revenue_F, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Tax Share of Revenue", size(medsmall)) name("g_tax_share_revenue_F") yscale(r(-.25 .25)) ylabel(-.25 (.1) .25) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	

******************
*Debt  

local outcomes "ihs_debt_interest_F_pc ihs_debt_mgmt_costs_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*ihs_debt_interest_F_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_debt_interest_F_pc s_ihs_debt_interest_F_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Interest Payments per capita", size(medsmall)) name("g_ihs_debt_interest_F_pc") yscale(r(-3.5 3.5)) ylabel(-3.5 (1) 3.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_debt_mgmt_costs_pc 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_debt_mgmt_costs_pc s_ihs_debt_mgmt_costs_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Debt Management Costs per capita", size(medsmall)) name("g_ihs_debt_mgmt_costs_pc") yscale(r(-3.5 3.5)) ylabel(-3.5 (1) 3.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	

******************
*Public Goods Provision and Quality 

local outcomes "ihs_mun_beds_per1000 births_7pluscheckups ihs_infant_mort_perbirth infrastructure_index teachers_share_superior ideb"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*ihs_mun_beds_per1000
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_mun_beds_per1000 s_ihs_mun_beds_per1000, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Hospital Beds per 1000 Residents*", size(medsmall)) name("g_ihs_mun_beds_per1000") yscale(r(-.75 .75)) ylabel(-.75 (0.25) .75) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*births_7pluscheckups 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_births_7pluscheckups s_births_7pluscheckups, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("7 or More Prenatal Checkups", size(medsmall)) name("g_births_7pluscheckups") yscale(r(-.4 .2)) ylabel(-.4 (.1) .2) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_infant_mort_perbirth 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_infant_mort_perbirth s_ihs_infant_mort_perbirth, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Avoidable Infant Mort per 1000 Births", size(medsmall)) name("g_ihs_infant_mort_perbirth") yscale(r(-.4 .2)) ylabel(-.4 (.1) .2) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*infrastructure_index
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_infrastructure_index s_infrastructure_index, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("School Infrastructure Index", size(medsmall)) name("g_infrastructure_index") yscale(r(-.4 .2)) ylabel(-.4 (.1) .2) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*teachers_share_superior 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_teachers_share_superior s_teachers_share_superior, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Share of Teachers with College Degree", size(medsmall)) name("g_teachers_share_superior") yscale(r(-.4 .2)) ylabel(-.4 (.1) .2) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ideb
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ideb s_ideb, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("IDEB Education Outcomes Index*", size(medsmall)) name("g_ideb") yscale(r(-1 1)) ylabel(-1 (.5) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	

******************
*In-Migration

*local outcomes "migrant_number ihs_migrant_number_pc ihs_migrant_number"
local outcomes "ihs_migrant_number"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*migrant_number
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_migrant_number s_migrant_number, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp7 Tp8 Tp9 Tp10 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Number of In-Migrants", size(medsmall)) name("g_migrant_number") yscale(r(-1500 1500)) ylabel(-1500 (500) 1500) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_migrant_number_pc 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_migrant_number_pc s_ihs_migrant_number_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp7 Tp8 Tp9 Tp10 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("In-Migrants per capita", size(medsmall)) name("g_ihs_migrant_number_pc") yscale(r(-.025 .01)) ylabel(-.025 (.005) .01) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_migrant_number 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_migrant_number s_ihs_migrant_number, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp7 Tp8 Tp9 Tp10 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("In-Migrants", size(medsmall)) name("g_ihs_migrant_number") yscale(r(-.025 .01)) ylabel(-.025 (.005) .01) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
******************
*Formal Labor Migration (Number of in-migrants)

*local outcomes "ihs_num_workers_tot ihs_num_workers_ag ihs_num_workers_extr ihs_num_workers_mfg ihs_num_workers_constr ihs_num_workers_ret ihs_num_workers_otherserv ihs_num_workers_govt"
local outcomes "ihs_num_workers_tot"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*ihs_num_workers_tot
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_num_workers_tot s_ihs_num_workers_tot, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total", size(medsmall)) name("g_formal_tot") yscale(r(-3 3)) ylabel(-3 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_num_workers_ag
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_num_workers_ag s_ihs_num_workers_ag, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Agriculture", size(medsmall)) name("g_formal_ag") yscale(r(-3 3)) ylabel(-3 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_num_workers_extr
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_num_workers_extr s_ihs_num_workers_extr, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Extractive", size(medsmall)) name("g_formal_ext") yscale(r(-3 3)) ylabel(-3 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_num_workers_mfg
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_num_workers_mfg s_ihs_num_workers_mfg, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Manufacturing", size(medsmall)) name("g_formal_mfg") yscale(r(-3 3)) ylabel(-3 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_num_workers_constr
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_num_workers_constr s_ihs_num_workers_constr, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Construction", size(medsmall)) name("g_formal_constr") yscale(r(-3 3)) ylabel(-3 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_num_workers_ret
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_num_workers_ret s_ihs_num_workers_ret, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Retail", size(medsmall)) name("g_formal_ret") yscale(r(-3 3)) ylabel(-3 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_num_workers_otherserv
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_num_workers_otherserv s_ihs_num_workers_otherserv, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Other Services", size(medsmall)) name("g_formal_otherserv") yscale(r(-3 3)) ylabel(-3 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_num_workers_govt
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_num_workers_govt s_ihs_num_workers_govt, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Government", size(medsmall)) name("g_formal_govt") yscale(r(-3 3)) ylabel(-3 (1) 3) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
******************
*Formal Employment 

local outcomes "ihs_n_empl_extr ihs_n_empl_mfg ihs_n_empl_ag ihs_n_empl_const ihs_n_empl_ret ihs_n_empl_othserv ihs_n_empl_tot"
*local outcomes "ihs_n_empl_tot"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*ihs_n_empl_extr
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_empl_extr s_ihs_n_empl_extr, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Extractive", size(medsmall)) name("g_ihs_n_empl_extr") yscale(r(-1.5 1.5)) ylabel(-1.5 (0.5) 1.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_n_empl_mfg 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_empl_mfg s_ihs_n_empl_mfg, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Manufacturing", size(medsmall)) name("g_ihs_n_empl_mfg") yscale(r(-1.5 1.5)) ylabel(-1.5 (0.5) 1.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_n_empl_ag
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_empl_ag s_ihs_n_empl_ag, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Agriculture", size(medsmall)) name("g_ihs_n_empl_ag") yscale(r(-1.5 1.5)) ylabel(-1.5 (0.5) 1.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_n_empl_const 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_empl_const s_ihs_n_empl_const, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Construction", size(medsmall)) name("g_ihs_n_empl_const") yscale(r(-1.5 1.5)) ylabel(-1.5 (0.5) 1.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_n_empl_ret
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_empl_ret s_ihs_n_empl_ret, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Retail", size(medsmall)) name("g_ihs_n_empl_ret") yscale(r(-1.5 1.5)) ylabel(-1.5 (0.5) 1.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_n_empl_otherserv
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_empl_othserv s_ihs_n_empl_othserv, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Other Services", size(medsmall)) name("g_ihs_n_empl_othserv") yscale(r(-1.5 1.5)) ylabel(-1.5 (0.5) 1.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_n_empl_tot
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_empl_tot s_ihs_n_empl_tot, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total", size(medsmall)) name("g_ihs_n_empl_tot") yscale(r(-1.5 1.5)) ylabel(-1.5 (0.5) 1.5) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
********************************************************************************
*Firm Entry

*local outcomes "ihs_n_firms_ag ihs_n_firms_const ihs_n_firms_extr ihs_n_firms_mfg ihs_n_firms_ret ihs_n_firms_tot"
local outcomes "ihs_n_firms_tot"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}
	
*extractive
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_extr s_ihs_n_firms_extr, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Extractive", size(medsmall)) name("g_ihs_n_firms_extr") yscale(r(-.8 1)) ylabel(-.8 (0.2) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*mfg 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_mfg s_ihs_n_firms_mfg, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Manufacturing", size(medsmall)) name("g_ihs_n_firms_mfg") yscale(r(-.8 1)) ylabel(-.8 (0.2) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ag
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_ag s_ihs_n_firms_ag, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Agriculture", size(medsmall)) name("g_ihs_n_firms_ag") yscale(r(-.8 1)) ylabel(-.8 (0.2) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*const 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_const s_ihs_n_firms_const, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Construction", size(medsmall)) name("g_ihs_n_firms_const") yscale(r(-.8 1)) ylabel(-.8 (0.2) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ret
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_ret s_ihs_n_firms_ret, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Retail", size(medsmall)) name("g_ihs_n_firms_ret") yscale(r(-.8 1)) ylabel(-.8 (0.2) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*tot
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_tot s_ihs_n_firms_tot, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total", size(medsmall)) name("g_ihs_n_firms_tot") yscale(r(-.8 1)) ylabel(-.8 (0.2) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))	

************************
*Firm Entry (non-micro)

local outcomes "ihs_n_firms_nm_ag ihs_n_firms_nm_const ihs_n_firms_nm_extr ihs_n_firms_nm_mfg ihs_n_firms_nm_ret ihs_n_firms_nm_othserv ihs_n_firms_nm_tot"
*local outcomes "ihs_n_firms_nm_tot"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}
	
*extractive
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_nm_extr s_ihs_n_firms_nm_extr, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Extractive", size(medsmall)) name("g_ihs_n_firms_nm_extr") yscale(r(-.8 .8)) ylabel(-.8 (0.2) .8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*mfg 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_nm_mfg s_ihs_n_firms_nm_mfg, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Manufacturing", size(medsmall)) name("g_ihs_n_firms_nm_mfg") yscale(r(-.8 .8)) ylabel(-.8 (0.2) .8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ag
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_nm_ag s_ihs_n_firms_nm_ag, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Agriculture", size(medsmall)) name("g_ihs_n_firms_nm_ag") yscale(r(-.8 .8)) ylabel(-.8 (0.2) .8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*const 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_nm_const s_ihs_n_firms_nm_const, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Construction", size(medsmall)) name("g_ihs_n_firms_nm_const") yscale(r(-.8 .8)) ylabel(-.8 (0.2) .8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ret
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_nm_ret s_ihs_n_firms_nm_ret, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Retail", size(medsmall)) name("g_ihs_n_firms_nm_ret") yscale(r(-.8 .8)) ylabel(-.8 (0.2) .8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_n_firms_nm_otherserv
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_nm_othserv s_ihs_n_firms_nm_othserv, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Other Services", size(medsmall)) name("g_ihs_n_firms_nm_othserv") yscale(r(-.8 .8)) ylabel(-.8 (0.2) .8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*tot
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_firms_nm_tot s_ihs_n_firms_nm_tot, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total", size(medsmall)) name("g_ihs_n_firms_nm_tot") yscale(r(-.8 .8)) ylabel(-.8 (0.2) .8) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))	
	

******************
*Formal sector wages 

*local outcomes "ihs_w_avg_ag ihs_w_avg_const ihs_w_avg_extr ihs_w_avg_mfg ihs_w_avg_gov ihs_avg_wage_year ihs_w_avg_othserv"
local outcomes "ihs_avg_wage_year"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*ihs_w_avg_ag
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_w_avg_ag s_ihs_w_avg_ag, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Agriculture", size(medsmall)) name("g_ihs_w_avg_ag") yscale(r(-.6 .4)) ylabel(-.6 (0.2) .4) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_w_avg_const 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_w_avg_const s_ihs_w_avg_const, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Construction", size(medsmall)) name("g_ihs_w_avg_const") yscale(r(-.6 .4)) ylabel(-.6 (0.2) .4) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_w_avg_extr 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_w_avg_extr s_ihs_w_avg_extr, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Extractive*", size(medsmall)) name("g_ihs_w_avg_extr") yscale(r(-1.5 1)) ylabel(-1.5 (0.5) 1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_w_avg_mfg
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_w_avg_mfg s_ihs_w_avg_mfg, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Manufacturing", size(medsmall)) name("g_ihs_w_avg_mfg") yscale(r(-.6 .4)) ylabel(-.6 (0.2) .4) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_w_avg_gov 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_w_avg_gov s_ihs_w_avg_gov, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Public Sector (Municipal)", size(medsmall)) name("g_ihs_w_avg_gov") yscale(r(-.6 .4)) ylabel(-.6 (0.2) .4) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_w_avg_otherserv 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_w_avg_othserv s_ihs_w_avg_othserv, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Other Services", size(medsmall)) name("g_ihs_w_avg_othserv") yscale(r(-.6 .4)) ylabel(-.6 (0.2) .4) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_total_wages_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_avg_wage_year s_ihs_avg_wage_year, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Total", size(medsmall)) name("g_ihs_avg_wage_year") yscale(r(-.6 .4)) ylabel(-.6 (0.2) .4) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	/*
*********************************************************************************
*Bolsa Familia and Cadastro Unico 

*local outcomes "ihs_families_bf_pc ihs_families_cu_pc ihs_value_bf_pc"
local outcomes "ihs_people_bf_pc"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}

*ihs_people_bf_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_people_bf_pc s_ihs_people_bf_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Bolsa Familia", size(medsmall)) name("g_ihs_people_bf_pc") yscale(r(-.1 .1)) ylabel(-.1 (0.25) .1) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_value_bf_pc 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_value_bf_pc s_ihs_value_bf_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Bolsa Familia Value", size(medsmall)) name("g_ihs_value_bf_pc") yscale(r(-.6 .4)) ylabel(-.6 (0.2) .4) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

*ihs_families_cu_pc 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_families_cu_pc s_ihs_families_cu_pc, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Cadastro Unico", size(medsmall)) name("g_ihs_families_cu_pc") yscale(r(-.6 .4)) ylabel(-.6 (0.2) .4) legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))

**********************************************
*Analyze school enrollment (2004-2017 panel)
keep if year > 2003

gen total_enroll = n_student_mun + n_student_pri + n_student_otherpub
gen total_enroll_pc = total_enroll / population_complete
gen ihs_total_enroll_pc = asinh(total_enroll_pc)
gen ihs_total_enroll = asinh(total_enroll)

*local outcomes "ihs_n_student_mun_pc ihs_n_student_pri_pc ihs_n_student_otherpub_pc ihs_total_enroll"
local outcomes "ihs_n_student_mun ihs_n_student_pri ihs_n_student_otherpub ihs_total_enroll"
foreach j of local outcomes {
	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 1, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("d_`j'")

	csdid `j' if disappointed_pc_low == 0 | disappointed_pc_low == 2, ivar(munic_code) time(year) gvar(first_CVM_year)
	estat all 
	estat event, estore("s_`j'")
}
	
*ihs_n_student_mun_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_student_mun s_ihs_n_student_mun, vertical coeflabels(Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm4 Tm5 Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(4, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Municipal Public Schools", size(medsmall)) name("g_ihs_n_student_mun") legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal)) yscale(r(-1.25 1.75)) ylabel(-1.25 (0.5) 1.75)
	
*ihs_n_student_pri_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_student_pri s_ihs_n_student_pri, vertical coeflabels(Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm4 Tm5 Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(4, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Private Schools", size(medsmall)) name("g_ihs_n_student_pri") legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal)) yscale(r(-1.25 1.75)) ylabel(-1.25 (0.5) 1.75)
	
*ihs_n_student_otherpub_pc
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_n_student_otherpub s_ihs_n_student_otherpub, vertical coeflabels(Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm4 Tm5 Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(4, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Other Public Schools", size(medsmall)) name("g_ihs_n_student_otherpub") legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
	
*ihs_total_enroll
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color black gs10
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot d_ihs_total_enroll s_ihs_total_enroll, vertical coeflabels(Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm4 Tm5 Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tp11 Tp12 Tp13 Tp14 Tp15) yline(0) xline(4, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from Discovery Announcement", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Enrollment", size(medsmall)) name("g_ihs_total_enroll") legend(order(2 "Discovery Unrealized (Disappointed)" 4 "Discovery Realized (Satisfied)")) xlabel(,labsize(small) angle(horizontal))
*/


**************************************************************************************************************************	
*Combine results 

grc1leg2 g_ihs_revenue_current_I g_ihs_rev_current_I_pc g_ihs_oil_revenue_pc g_ihs_rev_taxes_I_pc g_ihs_transf_nonoil_pc
graph export "${output}\Event_Studies\cs_revenue.pdf", replace

grc1leg2 g_ihs_spending_current_I g_ihs_spend_current_I_pc g_ihs_spend_admin_I_pc g_ihs_spend_personnel_I_pc g_ihs_mun_pubadmin_pc
graph export "${output}\Event_Studies\cs_spending.pdf", replace

grc1leg2 g_ihs_invest_F_pc g_ihs_econ_dev_spend_pc
graph export "${output}\Event_Studies\cs_investment.pdf", replace

grc1leg2 g_ihs_spend_edculture_I_pc g_ihs_spend_hlthsanit_I_pc g_score_educ g_score_health
graph export "${output}\Event_Studies\cs_pubgoods.pdf", replace

grc1leg2 g_ihs_gdp_pc g_ihs_population
graph export "${output}\Event_Studies\cs_gdppop.pdf", replace
*/
grc1leg2 g_ihs_ed_transf_pc g_ihs_FPM_pc g_ihs_oil_revenue_pc2 g_ihs_LeiKandir_pc g_ihs_FEX_pc g_ihs_ITR_pc g_ihs_AFM_AFE_pc g_ihs_CIDE_fuel_pc 
graph export "${output}\Event_Studies\cs_transfers.pdf", replace

grc1leg2 g_investment_share_F g_spending_personnel_share g_tax_share_revenue_F g_debt_stock_share
graph export "${output}\Event_Studies\cs_fiscal.pdf", replace

grc1leg2 g_ihs_debt_interest_F_pc g_ihs_debt_mgmt_costs_pc
graph export "${output}\Event_Studies\cs_debt.pdf", replace

grc1leg2 g_infrastructure_index g_teachers_share_superior g_ideb g_ihs_mun_beds_per1000 g_births_7pluscheckups g_ihs_infant_mort_perbirth
graph export "${output}\Event_Studies\cs_pubgoodsprovision.pdf", replace

grc1leg2 g_migrant_number g_ihs_migrant_number_pc 
graph export "${output}\Event_Studies\cs_migrants.pdf", replace

grc1leg2 g_ihs_n_empl_extr g_ihs_n_empl_mfg g_ihs_n_empl_ag g_ihs_n_empl_const g_ihs_n_empl_ret g_ihs_n_empl_othserv
graph export "${output}\Event_Studies\cs_employment.pdf", replace

grc1leg2 g_ihs_n_firms_extr g_ihs_n_firms_mfg g_ihs_n_firms_ag g_ihs_n_firms_const g_ihs_n_firms_ret g_ihs_n_
graph export "${output}\Event_Studies\cs_firmentry.png", replace

grc1leg2 g_ihs_n_firms_nm_extr g_ihs_n_firms_nm_mfg g_ihs_n_firms_nm_ag g_ihs_n_firms_nm_const g_ihs_n_firms_nm_ret g_ihs_n_firms_nm_othserv
graph export "${output}\Event_Studies\cs_firmentry_nonmicro.pdf", replace

grc1leg2 g_ihs_w_avg_extr g_ihs_w_avg_mfg g_ihs_w_avg_ag g_ihs_w_avg_const g_ihs_w_avg_gov g_ihs_w_avg_othserv
graph export "${output}\Event_Studies\cs_wages.pdf", replace

grc1leg2 g_formal_tot g_formal_ag g_formal_ext g_formal_mfg g_formal_constr g_formal_govt
graph export "${output}\Event_Studies\cs_formalmigration.pdf", replace


***************************************************************************************************************
*Sample characteristics 
*Sample size, number of units, and DV mean (pre-treatment control mean)

*Sample sizes 
local vars "ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_rev_taxes_I_pc ihs_transf_nonoil_pc ihs_spending_current_I ihs_spend_current_I_pc ihs_spend_admin_I_pc ihs_spend_personnel_I_pc ihs_mun_pubadmin_pc ihs_invest_F_pc ihs_econ_dev_spend_pc ihs_spend_edculture_I_pc ihs_spend_hlthsanit_I_pc score_educ score_health ihs_gdp_pc ihs_population ihs_n_empl_extr ihs_n_empl_mfg ihs_n_empl_ag ihs_n_empl_const"
foreach k of local vars {
	gen d_`k' = 0
	replace d_`k' = 1 if `k' != . & (disappointed_pc_low == 0 | disappointed_pc_low == 1)
	gen s_`k' = 0
	replace s_`k' = 1 if `k' != . & (disappointed_pc_low == 0 | disappointed_pc_low == 2)
	
	tab d_`k'
	tab s_`k'
}

preserve
*Compute sample means 
*Keep only t-1 period
keep if relative_time == 14
local vars "ihs_revenue_current_I ihs_rev_current_I_pc ihs_oil_revenue_pc ihs_rev_taxes_I_pc ihs_transf_nonoil_pc ihs_spending_current_I ihs_spend_current_I_pc ihs_spend_admin_I_pc ihs_spend_personnel_I_pc ihs_mun_pubadmin_pc ihs_invest_F_pc ihs_econ_dev_spend_pc ihs_spend_edculture_I_pc ihs_spend_hlthsanit_I_pc score_educ score_health ihs_gdp_pc ihs_population ihs_n_empl_extr ihs_n_empl_mfg ihs_n_empl_ag ihs_n_empl_const"
foreach k of local vars {
	sum `k' if disappointed_pc_low == 0 | disappointed_pc_low == 1
	sum `k' if disappointed_pc_low == 0 | disappointed_pc_low == 2
}
restore 

*Collapse to compute number of units 
collapse (max) d_ihs_revenue_current_I d_ihs_rev_current_I_pc d_ihs_oil_revenue_pc d_ihs_rev_taxes_I_pc d_ihs_transf_nonoil_pc d_ihs_spending_current_I d_ihs_spend_current_I_pc d_ihs_spend_admin_I_pc d_ihs_spend_personnel_I_pc d_ihs_mun_pubadmin_pc d_ihs_invest_F_pc d_ihs_econ_dev_spend_pc d_ihs_spend_edculture_I_pc d_ihs_spend_hlthsanit_I_pc d_score_educ d_score_health d_ihs_gdp_pc d_ihs_population d_ihs_n_empl_extr d_ihs_n_empl_mfg d_ihs_n_empl_ag d_ihs_n_empl_const s_ihs_revenue_current_I s_ihs_rev_current_I_pc s_ihs_oil_revenue_pc s_ihs_rev_taxes_I_pc s_ihs_transf_nonoil_pc s_ihs_spending_current_I s_ihs_spend_current_I_pc s_ihs_spend_admin_I_pc s_ihs_spend_personnel_I_pc s_ihs_mun_pubadmin_pc s_ihs_invest_F_pc s_ihs_econ_dev_spend_pc s_ihs_spend_edculture_I_pc s_ihs_spend_hlthsanit_I_pc s_score_educ s_score_health s_ihs_gdp_pc s_ihs_population s_ihs_n_empl_extr s_ihs_n_empl_mfg s_ihs_n_empl_ag s_ihs_n_empl_const, by(munic_code)

gen collapser = 1
collapse (sum) d_ihs_revenue_current_I d_ihs_rev_current_I_pc d_ihs_oil_revenue_pc d_ihs_rev_taxes_I_pc d_ihs_transf_nonoil_pc d_ihs_spending_current_I d_ihs_spend_current_I_pc d_ihs_spend_admin_I_pc d_ihs_spend_personnel_I_pc d_ihs_mun_pubadmin_pc d_ihs_invest_F_pc d_ihs_econ_dev_spend_pc d_ihs_spend_edculture_I_pc d_ihs_spend_hlthsanit_I_pc d_score_educ d_score_health d_ihs_gdp_pc d_ihs_population d_ihs_n_empl_extr d_ihs_n_empl_mfg d_ihs_n_empl_ag d_ihs_n_empl_const s_ihs_revenue_current_I s_ihs_rev_current_I_pc s_ihs_oil_revenue_pc s_ihs_rev_taxes_I_pc s_ihs_transf_nonoil_pc s_ihs_spending_current_I s_ihs_spend_current_I_pc s_ihs_spend_admin_I_pc s_ihs_spend_personnel_I_pc s_ihs_mun_pubadmin_pc s_ihs_invest_F_pc s_ihs_econ_dev_spend_pc s_ihs_spend_edculture_I_pc s_ihs_spend_hlthsanit_I_pc s_score_educ s_score_health s_ihs_gdp_pc s_ihs_population s_ihs_n_empl_extr s_ihs_n_empl_mfg s_ihs_n_empl_ag s_ihs_n_empl_const, by(collapser)
