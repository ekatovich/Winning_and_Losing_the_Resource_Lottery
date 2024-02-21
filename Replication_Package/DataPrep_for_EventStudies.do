clear
cd "${user}\Data Directory\Treatment Variables"


*Prepping data for analysis 

use "Municipality_Wells_Treatment_with_Outcomes", clear

*First, construct subsample of municipalities that ever had a well completed.
bysort munic_code: egen wells_completed_2000_2017 = sum(number_of_wells_completed)
bysort munic_code: egen hydrocarbon_detections_2000_2017 = sum(number_hydrocarbon_detections)
bysort munic_code: egen cvm_announcements_2000_2017 = sum(number_cvm_announcements)
bysort munic_code: egen volume_announced_2000_2017 = sum(announced_new_volume_mmboe)
bysort munic_code: egen successful_wells_2000_2017 = sum(num_successful_wells)
bysort munic_code: egen oil_revenue_2000_2017 = sum(oil_revenue)

*Now compute cumulative wells completed, hydrocarbon detections, cvm announcements, volume announced, and oil/gas production
drop cum_wells_completed cum_hydrocarbons_detected cum_CVM_announcements cum_volume_announced
bysort munic_code (year): gen cum_wells_completed = sum(number_of_wells_completed)
bysort munic_code (year): gen cum_hydrocarbons_detected = sum(number_hydrocarbon_detections)
bysort munic_code (year): gen cum_cvm_announcements = sum(number_cvm_announcements)
bysort munic_code (year): gen cum_volume_announced = sum(announced_new_volume_mmboe)
bysort munic_code (year): gen cum_successful_wells = sum(num_successful_wells)
bysort munic_code (year): gen cum_oil_prod = sum(oil_bbl)
bysort munic_code (year): gen cum_gas_prod = sum(gas_mm3)
bysort munic_code (year): gen cum_boe_prod = sum(prod_boe)
bysort munic_code (year): gen cum_oil_revenue = sum(oil_revenue)


order munic_code munic_code_6digit municipality uf UF_NO micro_code meso_code year number_of_wells_completed number_hydrocarbon_detections num_successful_wells num_unsuccessful_wells number_cvm_announcements announced_new_volume_mmboe all_time_production oil_bbl gas_mm3 prod_boe cum_wells_completed cum_hydrocarbons_detected cum_successful_wells cum_cvm_announcements cum_volume_announced cum_oil_prod cum_gas_prod cum_boe_prod cum_oil_revenue wells_completed_2000_2017 hydrocarbon_detections_2000_2017 cvm_announcements_2000_2017 volume_announced_2000_2017 successful_wells_2000_2017 oil_revenue_2000_2017


*Clean up initial conditions variables 

drop if municipality == ""
sort municipality year 

bysort munic_code: gen gdp_2002_tmp = gdp if year == 2002
bysort munic_code: egen gdp_2002 = max(gdp_2002_tmp)
drop gdp_2002_tmp

local initials "dist_brasilia dist_statecapital latitude gdp_2002 MORT_2000 T_FUND18M_2000 T_MED18M_2000 T_SUPER25M_2000 GINI_2000 PREN10RICOS_2000 PREN40_2000 R1040_2000 RDPC_2000 RDPC1_2000 RDPC10_2000 P_AGRO_2000 P_COM_2000 P_CONSTR_2000 P_EXTR_2000 P_FORMAL_2000 P_SERV_2000 P_SIUP_2000 P_TRANSF_2000 T_ATIV18M_2000 T_DES18M_2000 TRABCC_2000 TRABPUB_2000 T_LUZ_2000 AGUA_ESGOTO_2000 T_FUNDIN18MINF_2000 PEA18M_2000 pesoRUR_2000 pesotot_2000 pesourb_2000 ifdm_2000 ifdm_employment_income_2000 ifdm_education_2000 ifdm_health_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 income_capita_2000 theil_2000 poverty_2000"
foreach i of local initials {
bysort munic_code: egen `i'_tmp = max(`i')
drop `i'
rename `i'_tmp `i'
}

gen urban_share = pesourb_2000 / pesotot_2000

local log_vars "dist_brasilia dist_statecapital gdp_2002 pesotot_2000"
foreach i of local log_vars {
gen ihs_`i' = asinh(`i')
}

gen oil_rev_2000 = cum_oil_revenue if year == 2000
replace oil_rev_2000 = 0 if oil_rev_2000 == .
gen oil_rev_2000_indicator = 0
replace oil_rev_2000_indicator = 1 if oil_rev_2000 > 0

sort municipality year

save "Munics_for_Matching", replace


********************************************************************************

*Sample 5: All (for matching) first event 
use "Munics_for_Matching", replace 

*FINBRA Outcomes 
*Other: POPULACAO
*Revenue: RECORCAMENTARIA IMPOSTOS TAXAS RECINDUSTRIAL RECAGROPECUARIA RECDESERVICOS
*Spending: DESPESASORCAMENTARIAS DESPESASDECAPITAL INVESTIMENTOS INVESTIMENTOS PESSOALEENCARGSOC_PES SAUDE EDUCACAO URBANISMO HABITACAO SANEAMENTO
*Debt:RESTOSAPAGARPROCESSADOS RESTOSAPAGARNP RESTOSALIQUIDAR AMORTIZACAODADIVIDA JUROSEENCARGOSDIVIDA_JED SERVICOSFINANCEIROS REFINANCIAMENTODADIVIDAINTERNA REFINANCIAMENTODADIVIDAEXTERNA SERVICODADIVIDAINTERNA SERVICODADIVIDAEXTERNA
rename POPULACAO population 
rename RECORCAMENTARIA revenue_budget_F
rename IMPOSTOS revenue_taxes_F
rename TAXAS revenue_fees_F
rename RECINDUSTRIAL revenue_industrial_F
rename RECAGROPECUARIA revenue_agro_F
rename RECDESERVICOS revenue_services_F
rename DESPESASORCAMENTARIAS spending_budget_F
rename DESPESASDECAPITAL spending_capital_F
rename INVESTIMENTOS investment_F
rename PESSOALEENCARGSOC_PES spending_personnel_F
rename SAUDE spending_health_F
rename EDUCACAO spending_education_F
rename URBANISMO spending_urban_F
rename HABITACAO spending_housing_F
rename SANEAMENTO spending_sanitation_F
rename RESTOSAPAGARPROCESSADOS debt_processed_F
rename RESTOSAPAGARNP debt_unprocessed_F
rename RESTOSALIQUIDAR debt_toliquidate_F
rename AMORTIZACAODADIVIDA debt_payment_F
rename JUROSEENCARGOSDIVIDA_JED debt_interest_F
rename SERVICOSFINANCEIROS spending_finservices_F
rename REFINANCIAMENTODADIVIDAINTERNA debt_refinanceintern_F
rename REFINANCIAMENTODADIVIDAEXTERNA debt_refinanceextern_F
rename SERVICODADIVIDAINTERNA debt_serviceintern_F
rename SERVICODADIVIDAEXTERNA debt_serviceextern_F

rename OUTRASDESPNAFUNCAOINDUSTRIA other_industry__F

*Shorten enrollment var names 
rename num_students_municipal n_student_mun
rename num_students_private n_student_pri
rename num_students_fed_state n_student_otherpub

gen debt_mgmt_costs = debt_payment_F + debt_interest_F + spending_finservices_F + debt_serviceintern_F + debt_serviceextern_F
gen debt_stock = debt_processed_F + debt_unprocessed_F + debt_toliquidate_F
gen debt_total = debt_mgmt_costs + debt_stock


*IPEA Outcomes 
rename spending_assistancepensions spending_assistpension
rename spending_healthsanitation spending_hlthsanit
rename spending_financialinvest spending_fininvest

gen rev_nonoil_I = revenue_current - oil_revenue

local vars "spending_admin spending_assistpension spending_edculture spending_housingurban spending_hlthsanit spending_labor revenue_budget revenue_current revenue_taxes spending_specialcharges spending_current spending_costs spending_personnel spending_capital spending_budget spending_capitalinvest spending_fininvest"
foreach j of local vars{
rename `j' `j'_I
}

*RAIS Public Employment Outcomes 
*No transformations required: avg_wage_dez avg_wage_year ag_wage extr_wage mfg_wage util_wage constr_wage hosp_wage trade_wage nontrade_wage total_hourscontracted total_wages extractive manufacturing construction commerce hospitality publicadmin mun_pubadmin education health public total_formalworkers


*RAIS Private Sector Outcomes
*Create shorter variable names 
rename wage_avg_ag w_avg_ag
rename number_hired_ag n_hire_ag
rename number_laid_off_ag n_laidoff_ag
rename number_employed_ag n_empl_ag
rename wage_avg_constr w_avg_const
rename number_hired_constr n_hire_const
rename number_laid_off_constr n_laidoff_const
rename number_employed_constr n_empl_const
rename wage_avg_extract w_avg_extr
rename number_hired_extract n_hire_extr
rename number_laid_off_extract n_laidoff_extr
rename number_employed_extract n_empl_extr
rename wage_avg_govt w_avg_gov
rename number_hired_govt n_hire_gov
rename number_laid_off_govt n_laidoff_gov
rename number_employed_govt n_empl_gov
rename wage_avg_mfg w_avg_mfg
rename number_hired_mfg n_hire_mfg
rename number_laid_off_mfg n_laidoff_mfg
rename number_employed_mfg n_empl_mfg
rename wage_avg_otherserv w_avg_othserv
rename number_hired_otherserv n_hire_othserv
rename number_laid_off_otherserv n_laidoff_othserv
rename number_employed_otherserv n_empl_othserv
rename wage_avg_retail w_avg_ret
rename number_hired_retail n_hire_ret
rename number_laid_off_retail n_laidoff_ret
rename number_employed_retail n_empl_ret
rename num_hired_tot n_hire_tot
rename num_laid_off_tot n_laidoff_tot
rename num_empl_tot n_empl_tot
rename num_hired_trade n_hire_trade
rename num_laid_off_trade n_laidoff_trade
rename num_empl_trade n_empl_trade
rename wage_avg_oil w_avg_oil
rename number_hired_oil n_hire_oil
rename number_laid_off_oil n_laidoff_oil
rename number_employed_oil n_empl_oil
rename num_firms_ag n_firms_ag
rename num_firms_nonmicro_ag n_firms_nm_ag
rename num_firms_constr n_firms_const
rename num_firms_nonmicro_constr n_firms_nm_const
rename num_firms_extract n_firms_extr
rename num_firms_nonmicro_extract n_firms_nm_extr
rename num_firms_govt n_firms_gov
rename num_firms_nonmicro_govt n_firms_nm_gov
rename num_firms_mfg n_firms_mfg
rename num_firms_nonmicro_mfg n_firms_nm_mfg
rename num_firms_otherserv n_firms_othserv
rename num_firms_nonmicro_otherserv n_firms_nm_othserv
rename num_firms_retail n_firms_ret
rename num_firms_nonmicro_retail n_firms_nm_ret
rename num_firms_tot n_firms_tot
rename num_firms_nonmicro_tot n_firms_nm_tot
rename num_firms_trade n_firms_trade
rename num_firms_nonmicro_trade n_firms_nm_trade
rename num_firms_oil n_firms_oil
rename num_firms_nonmicro_oil n_firms_nm_oil
rename net_entries_ag net_entry_ag
rename net_entries_nonmicro_ag net_entry_nm_ag
rename net_entries_extract net_entry_extr
rename net_entries_nonmicro_extract net_entry_nm_extr
rename net_entries_mfg net_entry_mfg
rename net_entries_nonmicro_mfg net_entry_nm_mfg
rename net_entries_constr net_entry_const
rename net_entries_nonmicro_constr net_entry_nm_const
rename net_entries_retail net_entry_ret
rename net_entries_nonmicro_retail net_entry_nm_ret
rename net_entries_otherserv net_entry_othserv
rename net_entries_nonmicro_otherserv net_entry_nm_othserv
rename net_entries_govt net_entry_gov
rename net_entries_nonmicro_govt net_entry_nm_gov
rename net_entries_tot net_entry_tot
rename net_entries_nonmicro_tot net_entry_nm_tot
rename net_entries_trade net_entry_trade
rename net_entries_nonmicro_trade net_entry_nm_trade
rename net_entries_oil net_entry_oil
rename net_entries_nonmicro_oil net_entry_nm_oil

*Add constant to all net hires (5000) and net firm entries (10000) to deal with negative values 
local nethires "nethire_ag nethire_constr nethire_extract nethire_govt nethire_mfg nethire_otherserv nethire_retail nethire_oil nethire_tot nethire_trade"
foreach k of local nethires {
replace `k' = `k'+5000
}

local netentries "net_entry_ag net_entry_nm_ag net_entry_extr net_entry_nm_extr net_entry_mfg net_entry_nm_mfg net_entry_const net_entry_nm_const net_entry_nm_ret net_entry_othserv net_entry_nm_othserv net_entry_gov net_entry_nm_gov net_entry_tot net_entry_nm_tot net_entry_trade net_entry_nm_trade net_entry_oil net_entry_nm_oil"
foreach j of local netentries {
replace `j' = `j' + 10000
}

*Compute growth rates for RAIS private sector vars 



*Additional outcomes: GDP, Population, Oil revenues 
*No transformations required at this stage.

*Transfers (Federal to Municipality)
*These include: AFM_AFE CIDE_fuel FEX FPM FUNDEB FUNDEF IOF_ouro ITR LeiKandir Royalties total_transfers transfers_nonroyalty

*Sum FUNDEB and FUNDEF 
gen FUNDEB_tot = FUNDEB + FUNDEF


*Calculate additional variables for analysis 

*Personnel as share of budget 
gen spending_personnel_share = spending_personnel_I / revenue_current_I
gen investment_share_F = investment_F / revenue_current_I
gen investment_share_I = spending_capitalinvest_I / revenue_current_I
gen debt_stock_share = debt_stock / revenue_current_I
gen tax_share_revenue_F = revenue_taxes_F / revenue_current_I 
gen oil_share_rev_transf = Royalties / revenue_current_I
gen oil_share_rev_ANP = oil_revenue / revenue_current_I

********************************************************************************
*Calculate GDP and population growth rates 
tsset munic_code year
sort munic_code year
*bysort munic_code: gen previous_population = population_complete[_n-1]
*WORK ON GDP
*bysort munic_code: gen previous_gdp = gdp[_n-1]

bysort munic_code: gen population_growth = (population_complete / population_complete[_n-1])*100-100
*bysort munic_code: gen gdp_growth = (gdp / gdp[_n-1])*100

********************************************************************************
*Compute per capita values and apply Inverse Hyperbolic Sine Transformation to relevant variables 

*First apply asinh transformation of total values 
local F "population_complete revenue_budget_F revenue_taxes_F revenue_fees_F revenue_industrial_F revenue_agro_F revenue_services_F rev_nonoil_I spending_budget_F spending_capital_F investment_F spending_personnel_F spending_health_F spending_education_F spending_urban_F spending_housing_F spending_sanitation_F debt_processed_F debt_unprocessed_F debt_toliquidate_F debt_payment_F debt_interest_F spending_finservices_F debt_refinanceintern_F debt_refinanceextern_F  debt_serviceextern_F debt_serviceintern_F debt_mgmt_costs debt_stock debt_total spending_admin_I spending_assistpension_I spending_edculture_I spending_housingurban_I spending_hlthsanit_I spending_labor_I revenue_budget_I revenue_current_I revenue_taxes_I spending_specialcharges_I spending_current_I spending_costs_I spending_personnel_I spending_capital_I spending_budget_I spending_capitalinvest_I spending_fininvest_I avg_wage_dez avg_wage_year ag_wage extr_wage mfg_wage util_wage constr_wage hosp_wage trade_wage nontrade_wage total_hourscontracted total_wages extractive manufacturing construction commerce hospitality publicadmin mun_pubadmin education health public total_formalworkers gdp oil_revenue AFM_AFE CIDE_fuel FEX FPM FUNDEB FUNDEF FUNDEB_tot IOF_ouro ITR LeiKandir Royalties total_transfers transfers_nonroyalty rank_educ rank_health rank_empl w_avg_ag n_hire_ag n_laidoff_ag n_empl_ag w_avg_const n_hire_const n_laidoff_const n_empl_const w_avg_extr n_hire_extr n_laidoff_extr n_empl_extr w_avg_gov n_hire_gov n_laidoff_gov n_empl_gov w_avg_mfg n_hire_mfg n_laidoff_mfg n_empl_mfg w_avg_othserv n_hire_othserv n_laidoff_othserv n_empl_othserv w_avg_ret n_hire_ret n_laidoff_ret n_empl_ret n_hire_tot n_laidoff_tot n_empl_tot n_hire_trade n_laidoff_trade n_empl_trade w_avg_oil n_hire_oil n_laidoff_oil n_empl_oil n_firms_ag n_firms_nm_ag n_firms_const n_firms_nm_const n_firms_extr n_firms_nm_extr n_firms_gov n_firms_nm_gov n_firms_mfg n_firms_nm_mfg n_firms_othserv n_firms_nm_othserv n_firms_ret n_firms_nm_ret n_firms_tot n_firms_nm_tot n_firms_trade n_firms_nm_trade n_firms_oil n_firms_nm_oil net_entry_ag net_entry_nm_ag net_entry_extr net_entry_nm_extr net_entry_mfg net_entry_nm_mfg net_entry_const net_entry_nm_const net_entry_ret net_entry_nm_ret net_entry_othserv net_entry_nm_othserv net_entry_gov net_entry_nm_gov net_entry_tot net_entry_nm_tot net_entry_trade net_entry_nm_trade net_entry_oil net_entry_nm_oil nethire_ag nethire_constr nethire_extract nethire_govt nethire_mfg nethire_otherserv nethire_retail nethire_oil nethire_tot nethire_trade municipal_beds migrant_number n_student_mun n_student_pri n_student_otherpub families_bf people_bf value_bf families_cu people_cu"
foreach i of local F {
*replace `i' = 0 if `i' == .
gen ihs_`i' = asinh(`i')
}

*Compute per capita values
local F "revenue_budget_F revenue_taxes_F revenue_fees_F revenue_industrial_F revenue_agro_F revenue_services_F rev_nonoil_I spending_budget_F spending_capital_F investment_F spending_personnel_F spending_health_F spending_education_F spending_urban_F spending_housing_F spending_sanitation_F debt_processed_F debt_unprocessed_F debt_toliquidate_F debt_payment_F debt_interest_F spending_finservices_F debt_refinanceintern_F debt_refinanceextern_F  debt_serviceextern_F debt_serviceintern_F debt_mgmt_costs debt_stock debt_total spending_admin_I spending_assistpension_I spending_edculture_I spending_housingurban_I spending_hlthsanit_I spending_labor_I revenue_budget_I revenue_current_I revenue_taxes_I spending_specialcharges_I spending_current_I spending_costs_I spending_personnel_I spending_capital_I spending_budget_I spending_capitalinvest_I spending_fininvest_I avg_wage_dez avg_wage_year ag_wage extr_wage mfg_wage util_wage constr_wage hosp_wage trade_wage nontrade_wage total_hourscontracted total_wages extractive manufacturing construction commerce hospitality publicadmin mun_pubadmin education health public total_formalworkers gdp oil_revenue AFM_AFE CIDE_fuel FEX FPM FUNDEB FUNDEF FUNDEB_tot IOF_ouro ITR LeiKandir Royalties total_transfers transfers_nonroyalty w_avg_ag n_hire_ag n_laidoff_ag n_empl_ag w_avg_const n_hire_const n_laidoff_const n_empl_const w_avg_extr n_hire_extr n_laidoff_extr n_empl_extr w_avg_gov n_hire_gov n_laidoff_gov n_empl_gov w_avg_mfg n_hire_mfg n_laidoff_mfg n_empl_mfg w_avg_othserv n_hire_othserv n_laidoff_othserv n_empl_othserv w_avg_ret n_hire_ret n_laidoff_ret n_empl_ret n_hire_tot n_laidoff_tot n_empl_tot n_hire_trade n_laidoff_trade n_empl_trade w_avg_oil n_hire_oil n_laidoff_oil n_empl_oil n_firms_ag n_firms_nm_ag n_firms_const n_firms_nm_const n_firms_extr n_firms_nm_extr n_firms_gov n_firms_nm_gov n_firms_mfg n_firms_nm_mfg n_firms_othserv n_firms_nm_othserv n_firms_ret n_firms_nm_ret n_firms_tot n_firms_nm_tot n_firms_trade n_firms_nm_trade n_firms_oil n_firms_nm_oil net_entry_ag net_entry_nm_ag net_entry_extr net_entry_nm_extr net_entry_mfg net_entry_nm_mfg net_entry_const net_entry_nm_const net_entry_ret net_entry_nm_ret net_entry_othserv net_entry_nm_othserv net_entry_gov net_entry_nm_gov net_entry_tot net_entry_nm_tot net_entry_trade net_entry_nm_trade net_entry_oil net_entry_nm_oil nethire_ag nethire_constr nethire_extract nethire_govt nethire_mfg nethire_otherserv nethire_retail nethire_oil nethire_tot nethire_trade municipal_beds migrant_number AGRICULTURA COMERCIOESERVICOS PROMOCAOCOMERCIAL PROMOCAOINDUSTRIAL PROMOCAODAPRODUCAOVEGETAL PROMOCAODAPRODUCAOANIMAL other_industry__F PRODUCAOINDUSTRIAL PROPRIEDADEINDUSTRIAL n_student_mun n_student_pri n_student_otherpub families_bf value_bf people_bf families_cu people_cu"
foreach i of local F {
gen `i'_pc = `i' / population_complete 
}

*Next, compute asinh of per capita values 
local F "revenue_budget_F_pc revenue_taxes_F_pc revenue_fees_F_pc revenue_industrial_F_pc revenue_agro_F_pc revenue_services_F_pc rev_nonoil_I_pc spending_budget_F_pc spending_capital_F_pc investment_F_pc spending_personnel_F_pc spending_health_F_pc spending_education_F_pc spending_urban_F_pc spending_housing_F_pc spending_sanitation_F_pc debt_processed_F_pc debt_unprocessed_F_pc debt_toliquidate_F_pc debt_payment_F_pc debt_interest_F_pc spending_finservices_F_pc debt_refinanceintern_F_pc debt_refinanceextern_F_pc debt_serviceextern_F_pc debt_serviceintern_F_pc debt_mgmt_costs_pc debt_stock_pc debt_total_pc spending_admin_I_pc spending_assistpension_I_pc spending_edculture_I_pc spending_housingurban_I_pc spending_hlthsanit_I_pc spending_labor_I_pc revenue_budget_I_pc revenue_current_I_pc revenue_taxes_I_pc spending_specialcharges_I_pc spending_current_I_pc spending_costs_I_pc spending_personnel_I_pc spending_capital_I_pc spending_budget_I_pc spending_capitalinvest_I_pc spending_fininvest_I_pc avg_wage_dez_pc avg_wage_year_pc ag_wage_pc extr_wage_pc mfg_wage_pc util_wage_pc constr_wage_pc hosp_wage_pc trade_wage_pc nontrade_wage_pc total_hourscontracted_pc total_wages_pc extractive_pc manufacturing_pc construction_pc commerce_pc hospitality_pc publicadmin_pc mun_pubadmin_pc education_pc health_pc public_pc total_formalworkers_pc gdp_pc oil_revenue_pc AFM_AFE_pc CIDE_fuel_pc FEX_pc FPM_pc FUNDEB_pc FUNDEF_pc FUNDEB_tot_pc IOF_ouro_pc ITR_pc LeiKandir_pc Royalties_pc total_transfers_pc transfers_nonroyalty_pc w_avg_ag_pc n_hire_ag_pc n_laidoff_ag_pc n_empl_ag_pc w_avg_const_pc n_hire_const_pc n_laidoff_const_pc n_empl_const_pc w_avg_extr_pc n_hire_extr_pc n_laidoff_extr_pc n_empl_extr_pc w_avg_gov_pc n_hire_gov_pc n_laidoff_gov_pc n_empl_gov_pc w_avg_mfg_pc n_hire_mfg_pc n_laidoff_mfg_pc n_empl_mfg_pc w_avg_othserv_pc n_hire_othserv_pc n_laidoff_othserv_pc n_empl_othserv_pc w_avg_ret_pc n_hire_ret_pc n_laidoff_ret_pc n_empl_ret_pc n_hire_tot_pc n_laidoff_tot_pc n_empl_tot_pc n_hire_trade_pc n_laidoff_trade_pc n_empl_trade_pc w_avg_oil_pc n_hire_oil_pc n_laidoff_oil_pc n_empl_oil_pc n_firms_ag_pc n_firms_nm_ag_pc n_firms_const_pc n_firms_nm_const_pc n_firms_extr_pc n_firms_nm_extr_pc n_firms_gov_pc n_firms_nm_gov_pc n_firms_mfg_pc n_firms_nm_mfg_pc n_firms_othserv_pc n_firms_nm_othserv_pc n_firms_ret_pc n_firms_nm_ret_pc n_firms_tot_pc n_firms_nm_tot_pc n_firms_trade_pc n_firms_nm_trade_pc n_firms_oil_pc n_firms_nm_oil_pc net_entry_ag_pc net_entry_nm_ag_pc net_entry_extr_pc net_entry_nm_extr_pc net_entry_mfg_pc net_entry_nm_mfg_pc net_entry_const_pc net_entry_nm_const_pc net_entry_ret_pc net_entry_nm_ret_pc net_entry_othserv_pc net_entry_nm_othserv_pc net_entry_gov_pc net_entry_nm_gov_pc net_entry_tot_pc net_entry_nm_tot_pc net_entry_trade_pc net_entry_nm_trade_pc net_entry_oil_pc net_entry_nm_oil_pc nethire_ag_pc nethire_constr_pc nethire_extract_pc nethire_govt_pc nethire_mfg_pc nethire_otherserv_pc nethire_retail_pc nethire_oil_pc nethire_tot_pc nethire_trade_pc municipal_beds_pc migrant_number_pc AGRICULTURA_pc COMERCIOESERVICOS_pc PROMOCAOCOMERCIAL_pc PROMOCAOINDUSTRIAL_pc PROMOCAODAPRODUCAOVEGETAL_pc PROMOCAODAPRODUCAOANIMAL_pc other_industry__F PRODUCAOINDUSTRIAL_pc PROPRIEDADEINDUSTRIAL_pc n_student_mun_pc n_student_pri_pc n_student_otherpub_pc families_bf_pc people_bf_pc value_bf_pc families_cu_pc people_cu_pc"
foreach i of local F {
gen ihs_`i' = asinh(`i')
}

*Abbreviate variable names
rename ihs_revenue_budget_F_pc ihs_rev_budget_F_pc
rename ihs_revenue_taxes_F_pc ihs_rev_taxes_F_pc
rename ihs_revenue_fees_F_pc ihs_rev_fees_F_pc
rename ihs_revenue_industrial_F_pc ihs_rev_industr_F_pc
rename ihs_revenue_agro_F_pc ihs_rev_agro_F_pc
rename ihs_revenue_services_F_pc ihs_rev_service_F_pc
rename ihs_spending_budget_F_pc ihs_spend_budget_F_pc
rename ihs_spending_capital_F_pc ihs_spend_capital_F_pc
rename ihs_investment_F_pc ihs_invest_F_pc 
rename ihs_spending_personnel_F_pc ihs_spend_personnel_F_pc
rename ihs_spending_health_F_pc ihs_spend_health_F_pc
rename ihs_spending_education_F_pc ihs_spend_education_F_pc
rename ihs_spending_urban_F_pc ihs_spend_urban_F_pc
rename ihs_spending_housing_F_pc ihs_spend_housing_F_pc
rename ihs_spending_sanitation_F_pc ihs_spend_sanitation_F_pc
rename ihs_debt_processed_F_pc ihs_debt_process_F_pc
rename ihs_debt_unprocessed_F_pc ihs_debt_unprocess_F_pc
rename ihs_debt_toliquidate_F_pc ihs_debt_toliquid_F_pc
rename ihs_debt_payment_F_pc ihs_debt_pay_F_pc
rename ihs_debt_interest_F_pc ihs_debt_interest_F_pc
rename ihs_spending_finservices_F_pc ihs_spend_finservice_F_pc
rename ihs_debt_refinanceintern_F_pc ihs_debt_refinintern_F_pc
rename ihs_debt_refinanceextern_F_pc ihs_debt_refinextern_F_pc
rename ihs_debt_serviceextern_F_pc ihs_debt_servextern_F_pc
rename ihs_debt_serviceintern_F_pc ihs_debt_servintern_F_pc
rename ihs_debt_mgmt_costs_pc ihs_debt_mgmt_costs_pc
rename ihs_debt_stock_pc ihs_debt_stock_pc
rename ihs_debt_total_pc ihs_debt_total_pc
rename ihs_spending_admin_I_pc ihs_spend_admin_I_pc
rename ihs_spending_assistpension_I_pc ihs_spend_asstpens_I_pc
rename ihs_spending_edculture_I_pc ihs_spend_edculture_I_pc
rename ihs_spending_housingurban_I_pc ihs_spend_housurban_I_pc
rename ihs_spending_hlthsanit_I_pc ihs_spend_hlthsanit_I_pc
rename ihs_spending_labor_I_pc ihs_spend_labor_I_pc
rename ihs_revenue_budget_I_pc ihs_rev_budget_I_pc
rename ihs_revenue_current_I_pc ihs_rev_current_I_pc
rename ihs_revenue_taxes_I_pc ihs_rev_taxes_I_pc
rename ihs_spending_specialcharges_I_pc ihs_spend_spec_I_pc
rename ihs_spending_current_I_pc ihs_spend_current_I_pc
rename ihs_spending_costs_I_pc ihs_spend_costs_I_pc
rename ihs_spending_personnel_I_pc ihs_spend_personnel_I_pc
rename ihs_spending_capital_I_pc ihs_spend_capital_I_pc
rename ihs_spending_budget_I_pc ihs_spend_budget_I_pc
rename ihs_spending_capitalinvest_I_pc ihs_spend_capinv_I_pc
rename ihs_spending_fininvest_I_pc ihs_spend_fininv_I_pc
rename ihs_total_hourscontracted_pc ihs_tot_hrscontract_pc
rename ihs_total_formalworkers_pc ihs_tot_formalempl_pc
rename ihs_total_transfers_pc ihs_tot_transf_pc 
rename ihs_transfers_nonroyalty_pc ihs_transf_nonoil_pc


save "Munics_for_Matching_cleaned_outcomes", replace 


********************************************************************************
********************************************************************************
*Keep all observations
use "Munics_for_Matching_cleaned_outcomes", clear

*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_announcements if cum_cvm_announcements != 0 & L1.cum_cvm_announcements == 0
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*We now have indicator for year when first event occurred

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

*Create relative time indicator 
gen first_CVM_year_tmp = year if first_CVM != 0
bysort munic_code: egen first_CVM_year = max(first_CVM_year_tmp)
drop first_CVM_year_tmp

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

*Events are now totally saturated.

*Merge in disappointment indicators
merge m:1 municipality using "Temporary_Disappointment"
replace disappointed = 0 if _merge == 1
drop _merge
rename disappointed disappointed_temp

merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

*Save dataset for analysis 
save "Event_Analysis_FirstEvent", replace 

*********************************************************************************
*Create datasets for AFFECTED BY OIL FIRST EVENT 
keep if wells_completed_2000_2017 > 0 | hydrocarbon_detections_2000_2017 > 0 | cvm_announcements_2000_2017 > 0 | volume_announced_2000_2017 > 0 | all_time_production > 0 

preserve 
keep if hydrocarbon_detections_2000_2017 > 0
save "Event_Analysis_Hydrocarbons_FirstEvent", replace 
restore 

preserve 
keep if wells_completed_2000_2017 > 0
save "Event_Analysis_Wells_FirstEvent", replace 
restore 

********************************************************************************
*Repeat for multiple events 
*Hydrocarbons 
use "Munics_for_Matching_cleaned_outcomes", clear 

*All munics with hydrocarbon detections (most comparable, since successful)
*Keep first comparison group: all municipalities with some hydrocarbon detections. 
*Among these, those with no CVM announcements ever are control, while those with some
*CVM announcements are treated. This group is comparable because it is all amongst places
*that got 1) drilling and 2) discoveries.
keep if hydrocarbon_detections_2000_2017 > 0

*VERSION 1: Multiple events per unit 

*Define "event" = CVM announcement in year = number_cvm_announcements > 0 for a year
*First, create event indicator and turn it on when number_cvm_announcements > 0
gen event_time_0 = 0
replace event_time_0 = 1 if number_cvm_announcements > 0

*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

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
/*
*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & number_cvm_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.number_cvm_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017
*/
*Merge in disappointment indicators
merge m:1 municipality using "Temporary_Disappointment"
replace disappointed = 0 if _merge == 1
drop _merge
rename disappointed disappointed_temp

merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge


*Save dataset for analysis 
save "Event_Analysis_Hydrocarbons_MultipleEvents", replace 

***********************************************************************************
********************************************************************************
*Repeat for multiple events 
use "Munics_for_Matching_cleaned_outcomes", clear 
*WELLS 

*All munics with wells
*Keep first comparison group: all municipalities with some hydrocarbon detections. 
*Among these, those with no CVM announcements ever are control, while those with some
*CVM announcements are treated. This group is comparable because it is all amongst places
*that got 1) drilling and 2) discoveries.
keep if wells_completed_2000_2017 > 0

*VERSION 1: Multiple events per unit 

*Define "event" = CVM announcement in year = number_cvm_announcements > 0 for a year
*First, create event indicator and turn it on when number_cvm_announcements > 0
gen event_time_0 = 0
replace event_time_0 = 1 if number_cvm_announcements > 0

*Set data as time series to allow ts operators
tsset munic_code year
sort munic_code year

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
/*
*Now, generate indicator post for events in 2017
gen event_time_post = 0
replace event_time_post = 1 if year == 2017 & number_cvm_announcements > 0

*Turn off pre-2017 indicators 
forvalues i = 1(1)15 {
replace event_time_`i'b = 0 if F`i'.year == 2017 & F`i'.number_cvm_announcements > 0
}

*Now, drop 2017 observations from sample 
drop if year == 2017
*/
*Merge in disappointment indicators
merge m:1 municipality using "Temporary_Disappointment"
replace disappointed = 0 if _merge == 1
drop _merge
rename disappointed disappointed_temp

merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge


*Save dataset for analysis 
save "Event_Analysis_Wells_MultipleEvents", replace 
*********************************************************************************

