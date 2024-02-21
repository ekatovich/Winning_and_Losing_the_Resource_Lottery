
cd "${user}\Data Directory\Discoveries"

*Import wells data
import delimited "Wells_Table3", clear

*Keep relevant variables
drop latitude_base_4c longitude_base_4c datum_horizontal tipo_de_coordenada_de_base referencia_de_profundidade mesa_rotativa cota_altimetrica_m lamina_d_agua_m datum_vertical unidade_estratigrafica geologia_grupo_final geologia_formacao_final geologia_membro_final cdpe agp pc pag perfis_convencionais durante_perfuracao perfis_digitais perfis_processados perfis_especiais amostra_lateral sismica tabela_tempo_profundidade dados_direcionais teste_a_cabo teste_de_formacao canhoneio testemunho geoquimica dha_atualizacao

*Extract start, end, and conclusion year 
gen start_year = substr(inicio,-9,4)
destring start_year, replace

gen end_year = substr(termino,-9,4)
destring end_year, replace

gen conclusion_year = substr(conclusao,-9,4)
destring conclusion_year, replace


*Convert date strings to Stata dates 
*First remove hours and minutes
local dates "inicio termino conclusao"
foreach j of local dates {
gen `j'_tmp = substr(`j', 1, length(`j') - 5)
}

*Now convert to date format
local dates "inicio_tmp termino_tmp conclusao_tmp"
foreach j of local dates {
gen `j'_2 = date(`j', "MDY")
format `j'_2 %td
}

drop inicio_tmp termino_tmp conclusao_tmp
drop inicio termino conclusao
rename inicio_tmp_2 start_date
rename termino_tmp_2 end_date
rename conclusao_tmp_2 conclusion_date 

rename poco well_anp
rename poco_operador well_operator 

*Clean well, block, and field
local clean_vars "well_anp well_operator bloco campo"
foreach j of local clean_vars {
*Remove all accents and special characters using ustrnormalize:
replace `j' = ustrto(ustrnormalize(`j', "nfd"), "ascii", 2)	
*Remove hyphens
replace `j' = subinstr(`j', "-","",.)
*Remove question marks
replace `j' = subinstr(`j', "?","",.)
*Remove spaces
replace `j' = subinstr(`j', " ","",.)
*Capitalize letters 
replace `j' = upper(`j')
}

rename bloco concession_block 
rename campo field_exploration 
gen field_production = field_exploration

order cadastro well_anp well_operator operador concession_block estado bacia field_exploration field_production sig_campo terra_mar tipo categoria reclassificacao situacao start_year end_year conclusion_year start_date end_date conclusion_date

*Save complete wells dataset 
save "Wells_Registry_Complete", replace 

*******************************************************************************
*Merge complete wells data with announcements of signs of hydrocarbons detected.
import delimited "${user}\Data Directory\Discoveries\Signs_of_Hydrocarbons_Detected.csv", clear

rename well well_anp 

*Drop terra_mar which appears in wells_registry 
drop terra_mar 

gen hydrocarbons_detected_year = substr(announcement_date,-4,4)
destring hydrocarbons_detected_year, replace
rename announcement_date hydrocarbons_detected_date 

gen hydrocarbons_detected_date_tmp = date(hydrocarbons_detected_date, "DMY")
format hydrocarbons_detected_date_tmp %td
drop hydrocarbons_detected_date
rename hydrocarbons_detected_date_tmp hydrocarbons_detected_date

*Generate hydrocarbons detected indicator 
gen hydrocarbons_detected = 1

*Clean well, block
local clean_vars "well_anp block"
foreach j of local clean_vars {
*Remove all accents and special characters using ustrnormalize:
replace `j' = ustrto(ustrnormalize(`j', "nfd"), "ascii", 2)	
*Remove hyphens
replace `j' = subinstr(`j', "-","",.)
*Remove hyphens
replace `j' = subinstr(`j', "_","",.)
*Remove question marks
replace `j' = subinstr(`j', "?","",.)
*Remove spaces
replace `j' = subinstr(`j', " ","",.)
*Capitalize letters 
replace `j' = upper(`j')
}

save "Signs_of_Hydrocarbons_Detected", replace 

*Collapse to well-year level to remove duplicates 
collapse (firstnm) block fluids depth_m hydrocarbons_detected_date (sum) hydrocarbons_detected, by(well_anp hydrocarbons_detected_year)

*drop duplicates to facilitate merging (only 41 drop)
duplicates drop well_anp, force

save "Signs_of_Hydrocarbons_Detected_Unique", replace 

merge m:1 well_anp using "Wells_Registry_Complete"
drop _merge 
drop block
replace hydrocarbons_detected = 0 if hydrocarbons_detected == .

save "Wells_with_HydrocarbonAnnouncements", replace 

*******************************************************************************
*Import CVM discovery announcements dataset 
import delimited "Discoveries_Stata_Complete.csv", clear

*Clean date
gen announcement_year = substr(announcement_date,-4,.)
destring announcement_year, replace
gen announcement_date2 = date(announcement_date, "MDY")
format announcement_date2 %td
drop announcement_date
rename announcement_date2 announcement_date
order announcement_source announcement_date

*Create announcement indicator 
gen announcement_indicator = 1

*Clean concession blocks, well names, wells, and fields
local clean_vars "field_exploration field_production concession_block well_name well_operator well_anp well_other"
foreach i of local clean_vars {
*Remove all accents and special characters using ustrnormalize:
replace `i' = ustrto(ustrnormalize(`i', "nfd"), "ascii", 2)	
*Remove hyphens
replace `i' = subinstr(`i', "-","",.)
*Remove question marks
replace `i' = subinstr(`i', "?","",.)
*Remove spaces
replace `i' = subinstr(`i', " ","",.)
*Remove slashes
replace `i' = subinstr(`i', "/","",.)
*Capitalize letters 
replace `i' = upper(`i')
}

*Impute discovery volumes 

*First, fill in inputed discovery volumes where known 
replace imputed_volume_mmboe = announced_new_volume_mmboe if announced_new_volume_mmboe != .

*Now compute average announcement size by discovery type 
sum announced_new_volume_mmboe if announcement_type == "Preliminary", detail
gen preliminary_median =  r(p50)

sum announced_new_volume_mmboe if announcement_type == "Discovery", detail
gen discovery_median =  r(p50)

sum announced_new_volume_mmboe if announcement_type == "Confirmatory", detail
gen confirmatory_median =  r(p50)

sum announced_new_volume_mmboe if announcement_type == "Commerciality", detail
gen commerciality_median =  r(p50)

*Impute preliminary volumes using preliminary mean, where volume not announced 
replace imputed_volume_mmboe = preliminary_median if imputed_volume_mmboe == . & announcement_type == "Preliminary"

*Repeat procedure for discoveries 
replace imputed_volume_mmboe = discovery_median if imputed_volume_mmboe == . & announcement_type == "Discovery"

*Repeat procedure for declarations of commerciality, since volume is only reported here when it is additional volume 
*in excess of what was originally reported in preliminary or discovery announcements 
replace imputed_volume_mmboe = commerciality_median if imputed_volume_mmboe == . & announcement_type == "Commerciality"

*Finally, consider confirmatory announcements. These do not add new volumes, but merely confirm previous announcements. 
*However, they do increase the confidence and salience of earlier announcements. 
*For now, arbitrarily assign a volume value of 25 to confirmatory announcements
replace imputed_volume_mmboe = confirmatory_median*0.01 if imputed_volume_mmboe == . & announcement_type == "Confirmatory"

*Likewise, fill in announcement of type production with a value of zero.
replace imputed_volume_mmboe = 0 if announcement_type == "Production"

save "Discovery_Announcements", replace


*************************
*Now flip the names of well_anp and well_operator in discoveries dataset and try the merges again.
use "Discovery_Announcements", clear
rename well_anp well_anp_tmp
rename well_operator well_anp
rename well_anp_tmp well_operator 

save "Discovery_Announcements_Flipped", replace
**************************


*********************************************************************************
*Merge wells with yearly production 

use "Wells_with_HydrocarbonAnnouncements", clear

*First merge with well_anp 
merge 1:1 well_anp using "${user}\Data Directory\Oil Production Value\Well_Level_Production\wells_production_unique_ANP"
sort _merge
rename _merge merge_production_anp
*Drop wells that only have production in 2018, and no information in well registry
keep if merge_production_anp == 3 | merge_production_anp == 1
save "wells_production_merge_ANP", replace 

*Fill in zero production for wells in registry that don't merge. These ones must not produce.
local prod_vars "oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 oil_bbl2018 gas_mm32018"
foreach i of local prod_vars {
replace `i' = 0 if merge_production_anp == 1
}

save "Wells_Complete_with_Hydrocarbons_and_Production", replace

********************************************************************************
*Keep only offshore wells 
keep if terra_mar == "M"

drop merge_production_anp

sort end_year


save "Wells_Offshore_AllYears", replace

*Keep only relevant timeframe
*drop if wells outside of focus time frame 
keep if end_year > 1999
keep if end_year < 2018

sort end_year 

save "Wells_Offshore_2000_2017", replace

***********************************************************************************

*Merge wells data with discoveries announcements 

*First, merge on well_anp
use "Wells_Offshore_2000_2017", clear

merge 1:m well_anp using "Discovery_Announcements"
rename _merge merge_anp
sort merge_anp 

*Save the observations that merged
keep if merge_anp == 3
save "matched_on_well_anp", replace



*Now match on well_operator
use "Wells_Offshore_2000_2017", clear

merge 1:m well_operator using "Discovery_Announcements"
rename _merge merge_operator
sort merge_operator

*Save the observations that merged
keep if merge_operator == 3
save "matched_on_well_operator", replace



*Now match on well_anp using flipped 
use "Wells_Offshore_2000_2017", clear

merge 1:m well_anp using "Discovery_Announcements_Flipped"
rename _merge merge_anp
sort merge_anp 

*Save the observations that merged
keep if merge_anp == 3
rename merge_anp merge_anp_flipped
save "matched_on_well_anp_flipped", replace



*Now match on well_operator using flipped 
use "Wells_Offshore_2000_2017", clear

merge 1:m well_operator using "Discovery_Announcements_Flipped"
rename _merge merge_operator
sort merge_operator

*Save the observations that merged
keep if merge_operator == 3
rename merge_operator merge_operator_flipped
save "matched_on_well_operator_flipped", replace



*Now match on well_other against ANP
use "Wells_Offshore_2000_2017", clear
gen well_other = well_anp 

merge 1:m well_other using "Discovery_Announcements"
rename _merge merge_other
sort merge_other

*Save the observations that merged
keep if merge_other== 3
rename merge_other merge_other_anp
save "matched_on_well_other_anp", replace



*Now match on well_other against operator
use "Wells_Offshore_2000_2017", clear
gen well_other = well_operator

merge 1:m well_other using "Discovery_Announcements"
rename _merge merge_other
sort merge_other

*Save the observations that merged
keep if merge_other== 3
rename merge_other merge_other_operator
save "matched_on_well_other_operator", replace



*Now match on well_name against well_operator
use "Wells_Offshore_2000_2017", clear
gen well_name = well_operator

merge 1:m well_name using "Discovery_Announcements"
rename _merge merge_name
sort merge_name

*Save the observations that merged
keep if merge_name== 3
save "matched_on_well_name", replace


*Now append matched datasets back into this dataset of no matches.
use "matched_on_well_anp", clear
append using "matched_on_well_operator", force
append using "matched_on_well_anp_flipped", force 
append using "matched_on_well_operator_flipped", force
append using "matched_on_well_other_anp", force
append using "matched_on_well_other_operator", force
append using "matched_on_well_name", force

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

*Graph gaps between announcement and start/end/conclusion dates 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(4)
twoway (histogram start_gap if announcement_type != "Commerciality" & announcement_type != "Confirmatory", start(-1000) width(25) color(blue%30)) ///
       (histogram end_gap if announcement_type != "Commerciality" & announcement_type != "Confirmatory", start(-1000) width(25) color(red%30)) ///        
       (histogram conclusion_gap if announcement_type != "Commerciality" & announcement_type != "Confirmatory", start(-1000) width(25) color(green%30)) /// 
	   (histogram hydrocarbon_gap if announcement_type != "Commerciality" & announcement_type != "Confirmatory", start(-1000) width(25) color(orange%30)), ///
       legend(order(1 "Well Start" 2 "Well End" 3 "Well Conclusion" 4 "Hydrocarbons Detected")) title("Days Before CVM Announcement") xline(0, lcolor(black))

set scheme plotplain
graph drop _all	   
grstyle init
twoway (histogram start_gap if announcement_type != "Commerciality" & announcement_type != "Confirmatory", start(-900) width(25) color(blue%60)), xline(0, lcolor(black) lpattern(solid) lwidth(medthick)) xsc(r(-900 500)) xtitle("Well Initiation") name(start_gap1)

grstyle init
*grstyle set plain, nogrid noextend
twoway (histogram end_gap if announcement_type != "Commerciality" & announcement_type != "Confirmatory", start(-900) width(25) color(red%60)), xline(0, lcolor(black) lpattern(solid) lwidth(medthick)) xsc(r(-900 500)) xtitle("Well Completion") name(end_gap1)

grstyle init
*grstyle set plain, nogrid noextend
twoway (histogram conclusion_gap if announcement_type != "Commerciality" & announcement_type != "Confirmatory", start(-900) width(25) color(green%60)), xline(0, lcolor(black) lpattern(solid) lwidth(medthick)) xsc(r(-900 500)) xtitle("Well Conclusion") name(conclusion_gap1)

grstyle init
*grstyle set plain, nogrid noextend
twoway (histogram hydrocarbon_gap if announcement_type != "Commerciality" & announcement_type != "Confirmatory", start(-900) width(25) color(purple%60)), xline(0, lcolor(black) lpattern(solid) lwidth(medthick)) xsc(r(-900 500)) xtitle("Declaration of Hydrocarbons Detected") name(hydrocarbons_gap1)

graph combine start_gap1 end_gap1 conclusion_gap1 hydrocarbons_gap1, rows(4) xsize(3) title("Days Between Well Declarations and Major Discovery Announcements", size(small))

save "Announcements_Matched", replace

**********************************************************************************

*Check for unmatched announcements 
use "Discovery_Announcements", clear 
merge 1:1 announcement_id using "Announcements_Matched"
sort _merge 
keep if _merge == 1

********************************************************************************
*Merge matched announcements back into main wells dataset 
use "Announcements_Matched", clear 
keep announcement_source announcement_date announcement_year announcement_id operator basin well_other field_centroid_x field_centroid_y announcement_type announced_new_volume_mmboe imputed_volume_mmboe est_production_start quality_api confronting_regions_cited announcement_indicator start_gap end_gap conclusion_gap hydrocarbon_gap field_exploration field_production concession_block well_name well_operator well_anp well_other cadastro 

order cadastro announcement_id announcement_date announcement_year operator basin field_exploration field_production concession_block well_name well_operator well_anp well_other field_centroid_x	field_centroid_y announcement_type announced_new_volume_mmboe imputed_volume_mmboe est_production_start quality_api confronting_regions_cited start_gap end_gap conclusion_gap hydrocarbon_gap

merge m:1 cadastro using "Wells_Offshore_2000_2017"
drop _merge

sort end_date cadastro 

rename latitude_base_dd latitude_unclean
rename longitude_base_dd longitude_unclean

save "Wells_with_Hydrocarbons_Production_Announcements", replace

*This dataset now contains all offshore wells ended between 2000 and 2017, with production (2005-2018) and discovery announcements if they occurred. 
*This dataset has 2,429 observations 
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
keep if end_year > 1999
keep if end_year < 2018

*Drop duplicate wells (there aren't many)
duplicates drop cadastro, force 
drop end_year 

*Drop observations for which both munic_code_orthogonal munic_code_parallel are NA
*drop if (munic_code_orthogonal == "NA" & munic_code_parallel == "NA")

*What remains in this dataset are all offshore wells which mapped back to parallel or orthogonal municipalities. 
*Now merge with dataset of all wells

merge 1:m cadastro using "Wells_with_Hydrocarbons_Production_Announcements"
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

********************************************************************************
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
 
 
save "Wells_Registry_2000_2017_Supplemented", replace 

*Final: 2,428 observations (discovered since 2000-2018)
********************************************************************************




















