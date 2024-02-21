
clear
cd "${user}\Data Directory\Treatment Variables"


*Use wells sample:

use "Munics_Affected_by_Oil", clear

keep munic_code municipality munic_code_6digit uf munic_code munic_code_6digit municipality wells_completed_2000_2017 hydrocarbon_detections_2000_2017 cvm_announcements_2000_2017 coastal_indicator

collapse (firstnm) municipality munic_code_6digit uf coastal_indicator (mean) wells_completed_2000_2017 hydrocarbon_detections_2000_2017 cvm_announcements_2000_2017, by(munic_code)



*Merge in disappointment indicators
merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

gen disappointed = 0
replace disappointed = 1 if disappointed_pc_med == 1
replace disappointed = 2 if disappointed_pc_med == 2

gen Sample = ""
replace Sample = "Wells, No Discoveries" if wells_completed_2000_2017 > 0 
drop if Sample == ""
replace Sample = "Wells, No Discoveries" if hydrocarbon_detections_2000_2017 > 0
replace Sample = "Discoveries (Disappointed)" if disappointed == 1
replace Sample = "Discoveries (Satisfied)" if disappointed == 2

rename munic_code CD_GCMUN

gen keeper = 0
replace keeper = 1 if municipality == "RIODEJANEIRO33" 
replace keeper = 1 if municipality == "ILHABELA35"
*replace keeper = 1 if municipality == "ARACAJU28"
replace keeper = 1 if municipality == "PIRAMBU28"
*replace keeper = 1 if municipality == "CAMPOSDOSGOYTACAZES33"
*replace keeper = 1 if municipality == "SERRA32"
*replace keeper = 1 if municipality == "CANAVIEIRAS29"
replace keeper = 1 if municipality == "IGUAPE35"
replace keeper = 1 if municipality == "AREIABRANCA24"
*replace keeper = 1 if municipality == "PARACURU23"
*replace keeper = 1 if municipality == "ARMACAODOSBUZIOS33"

replace municipality = "" if keeper == 0

replace municipality = "Rio de Janeiro, RJ" if municipality == "RIODEJANEIRO33" 
replace municipality = "Ilha Bela, SP" if municipality == "ILHABELA35"
*replace municipality = "Aracaju, SE" if municipality == "ARACAJU28"
replace municipality = "Pirambu, SE" if municipality == "PIRAMBU28"
*replace municipality = "Campos dos Goytacazes, RJ" if municipality == "CAMPOSDOSGOYTACAZES33"
*replace municipality = "Serra, ES" if municipality == "SERRA32"
*replace municipality = "Canavieiras, BA" if municipality == "CANAVIEIRAS29"
replace municipality = "Iguape, SP" if municipality == "IGUAPE35"
replace municipality = "Areia Branca, RN" if municipality == "AREIABRANCA24"
*replace municipality = "Paracuru, CE" if municipality == "PARACURU23"
*replace municipality = "Armacao dos Buzios, RJ" if municipality == "ARMACAODOSBUZIOS33"

export delimited using "${user}\Data Directory\Treatment Variables\Samples_for_Mapping.csv", replace

********************************************************************************
*Now compute descriptive statistics

use "Munics_Affected_by_Oil", clear

collapse (firstnm) municipality munic_code_6digit uf dist_statecapital latitude gdp GINI_2000 pesourb_2000 ifdm_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 POPULACAO (mean) wells_completed_2000_2017 hydrocarbon_detections_2000_2017 cvm_announcements_2000_2017, by(munic_code)

*Merge in disappointment indicators
merge m:1 municipality using "Temporary_Disappointment"
replace disappointed = 0 if _merge == 1
drop _merge

rename POPULACAO population 

gen Wells_Sample = 0
replace Wells_Sample = 1 if wells_completed_2000_2017 > 0 & cvm_announcements_2000_2017 == 0

gen Hydrocarbons_Sample = 0
replace Hydrocarbons_Sample = 1 if hydrocarbon_detections_2000_2017 > 0 & cvm_announcements_2000_2017 == 0

gen CVM_Disappointed = 0
replace CVM_Disappointed = 1 if disappointed == 1

gen CVM_Satisfied = 0
replace CVM_Satisfied = 1 if disappointed == 2 

gen urban_share = pesourb_2000 / population 

local vars "dist_statecapital latitude gdp GINI_2000 urban_share ifdm_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 population"
foreach i of local vars {

sum `i' if Wells_Sample == 1
sum `i' if Hydrocarbons_Sample == 1
sum `i' if CVM_Disappointed == 1
sum `i' if CVM_Satisfied == 1

}

*********************************************************************************
use "${user}\Data Directory\Discoveries\Wells_Registry_2000_2017_Supplemented", clear 

keep if announcement_id != .

keep announcement_year well_name concession_block field imputed_volume_mmboe latitude_base_dd longitude_base_dd announcement_id

sort announcement_year 

*Generate text labels 
gen field_label = ""
replace field_label = "TUPI" if field == "LULA" & announcement_id == 16
replace field_label = "JUBARTE" if field == "JUBARTE" & announcement_id == 3
replace field_label = "LIBRA" if field == "MERO" & announcement_id == 146
replace field_label = "PECEM" if well_name == "PECEM" & announcement_id == 128
replace field_label = "FARFAN" if well_name == "FARFAN" & announcement_id == 132

export delimited using "${user}\Data Directory\Discoveries\Discoveries_for_Mapping.csv", replace


