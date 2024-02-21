clear 
cd "${user}\Data Directory\Treatment Variables"


use "Expectations_withParameters", clear 

*Plot expected royalties relative to realized royalties for municipalities that recieved CVM announcements 
keep if cvm_announcements_2000_2017 > 0

*Generate time varying measure of disappointment = realized - expected revenues 
gen disappointed_t = oil_revenue_pc - exp_oilrev_pc_low 

*Create election period indicators 
gen election_period = .
replace election_period = 2000 if year == 1998 | year == 1999 | year == 2000
replace election_period = 2004 if year == 2001 | year == 2002 | year == 2003 | year == 2004
replace election_period = 2008 if year == 2005 | year == 2006 | year == 2007 | year == 2008
replace election_period = 2012 if year == 2009 | year == 2010 | year == 2011 | year == 2012
replace election_period = 2016 if year == 2013 | year == 2014 | year == 2015 | year == 2016

drop if election_period == 2000 
drop if year == 2017

*Create variables for each expected year of revenue and real year of revenue 
local years "2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016"
foreach i of local years {
bysort munic_code: gen exp_rev_`i'_tmp = exp_oilrev_pc_low if year == `i'
bysort munic_code: egen exp_rev_`i' = max(exp_rev_`i'_tmp)
drop exp_rev_`i'_tmp
}

local years "2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016"
foreach i of local years {
bysort munic_code: gen realized_rev_`i'_tmp = oil_revenue_pc if year == `i'
bysort munic_code: egen realized_rev_`i' = max(realized_rev_`i'_tmp)
drop realized_rev_`i'_tmp
}

*For each election period, compute expected percent change in revenue based on discovery announcements 
*Period 2016 
gen exp_change_2012_2016 = (exp_rev_2016 / (exp_rev_2012 + 1)) * 100
gen exp_change_2008_2012 = (exp_rev_2012 / (exp_rev_2008 + 1))* 100
gen exp_change_2004_2008 = (exp_rev_2008 / (exp_rev_2004 + 1)) * 100
gen exp_change_2000_2004 = (exp_rev_2004 / (exp_rev_2002 + 1))* 100

*For each period, compute change in real revenues
gen real_change_2012_2016 = (realized_rev_2016 / (realized_rev_2012 + 1)) * 100
gen real_change_2008_2012 = (realized_rev_2012 / (realized_rev_2008 + 1))* 100
gen real_change_2004_2008 = (realized_rev_2008 / (realized_rev_2004 + 1)) * 100
gen real_change_2000_2004 = (realized_rev_2004 / (realized_rev_2002 + 1))* 100

*Now compute ratio of expected to realized for each election period 
gen real_exp_ratio_2004 = real_change_2000_2004 / exp_change_2000_2004 
gen real_exp_ratio_2008 = real_change_2004_2008 / exp_change_2004_2008 
gen real_exp_ratio_2012 = real_change_2008_2012 / exp_change_2008_2012  
gen real_exp_ratio_2016 = real_change_2012_2016 / exp_change_2012_2016 

*Generate disappointment and satisfied indicators for each munic-election pair 
gen disappointed_2004 = 0
replace disappointed_2004 = 1 if real_exp_ratio_2004 < 0.4
replace disappointed_2004 = 2 if real_exp_ratio_2004 >= .4

gen disappointed_2008 = 0
replace disappointed_2008 = 1 if real_exp_ratio_2008 < 0.4
replace disappointed_2008 = 2 if real_exp_ratio_2008 >= .4

gen disappointed_2012 = 0
replace disappointed_2012 = 1 if real_exp_ratio_2012 < 0.4
replace disappointed_2012 = 2 if real_exp_ratio_2012 >= .4

gen disappointed_2016 = 0
replace disappointed_2016 = 1 if real_exp_ratio_2016 < 0.4
replace disappointed_2016 = 2 if real_exp_ratio_2016 >= .4

*Collapse to munic-election level 
collapse (firstnm) municipality disappointed_2004 disappointed_2008 disappointed_2012 disappointed_2016 real_exp_ratio_2004 real_exp_ratio_2008 real_exp_ratio_2012 real_exp_ratio_2016 (sum) number_cvm_announcements, by(munic_code election_period)
rename election_period year

save "Disappointment_ElectionPeriods", replace 

********************************************************************************
********************************************************************************

*Now construct reelection panel 

*Bring in complete individual-level dataset on all candidates and donations
use "${user}\Data Directory\TSE\Candidate_Year_Donations_Supplemented2", clear

*Keep relevant variables
*keep municipality year candidate_name cpf office_description office_code winner party_initials sex_description sex_code schooling_code schooling_description married_description age_at_election results_code results_description reelection UF_NO munic_code
keep municipality year candidate_name cpf results_description office_description 

*First, keep councilors
keep if office_description == "VEREADOR"
drop office_description

gen winner = 0
replace winner = 1 if results_description == "ELEITO" | results_description == "ELEITO POR MÉDIA" | results_description == "ELEITO POR QP"
drop results_description 

*Keep winners 
keep if winner == 1

drop if cpf == ""
sort municipality cpf year

*Now create reelection variables 
egen cpf_id = group(cpf)
egen munic_id = group(municipality)
tsset cpf_id year 

tsfill, full
keep if year == 2000 | year == 2004 | year == 2008 | year == 2012 | year == 2016

replace winner = 0 if winner == .
drop munic_id 

*Carryforward cpf 
carryforward cpf_id, gen(cpf_id_full)
sort cpf_id_full year 

*Create reelected indicator 
bysort cpf_id_full: gen reelected = winner[_n-1] if winner == 1
replace reelected = 0 if reelected == .

gen in_office = 1

keep if winner == 1
keep year cpf reelected in_office

save "Council_Reelection", replace 

***********************************************************************************
*Repeat for mayors 

*Bring in complete individual-level dataset on all candidates and donations
use "${user}\Data Directory\TSE\Candidate_Year_Donations_Supplemented2", clear

*Keep relevant variables
*keep municipality year candidate_name cpf office_description office_code winner party_initials sex_description sex_code schooling_code schooling_description married_description age_at_election results_code results_description reelection UF_NO munic_code
keep municipality year candidate_name cpf results_description office_description 

*First, keep councilors
keep if office_description == "PREFEITO"
drop office_description

gen winner = 0
replace winner = 1 if results_description == "ELEITO" | results_description == "ELEITO POR MÉDIA" | results_description == "ELEITO POR QP"
drop results_description 

*Keep winners 
keep if winner == 1

drop if cpf == ""
sort municipality cpf year

*Now create reelection variables 
egen cpf_id = group(cpf)
egen munic_id = group(municipality)
tsset cpf_id year 

tsfill, full
keep if year == 2000 | year == 2004 | year == 2008 | year == 2012 | year == 2016

replace winner = 0 if winner == .
drop munic_id 

*Carryforward cpf 
carryforward cpf_id, gen(cpf_id_full)
sort cpf_id_full year 

*Create first term
bysort cpf_id_full: gen first_term = 1 if winner[_n-1] == 0 & winner == 1
replace first_term = 0 if first_term == .

*Create second term indicator 
bysort cpf_id_full: gen reelected = winner[_n-1] if winner == 1
replace reelected = 0 if reelected == .

replace first_term = 1 if year == 2000 & reelected[_n+1] == 1

keep if winner == 1
keep year cpf first_term reelected

gen in_office = 1

save "Mayor_Reelection", replace 

********************************************************************************
*Append council and mayor reelection 
use "Council_Reelection", clear
append using "Mayor_Reelection", force 

sort cpf year

save "Reelection_AllCandidates_2000_2016", replace 

***********************************************************************************
use "${user}\Data Directory\TSE\Candidate_Year_Donations_Supplemented2", clear

*Drop problematic duplicates 
duplicates drop cpf year, force

*Merge reelection data back into main candidate panel using cpf and year 
merge 1:1 cpf year using "Reelection_AllCandidates_2000_2016"
replace reelected = 0 if reelected == .
replace first_term = 0 if first_term == .
replace in_office = 0 if in_office == .
drop _merge

*Generate variable for sex that can be averaged. 0 = male, 1 = female 
*Create disaggregated version of female by mayor/council
gen female = .
replace female = 1 if sex_code == 4
replace female = 0 if sex_code == 2
gen female_mayor = .
replace female_mayor = female if office_code == 11
gen female_council = .
replace female_council = female if office_code == 13

*Create disaggregated version of age by mayor/council 
gen age_at_election_mayor = .
replace age_at_election_mayor = age_at_election if office_code == 11
gen age_at_election_council = .
replace age_at_election_council = age_at_election if office_code == 13

*Clean incorrect age entries 
replace age_at_election = . if age_at_election < 18 | age_at_election > 100
replace age_at_election_mayor = . if age_at_election_mayor < 18 | age_at_election_mayor > 100
replace age_at_election_council = . if age_at_election_council < 18 | age_at_election_council > 100

*Create disaggregated version of received_donations indicator by mayor/council
gen received_donations_mayor = .
replace received_donations_mayor = received_donations if office_code == 11
gen received_donations_council = .
replace received_donations_council = received_donations if office_code == 13

*Create disggregated measure of schooling by mayor/council 
gen school_mayor = .
replace school_mayor = schooling_code if office_code == 11
gen school_council = .
replace school_council = schooling_code if office_code == 13
drop if schooling_code < 0

*Create votes for mayor which will be summed to total votes received in munic by mayoral candidates.
*This will give measure of voter turnout, since voters vote for multiple council members, so it 
*Doesn't make sense to add these all up.
gen votes_for_mayor = 0
replace votes_for_mayor = vote_total if office_code == 11

*Create mayoral candidate indicator to sum to number of candidates for mayor 
gen mayor_candidate_indicator = 0
replace mayor_candidate_indicator = 1 if office_code == 11

*Repeat for council members
gen council_candidate_indicator = 0
replace council_candidate_indicator = 1 if office_code == 13

*Compute number of council seats (proportional to population)
*Do so by creating indicator for council winner and summing this in collapse command
gen council_winner = 0
replace council_winner = 1 if council_candidate_indicator == 1 & winner == 1

*Merge candidate dataset with disappointment 
merge m:1 municipality year using "Disappointment_ElectionPeriods"
drop _merge  
local vars "disappointed_2004 disappointed_2008 disappointed_2012 disappointed_2016 number_cvm_announcements"
foreach i of local vars {
replace `i' = 0 if `i' == .
}

local vars "real_exp_ratio_2004 real_exp_ratio_2008 real_exp_ratio_2012 real_exp_ratio_2016"
foreach i of local vars {
replace `i' = 1 if `i' == .
}

*Create indicator for whether CVM announcements occurred. 
gen cvm_indicator = 0
replace cvm_indicator = 1 if number_cvm_announcements > 0

gen disappointed = 0
replace disappointed = disappointed_2004 if year == 2004 
replace disappointed = disappointed_2008 if year == 2008 
replace disappointed = disappointed_2012 if year == 2012 
replace disappointed = disappointed_2016 if year == 2016 



*Generate time varying measure of disappointment 
gen real_over_expected = 1
replace real_over_expected = real_exp_ratio_2004 if year == 2004
replace real_over_expected = real_exp_ratio_2008 if year == 2008
replace real_over_expected = real_exp_ratio_2012 if year == 2012
replace real_over_expected = real_exp_ratio_2016 if year == 2016

gen real_over_expected_flipped = 1- real_over_expected // so disappointed is increasing in this variable


*Keep only coastal states 
keep if uf == "AP" | uf == "MA" | uf == "PA" | uf == "PI" | uf == "CE" | uf == "RN" | uf == "PB" | uf == "PE" | uf == "SE" | uf == "AL" | uf == "BA" | uf == "ES" | uf == "RJ" | uf == "SP" | uf == "PR" | uf == "SC" | uf == "RS"

*********************************************************************************
*Samples to focus on are all the people who could have gotten reelected. Independent variable is disappointed_2004 through disappointed_2016. Can include vector of controls. 
*First, identify samples of candidates who would be eligible for reelection. For mayors, this is candidates who's _n-1 term of first_term == 1. For council this is all candidates for whom
*_n-1 term of in_office = 1

sort municipality cpf year

*First create mayor sample 
preserve 
*Keep mayoral candidates
keep if office_description == "PREFEITO" 
*Keep all candidates for whom last term was their first term (e.g. eligible for reelection)
keep if first_term[_n-1] == 1
gen incumbent_win = 0
replace incumbent_win = 1 if winner == 1
save "Mayors_Up_For_Reelection", replace 
restore 

*Next create council sample 
preserve 
*Keep council candidates
keep if office_description == "VEREADOR"
*Keep those who were previously elected 
keep if in_office[_n-1] == 1
save "Councilors_Up_For_Reelection", replace
restore 

********************************************************************************
*Analysis
*First, mayors 
*Bring in dataset of all mayors running for reelection. 
use "Mayors_Up_For_Reelection", clear

sort municipality cpf year

keep if year == 2004 | year == 2008 | year == 2012 | year == 2016
*keep if year == 2012 | year == 2016
*keep if year == 2008 | year == 2012 | year == 2016

*Create continuous disappointment measure 
/*
gen relative_disappointment = 1
replace relative_disappointment = real_exp_ratio_2004 if year == 2004
replace relative_disappointment = real_exp_ratio_2008 if year == 2008
replace relative_disappointment = real_exp_ratio_2012 if year == 2012
replace relative_disappointment = real_exp_ratio_2016 if year == 2016
*/

********************************************************************************
*Regressions with state FEs

graph drop _all
estimates clear


*Disappointed 
*Repeat with controls 
logit incumbent_win disappointed age_at_election_mayor female_mayor school_mayor i.year i.UF_NO if disappointed == 0 | disappointed == 1, vce(cluster munic_code)
margins, dydx(disappointed)
estimates store d_control_log
reghdfe incumbent_win disappointed age_at_election_mayor female_mayor school_mayor if disappointed == 0 | disappointed == 1, absorb(year UF_NO) cluster(munic_code)
estimates store d_control_lpm

*Satisfied
*Repeat with controls 
logit incumbent_win disappointed age_at_election_mayor female_mayor school_mayor i.year i.UF_NO if disappointed == 0 | disappointed == 2, vce(cluster munic_code)
margins, dydx(disappointed)
estimates store s_control_log
reghdfe incumbent_win disappointed age_at_election_mayor female_mayor school_mayor if disappointed == 0 | disappointed == 2, absorb(year UF_NO) cluster(munic_code)
estimates store s_control_lpm

******************************************************
*Compute descriptive statistics 
keep if disappointed == 0
sum winner 

*********************************************************************************
*Now analyze council elections 
use "Councilors_Up_For_Reelection", clear 

sort municipality cpf year

keep if year == 2004 | year == 2008 | year == 2012 | year == 2016
*keep if year == 2012 | year == 2016

*Disappointed 

*Repeat with controls 
logit winner disappointed age_at_election_council female_council school_council i.year i.UF_NO if disappointed == 0 | disappointed == 1, vce(cluster munic_code)
margins, dydx(disappointed)
estimates store d_control_log_c
reghdfe winner disappointed age_at_election_council female_council school_council if disappointed == 0 | disappointed == 1, absorb(year UF_NO) cluster(munic_code)
estimates store d_control_lpm_c

*Repeat for satisfied 

*Repeat with controls 
logit winner disappointed age_at_election_council female_council school_council i.year i.UF_NO if disappointed == 0 | disappointed == 2, vce(cluster munic_code)
margins, dydx(disappointed)
estimates store s_control_log_c
reghdfe winner disappointed age_at_election_council female_council school_council if disappointed == 0 | disappointed == 2, absorb(year UF_NO) cluster(munic_code)
estimates store s_control_lpm_c

******************************************************
*Compute descriptive statistics 
keep if disappointed == 0
sum winner 
