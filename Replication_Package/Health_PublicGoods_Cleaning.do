clear
cd "${user}\Data Directory\Public Goods"

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

import delimited "Live Births\A_`i'.csv", delimiter(";") varnames(4) clear

keep município oumaisconsultas total

rename município munic
rename oumaisconsultas seven_or_more
rename total total_births

replace seven_or_more = "0" if seven_or_more == "-"
replace total_births = "0" if total_births == "-"
destring seven_or_more, replace 
destring total_births, replace 

gen seven_or_more_share = seven_or_more / total
drop if seven_or_more_share == .

*Clean up munic code 
gen munic_code_6digit = substr(munic, 1,6)
drop if munic_code_6digit == "Total"
destring munic_code_6digit, replace 

sort munic_code_6digit
drop seven_or_more munic

gen year = `i'

save "Live Births\Live_Births_SevenShare_`i'", replace 
}

use "Live Births\Live_Births_SevenShare_2000", clear 
append using "Live Births\Live_Births_SevenShare_2001", force 
append using "Live Births\Live_Births_SevenShare_2002", force
append using "Live Births\Live_Births_SevenShare_2003", force
append using "Live Births\Live_Births_SevenShare_2004", force
append using "Live Births\Live_Births_SevenShare_2005", force
append using "Live Births\Live_Births_SevenShare_2006", force
append using "Live Births\Live_Births_SevenShare_2007", force
append using "Live Births\Live_Births_SevenShare_2008", force
append using "Live Births\Live_Births_SevenShare_2009", force
append using "Live Births\Live_Births_SevenShare_2010", force
append using "Live Births\Live_Births_SevenShare_2011", force
append using "Live Births\Live_Births_SevenShare_2012", force
append using "Live Births\Live_Births_SevenShare_2013", force
append using "Live Births\Live_Births_SevenShare_2014", force
append using "Live Births\Live_Births_SevenShare_2015", force
append using "Live Births\Live_Births_SevenShare_2016", force
append using "Live Births\Live_Births_SevenShare_2017", force

sort munic_code_6digit year
order munic_code_6digit year 

rename seven_or_more_share births_7pluscheckups

save "Live Births\Live_Births_SevenShare_Panel_2000_2017", replace 

*********************************************************************************
*Avoidable infant mortality 

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

import delimited "Infant_Mortality\A_`i'.csv", delimiter(";") varnames(4) clear

keep município total
rename município munic 
drop if munic == "Total"
drop if total == .

gen munic_code_6digit = substr(munic, 1,6)
destring munic_code_6digit, replace
drop munic 

gen year = `i'

save "Infant_Mortality\Infant_Mortality_`i'", replace 

}

use "Infant_Mortality\Infant_Mortality_2000", clear 
append using "Infant_Mortality\Infant_Mortality_2001", force 
append using "Infant_Mortality\Infant_Mortality_2002", force
append using "Infant_Mortality\Infant_Mortality_2003", force
append using "Infant_Mortality\Infant_Mortality_2004", force
append using "Infant_Mortality\Infant_Mortality_2005", force
append using "Infant_Mortality\Infant_Mortality_2006", force
append using "Infant_Mortality\Infant_Mortality_2007", force
append using "Infant_Mortality\Infant_Mortality_2008", force
append using "Infant_Mortality\Infant_Mortality_2009", force
append using "Infant_Mortality\Infant_Mortality_2010", force
append using "Infant_Mortality\Infant_Mortality_2011", force
append using "Infant_Mortality\Infant_Mortality_2012", force
append using "Infant_Mortality\Infant_Mortality_2013", force
append using "Infant_Mortality\Infant_Mortality_2014", force
append using "Infant_Mortality\Infant_Mortality_2015", force
append using "Infant_Mortality\Infant_Mortality_2016", force
append using "Infant_Mortality\Infant_Mortality_2017", force

sort munic_code_6digit year
order munic_code_6digit year 

rename total avoidable_infant_mort

save "Infant_Mortality\Infant_Mortality_Panel_2000_2017", replace 

*********************************************************************************

clear
cd "${user}\Data Directory\Public Goods"

*Hospital Beds 

local years "2005 2006 2007 2008 2009 2010 2011 2012 2013 2014"
foreach i of local years {

import delimited "Hospital Beds\A_`i'.csv", delimiter(";") varnames(4) clear

keep município total municipal total
rename município munic
drop if munic == "Total"
drop if total == .

gen munic_code_6digit = substr(munic, 1,6)
destring munic_code_6digit, replace
drop munic 

rename municipal municipal_beds 
rename total total_beds 
replace municipal_beds = "0" if municipal_beds == "-"
destring municipal_beds, replace 

gen year = `i'

save "Hospital Beds\Hospital_Beds_`i'", replace 

}

local years "2015 2016 2017"
foreach i of local years {

import delimited "Hospital Beds\A_`i'.csv", delimiter(";") varnames(4) clear

keep município administraçãopúblicamunicipal total
rename município munic
drop if munic == "Total"
drop if total == .

gen munic_code_6digit = substr(munic, 1,6)
destring munic_code_6digit, replace
drop munic 

rename administraçãopúblicamunicipal municipal_beds 
rename total total_beds 
replace municipal_beds = "0" if municipal_beds == "-"
destring municipal_beds, replace 

gen year = `i'

save "Hospital Beds\Hospital_Beds_`i'", replace 

}

use "Hospital Beds\Hospital_Beds_2005", clear
append using "Hospital Beds\Hospital_Beds_2006", force
append using "Hospital Beds\Hospital_Beds_2007", force
append using "Hospital Beds\Hospital_Beds_2008", force
append using "Hospital Beds\Hospital_Beds_2009", force
append using "Hospital Beds\Hospital_Beds_2010", force
append using "Hospital Beds\Hospital_Beds_2011", force
append using "Hospital Beds\Hospital_Beds_2012", force
append using "Hospital Beds\Hospital_Beds_2013", force
append using "Hospital Beds\Hospital_Beds_2014", force
append using "Hospital Beds\Hospital_Beds_2015", force
append using "Hospital Beds\Hospital_Beds_2016", force
append using "Hospital Beds\Hospital_Beds_2017", force

sort munic_code_6digit year
order munic_code_6digit year municipal_beds total_beds

save "Hospital Beds\Hospital_Beds_Panel_2005_2017", replace 

***********************************************************************************
*Merge data on prenatal visits, infant mortality, and hospital beds 
use "Live Births\Live_Births_SevenShare_Panel_2000_2017", clear

merge 1:1 munic_code_6digit year using "Infant_Mortality\Infant_Mortality_Panel_2000_2017"
drop _merge 

merge 1:1 munic_code_6digit year using "Hospital Beds\Hospital_Beds_Panel_2005_2017"
replace municipal_beds = 0 if _merge == 1 & year > 2004
replace total_beds = 0 if _merge == 1 & year > 2004
drop _merge 

*Compute avoidable infant deaths as share of total live births 
rename total_births total_live_births 
gen total_births = total_live_births + avoidable_infant_mort
gen infant_mort_perbirth = avoidable_infant_mort / total_births

sort munic_code_6digit year 

save "Health_MunicipalPanel_2000_2017", replace 