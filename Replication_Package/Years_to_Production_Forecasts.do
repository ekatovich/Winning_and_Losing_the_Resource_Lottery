*Collapsing wells to field level, merging with production start estimates, and creating delay graphs

clear
cd "${user}\Data Directory\Oil Production Value\Well_Level_Production"

capture ssc install egenmore

********************************************************************************
*Import CVM Announcements dataset and keep announcements with field-level production start predictions 
use "${user}\Data Directory\Discoveries\Discovery_Announcements", clear

keep if est_production_start != .

keep operator field_exploration field_production concession_block well_anp est_production_start announcement_year announced_new_volume_mmboe

order announcement_year field_exploration field_production concession_block well_anp operator est_production_start

*Manually input announcements that did not appear in CVM, but appeared in ANP statements
input 
2008 JUBARTE JUBARTE . . . 2008 .
2013 MERO MERO . . . 2019 . 
end

preserve 
drop if field_production == ""
duplicates drop field_production, force 
*Save observations with fields 
save "CVM_ProductionStart_Predictions_fields", replace 
restore 

drop if field_production == "BUZIOS" | field_production == "GOLFINHO" | field_production == "ITAPU" | field_production == "LULA" | field_production == "PAPATERRA" | field_production == "SEPIA"  | field_production =="SULDELULA" | field_production == "TARTARUGAVERDE" | field_production == "JUBARTE" | field_production == "LIBRA"
drop if concession_block == ""
save "CVM_ProductionStart_Predictions_blocks", replace
********************************************************************************

*Bring in well-level data with field and block 
use "${user}\Data Directory\Discoveries\Wells_Registry_2000_2017_Supplemented", clear

*Collapse to well level to remove duplicates 
collapse (firstnm) state basin field operator concession_block (sum) oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018, by(well_anp)

*Now collapse to field level
collapse (sum) oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018 (firstnm) state basin operator concession_block, by(field)

*Organize
order field basin concession_block state operator
sort field
rename field field_production 

*Merge with fields from predictions dataset and save merged observations 

preserve
merge m:1 field_production using "CVM_ProductionStart_Predictions_fields"
keep if _merge == 3 
save "Predictions_MergedOnField", replace 
restore


merge m:1 concession_block using "CVM_ProductionStart_Predictions_blocks"
keep if _merge == 3 | _merge == 2

append using "Predictions_MergedOnField", force

rename field_production field
replace field = "BM-S-40" if concession_block == "BMS40"
replace field = "BM-SEAL-11" if concession_block == "BMSEAL11"

local prod "oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018"
foreach i of local prod {
replace `i' = 0 if `i' == .
}

drop _merge well_anp field_exploration

order field basin concession_block state operator announcement_year est_production_start

local years "2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
foreach i of local years {
gen prod_boe_`i' = oil_bbl`i' + (5.883*gas_mm3`i')
}

drop oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018

local year "2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local year {
gen significant_prod_`i' = 0
replace significant_prod_`i' = 1 if prod_boe_`i' > 3650000
}

*Drop redundant Mero observation 
drop if concession_block == "."

gen predicted_delay = est_production_start - announcement_year

*For now, manually code first_significant_year
gen first_significant_year = .
replace first_significant_year = . if field == "TARTARUGAMESTICA"
replace first_significant_year = . if field == "BM-S-40"
replace first_significant_year = . if field == "BM-SEAL-11"
replace first_significant_year = 2016 if field == "BUZIOS"
replace first_significant_year = 2006 if field == "GOLFINHO"
replace first_significant_year = 2017 if field == "ITAPU"
replace first_significant_year = 2010 if field == "LULA"
replace first_significant_year = 2014 if field == "PAPATERRA"
replace first_significant_year = 2016 if field == "SEPIA"
replace first_significant_year = . if field == "SULDELULA"
replace first_significant_year = 2011 if field == "TARTARUGAVERDE"
replace first_significant_year = 2009 if field == "JUBARTE"
replace first_significant_year = 2018 if field == "MERO"

gen actual_delay = first_significant_year - announcement_year

replace actual_delay = 10 if first_significant_year == .

gen actual_delay_never = .
replace actual_delay_never = 10 if first_significant_year == .

replace announced_new_volume_mmboe = 100 if announced_new_volume_mmboe == .

keep field announcement_year est_production_start predicted_delay actual_delay actual_delay_never announced_new_volume_mmboe

*Manually jitter duplicated entries 
replace actual_delay = 1.2 if field == "JUBARTE"
replace actual_delay = .8 if field == "LULA"

replace predicted_delay = 3.9 if field == "SULDELULA"
replace predicted_delay = 4 if field == "TARTARUGAMESTICA"


*Fill in sizes of fields that are later announced 
replace announced_new_volume_mmboe = 4500 if field == "BUZIOS"
replace announced_new_volume_mmboe = 320 if field == "GOLFINHO"
replace announced_new_volume_mmboe = 1750 if field == "JUBARTE"
replace announced_new_volume_mmboe = 6500 if field == "LULA"
replace announced_new_volume_mmboe = 7900 if field == "MERO"

replace field = "" if field == "TARTARUGAMESTICA"
replace field = "" if field == "BM-SEAL-11"

input 

"" . . 0 0 0 .
end
********************************************************************************

*Good
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color black ebblue orange
twoway (line actual_delay actual_delay) (scatter actual_delay predicted_delay [w=announced_new_volume_mmboe], msymbol(circle_hollow)) (scatter actual_delay_never predicted_delay [w=announced_new_volume_mmboe], msymbol(circle_hollow)) (scatter actual_delay predicted_delay, msymbol(none) mlabel(field) mlabposition(6) mlabsize(vsmall) mlabcolor(black)) (pcarrowi 10.7 4 10.3 4, color(black), size(vsmall)), yscale(range(0 11)) xscale(range(1 10)) yscale(range(0 10)) xtitle("Initial Forecast of Years to Production", size(small)) ytitle("Actual Years to Production", size(small)) ylabel(0 1 2 3 4 5 6 7 8 9 10) xlabel(0 1 2 3 4 5 6 7 8 9 10) ysize(6) xsize(6)  text(10 5.5 "BM-SEAL-11", size(vsmall)) text(10.9 4 "TARTARUGAMESTICA", size(vsmall)) legend(order(2 "Began Production within Sample Timeframe" 3 "Never Produced within Sample Timeframe") cols(1) size(small)) 
