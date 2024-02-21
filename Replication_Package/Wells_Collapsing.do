********************************************************************************
*Collapse Supplemented Wells Registry down to Municipality Level
********************************************************************************

clear
cd "${user}\Data Directory\Discoveries"

*Bring in supplemented well registry
use "Wells_Registry_2000_2017_Supplemented", clear

*Drop wells where municipality is unidentified for both parallel and orthogonal projections
drop if (munic_code_orthogonal == "NA" & munic_code_parallel == "NA")

save "Wells_Registry_2000_2017_Supplemented_NoMissings", replace 

********************************************************************************
*Orthogonal well count
use "Wells_Registry_2000_2017_Supplemented_NoMissings", clear

*Generate a well indicator to count number of wells 
gen well_indicator = 1

*Collapse by end_year municipality to find number of well completed in a year
*"Completed" is the definition of "drilled", since this is when success would be announced 
collapse (sum) well_indicator (firstnm) basin, by(munic_code_orthogonal end_year)

rename well_indicator number_of_wells_completed
rename end_year year

save "Number_of_Wells_Completed_Munic_Orthogonal", replace 

*Repeat for parallel 
*Bring in supplemented well registry
use "Wells_Registry_2000_2017_Supplemented_NoMissings", clear

*Generate a well indicator to count number of wells 
gen well_indicator = 1

*Collapse by end_year municipality to find number of well completed in a year
*"Completed" is the definition of "drilled", since this is when success would be announced 
collapse (sum) well_indicator (firstnm) basin, by(munic_code_parallel end_year)

rename well_indicator number_of_wells_completed
rename end_year year

save "Number_of_Wells_Completed_Munic_Parallel", replace 

*Append orthogonal and parallel municipalities, and collapse to municipality to sum 
use "Number_of_Wells_Completed_Munic_Orthogonal", clear
append using "Number_of_Wells_Completed_Munic_Parallel", force 

gen munic_code = munic_code_orthogonal
replace munic_code = munic_code_parallel if munic_code == ""
drop if munic_code == "NA"
drop munic_code_orthogonal munic_code_parallel

collapse (sum) number_of_wells_completed (firstnm) basin, by(munic_code year)

sort munic_code year

save "Number_of_Wells_Completed_Munic_Total", replace 


*********************************************************************************
*Now sum to municipality level number of hydrocarbon detections 
*Bring in supplemented well registry
use "Wells_Registry_2000_2017_Supplemented_NoMissings", clear

*Collapse by end_year municipality to find number of hydrocarbon detections in a year
collapse (sum) hydrocarbons_detected (firstnm) basin, by(munic_code_orthogonal hydrocarbons_detected_year)

rename hydrocarbons_detected number_hydrocarbon_detections
drop if hydrocarbons_detected_year == .

save "Number_of_Hydrocarbon_Detections_Munic_Orthogonal", replace 

*Repeat for parallel 
*Bring in supplemented well registry
use "Wells_Registry_2000_2017_Supplemented_NoMissings", clear

*Collapse by end_year municipality to find number of hydrocarbon detections in a year
collapse (sum) hydrocarbons_detected (firstnm) basin, by(munic_code_parallel hydrocarbons_detected_year)

rename hydrocarbons_detected number_hydrocarbon_detections
drop if hydrocarbons_detected_year == .

save "Number_of_Hydrocarbon_Detections_Munic_Parallel", replace 

*Append orthogonal and parallel municipalities, and collapse to municipality to sum 
use "Number_of_Hydrocarbon_Detections_Munic_Orthogonal", clear
append using "Number_of_Hydrocarbon_Detections_Munic_Parallel", force 

gen munic_code = munic_code_orthogonal
replace munic_code = munic_code_parallel if munic_code == ""
drop if munic_code == "NA"
drop munic_code_orthogonal munic_code_parallel

collapse (sum) number_hydrocarbon_detections (firstnm) basin, by(munic_code hydrocarbons_detected_year)

sort munic_code hydrocarbons_detected_year
rename hydrocarbons_detected_year year

save "Number_of_Hydrocarbon_Detections_Munic_Total", replace 

********************************************************************************
*Collapse to calculate number of CVM announcements and announced/imputed volumes at municipality level 
*Bring in supplemented well registry
use "Wells_Registry_2000_2017_Supplemented_NoMissings", clear

*Collapse by end_year municipality to find number of CVM announcements in a year
collapse (sum) announcement_indicator announced_new_volume_mmboe imputed_volume_mmboe (firstnm) basin, by(munic_code_orthogonal announcement_year)

rename announcement_indicator number_cvm_announcements
drop if announcement_year == .

save "Number_of_CVM_Announcements_Munic_Orthogonal", replace 

*Repeat for parallel
*Bring in supplemented well registry
use "Wells_Registry_2000_2017_Supplemented_NoMissings", clear

*Collapse by end_year municipality to find number of CVM announcements in a year
collapse (sum) announcement_indicator announced_new_volume_mmboe imputed_volume_mmboe (firstnm) basin, by(munic_code_parallel announcement_year)

rename announcement_indicator number_cvm_announcements
drop if announcement_year == .

save "Number_of_CVM_Announcements_Munic_Parallel", replace 

*Append orthogonal and parallel municipalities, and collapse to municipality to sum 
use "Number_of_CVM_Announcements_Munic_Orthogonal", clear
append using "Number_of_CVM_Announcements_Munic_Parallel", force 

gen munic_code = munic_code_orthogonal
replace munic_code = munic_code_parallel if munic_code == ""
drop if munic_code == "NA"
drop munic_code_orthogonal munic_code_parallel

collapse (sum) number_cvm_announcements announced_new_volume_mmboe imputed_volume_mmboe (firstnm) basin, by(munic_code announcement_year)

sort munic_code announcement_year
rename announcement_year year

save "Number_of_CVM_Announcements_Munic_Total", replace 


********************************************************************************
*Collapse PRODUCTION to municipality level 
use "Wells_Registry_AllYears_Supplemented", clear

*Fill in zero production for wells in registry that don't merge. These ones must not produce.
local prod_vars "oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018"
foreach i of local prod_vars {
replace `i' = 0 if 	`i' == .
}

*Create indicator for whether well is split between two municipalities, or fully allocated to one 
gen only_parallel = 0
replace only_parallel = 1 if munic_code_orthogonal == "NA" & munic_code_parallel!="NA"
gen only_orthogonal = 0
replace only_orthogonal = 1 if munic_code_parallel == "NA" & munic_code_orthogonal!="NA"
gen split = 0
replace split = 1 if only_parallel == 0 & only_orthogonal == 0

*First keep only orthogonals
keep if only_orthogonal == 1

local years "2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
foreach i of local years {
gen prod_boe_`i' = oil_bbl`i' + (5.883*gas_mm3`i')
}

gen all_time_production = prod_boe_2005 + prod_boe_2006 + prod_boe_2007 + prod_boe_2008 + prod_boe_2009 + prod_boe_2010 + prod_boe_2011 + prod_boe_2012 + prod_boe_2013 + prod_boe_2014 + prod_boe_2015 + prod_boe_2016 + prod_boe_2017 + prod_boe_2018

collapse (sum) oil_bbl20* gas_mm320* prod_boe_20* all_time_production (firstnm) basin, by(munic_code_orthogonal)

*Reshape data from wide to long 
reshape long oil_bbl gas_mm3 prod_boe_, i(munic_code_orthogonal) j(year)

sort munic_code_orthogonal year

drop if munic_code_orthogonal == "NA"

rename munic_code_orthogonal munic_code 
rename oil_bbl oil_bbl_orth 
rename gas_mm3 gas_mm3_orth
rename prod_boe_ prod_boe_orth 

save "Municipality_Production_OnlyOrthogonal", replace 

***There are no only_parallel wells 
************************************
*Proceed to splits 

*Now collapse to split (both parallel and orthogonal) and divide by two to avoid double counting 
use "Wells_Registry_AllYears_Supplemented", clear

*Fill in zero production for wells in registry that don't merge. These ones must not produce.
local prod_vars "oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018"
foreach i of local prod_vars {
replace `i' = 0 if 	`i' == .
}

*Create indicator for whether well is split between two municipalities, or fully allocated to one 
gen only_parallel = 0
replace only_parallel = 1 if munic_code_orthogonal == "NA" & munic_code_parallel!="NA"
gen only_orthogonal = 0
replace only_orthogonal = 1 if munic_code_parallel == "NA" & munic_code_orthogonal!="NA"
gen split = 0
replace split = 1 if only_parallel == 0 & only_orthogonal == 0

*Keep only parallels
keep if split == 1

local years "2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
foreach i of local years {
gen prod_boe_`i' = oil_bbl`i' + (5.883*gas_mm3`i')
}

gen all_time_production = prod_boe_2005 + prod_boe_2006 + prod_boe_2007 + prod_boe_2008 + prod_boe_2009 + prod_boe_2010 + prod_boe_2011 + prod_boe_2012 + prod_boe_2013 + prod_boe_2014 + prod_boe_2015 + prod_boe_2016 + prod_boe_2017 + prod_boe_2018

collapse (sum) oil_bbl20* gas_mm320* prod_boe_20* all_time_production (firstnm) basin, by(munic_code_orthogonal)

*Reshape data from wide to long 
reshape long oil_bbl gas_mm3 prod_boe_, i(munic_code_orthogonal) j(year)

sort munic_code_orthogonal year

drop if munic_code_orthogonal == "NA"

rename munic_code_orthogonal munic_code 
rename oil_bbl oil_bbl_orthsplit
rename gas_mm3 gas_mm3_orthsplit
rename prod_boe_ prod_boe_orthsplit

save "Municipality_Production_OrthSplit", replace 

*Repeat split wells for parallel 
use "Wells_Registry_AllYears_Supplemented", clear

*Fill in zero production for wells in registry that don't merge. These ones must not produce.
local prod_vars "oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018"
foreach i of local prod_vars {
replace `i' = 0 if 	`i' == .
}

*Create indicator for whether well is split between two municipalities, or fully allocated to one 
gen only_parallel = 0
replace only_parallel = 1 if munic_code_orthogonal == "NA" & munic_code_parallel!="NA"
gen only_orthogonal = 0
replace only_orthogonal = 1 if munic_code_parallel == "NA" & munic_code_orthogonal!="NA"
gen split = 0
replace split = 1 if only_parallel == 0 & only_orthogonal == 0

keep if split == 1

local years "2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
foreach i of local years {
gen prod_boe_`i' = oil_bbl`i' + (5.883*gas_mm3`i')
}

gen all_time_production = prod_boe_2005 + prod_boe_2006 + prod_boe_2007 + prod_boe_2008 + prod_boe_2009 + prod_boe_2010 + prod_boe_2011 + prod_boe_2012 + prod_boe_2013 + prod_boe_2014 + prod_boe_2015 + prod_boe_2016 + prod_boe_2017 + prod_boe_2018

collapse (sum) oil_bbl20* gas_mm320* prod_boe_20* all_time_production (firstnm) basin, by(munic_code_parallel)

*Reshape data from wide to long 
reshape long oil_bbl gas_mm3 prod_boe_, i(munic_code_parallel) j(year)

sort munic_code_parallel year

drop if munic_code_parallel == "NA"

rename munic_code_parallel munic_code 
rename oil_bbl oil_bbl_parsplit
rename gas_mm3 gas_mm3_parsplit
rename prod_boe_ prod_boe_parsplit

save "Municipality_Production_ParSplit", replace 


*Now merge orthogonal and parallel production datasets together 
use "Municipality_Production_OnlyOrthogonal", clear 

merge 1:1 munic_code year using "Municipality_Production_OrthSplit"
drop _merge 

merge 1:1 munic_code year using "Municipality_Production_ParSplit" 
drop _merge 

local vars "oil_bbl_orth gas_mm3_orth prod_boe_orth all_time_production oil_bbl_orthsplit gas_mm3_orthsplit prod_boe_orthsplit oil_bbl_parsplit gas_mm3_parsplit prod_boe_parsplit"
foreach i of local vars {
replace `i' = 0 if `i' == .
}

*Now consolidate variables to avoid double counting 
gen oil_bbl = oil_bbl_orth + (0.5*oil_bbl_orthsplit) + (0.5*oil_bbl_parsplit)
gen gas_mm3 = gas_mm3_orth + (0.5*gas_mm3_orthsplit) + (0.5*gas_mm3_parsplit)
gen prod_boe = prod_boe_orth + (0.5*prod_boe_orthsplit) + (0.5*prod_boe_parsplit)

keep munic_code year oil_bbl gas_mm3 prod_boe all_time_production basin 
sort munic_code year

tab munic_code if prod_boe != 0

save "Munic_Level_OilGasProduction", replace 



********************************************************************************
*Merge number of wells, hydrocarbon detections, and CVM announcements together using munic_code year
use "Number_of_Wells_Completed_Munic_Total", clear

merge 1:1 munic_code year using "Number_of_Hydrocarbon_Detections_Munic_Total"
drop _merge 
merge 1:1 munic_code year using "Number_of_CVM_Announcements_Munic_Total"
drop _merge 
merge 1:1 munic_code year using "Munic_Level_OilGasProduction"
drop _merge

local vars "number_of_wells_completed number_hydrocarbon_detections number_cvm_announcements announced_new_volume_mmboe imputed_volume_mmboe oil_bbl gas_mm3 prod_boe all_time_production"
foreach i of local vars {
replace `i' = 0 if `i' == .
}

*Generate variables for successful and unsuccessful wells 
gen num_successful_wells = number_hydrocarbon_detections
gen num_unsuccessful_wells = number_of_wells_completed - num_successful_wells
replace num_unsuccessful_wells = 0 if num_unsuccessful_wells < 0

drop if year == 1999

sort munic_code year 

replace basin = "Ceara" if basin == "Ceará"
replace basin = "Espirito Santo" if basin == "Espírito Santo"
replace basin = "Jacuipe" if basin == "Jacuípe"
replace basin = "Para-Maranhao" if basin == "Pará - Maranhão"

*Save municipality-level treatment dataset 
save "Municipality_Well_Treatment", replace 



