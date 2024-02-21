
clear 
cd "${user}\Data Directory\Discoveries"


*Merge wells data with discoveries announcements 

*First, merge on well_anp
use "Wells_Offshore_AllYears", clear

merge 1:m well_anp using "Discovery_Announcements"
rename _merge merge_anp
sort merge_anp 

*Save the observations that merged
keep if merge_anp == 3
save "matched_on_well_anp_allyears", replace



*Now match on well_operator
use "Wells_Offshore_AllYears", clear

duplicates drop well_operator, force

merge 1:m well_operator using "Discovery_Announcements"
rename _merge merge_operator
sort merge_operator

*Save the observations that merged
keep if merge_operator == 3
save "matched_on_well_operator_allyears", replace



*Now match on well_anp using flipped 
use "Wells_Offshore_AllYears", clear

merge 1:m well_anp using "Discovery_Announcements_Flipped"
rename _merge merge_anp
sort merge_anp 

*Save the observations that merged
keep if merge_anp == 3
rename merge_anp merge_anp_flipped
save "matched_on_well_anp_flipped_allyears", replace



*Now match on well_operator using flipped 
use "Wells_Offshore_AllYears", clear

duplicates drop well_operator, force

merge 1:m well_operator using "Discovery_Announcements_Flipped"
rename _merge merge_operator
sort merge_operator

*Save the observations that merged
keep if merge_operator == 3
rename merge_operator merge_operator_flipped
save "matched_on_well_operator_flipped_allyears", replace



*Now match on well_other against ANP
use "Wells_Offshore_AllYears", clear
gen well_other = well_anp 

merge 1:m well_other using "Discovery_Announcements"
rename _merge merge_other
sort merge_other

*Save the observations that merged
keep if merge_other== 3
rename merge_other merge_other_anp
save "matched_on_well_other_anp_allyears", replace



*Now match on well_other against operator
use "Wells_Offshore_AllYears", clear
gen well_other = well_operator

duplicates drop well_other, force

merge 1:m well_other using "Discovery_Announcements"
rename _merge merge_other
sort merge_other

*Save the observations that merged
keep if merge_other== 3
rename merge_other merge_other_operator
save "matched_on_well_other_operator_allyears", replace



*Now match on well_name against well_operator
use "Wells_Offshore_AllYears", clear
gen well_name = well_operator

duplicates drop well_name, force

merge 1:m well_name using "Discovery_Announcements"
rename _merge merge_name
sort merge_name

*Save the observations that merged
keep if merge_name== 3
save "matched_on_well_name_allyears", replace


*Now append matched datasets back into this dataset of no matches.
use "matched_on_well_anp_allyears", clear
append using "matched_on_well_operator_allyears", force
append using "matched_on_well_anp_flipped_allyears", force 
append using "matched_on_well_operator_flipped_allyears", force
append using "matched_on_well_other_anp_allyears", force
append using "matched_on_well_other_operator_allyears", force
append using "matched_on_well_name_allyears", force

duplicates drop announcement_id, force

sort announcement_id


*Calculate gaps between each date and announcement date 
gen start_gap = announcement_date - start_date
gen end_gap = announcement_date - end_date 
gen conclusion_gap = announcement_date - conclusion_date 
gen hydrocarbon_gap = announcement_date - hydrocarbons_detected_date

replace start_gap = start_gap * -1
replace end_gap = end_gap * -1
replace conclusion_gap = conclusion_gap * -1
replace hydrocarbon_gap = hydrocarbon_gap * -1

save "Announcements_Matched_allyears", replace

**********************************************************************************

*Check for unmatched announcements 
use "Discovery_Announcements", clear 
merge 1:1 announcement_id using "Announcements_Matched_allyears"
sort _merge 
keep if _merge == 1

********************************************************************************
*Merge matched announcements back into main wells dataset 
use "Announcements_Matched_allyears", clear 
keep announcement_source announcement_date announcement_year announcement_id operator basin well_other field_centroid_x field_centroid_y announcement_type announced_new_volume_mmboe imputed_volume_mmboe est_production_start quality_api confronting_regions_cited announcement_indicator start_gap end_gap conclusion_gap hydrocarbon_gap field_exploration field_production concession_block well_name well_operator well_anp well_other cadastro 

order cadastro announcement_id announcement_date announcement_year operator basin field_exploration field_production concession_block well_name well_operator well_anp well_other field_centroid_x	field_centroid_y announcement_type announced_new_volume_mmboe imputed_volume_mmboe est_production_start quality_api confronting_regions_cited start_gap end_gap conclusion_gap hydrocarbon_gap

merge m:1 cadastro using "Wells_Offshore_AllYears"
drop _merge

sort end_date cadastro 

rename latitude_base_dd latitude_unclean
rename longitude_base_dd longitude_unclean

save "Wells_with_Hydrocarbons_Production_Announcements_allyears", replace

*This dataset now contains all offshore wells (from all years), with production (2005-2018) and discovery announcements if they occurred. 
*This dataset has 6,864 observations  
*******************************************************************************

********************************************************************************
*Merge in municipality codes 
*Now merge wells dataset that includes production and announcements with polygon and municipality codes from mapping exercise. 
*Note that there are a few cases of multiple repeated wells in discoveries dataset, so need to use 1:m merging.

*Import wells data
import delimited "${user}\Data Directory\Brazil_GeodesicProjections\Outputs\Data\Wells_with_Municipalities.csv", clear

keep pol_id_parallel pol_id_orthogonal cadastro latitude_base_dd longitude_base_dd munic_code_orthogonal munic_code_parallel success type termino

*Keep only observations between 2000 and 2017
gen end_year = substr(termino,-9,4)
destring end_year, replace
*keep if end_year > 1999
*keep if end_year < 2018

*Drop duplicate wells (there aren't many)
duplicates drop cadastro, force 
*drop end_year 

*Drop observations for which both munic_code_orthogonal munic_code_parallel are NA
*drop if (munic_code_orthogonal == "NA" & munic_code_parallel == "NA")

*What remains in this dataset are all offshore wells which mapped back to parallel or orthogonal municipalities. 
*Now merge with dataset of all wells

merge 1:m cadastro using "Wells_with_Hydrocarbons_Production_Announcements_allyears"
sort _merge 

*Drop non merges (only one)
drop if _merge == 2
drop _merge 

*Organize and save final well-level dataset 
*First, drop unnecessary variables 
drop termino basin field_exploration field_centroid_x field_centroid_y latitude_unclean longitude_unclean tipo 
order cadastro start_date end_date conclusion_date start_year end_year conclusion_year hydrocarbons_detected_year hydrocarbons_detected_date announcement_date announcement_year well_anp well_operator well_other well_name concession_block field_production sig_campo bacia estado operador terra_mar latitude_base_dd longitude_base_dd type categoria reclassificacao situacao munic_code_orthogonal munic_code_parallel pol_id_parallel pol_id_orthogonal announcement_id operator announcement_type announced_new_volume_mmboe imputed_volume_mmboe est_production_start quality_api confronting_regions_cited hydrocarbons_detected start_gap end_gap conclusion_gap hydrocarbon_gap

sort end_date

rename field_production field 
rename operator announcement_operator
**********************************************************************************

*Rename all variables in English and label 

rename sig_campo field_initials
rename bacia basin 
rename estado state
rename operador operator 
rename terra_mar onshore_offshore 
rename categoria category
rename reclassificacao reclassification
rename situacao situation 
rename poco_pos_anp well_pos_anp 
rename titularidade title
rename direcao direction 
rename profundidade_vertical_m depth_vertical_m 
rename profundidade_sondador_m depth_drill_rig_m 
rename profundidade_medida_m depth_measured_m 
rename sig_sonda drill_rig_initials
rename nom_sonda drill_rig_name 

label var cadastro "Unique Well Registry ID"
label var start_date "Date of well initiation"
label var end_date "Date of well completion"
label var conclusion_date "Date of well conclusion"
label var hydrocarbons_detected_year "Year of hydrocarbon detection filing"
label var hydrocarbons_detected_date "Date of hydrocarbon detection filing"
label var announcement_date "Date of CVM Announcement"
label var announcement_year "Year of CVM Announcement"
label var field_initials "Initials of Offshore Production Field"
label var basin "Name of Sedimentary Basin"
label var state "Initials of State aligned with well"
label var operator "Oil Company with controlling stake in block"
label var onshore_offshore "T = onshore, M = offshore"
label var category "Function of Well"
label var reclassification "Finality of Well"
label var situation "Status of Well"
label var well_pos_anp ""
label var title "Public or Confidential (all public here)"
label var direction "Directionality of Well"
label var depth_vertical_m "Vertical depth in meters"
label var depth_drill_rig_m "Depth from drilling rig (m)"
label var depth_measured_m "Measured depth (m)"
label var drill_rig_initials "Initials of drilling rig/vessel"
label var drill_rig_name "Name of drilling rig/vessel"
label var well_anp "Well Designator using ANP coding system"
label var well_operator "Well designator using operator's coding system"
label var well_other "Well designator using other coding system"
label var well_name "Familiar/informal Name of well"
label var concession_block "Concession Block (auctioned area within field)"
label var field "Offshore field name"
label var latitude_base_dd "Latitude"
label var longitude_base_dd "Longitude"
label var start_year "Year of well initiation"
label var end_year "Year of well termination"
label var conclusion_year "Year of well conclusion"
label var munic_code_orthogonal "IBGE Code of municipality orthogonally aligned"
label var munic_code_parallel "IBGE code of municipality parallely aligned"
label var pol_id_parallel "ID of parallel projection polygon"
label var pol_id_orthogonal "ID of orthogonal projection polygon"
label var announcement_id "ID of CVM announcement"
label var announcement_operator "Operator that issued CVM Announcement"
label var announcement_type "Type of CVM Announcement"
label var announced_new_volume_mmboe "Volume of Recoverable Reserves in CVM Announcement"
label var imputed_volume_mmboe "Imputed volume of recoverable reserves"
label var est_production_start "Estimated year production will start in CVM announcement"
label var quality_api "Quality (API) in CVM announcement"
label var confronting_regions_cited "Aligned regions in CVM announcement"
label var hydrocarbons_detected "Number of hydrocarbon detected filings in well-year"
label var start_gap "Days btw well initiation and CVM announcement"
label var end_gap "Days btw well completion and CVM announcement"
label var conclusion_gap "Days between well conclusion and CVM announcement"
label var hydrocarbon_gap "Days between hydrocarbon-detection filing and CVM announcement"
label var type "Type of well"
label var success "Success of well as determined by reclassification"
label var announcement_source "Source of CVM announcement"
label var announcement_indicator "Indicator that CVM announcement was made"
label var fluids "Type of fluids reported in hydrocarbon detection filing"
label var depth_m "Depth (m) at which hydrocarbons were detected"
 
label var oil_bbl2005 "Barrels of Oil Produced in 2005"
label var gas_mm32005 "Thousands of cubic meters of gas produced in 2005"
label var oil_bbl2006 "Barrels of Oil Produced in 2006"
label var gas_mm32006 "Thousands of cubic meters of gas produced in 2006"
label var oil_bbl2007 "Barrels of Oil Produced in 2007"
label var gas_mm32007 "Thousands of cubic meters of gas produced in 2007"
label var oil_bbl2008 "Barrels of Oil Produced in 2008"
label var gas_mm32008 "Thousands of cubic meters of gas produced in 2008"
label var oil_bbl2009 "Barrels of Oil Produced in 2009"
label var gas_mm32009 "Thousands of cubic meters of gas produced in 2009"
label var oil_bbl2010 "Barrels of Oil Produced in 2010"
label var gas_mm32010 "Thousands of cubic meters of gas produced in 2010"
label var oil_bbl2011 "Barrels of Oil Produced in 2011"
label var gas_mm32011 "Thousands of cubic meters of gas produced in 2011"
label var oil_bbl2012 "Barrels of Oil Produced in 2012"
label var gas_mm32012 "Thousands of cubic meters of gas produced in 2012"
label var oil_bbl2013 "Barrels of Oil Produced in 2013"
label var gas_mm32013 "Thousands of cubic meters of gas produced in 2013"
label var oil_bbl2014 "Barrels of Oil Produced in 2014"
label var gas_mm32014 "Thousands of cubic meters of gas produced in 2014"
label var oil_bbl2015 "Barrels of Oil Produced in 2015"
label var gas_mm32015 "Thousands of cubic meters of gas produced in 2015"
label var oil_bbl2016 "Barrels of Oil Produced in 2016"
label var gas_mm32016 "Thousands of cubic meters of gas produced in 2016"
label var oil_bbl2017 "Barrels of Oil Produced in 2017"
label var gas_mm32017 "Thousands of cubic meters of gas produced in 2017"
label var oil_bbl2018 "Barrels of Oil Produced in 2018"
label var gas_mm32018 "Thousands of cubic meters of gas produced in 2018"
 
save "Wells_Registry_AllYears_Supplemented", replace 

*Final: 6,840 observations 
********************************************************************************
