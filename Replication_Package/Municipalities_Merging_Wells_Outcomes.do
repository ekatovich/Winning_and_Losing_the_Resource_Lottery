********************************************************************************
*Merge Municipality-level Treatment Dataset into Balanced Municipality Panel of Outcomes and Covariates
*These include Royalties and Special Participations (annual), Public Finances, and Private Sector from RAIS
*Election outcomes require additional collapses (separate do-file)
********************************************************************************

*Set working directory
clear
cd "${user}\Data Directory\Treatment Variables"

*******************************************************************************************************
*ROYALTIES AND SPECIAL PARTICIPATIONS
*Merge municipality-level wells treatment dataset with balanced royalties and special participations panel 
use "${user}\Data Directory\Discoveries\Municipality_Well_Treatment", clear

destring munic_code, replace 

merge 1:1 munic_code year using "${user}\Data Directory\Royalties_and_SpecialParticipations\Data\Analysis\Royalties_and_SpecialPart_AnnualPanel_FINAL"
drop _merge 

sort munic_code year

*Set missings to zero were appropriate 
local zeros "number_of_wells_completed number_hydrocarbon_detections number_cvm_announcements announced_new_volume_mmboe imputed_volume_mmboe num_successful_wells num_unsuccessful_wells"
foreach j of local zeros {
replace `j' = 0 if `j' == .
}

*Now compute cumulative wells, hydrocarbon detections, CVM announcements, and volume 
bysort munic_code (year): gen cum_wells_completed = sum(number_of_wells_completed)
bysort munic_code (year): gen cum_hydrocarbons_detected = sum(number_hydrocarbon_detections)
bysort munic_code (year): gen cum_CVM_announcements = sum(number_cvm_announcements)
bysort munic_code (year): gen cum_volume_announced = sum(announced_new_volume_mmboe)
bysort munic_code (year): gen cum_volume_imputed = sum(imputed_volume_mmboe)

drop if year == 1999

********************************************************************************
*IPEA PUBLIC FINANCES (2000-2017)
*Merge in public finance data from IPEA 
merge 1:1 munic_code year using "IPEA_PublicFinances_2000_2017.dta"
drop if _merge == 2
drop _merge 

sort munic_code year

********************************************************************************
*RAIS FORMAL EMPLOYMENT (2000-2017)

*Create munic_code_6digit 
tostring munic_code, replace 
gen munic_code_6digit = substr(munic_code,1,6)
destring munic_code, replace 
destring munic_code_6digit, replace 
order munic_code munic_code_6digit

merge 1:1 munic_code_6digit year using "RAIS_Unidentified_Municipalities.dta"

*For now, RAIS data only cleaned for coastal states. This shouldn't be a problem since comparisons are all amongst coastal areas. 
*Only problem may be if I include Minas Gerais later.
rename _merge RAIS_merge_coastal_state

********************************************************************************
*RAIS PRIVATE SECTOR (EMPLOYMENT and FIRM ENTRY) (2000-2017)
merge 1:1 munic_code_6digit year using "Munic_RAIS_PrivateSector_Panel_2000_to_2017"
drop _merge 


********************************************************************************
*SUPPLEMENTARY DATA (2000-2017)
merge m:1 year using "SupplementaryData.dta"
drop _merge 
drop if year == 2018 | year == 1999 | year == 1998

********************************************************************************

*Save partial progress on merges 
sort munic_code year
save "Municipality_Well_Treatment_with_Outcomes_TMP1", replace 


********************************************************************************
*CENSUS (1991, 2000-2015)
use "Census_IPEA_long", clear 

drop if year == 1985 | year == 1996

*Create munic_code_6digit 
tostring munic_code, replace 
gen munic_code_6digit = substr(munic_code,1,6)
destring munic_code, replace 
destring munic_code_6digit, replace 
order munic_code munic_code_6digit

*Create time invariant variables for 1991 covariates
local var_1991 "MORT T_FUND18M T_MED18M T_SUPER25M GINI PREN10RICOS PREN40 R1040 RDPC T_LUZ AGUA_ESGOTO pesoRUR pesotot pesourb income_capita theil poverty"
foreach i of local var_1991 {

sort munic_code_6digit year
bysort munic_code_6digit: gen `i'_1991_tmp = `i' if year == 1991 
bysort munic_code_6digit: egen `i'_1991 = max(`i'_1991_tmp)
drop `i'_1991_tmp

}

local var_2000 "MORT T_FUND18M T_MED18M T_SUPER25M GINI PREN10RICOS PREN40 R1040 RDPC RDPC1 RDPC10 P_AGRO P_COM P_CONSTR P_EXTR P_FORMAL P_SERV P_SIUP P_TRANSF T_ATIV18M T_DES18M TRABCC TRABPUB T_LUZ AGUA_ESGOTO T_FUNDIN18MINF PEA18M pesoRUR pesotot pesourb ifdm ifdm_employment_income ifdm_education ifdm_health hdi_income hdi_lifeexpect hdi_education income_capita theil poverty"
foreach j of local var_2000 {

sort munic_code_6digit year
bysort munic_code_6digit: gen `j'_2000_tmp = `j' if year == 2000
bysort munic_code_6digit: egen `j'_2000 = max(`j'_2000_tmp)
drop `j'_2000_tmp

}

drop if year == 1991

keep munic_code munic_code_6digit year dist_brasilia dist_statecapital latitude gdp_industry gdp_services gdp_publicadmin gdp_agriculture gdp MORT_1991 T_FUND18M_1991 T_MED18M_1991 T_SUPER25M_1991 GINI_1991 PREN10RICOS_1991 PREN40_1991 R1040_1991 RDPC_1991 T_LUZ_1991 AGUA_ESGOTO_1991 pesoRUR_1991 pesotot_1991 pesourb_1991 income_capita_1991 theil_1991 poverty_1991 MORT_2000 T_FUND18M_2000 T_MED18M_2000 T_SUPER25M_2000 GINI_2000 PREN10RICOS_2000 PREN40_2000 R1040_2000 RDPC_2000 RDPC1_2000 RDPC10_2000 P_AGRO_2000 P_COM_2000 P_CONSTR_2000 P_EXTR_2000 P_FORMAL_2000 P_SERV_2000 P_SIUP_2000 P_TRANSF_2000 T_ATIV18M_2000 T_DES18M_2000 TRABCC_2000 TRABPUB_2000 T_LUZ_2000 AGUA_ESGOTO_2000 T_FUNDIN18MINF_2000 PEA18M_2000 pesoRUR_2000 pesotot_2000 pesourb_2000 ifdm_2000 ifdm_employment_income_2000 ifdm_education_2000 ifdm_health_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 income_capita_2000 theil_2000 poverty_2000

save "Census_IPEA_forMerging", replace 

use "Municipality_Well_Treatment_with_Outcomes_TMP1", clear

merge 1:1 munic_code_6digit year using "Census_IPEA_forMerging"
drop _merge 
sort munic_code year

*Save partial progress on merges 
save "Municipality_Well_Treatment_with_Outcomes_TMP2", replace 

********************************************************************************
*Merge in coastal munic indicator 
import delimited "${user}\Data Directory\Shapefiles\CoastalMunics.csv", encoding(ISO-8859-2) clear

gen coastal_indicator = 1

save "Coastal_Indicator", replace 

use "Municipality_Well_Treatment_with_Outcomes_TMP2", clear 

merge m:1 munic_code using "Coastal_Indicator"
drop if _merge == 2
drop _merge 

replace coastal_indicator = 0 if coastal_indicator == .

save "Municipality_Well_Treatment_with_Outcomes_TMP3", replace 

********************************************************************************
*FINBRA PUBLIC FINANCES
use "${user}\Data Directory\Public Finances\PublicFinances_1998_2017", clear
keep if year > 1999
destring UF_NO, replace 

merge m:1 municipality using "brazil_geographical_codes.dta"

drop if _merge != 3
drop _merge 
drop munic_code_6digit micro_code meso_code

save "PublicFinances_2000_2017_forMerge", replace 

use "Municipality_Well_Treatment_with_Outcomes_TMP3", clear

merge 1:1 munic_code year using "PublicFinances_2000_2017_forMerge"
drop _merge

********************************************************************************
*Complete Population (IBGE + FINBRA)
merge 1:1 munic_code year using "${user}\Data Directory\Census\Population_Complete_Panel"
drop _merge

********************************************************************************
*Merge in In-Migration from Demographic census (2000-2010 only, so there'll be non-merges in the master dataset)
merge 1:1 munic_code year using "${user}\Data Directory\Census\In_Migration_with_NativeComparisons"
drop _merge 

********************************************************************************
*Federal to Municipality Transfers from Treasury (2000-2017)
merge 1:1 munic_code year using "${user}\Data Directory\Public Finances\Transfers\Transfers_Disaggregated_2000_to_2017"
drop _merge
*Drop non-coastal states
drop if uf == "MG" | uf == "MS" | uf == "MT" | uf == "GO" | uf == "BR" | uf == "TO" | uf == "RO" | uf == "RR" | uf == "AC" | uf == "AM"

sort municipality year 

**********************************************************************************
*Merge in FIRJAN Development Index (Public Goods) Indicators 
merge 1:1 munic_code_6digit year using "${user}\Data Directory\Public Goods\FIRJAN_IMD_Indicators_2005_2016"
drop _merge 

*Drop non-coastal states
drop if uf == "MG" | uf == "MS" | uf == "MT" | uf == "GO" | uf == "BR" | uf == "TO" | uf == "RO" | uf == "RR" | uf == "AC" | uf == "AM"

sort municipality year 


*********************************************************************************
*Merge in public goods indicators 

*First, health indicators 
merge 1:1 munic_code_6digit year using "${user}\Data Directory\Public Goods\Health_MunicipalPanel_2000_2017"

replace avoidable_infant_mort = 0 if avoidable_infant_mort == .
replace municipal_beds = 0 if municipal_beds == .
replace total_beds = 0 if total_beds == .
*Drop non-matches from using, which are non coastal state municipalities
drop if _merge == 2
rename _merge merge_health

sort munic_code year 

*******************************************************************************
*Education Indicators 
merge 1:1 munic_code_6digit year using "${user}\Data Directory\Public Goods\Education_PublicGoods_Panel_2000_2017"
*Drop non-matches from using 
drop if _merge == 2
drop _merge 

sort munic_code year 

*Enrollment 
merge 1:1 munic_code_6digit year using "${user}\Data Directory\Public Goods\Basic_Education_Census/Matriculations_Panel_2004_2017"
drop if _merge == 2
drop _merge 

*******************************************************************************
*Merge in Bolsa Familia data 
drop if munic_code == .
merge 1:1 munic_code year using "${user}\Data Directory\Census\BolsaFamilia_Panel_2004_2020"
drop if _merge == 2
drop _merge 


*******************************************************************************
*Formal labor migration 
merge 1:1 munic_code_6digit year using "${user}\Data Directory\Census\Formal_Migrants_Panel_2004_2017"
drop if _merge == 2
drop _merge 

********************************************************************************
*Now, drop observations from non-coastal states 
drop if RAIS_merge_coastal_state == 1

********************************************************************************
*This is the final panel with treatment and outcomes. 
*Organize and save 
sort munic_code year
order munic_code munic_code_6digit municipality uf UF_NO micro_code meso_code year

replace all_time_production = 0 if all_time_production == .
replace oil_bbl = 0 if oil_bbl == .
replace gas_mm3 = 0 if gas_mm3 == .
replace prod_boe = 0 if prod_boe == .

save "Municipality_Wells_Treatment_with_Outcomes", replace 




