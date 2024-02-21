clear
cd "${user}\Data Directory\Treatment Variables"

*Create different samples 
********************************************************************************
*1) Disappointed
use "Event_Analysis_Wells_FirstEvent", clear 

keep if disappointed_pc_low == 1

keep munic_code year latitude dist_statecapital gdp_2002 income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F

*Compute per capita values 
local pc "gdp_2002 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F"
foreach j of loca pc {
	gen `j'_pc = `j'/ pesotot_2000
}

keep munic_code year latitude dist_statecapital gdp_2002_pc income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc 

rename RDPC_2000 income_pc_2000

local sd "latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc"
foreach i of local sd {
	gen `i'_sd = `i'
}

keep if year == 2000

replace gdp_2002_pc = gdp_2002_pc * 1000
replace income_pc_2000 = income_pc_2000 * 12

collapse (mean) latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc (sd) latitude_sd dist_statecapital_sd gdp_2002_pc_sd income_pc_2000_sd GINI_2000_sd pesotot_2000_sd AGUA_ESGOTO_2000_sd urban_share_sd ifdm_2000_sd P_EXTR_2000_sd P_FORMAL_2000_sd oil_revenue_pc_sd revenue_current_I_pc_sd revenue_taxes_I_pc_sd spending_current_I_pc_sd investment_F_pc_sd

gen group = "disappointed_low"

save "Balance_Table_Disappointed_Low", replace


********************************************************************************
*2) Satisfied 
use "Event_Analysis_Wells_FirstEvent", clear 

keep if disappointed_pc_low == 2

keep munic_code year latitude dist_statecapital gdp_2002 income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F

*Compute per capita values 
local pc "gdp_2002 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F"
foreach j of loca pc {
	gen `j'_pc = `j'/ pesotot_2000
}

keep munic_code year latitude dist_statecapital gdp_2002_pc income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc 

rename RDPC_2000 income_pc_2000

local sd "latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc"
foreach i of local sd {
	gen `i'_sd = `i'
}

keep if year == 2000

replace gdp_2002_pc = gdp_2002_pc * 1000
replace income_pc_2000 = income_pc_2000 * 12

collapse (mean) latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc (sd) latitude_sd dist_statecapital_sd gdp_2002_pc_sd income_pc_2000_sd GINI_2000_sd pesotot_2000_sd AGUA_ESGOTO_2000_sd urban_share_sd ifdm_2000_sd P_EXTR_2000_sd P_FORMAL_2000_sd oil_revenue_pc_sd revenue_current_I_pc_sd revenue_taxes_I_pc_sd spending_current_I_pc_sd investment_F_pc_sd


gen group = "satisfied_low"

save "Balance_Table_Satisfied_Low", replace

********************************************************************************
*4) Wells non-treated
use "Event_Analysis_Wells_FirstEvent", clear 

keep if disappointed_pc_low == 0

keep munic_code year latitude dist_statecapital gdp_2002 income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F

*Compute per capita values 
local pc "gdp_2002 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F"
foreach j of loca pc {
	gen `j'_pc = `j'/ pesotot_2000
}

keep munic_code year latitude dist_statecapital gdp_2002_pc income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc 

rename RDPC_2000 income_pc_2000

local sd "latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc"
foreach i of local sd {
	gen `i'_sd = `i'
}

keep if year == 2000

replace gdp_2002_pc = gdp_2002_pc * 1000
replace income_pc_2000 = income_pc_2000 * 12

collapse (mean) latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc (sd) latitude_sd dist_statecapital_sd gdp_2002_pc_sd income_pc_2000_sd GINI_2000_sd pesotot_2000_sd AGUA_ESGOTO_2000_sd urban_share_sd ifdm_2000_sd P_EXTR_2000_sd P_FORMAL_2000_sd oil_revenue_pc_sd revenue_current_I_pc_sd revenue_taxes_I_pc_sd spending_current_I_pc_sd investment_F_pc_sd

gen group = "well_controls"

save "Balance_Table_Wells_Controls", replace

********************************************************************************
*5) Matched non-treated (disappointed)
use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_low", clear

keep if control_disappointed == 1

keep munic_code year latitude dist_statecapital gdp_2002 income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F

*Compute per capita values 
local pc "gdp_2002 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F"
foreach j of loca pc {
	gen `j'_pc = `j'/ pesotot_2000
}

keep munic_code year latitude dist_statecapital gdp_2002_pc income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc 

rename RDPC_2000 income_pc_2000

local sd "latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc"
foreach i of local sd {
	gen `i'_sd = `i'
}

keep if year == 2000

replace gdp_2002_pc = gdp_2002_pc * 1000
replace income_pc_2000 = income_pc_2000 * 12

collapse (mean) latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc (sd) latitude_sd dist_statecapital_sd gdp_2002_pc_sd income_pc_2000_sd GINI_2000_sd pesotot_2000_sd AGUA_ESGOTO_2000_sd urban_share_sd ifdm_2000_sd P_EXTR_2000_sd P_FORMAL_2000_sd oil_revenue_pc_sd revenue_current_I_pc_sd revenue_taxes_I_pc_sd spending_current_I_pc_sd investment_F_pc_sd

gen group = "matched_control_disappointed_low"

save "Balance_Table_MatchedControls_Disappointed_Low", replace

********************************************************************************
*6) Matched non-treated (satisfied)
use "Event_Analysis_CEMMedium_FirstEvent_disappointed_pc_low", clear

keep if control_satisfied == 1

keep munic_code year latitude dist_statecapital gdp_2002 income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F

*Compute per capita values 
local pc "gdp_2002 oil_revenue revenue_current_I revenue_taxes_I spending_current_I investment_F"
foreach j of loca pc {
	gen `j'_pc = `j'/ pesotot_2000
}

keep munic_code year latitude dist_statecapital gdp_2002_pc income_capita_2000 RDPC_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc 

rename RDPC_2000 income_pc_2000

local sd "latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc"
foreach i of local sd {
	gen `i'_sd = `i'
}

keep if year == 2000

replace gdp_2002_pc = gdp_2002_pc * 1000
replace income_pc_2000 = income_pc_2000 * 12

collapse (mean) latitude dist_statecapital gdp_2002_pc income_pc_2000 GINI_2000 pesotot_2000 AGUA_ESGOTO_2000 urban_share ifdm_2000 P_EXTR_2000 P_FORMAL_2000 oil_revenue_pc revenue_current_I_pc revenue_taxes_I_pc spending_current_I_pc investment_F_pc (sd) latitude_sd dist_statecapital_sd gdp_2002_pc_sd income_pc_2000_sd GINI_2000_sd pesotot_2000_sd AGUA_ESGOTO_2000_sd urban_share_sd ifdm_2000_sd P_EXTR_2000_sd P_FORMAL_2000_sd oil_revenue_pc_sd revenue_current_I_pc_sd revenue_taxes_I_pc_sd spending_current_I_pc_sd investment_F_pc_sd

gen group = "matched_control_satisfied_low"

save "Balance_Table_MatchedControls_Satisfied_Low", replace

*******************************************************************************
use "Balance_Table_Disappointed_Low", clear
append using "Balance_Table_Satisfied_Low", force
*append using "Balance_Table_AllCoastalControl", force
append using "Balance_Table_Wells_Controls", force 
append using "Balance_Table_MatchedControls_Disappointed_Low", force 
append using "Balance_Table_MatchedControls_Satisfied_Low", force 

order group 

save "Balance_Table_Statistics", replace 






*******************************************************************************
*Compute baseline outcome means for control group 

*Wells controls
use "Event_Analysis_Wells_FirstEvent", clear 

keep if disappointed_pc_low == 0

keep if year == 2000

drop gdp_pc 
gen gdp_pc = gdp_2002*1000 / population_complete 

collapse (mean) revenue_current_I revenue_current_I_pc revenue_taxes_I_pc oil_revenue_pc transfers_nonroyalty_pc spending_current_I spending_current_I_pc investment_F_pc spending_personnel_I_pc spending_edculture_I_pc spending_hlthsanit_I_pc gdp_2002 gdp_pc population_complete