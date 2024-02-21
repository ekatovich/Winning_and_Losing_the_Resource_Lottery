
clear 
cd "${user}\Data Directory\Treatment Variables"

use "Municipality_Wells_Treatment_with_Outcomes", clear

*First, construct subsample of municipalities that ever had a well completed.
bysort munic_code: egen wells_completed_2000_2017 = sum(number_of_wells_completed)
bysort munic_code: egen hydrocarbon_detections_2000_2017 = sum(number_hydrocarbon_detections)
bysort munic_code: egen cvm_announcements_2000_2017 = sum(number_cvm_announcements)
bysort munic_code: egen volume_announced_2000_2017 = sum(announced_new_volume_mmboe)
bysort munic_code: egen volume_imputed_2000_2017 = sum(imputed_volume_mmboe)
bysort munic_code: egen successful_wells_2000_2017 = sum(num_successful_wells)
bysort munic_code: egen oil_revenue_2000_2017 = sum(oil_revenue)

*Keep only oil affected municipalities for now
keep if wells_completed_2000_2017 > 0 | hydrocarbon_detections_2000_2017 > 0 | cvm_announcements_2000_2017 > 0 | volume_announced_2000_2017 > 0 | all_time_production > 0

*Now compute cumulative wells completed, hydrocarbon detections, cvm announcements, volume announced, and oil/gas production
drop cum_wells_completed cum_hydrocarbons_detected cum_CVM_announcements cum_volume_announced cum_volume_imputed
bysort munic_code (year): gen cum_wells_completed = sum(number_of_wells_completed)
bysort munic_code (year): gen cum_hydrocarbons_detected = sum(number_hydrocarbon_detections)
bysort munic_code (year): gen cum_cvm_announcements = sum(number_cvm_announcements)
bysort munic_code (year): gen cum_volume_announced = sum(announced_new_volume_mmboe)
bysort munic_code (year): gen cum_volume_imputed = sum(imputed_volume_mmboe)
bysort munic_code (year): gen cum_successful_wells = sum(num_successful_wells)
bysort munic_code (year): gen cum_oil_prod = sum(oil_bbl)
bysort munic_code (year): gen cum_gas_prod = sum(gas_mm3)
bysort munic_code (year): gen cum_boe_prod = sum(prod_boe)
bysort munic_code (year): gen cum_oil_revenue = sum(oil_revenue)

order munic_code munic_code_6digit municipality uf UF_NO micro_code meso_code year number_of_wells_completed number_hydrocarbon_detections num_successful_wells num_unsuccessful_wells number_cvm_announcements announced_new_volume_mmboe imputed_volume_mmboe all_time_production oil_bbl gas_mm3 prod_boe cum_wells_completed cum_hydrocarbons_detected cum_successful_wells cum_cvm_announcements cum_volume_announced cum_volume_imputed cum_oil_prod cum_gas_prod cum_boe_prod cum_oil_revenue wells_completed_2000_2017 hydrocarbon_detections_2000_2017 cvm_announcements_2000_2017 volume_announced_2000_2017 volume_imputed_2000_2017 successful_wells_2000_2017 oil_revenue_2000_2017

sort munic_code year

save "Munics_Affected_by_Oil", replace 

********************************************************************************
