clear
cd "${user}\Data Directory\Public Goods"

*Import, clean, and save education data from FIRJAN Index of Municipal Development 
import delimited "FIRJAN_Education.csv", clear 

forvalues i = 2005(1)2016 {
replace score_`i' = "" if score_`i' == "*"
destring score_`i', replace 
rename score_`i' score_educ`i'
}

forvalues i = 2005(1)2016 {
replace rank_`i' = "" if rank_`i' == "*"
destring rank_`i', replace 
rename rank_`i' rank_educ`i'
}

drop munic region 

*Reshape dataset from wide to long 
reshape long score_educ rank_educ, i(munic_code) j(year)


save "FIRJAN_Education", replace 

********************************************************************************
*Import, clean, and save health data from FIRJAN Index of Municipal Development 
import delimited "FIRJAN_Health.csv", clear 

forvalues i = 2005(1)2016 {
capture replace score_`i' = "" if score_`i' == "*"
capture destring score_`i', replace 
rename score_`i' score_health`i'
}

forvalues i = 2005(1)2016 {
replace rank_`i' = "" if rank_`i' == "*"
replace rank_`i' = subinstr(rank_`i', "º", "",.)
replace rank_`i' = subinstr(rank_`i', ",", "",.)
destring rank_`i', replace 
rename rank_`i' rank_health`i'
}

drop munic region 

*Reshape dataset from wide to long 
reshape long score_health rank_health, i(munic_code) j(year)

save "FIRJAN_Health", replace 

********************************************************************************
*Import, clean, and save employment and income data from FIRJAN Index of Municipal Development 
import delimited "FIRJAN_EmploymentIncome.csv", clear 

forvalues i = 2005(1)2016 {
replace score_`i' = "" if score_`i' == "*"
destring score_`i', replace 
rename score_`i' score_empl`i'
}

forvalues i = 2005(1)2016 {
replace rank_`i' = "" if rank_`i' == "*"
replace rank_`i' = subinstr(rank_`i', "º", "",.)
replace rank_`i' = subinstr(rank_`i', ",", "",.)
destring rank_`i', replace 
rename rank_`i' rank_empl`i'
}

drop munic region 

*Reshape dataset from wide to long 
reshape long score_empl rank_empl, i(munic_code) j(year)

save "FIRJAN_EmploymentIncome", replace 

*********************************************************************************
*Merge all three FIRJAN datasets on munic_code year 

use "FIRJAN_Education", clear 

merge 1:1 munic_code year using "FIRJAN_Health"
drop _merge

merge 1:1 munic_code year using "FIRJAN_EmploymentIncome"
drop _merge 

sort munic_code year

rename munic_code munic_code_6digit

save "FIRJAN_IMD_Indicators_2005_2016", replace 

