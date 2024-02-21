clear
cd "${user}\Data Directory\Treatment Variables"

********************************************************************************
*TWFE Wells
use "Municipalities_Elections_Wells_Analysis", clear

*Create indicator for whether CVM announcements occurred. 
gen cvm_indicator = 0
replace cvm_indicator = 1 if number_cvm_announcements > 0

*Shorten long variable names 
rename ihs_council_candidates_total ihs_coun_cand_tot
rename ihs_council_candidates_compet ihs_counc_cand_comp
rename ihs_mayor_candidates_total ihs_may_cand_tot
rename ihs_mayor_candidates_compet ihs_may_cand_comp
rename ihs_mayor_candidates_compet2 ihs_may_cand_comp2
rename ihs_margin_victory_mayor ihs_marg_vict_may
rename ihs_council_candidates_perseat ihs_counc_cand_seat
rename ihs_council_compcands_perseat ihs_counc_compcand_seat
rename ihs_age_at_election_council ihs_age_election_counc
rename ihs_age_at_election_mayor ihs_age_election_may
rename ihs_received_donations_council ihs_rec_donat_counc
rename ihs_received_donations_mayor ihs_rec_donat_may
rename ihs_received_donations_share ihs_rec_donat_share

*Generate total candidates by summing mayors and council 
gen candidates_total = council_candidates_total + mayor_candidates_total
gen ihs_cand_tot = asinh(candidates_total)

*Generate competitive candidates per seat total 
gen comp_cands_perseat = (council_candidates_compet + mayor_candidates_compet) / (council_seats_total + 1)
gen ihs_comp_cands_perseat = asinh(comp_cands_perseat)

*Create indicator for donor hired in commissioned position 
gen donor_hired_commissionedm = 0
replace donor_hired_commissionedm = 1 if commissioned_donorsm > 0

*Shorten patronage variable names 
rename donor_hired_commissionedm donor_hired_cm
rename commissioned_donorsm c_donorsm
rename donor_share_of_commissionedm donor_share_cm
rename commissioned_share_of_donorsm c_share_donorsm

*Take asinh of commissioned donors number 
gen ihs_c_donorsm = asinh(c_donorsm)

*******
*Repeat for total politician patronage values 
*Create indicator for donor hired in commissioned position 
gen donor_hired_commissionedt = 0
replace donor_hired_commissionedt = 1 if commissioned_donorst > 0

*Shorten patronage variable names 
rename donor_hired_commissionedt donor_hired_ct
rename commissioned_donorst c_donorst
rename donor_share_of_commissionedt donor_share_ct
rename commissioned_share_of_donorst c_share_donorst

*Take asinh of commissioned donors number 
gen ihs_c_donorst = asinh(c_donorst)

*Compute descriptive statistics: control mean 
bysort munic_code: egen ever_treated = max(cvm_indicator)

preserve 
collapse (mean) ihs_cand_tot ihs_comp_cands_perseat ihs_counc_cand_comp ihs_may_cand_tot ihs_may_cand_comp ihs_counc_compcand_seat ihs_total_donation_num ihs_total_donation_val ihs_female ihs_age_at_election ihs_schooling_code, by(ever_treated)
keep if ever_treated == 0

*Reverse IHS 
local vars "ihs_cand_tot ihs_counc_cand_comp ihs_may_cand_comp ihs_comp_cands_perseat ihs_total_donation_num ihs_total_donation_val ihs_female ihs_age_at_election ihs_schooling_code"
foreach q of local vars {
	gen orig_`q' = sinh(`q')
}
save "ElectionOutcomes_DescriptiveStats", replace 
restore 

graph drop _all
estimates clear

local outcomes "ihs_cand_tot ihs_counc_cand_comp ihs_may_cand_comp ihs_comp_cands_perseat"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

*Donations
local outcomes "ihs_total_donation_num ihs_total_donation_val"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

local outcomes "female age_at_election schooling_code"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

*Now analyze winners 
local outcomes "winner_fem_total winner_age_total winner_educ_total"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

*Analyse patronage (mayors only)
local outcomes "donor_hired_cm ihs_c_donorsm donor_share_cm c_share_donorsm"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

*Analyse patronage (all politicians)
local outcomes "donor_hired_ct ihs_c_donorst donor_share_ct c_share_donorst"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

********************************************************************************
*TWFE Matched 
use "Municipalities_Elections_Matched_Analysis", clear

*Create indicator for whether CVM announcements occurred. 
gen cvm_indicator = 0
replace cvm_indicator = 1 if number_cvm_announcements > 0

*Shorten long variable names 
rename ihs_council_candidates_total ihs_coun_cand_tot
rename ihs_council_candidates_compet ihs_counc_cand_comp
rename ihs_mayor_candidates_total ihs_may_cand_tot
rename ihs_mayor_candidates_compet ihs_may_cand_comp
rename ihs_mayor_candidates_compet2 ihs_may_cand_comp2
rename ihs_margin_victory_mayor ihs_marg_vict_may
rename ihs_council_candidates_perseat ihs_counc_cand_seat
rename ihs_council_compcands_perseat ihs_counc_compcand_seat
rename ihs_age_at_election_council ihs_age_election_counc
rename ihs_age_at_election_mayor ihs_age_election_may
rename ihs_received_donations_council ihs_rec_donat_counc
rename ihs_received_donations_mayor ihs_rec_donat_may
rename ihs_received_donations_share ihs_rec_donat_share

*Generate total candidates by summing mayors and council 
gen candidates_total = council_candidates_total + mayor_candidates_total
gen ihs_cand_tot = asinh(candidates_total)

*Generate competitive candidates per seat total 
gen comp_cands_perseat = (council_candidates_compet + mayor_candidates_compet) / (council_seats_total + 1)
gen ihs_comp_cands_perseat = asinh(comp_cands_perseat)

*Create indicator for donor hired in commissioned position 
gen donor_hired_commissionedm = 0
replace donor_hired_commissionedm = 1 if commissioned_donorsm > 0

*Shorten patronage variable names 
rename donor_hired_commissionedm donor_hired_cm
rename commissioned_donorsm c_donorsm
rename donor_share_of_commissionedm donor_share_cm
rename commissioned_share_of_donorsm c_share_donorsm

*Take asinh of commissioned donors number 
gen ihs_c_donorsm = asinh(c_donorsm)

*******
*Repeat for total politician patronage values 
*Create indicator for donor hired in commissioned position 
gen donor_hired_commissionedt = 0
replace donor_hired_commissionedt = 1 if commissioned_donorst > 0

*Shorten patronage variable names 
rename donor_hired_commissionedt donor_hired_ct
rename commissioned_donorst c_donorst
rename donor_share_of_commissionedt donor_share_ct
rename commissioned_share_of_donorst c_share_donorst

*Take asinh of commissioned donors number 
gen ihs_c_donorst = asinh(c_donorst)

graph drop _all
estimates clear

local outcomes "ihs_cand_tot ihs_counc_cand_comp ihs_may_cand_comp ihs_comp_cands_perseat"
foreach i of local outcomes {
reghdfe `i' cvm_indicator [aweight=cem_weights], absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

*[aweight=cem_weight]

*Donations
local outcomes "ihs_total_donation_num ihs_total_donation_val"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

local outcomes "female age_at_election schooling_code"
foreach i of local outcomes {
reghdfe `i' cvm_indicator [aweight=cem_weights], absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

*Now analyze winners 
local outcomes "winner_fem_total winner_age_total winner_educ_total"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

*Analyse patronage (mayors only)
local outcomes "donor_hired_cm ihs_c_donorsm donor_share_cm c_share_donorsm"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

*Analyse patronage (all politicians)
local outcomes "donor_hired_ct ihs_c_donorst donor_share_ct c_share_donorst"
foreach i of local outcomes {
reghdfe `i' cvm_indicator, absorb(munic_code election_period) cluster(munic_code)
estimates store `i'
}

***********************************************************************************
*CS Wells 
use "Event_Analysis_Elections_FirstEvent_Wells", clear

**Create indicator for whether CVM announcements occurred. 
gen cvm_indicator = 0
replace cvm_indicator = 1 if number_cvm_announcements > 0

*Generate total candidates by summing mayors and council 
*First, reverse asinh
gen candidates_total = council_candidates_total + mayor_candidates_total
gen ihs_cand_tot = asinh(candidates_total)

*Generate competitive candidates per seat total 
gen comp_cands_perseat = (council_candidates_compet + mayor_candidates_compet) / (council_seats_total + 1)
gen ihs_comp_cands_perseat = asinh(comp_cands_perseat)

*Create indicator for donor hired in commissioned position 
gen donor_hired_commissionedm = 0
replace donor_hired_commissionedm = 1 if commissioned_donorsm > 0

*Shorten patronage variable names 
rename donor_hired_commissionedm donor_hired_cm
rename commissioned_donorsm c_donorsm
rename donor_share_of_commissionedm donor_share_cm
rename commissioned_share_of_donorsm c_share_donorsm

*Take asinh of commissioned donors number 
gen ihs_c_donorsm = asinh(c_donorsm)

*******
*Repeat for total politician patronage values 
*Create indicator for donor hired in commissioned position 
gen donor_hired_commissionedt = 0
replace donor_hired_commissionedt = 1 if commissioned_donorst > 0

*Shorten patronage variable names 
rename donor_hired_commissionedt donor_hired_ct
rename commissioned_donorst c_donorst
rename donor_share_of_commissionedt donor_share_ct
rename commissioned_share_of_donorst c_share_donorst

*Take asinh of commissioned donors number 
gen ihs_c_donorst = asinh(c_donorst)

graph drop _all
estimates clear

set seed 25475183

local outcomes "ihs_cand_tot ihs_counc_cand_comp ihs_may_cand_comp ihs_comp_cands_perseat"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

*Donations
local outcomes "ihs_total_donation_num ihs_total_donation_val"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

local outcomes "female age_at_election schooling_code"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

*Now analyze winners 
local outcomes "winner_fem_total winner_age_total winner_educ_total winner_educ_mayor winner_educ_council"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

*Analyse patronage (mayors only)
local outcomes "donor_hired_cm ihs_c_donorsm donor_share_cm c_share_donorsm"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

*Analyse patronage (all politicians)
local outcomes "donor_hired_ct ihs_c_donorst donor_share_ct c_share_donorst"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

***********************************************************************************
***********************************************************************************
*CS Matched
use "Event_Analysis_Elections_FirstEvent_Matched.dta", clear

*Create indicator for whether CVM announcements occurred. 
gen cvm_indicator = 0
replace cvm_indicator = 1 if number_cvm_announcements > 0

*Generate total candidates by summing mayors and council 
*First, reverse asinh
*gen council_candidates_total = sinh(ihs_coun_cand_tot)
*gen mayor_candidates_total = sinh(ihs_may_cand_tot)
gen candidates_total = council_candidates_total + mayor_candidates_total
gen ihs_cand_tot = asinh(candidates_total)

*Generate competitive candidates per seat total 
gen comp_cands_perseat = (council_candidates_compet + mayor_candidates_compet) / (council_seats_total + 1)
gen ihs_comp_cands_perseat = asinh(comp_cands_perseat)

*Create indicator for donor hired in commissioned position 
gen donor_hired_commissionedm = 0
replace donor_hired_commissionedm = 1 if commissioned_donorsm > 0

*Shorten patronage variable names 
rename donor_hired_commissionedm donor_hired_cm
rename commissioned_donorsm c_donorsm
rename donor_share_of_commissionedm donor_share_cm
rename commissioned_share_of_donorsm c_share_donorsm

*Take asinh of commissioned donors number 
gen ihs_c_donorsm = asinh(c_donorsm)

*******
*Repeat for total politician patronage values 
*Create indicator for donor hired in commissioned position 
gen donor_hired_commissionedt = 0
replace donor_hired_commissionedt = 1 if commissioned_donorst > 0

*Shorten patronage variable names 
rename donor_hired_commissionedt donor_hired_ct
rename commissioned_donorst c_donorst
rename donor_share_of_commissionedt donor_share_ct
rename commissioned_share_of_donorst c_share_donorst

*Take asinh of commissioned donors number 
gen ihs_c_donorst = asinh(c_donorst)

graph drop _all
estimates clear

set seed 25475183

local outcomes "ihs_cand_tot ihs_counc_cand_comp ihs_may_cand_comp ihs_comp_cands_perseat"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

*Donations
local outcomes "ihs_total_donation_num ihs_total_donation_val"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

local outcomes "female age_at_election schooling_code"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'") 
}

*Now analyze winners 
local outcomes "winner_fem_total winner_age_total winner_educ_total"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

*Analyse patronage (mayors only)
local outcomes "donor_hired_cm ihs_c_donorsm donor_share_cm c_share_donorsm"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'")
}

*Analyse patronage (all politicians)
local outcomes "donor_hired_ct ihs_c_donorst donor_share_ct c_share_donorst"
foreach j of local outcomes {
csdid `j', ivar(munic_code) time(election_period) gvar(first_CVM_period) 
estat simple, estore("e_`j'") 
}