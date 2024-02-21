*Elections Analysis


clear
cd "${user}\Data Directory\Treatment Variables"

/*
*Variables of interest:
Number of candidates and competitive candidates for mayor and council 
Win margins for mayor (merge this in after collapse)
*Number of council seats 
*Candidates per seat 
Avg. schooling of mayor and council
Avg. age of mayor and council
Size of coalitions
Number of donations 
Value of donations 
Share of candidates receiving donations 
Avg. sex for mayor and council 
Voter turnout (votes cast / population)
*/


*Bring in complete individual-level dataset on all candidates and donations
use "${user}\Data Directory\TSE\Candidate_Year_Donations_Supplemented2", clear

*Keep relevant variables
keep municipality year office_code office_description vote_total winner party_number party_initials party_name coalition_makeup num_parties_coalition coalition_name sex_code sex_description schooling_code schooling_description married_code married_description age_at_election nationality_code nationality_description campaign_expense_total results_code results_description coalition_type reelection round UF_NO uf situation_code situation_description coalition_initials election_code election_date other_individual_val total_donation_val total_donation_num received_donations munic_code munic_code_6digit micro_code meso_code POPULACAO

*Drop empty observations
drop if office_code == .

rename POPULACAO population

gen winner_2 = 0
replace winner_2 = 1 if results_description == "ELEITO" | results_description == "ELEITO POR MÉDIA" | results_description == "ELEITO POR QP"
order winner winner_2
drop winner 
rename winner_2 winner 


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

*Create descriptives of winners 
gen winner_age_total = age_at_election if winner == 1
gen winner_fem_total = female if winner == 1
gen winner_educ_total = schooling_code if winner == 1

gen winner_age_mayor = age_at_election if winner == 1 & office_code == 11
gen winner_fem_mayor = female if winner == 1 & office_code == 11
gen winner_educ_mayor = schooling_code if winner == 1 & office_code == 11

gen winner_age_council = age_at_election if winner == 1 & office_code == 13
gen winner_fem_council = female if winner == 1 & office_code == 13
gen winner_educ_council = schooling_code if winner == 1 & office_code == 13

*********************************************************************************
*Calculate each mayoral candidate's win margin 
preserve
*Keep mayoral candidates to compute win margins 
keep if office_code == 11

****New method for computing win margin 
*Sum total mayoral votes in municipality 
bysort municipality year: egen total_votes_mayor = sum(vote_total)

*Compute each candidates share of total votes 
gen candidate_share_votes = (vote_total / total_votes_mayor)*100

*Drop duplicate candidates 
*duplicates drop municipality year candidate_id_tse, force

*Identify top vote share 
bysort municipality year: egen first_vote_share = max(candidate_share_votes)

*Identify second top vote share 
bysort municipality year: egen votes_share_rank = rank(-candidate_share_votes)
gen second_vote_share_tmp = candidate_share_votes if votes_share_rank == 2
bysort municipality year: egen second_vote_share = max(second_vote_share_tmp)
drop second_vote_share_tmp

*Compute win margin by subtracting second highest vote share from first highest 
gen win_margin_new = first_vote_share - second_vote_share
*************


*For each municipality-election, find total votes caste
bysort municipality year: egen total_votes = sum(vote_total)

*For each candidate for mayor, compute vote share of total 
bysort municipality year: gen share_of_mayor_vote = vote_total / total_votes

*Generate competitive mayor indicator 
gen competitive_mayor_cand = 0
replace competitive_mayor_cand = 1 if share_of_mayor_vote >= 0.25
gen competitive_mayor_cand2 = 0
replace competitive_mayor_cand2 = 1 if share_of_mayor_vote >= 0.10

*For each municipality-election, find winning number of votes
bysort municipality year: egen winning_votes = max(vote_total)

*Create indicator for officially designated winners
gen winner_official = 0
replace winner_official = 1 if results_code == 1 | results_code == 5

*Create indicator for candidates who receive the winning number of votes in each municipality-election
gen winner_votes = 0
replace winner_votes = 1 if vote_total == winning_votes

*In each municipality-election, rank candidates by vote
bysort municipality year: egen votes_rank = rank(vote_total), field

*Create indicator for candidates who receive second most votes
generate runner_up = 0
replace runner_up = 1 if votes_rank == 2

*Compute number of votes received by runner up
gen runner_up_votes_2 = vote_total if runner_up == 1

*Create variable taking value of runner up's vote total in each municipality-election
bysort municipality year: egen runner_up_votes = max(runner_up_votes_2)

*Next, compute win margin 
bysort municipality year: gen margin_victory = ((winning_votes/total_votes)*100) - ((runner_up_votes/total_votes)*100)

bysort municipality year: egen total_candidates = count(mayor_candidate_indicator)

replace margin_victory = 100 if total_candidates == 1

keep munic_code year margin_victory win_margin_new competitive_mayor_cand competitive_mayor_cand2

collapse (mean) margin_victory win_margin_new (sum) competitive_mayor_cand competitive_mayor_cand2, by(munic_code year)

save "MarginVictory_Mayors", replace 
restore

***********************************************************************************
*Calculate number of competitive candidates for council 
*Method from Niemi and Hsieh: https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.960.829&rep=rep1&type=pdf

*First, compute total votes for council 
bysort municipality year: egen council_votes = sum(vote_total) if office_code == 13

*Now compute total number of council seats 
bysort municipality year: egen council_seats_total = sum(council_winner)

*Next, compute each council candidates share of those total votes 
gen share_of_council_vote = .
replace share_of_council_vote = (vote_total / council_votes) if council_candidate_indicator == 1

*Calculate Hagenbach-Bischoff quota (??????)
*WORK ON THIS
bysort municipality year: gen council_competitive_cutoff = (1/(1 + council_seats_total))/8

gen competitive_council_cand = 0
replace competitive_council_cand = 1 if share_of_council_vote > council_competitive_cutoff

*********************************************************************************

*Collapse data to municipal level 
collapse (firstnm) municipality munic_code_6digit population (sum) competitive_council_cand council_candidate_indicator mayor_candidate_indicator votes_for_mayor total_donation_num total_donation_val (mean) council_seats_total num_parties_coalition female female_mayor female_council age_at_election_mayor age_at_election_council age_at_election received_donations received_donations_council received_donations_mayor school_mayor school_council schooling_code winner_age_total winner_age_mayor winner_age_council winner_fem_total winner_fem_mayor winner_fem_council winner_educ_total winner_educ_mayor winner_educ_council, by(year munic_code)

rename council_candidate_indicator council_candidates_total
rename mayor_candidate_indicator mayor_candidates_total
rename votes_for_mayor vote_total 
rename num_parties_coalition coalition_size 
rename received_donations received_donations_share 
rename competitive_council_cand council_candidates_compet

gen council_candidates_perseat = council_candidates_total / council_seats_total
gen voter_turnout = vote_total / population 

gen council_compcands_perseat = council_candidates_compet / council_seats_total 

gen donation_val_percand = total_donation_val / (council_candidates_total + mayor_candidates_total)
gen donation_num_percand = total_donation_num / (council_candidates_total + mayor_candidates_total)

replace donation_val_percand = . if year == 2000 | year == 2004
replace donation_num_percand = . if year == 2000 | year == 2004
replace total_donation_num = . if year == 2000 | year == 2004
replace total_donation_val = . if year == 2000 | year == 2004

sort munic_code year

**********************************************************************************
*Merge in mayoral data 
merge 1:1 munic_code year using "MarginVictory_Mayors"
drop if _merge == 1
drop _merge 

rename margin_victory margin_victory_mayor 
rename competitive_mayor_cand mayor_candidates_compet
rename competitive_mayor_cand2 mayor_candidates_compet2

order year munic_code munic_code_6digit municipality population vote_total voter_turnout total_donation_num total_donation_val donation_num_percand donation_val_percand council_candidates_total council_candidates_compet mayor_candidates_total mayor_candidates_compet mayor_candidates_compet2 margin_victory_mayor win_margin_new council_seats_total council_candidates_perseat council_compcands_perseat mayor_candidates_compet coalition_size female female_mayor female_council age_at_election age_at_election_mayor age_at_election_council received_donations_share received_donations_council received_donations_mayor schooling_code school_mayor school_council

sort municipality year

rename year election_period

**********************************************************************************
*Transform outcome variables 
local transform "vote_total voter_turnout total_donation_num total_donation_val donation_num_percand donation_val_percand council_candidates_total council_candidates_compet mayor_candidates_total  mayor_candidates_compet  mayor_candidates_compet2  margin_victory_mayor council_candidates_perseat council_compcands_perseat coalition_size female female_mayor female_council  age_at_election age_at_election_mayor age_at_election_council received_donations_share  received_donations_council received_donations_mayor  schooling_code school_mayor school_council"
foreach j of local transform {
gen ihs_`j' = asinh(`j')
}

*Merge in measures of patronage
merge 1:1 munic_code_6digit election_period using "${user}\Data Directory\TSE\Patronage_MayorOnly_2004_2016"
drop if _merge == 2
drop _merge 

*Rename patronage variables 
rename commissioned_tot commissioned_totm
rename commissioned_donors commissioned_donorsm
rename donor_share_of_commissioned donor_share_of_commissionedm
rename number_of_donors number_of_donorsm
rename commissioned_share_of_donors commissioned_share_of_donorsm

*Merge in measures of patronage
merge 1:1 munic_code_6digit election_period using "${user}\Data Directory\TSE\Patronage_TotalPoliticians_2004_2016"
drop if _merge == 2
drop _merge 

rename commissioned_tot commissioned_tott
rename commissioned_donors commissioned_donorst
rename donor_share_of_commissioned donor_share_of_commissionedt
rename number_of_donors number_of_donorst
rename commissioned_share_of_donors commissioned_share_of_donorst

save "Municipality_Elections_Outcomes", replace 


*************************************************************************************
*Prepare treatment data for elections analysis 

use "Munics_Affected_by_Oil", clear

keep if hydrocarbon_detections_2000_2017 > 0

gen election_period = .
replace election_period = 2000 if year == 1998 | year == 1999 | year == 2000
replace election_period = 2004 if year == 2001 | year == 2002 | year == 2003 | year == 2004
replace election_period = 2008 if year == 2005 | year == 2006 | year == 2007 | year == 2008
replace election_period = 2012 if year == 2009 | year == 2010 | year == 2011 | year == 2012
replace election_period = 2016 if year == 2013 | year == 2014 | year == 2015 | year == 2016

drop if year == 2017


*Calculate royalty windfalls for each election period

drop if election_period == .
gen oil_revenue_1999 = oil_revenue if year == 1999
gen oil_revenue_2000 = oil_revenue if year == 2000
gen oil_revenue_2004 = oil_revenue if year == 2004
gen oil_revenue_2008 = oil_revenue if year == 2008
gen oil_revenue_2012 = oil_revenue if year == 2012
gen oil_revenue_2016 = oil_revenue if year == 2016

bysort municipality: egen max_oil_revenue_1999 = max(oil_revenue_1999)
bysort municipality: egen max_oil_revenue_2000 = max(oil_revenue_2000)
bysort municipality: egen max_oil_revenue_2004 = max(oil_revenue_2004)
bysort municipality: egen max_oil_revenue_2008 = max(oil_revenue_2008)
bysort municipality: egen max_oil_revenue_2012 = max(oil_revenue_2012)
bysort municipality: egen max_oil_revenue_2016 = max(oil_revenue_2016)

drop oil_revenue_1999 oil_revenue_2000 oil_revenue_2004 oil_revenue_2008 oil_revenue_2012 oil_revenue_2016

rename max_oil_revenue_1999 oil_revenue_1999
rename max_oil_revenue_2000 oil_revenue_2000
rename max_oil_revenue_2004 oil_revenue_2004
rename max_oil_revenue_2008 oil_revenue_2008
rename max_oil_revenue_2012 oil_revenue_2012
rename max_oil_revenue_2016 oil_revenue_2016

replace oil_revenue_1999 = 0 if oil_revenue_1999 == .
replace oil_revenue_2000 = 0 if oil_revenue_2000 == .
replace oil_revenue_2004 = 0 if oil_revenue_2004 == .
replace oil_revenue_2008 = 0 if oil_revenue_2008 == .
replace oil_revenue_2012 = 0 if oil_revenue_2012 == .
replace oil_revenue_2016 = 0 if oil_revenue_2016 == .

gen oil_windfall_1999_2000 = oil_revenue_2000 - oil_revenue_1999 if year == 2000
gen oil_windfall_2000_2004 = oil_revenue_2004 - oil_revenue_2000 if year == 2004
gen oil_windfall_2004_2008 = oil_revenue_2008 - oil_revenue_2004 if year == 2008
gen oil_windfall_2008_2012 = oil_revenue_2012 - oil_revenue_2008 if year == 2012
gen oil_windfall_2012_2016 = oil_revenue_2016 - oil_revenue_2012 if year == 2016

gen oil_windfall = .
replace oil_windfall = oil_windfall_1999_2000 if year == 2000
replace oil_windfall = oil_windfall_2000_2004 if year == 2004
replace oil_windfall = oil_windfall_2004_2008 if year == 2008
replace oil_windfall = oil_windfall_2008_2012 if year == 2012
replace oil_windfall = oil_windfall_2012_2016 if year == 2016

*Collapse data down to election period 
collapse (firstnm) municipality munic_code_6digit uf UF_NO micro_code meso_code basin (sum) number_of_wells_completed number_hydrocarbon_detections num_successful_wells num_unsuccessful_wells number_cvm_announcements announced_new_volume_mmboe oil_bbl gas_mm3 prod_boe oil_revenue oil_windfall (mean) POPULACAO dist_brasilia dist_statecapital latitude MORT_2000 T_FUND18M_2000 T_MED18M_2000 T_SUPER25M_2000 GINI_2000 PREN10RICOS_2000 PREN40_2000 R1040_2000 RDPC_2000 RDPC1_2000 RDPC10_2000 P_AGRO_2000 P_COM_2000 P_CONSTR_2000 P_EXTR_2000 P_FORMAL_2000 P_SERV_2000 P_SIUP_2000 P_TRANSF_2000 T_ATIV18M_2000 T_DES18M_2000 TRABCC_2000 TRABPUB_2000 T_LUZ_2000 AGUA_ESGOTO_2000 T_FUNDIN18MINF_2000 PEA18M_2000 pesoRUR_2000 pesotot_2000 pesourb_2000 ifdm_2000 ifdm_employment_income_2000 ifdm_education_2000 ifdm_health_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 income_capita_2000 theil_2000 poverty_2000, by(munic_code election_period)


sort municipality election_period
order munic_code municipality munic_code_6digit uf UF_NO micro_code meso_code basin election_period 

merge 1:1 election_period munic_code using "Municipality_Elections_Outcomes"
drop if _merge == 1 | _merge == 2

sort municipality election_period
drop _merge
drop if election_period == 2000

drop population 
rename POPULACAO population


*Data organization complete
save "Municipalities_Elections_Hydrocarbons_Analysis", replace 
*******************************************************************************
*Prepare treatment data for elections analysis 

use "Munics_Affected_by_Oil", clear

keep if wells_completed_2000_2017 > 0

gen election_period = .
replace election_period = 2000 if year == 1998 | year == 1999 | year == 2000
replace election_period = 2004 if year == 2001 | year == 2002 | year == 2003 | year == 2004
replace election_period = 2008 if year == 2005 | year == 2006 | year == 2007 | year == 2008
replace election_period = 2012 if year == 2009 | year == 2010 | year == 2011 | year == 2012
replace election_period = 2016 if year == 2013 | year == 2014 | year == 2015 | year == 2016

drop if year == 2017


*Calculate royalty windfalls for each election period

drop if election_period == .
gen oil_revenue_1999 = oil_revenue if year == 1999
gen oil_revenue_2000 = oil_revenue if year == 2000
gen oil_revenue_2004 = oil_revenue if year == 2004
gen oil_revenue_2008 = oil_revenue if year == 2008
gen oil_revenue_2012 = oil_revenue if year == 2012
gen oil_revenue_2016 = oil_revenue if year == 2016

bysort municipality: egen max_oil_revenue_1999 = max(oil_revenue_1999)
bysort municipality: egen max_oil_revenue_2000 = max(oil_revenue_2000)
bysort municipality: egen max_oil_revenue_2004 = max(oil_revenue_2004)
bysort municipality: egen max_oil_revenue_2008 = max(oil_revenue_2008)
bysort municipality: egen max_oil_revenue_2012 = max(oil_revenue_2012)
bysort municipality: egen max_oil_revenue_2016 = max(oil_revenue_2016)

drop oil_revenue_1999 oil_revenue_2000 oil_revenue_2004 oil_revenue_2008 oil_revenue_2012 oil_revenue_2016

rename max_oil_revenue_1999 oil_revenue_1999
rename max_oil_revenue_2000 oil_revenue_2000
rename max_oil_revenue_2004 oil_revenue_2004
rename max_oil_revenue_2008 oil_revenue_2008
rename max_oil_revenue_2012 oil_revenue_2012
rename max_oil_revenue_2016 oil_revenue_2016

replace oil_revenue_1999 = 0 if oil_revenue_1999 == .
replace oil_revenue_2000 = 0 if oil_revenue_2000 == .
replace oil_revenue_2004 = 0 if oil_revenue_2004 == .
replace oil_revenue_2008 = 0 if oil_revenue_2008 == .
replace oil_revenue_2012 = 0 if oil_revenue_2012 == .
replace oil_revenue_2016 = 0 if oil_revenue_2016 == .

gen oil_windfall_1999_2000 = oil_revenue_2000 - oil_revenue_1999 if year == 2000
gen oil_windfall_2000_2004 = oil_revenue_2004 - oil_revenue_2000 if year == 2004
gen oil_windfall_2004_2008 = oil_revenue_2008 - oil_revenue_2004 if year == 2008
gen oil_windfall_2008_2012 = oil_revenue_2012 - oil_revenue_2008 if year == 2012
gen oil_windfall_2012_2016 = oil_revenue_2016 - oil_revenue_2012 if year == 2016

gen oil_windfall = .
replace oil_windfall = oil_windfall_1999_2000 if year == 2000
replace oil_windfall = oil_windfall_2000_2004 if year == 2004
replace oil_windfall = oil_windfall_2004_2008 if year == 2008
replace oil_windfall = oil_windfall_2008_2012 if year == 2012
replace oil_windfall = oil_windfall_2012_2016 if year == 2016

*Collapse data down to election period 
collapse (firstnm) municipality munic_code_6digit uf UF_NO micro_code meso_code basin (sum) number_of_wells_completed number_hydrocarbon_detections num_successful_wells num_unsuccessful_wells number_cvm_announcements announced_new_volume_mmboe oil_bbl gas_mm3 prod_boe oil_revenue oil_windfall (mean) POPULACAO dist_brasilia dist_statecapital latitude MORT_2000 T_FUND18M_2000 T_MED18M_2000 T_SUPER25M_2000 GINI_2000 PREN10RICOS_2000 PREN40_2000 R1040_2000 RDPC_2000 RDPC1_2000 RDPC10_2000 P_AGRO_2000 P_COM_2000 P_CONSTR_2000 P_EXTR_2000 P_FORMAL_2000 P_SERV_2000 P_SIUP_2000 P_TRANSF_2000 T_ATIV18M_2000 T_DES18M_2000 TRABCC_2000 TRABPUB_2000 T_LUZ_2000 AGUA_ESGOTO_2000 T_FUNDIN18MINF_2000 PEA18M_2000 pesoRUR_2000 pesotot_2000 pesourb_2000 ifdm_2000 ifdm_employment_income_2000 ifdm_education_2000 ifdm_health_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 income_capita_2000 theil_2000 poverty_2000, by(munic_code election_period)


sort municipality election_period
order munic_code municipality munic_code_6digit uf UF_NO micro_code meso_code basin election_period 

merge 1:1 election_period munic_code using "Municipality_Elections_Outcomes"
drop if _merge == 1 | _merge == 2

sort municipality election_period
drop _merge
drop if election_period == 2000

drop population 
rename POPULACAO population


*Data organization complete
save "Municipalities_Elections_Wells_Analysis", replace 

*************************************************************************************************************
*Repeat for matched dataset 

use "Event_Analysis_Matching_FirstEvent", clear

gen election_period = .
replace election_period = 2000 if year == 1998 | year == 1999 | year == 2000
replace election_period = 2004 if year == 2001 | year == 2002 | year == 2003 | year == 2004
replace election_period = 2008 if year == 2005 | year == 2006 | year == 2007 | year == 2008
replace election_period = 2012 if year == 2009 | year == 2010 | year == 2011 | year == 2012
replace election_period = 2016 if year == 2013 | year == 2014 | year == 2015 | year == 2016

drop if year == 2017


*Calculate royalty windfalls for each election period

drop if election_period == .
gen oil_revenue_1999 = oil_revenue if year == 1999
gen oil_revenue_2000 = oil_revenue if year == 2000
gen oil_revenue_2004 = oil_revenue if year == 2004
gen oil_revenue_2008 = oil_revenue if year == 2008
gen oil_revenue_2012 = oil_revenue if year == 2012
gen oil_revenue_2016 = oil_revenue if year == 2016

bysort municipality: egen max_oil_revenue_1999 = max(oil_revenue_1999)
bysort municipality: egen max_oil_revenue_2000 = max(oil_revenue_2000)
bysort municipality: egen max_oil_revenue_2004 = max(oil_revenue_2004)
bysort municipality: egen max_oil_revenue_2008 = max(oil_revenue_2008)
bysort municipality: egen max_oil_revenue_2012 = max(oil_revenue_2012)
bysort municipality: egen max_oil_revenue_2016 = max(oil_revenue_2016)

drop oil_revenue_1999 oil_revenue_2000 oil_revenue_2004 oil_revenue_2008 oil_revenue_2012 oil_revenue_2016

rename max_oil_revenue_1999 oil_revenue_1999
rename max_oil_revenue_2000 oil_revenue_2000
rename max_oil_revenue_2004 oil_revenue_2004
rename max_oil_revenue_2008 oil_revenue_2008
rename max_oil_revenue_2012 oil_revenue_2012
rename max_oil_revenue_2016 oil_revenue_2016

replace oil_revenue_1999 = 0 if oil_revenue_1999 == .
replace oil_revenue_2000 = 0 if oil_revenue_2000 == .
replace oil_revenue_2004 = 0 if oil_revenue_2004 == .
replace oil_revenue_2008 = 0 if oil_revenue_2008 == .
replace oil_revenue_2012 = 0 if oil_revenue_2012 == .
replace oil_revenue_2016 = 0 if oil_revenue_2016 == .

gen oil_windfall_1999_2000 = oil_revenue_2000 - oil_revenue_1999 if year == 2000
gen oil_windfall_2000_2004 = oil_revenue_2004 - oil_revenue_2000 if year == 2004
gen oil_windfall_2004_2008 = oil_revenue_2008 - oil_revenue_2004 if year == 2008
gen oil_windfall_2008_2012 = oil_revenue_2012 - oil_revenue_2008 if year == 2012
gen oil_windfall_2012_2016 = oil_revenue_2016 - oil_revenue_2012 if year == 2016

gen oil_windfall = .
replace oil_windfall = oil_windfall_1999_2000 if year == 2000
replace oil_windfall = oil_windfall_2000_2004 if year == 2004
replace oil_windfall = oil_windfall_2004_2008 if year == 2008
replace oil_windfall = oil_windfall_2008_2012 if year == 2012
replace oil_windfall = oil_windfall_2012_2016 if year == 2016

*Collapse data down to election period 
collapse (firstnm) municipality munic_code_6digit uf UF_NO micro_code meso_code basin disappointed_pc_low (sum) number_of_wells_completed number_hydrocarbon_detections num_successful_wells num_unsuccessful_wells number_cvm_announcements cum_cvm_announcements announced_new_volume_mmboe oil_bbl gas_mm3 prod_boe oil_revenue oil_windfall (mean) ihs_gdp_2002 population_complete dist_brasilia dist_statecapital latitude MORT_2000 T_FUND18M_2000 T_MED18M_2000 T_SUPER25M_2000 GINI_2000 PREN10RICOS_2000 PREN40_2000 R1040_2000 RDPC_2000 RDPC1_2000 RDPC10_2000 P_AGRO_2000 P_COM_2000 P_CONSTR_2000 P_EXTR_2000 P_FORMAL_2000 P_SERV_2000 P_SIUP_2000 P_TRANSF_2000 T_ATIV18M_2000 T_DES18M_2000 TRABCC_2000 TRABPUB_2000 T_LUZ_2000 AGUA_ESGOTO_2000 T_FUNDIN18MINF_2000 PEA18M_2000 pesoRUR_2000 pesotot_2000 pesourb_2000 ifdm_2000 ifdm_employment_income_2000 ifdm_education_2000 ifdm_health_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 income_capita_2000 theil_2000 poverty_2000, by(munic_code election_period)


sort municipality election_period
order munic_code municipality munic_code_6digit uf UF_NO micro_code meso_code basin election_period 

merge 1:1 election_period munic_code using "Municipality_Elections_Outcomes"
drop if _merge == 1 | _merge == 2

sort municipality election_period
drop _merge
drop if election_period == 2000

*Do CEM matching 
gen ihs_dist_statecapital = asinh(dist_statecapital)
gen ihs_pesotot_2000 = asinh(pesotot_2000)

gen treated = 0
replace treated = 1 if disappointed_pc_low == 1 | disappointed_pc_low == 2

*Try with coarser bins
cem ihs_dist_statecapital (#5) latitude (#5) ihs_gdp_2002 (#5) ihs_pesotot_2000 (#5) ifdm_2000 (#5) TRABPUB_2000 (#4) GINI_2000 (#4), treatment(treated) 

*Keep only matches
keep if cem_matched == 1

*Identify election period of first CVM announcement by municipality 
*Set data as time series to allow ts operators
egen election_period_id = group(election_period)

tsset munic_code election_period_id
sort munic_code election_period_id

bysort munic_code: gen first_CVM = cum_cvm_announcements if cum_cvm_announcements != 0 & L1.cum_cvm_announcements == 0
replace first_CVM = 0 if first_CVM == .

*Create first CVM year for Sant'Anna event study
gen cvm_period = .
replace cvm_period = election_period if first_CVM != 0
bysort munic_code: egen first_CVM_period = min(cvm_period)
replace first_CVM_period = 0 if first_CVM_period == .

save "Municipalities_Elections_Matched_Analysis", replace 




*************************************************************************************************************
*Event study with election periods 

*Keep all observations
use "Munics_for_Matching_cleaned_outcomes", clear

gen election_period = .
replace election_period = 2000 if year == 1998 | year == 1999 | year == 2000
replace election_period = 2004 if year == 2001 | year == 2002 | year == 2003 | year == 2004
replace election_period = 2008 if year == 2005 | year == 2006 | year == 2007 | year == 2008
replace election_period = 2012 if year == 2009 | year == 2010 | year == 2011 | year == 2012
replace election_period = 2016 if year == 2013 | year == 2014 | year == 2015 | year == 2016

drop if year == 2017


*Calculate royalty windfalls for each election period

drop if election_period == .
gen oil_revenue_1999 = oil_revenue if year == 1999
gen oil_revenue_2000 = oil_revenue if year == 2000
gen oil_revenue_2004 = oil_revenue if year == 2004
gen oil_revenue_2008 = oil_revenue if year == 2008
gen oil_revenue_2012 = oil_revenue if year == 2012
gen oil_revenue_2016 = oil_revenue if year == 2016

bysort municipality: egen max_oil_revenue_1999 = max(oil_revenue_1999)
bysort municipality: egen max_oil_revenue_2000 = max(oil_revenue_2000)
bysort municipality: egen max_oil_revenue_2004 = max(oil_revenue_2004)
bysort municipality: egen max_oil_revenue_2008 = max(oil_revenue_2008)
bysort municipality: egen max_oil_revenue_2012 = max(oil_revenue_2012)
bysort municipality: egen max_oil_revenue_2016 = max(oil_revenue_2016)

drop oil_revenue_1999 oil_revenue_2000 oil_revenue_2004 oil_revenue_2008 oil_revenue_2012 oil_revenue_2016

rename max_oil_revenue_1999 oil_revenue_1999
rename max_oil_revenue_2000 oil_revenue_2000
rename max_oil_revenue_2004 oil_revenue_2004
rename max_oil_revenue_2008 oil_revenue_2008
rename max_oil_revenue_2012 oil_revenue_2012
rename max_oil_revenue_2016 oil_revenue_2016

replace oil_revenue_1999 = 0 if oil_revenue_1999 == .
replace oil_revenue_2000 = 0 if oil_revenue_2000 == .
replace oil_revenue_2004 = 0 if oil_revenue_2004 == .
replace oil_revenue_2008 = 0 if oil_revenue_2008 == .
replace oil_revenue_2012 = 0 if oil_revenue_2012 == .
replace oil_revenue_2016 = 0 if oil_revenue_2016 == .

gen oil_windfall_1999_2000 = oil_revenue_2000 - oil_revenue_1999 if year == 2000
gen oil_windfall_2000_2004 = oil_revenue_2004 - oil_revenue_2000 if year == 2004
gen oil_windfall_2004_2008 = oil_revenue_2008 - oil_revenue_2004 if year == 2008
gen oil_windfall_2008_2012 = oil_revenue_2012 - oil_revenue_2008 if year == 2012
gen oil_windfall_2012_2016 = oil_revenue_2016 - oil_revenue_2012 if year == 2016

gen oil_windfall = .
replace oil_windfall = oil_windfall_1999_2000 if year == 2000
replace oil_windfall = oil_windfall_2000_2004 if year == 2004
replace oil_windfall = oil_windfall_2004_2008 if year == 2008
replace oil_windfall = oil_windfall_2008_2012 if year == 2012
replace oil_windfall = oil_windfall_2012_2016 if year == 2016

*Collapse data down to election period 
collapse (firstnm) municipality munic_code_6digit uf UF_NO micro_code meso_code basin (sum) number_of_wells_completed number_hydrocarbon_detections number_cvm_announcements announced_new_volume_mmboe oil_bbl gas_mm3 prod_boe oil_revenue oil_windfall (max) cum_cvm_announcements cum_volume_announced (mean) population_complete dist_brasilia dist_statecapital latitude MORT_2000 gdp_2002 T_FUND18M_2000 T_MED18M_2000 T_SUPER25M_2000 GINI_2000 PREN10RICOS_2000 PREN40_2000 R1040_2000 RDPC_2000 RDPC1_2000 RDPC10_2000 P_AGRO_2000 P_COM_2000 P_CONSTR_2000 P_EXTR_2000 P_FORMAL_2000 P_SERV_2000 P_SIUP_2000 P_TRANSF_2000 T_ATIV18M_2000 T_DES18M_2000 TRABCC_2000 TRABPUB_2000 T_LUZ_2000 AGUA_ESGOTO_2000 T_FUNDIN18MINF_2000 PEA18M_2000 pesoRUR_2000 pesotot_2000 pesourb_2000 ifdm_2000 ifdm_employment_income_2000 ifdm_education_2000 ifdm_health_2000 hdi_income_2000 hdi_lifeexpect_2000 hdi_education_2000 income_capita_2000 theil_2000 poverty_2000, by(munic_code election_period)

sort municipality election_period
order munic_code municipality munic_code_6digit uf UF_NO micro_code meso_code basin election_period 

*Set data as time series to allow ts operators
egen election_period_id = group(election_period)

tsset munic_code election_period_id
sort munic_code election_period_id

*Identify election period of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_announcements if cum_cvm_announcements != 0 & L1.cum_cvm_announcements == 0
replace first_CVM = 0 if first_CVM == .
gen event_time_0 = 0
replace event_time_0 = 1 if first_CVM > 0

*Create first CVM year for Sant'Anna event study
gen cvm_period = .
replace cvm_period = election_period if first_CVM != 0
bysort munic_code: egen first_CVM_period = min(cvm_period)
replace first_CVM_period = 0 if first_CVM_period == .

*We now have indicator for period when first event occurred

*Create dummy indicators that equal 1 when event (CVM announcement) happened i years before or after.
*Create dummies out to full extent of data to fully saturate events. (3 periods in either direction).
forvalues i = 1(1)3 {
gen event_time_`i'b = 0
bysort munic_code: replace event_time_`i'b = 1 if F`i'.event_time_0 == 1
}

forvalues i = 1(1)3 {
gen event_time_`i'a = 0
bysort munic_code: replace event_time_`i'a = 1 if L`i'.event_time_0 == 1
}

*Create relative_time indicators 
gen relative_time = .
replace relative_time = 0 if election_period == first_CVM_period 
replace relative_time = 1 if election_period == first_CVM_period + 4
replace relative_time = 2 if election_period == first_CVM_period + 8
replace relative_time = 3 if election_period == first_CVM_period + 12

replace relative_time = -1 if election_period == first_CVM_period - 4
replace relative_time = -2 if election_period == first_CVM_period - 8
replace relative_time = -3 if election_period == first_CVM_period - 12

*Now make all relative_time indicators positive
*Set up relative time indicator 
replace relative_time = -1 if relative_time == .
*Add 15 to make all values non-negative
replace relative_time = relative_time + 3
*Now, omitted period (-1) is represented by value 2

*Events are now totally saturated.

*Merge in disappointment indicators
merge m:1 municipality using "Temporary_Disappointment"
replace disappointed = 0 if _merge == 1
drop _merge
rename disappointed disappointed_temp

merge m:1 municipality using "Disappointed_List_Long"

local vars "disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3"
foreach j of local vars {
replace `j' = 0 if _merge == 1
}
drop _merge

*Merge in elections outcomes
merge 1:1 election_period munic_code using "Municipality_Elections_Outcomes"
drop if _merge == 1 | _merge == 2

sort municipality election_period
drop _merge
*drop if election_period == 2000

*drop population 
*rename POPULACAO population

*Rename long variables 
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


*Save dataset for analysis 
save "Event_Analysis_Elections_FirstEvent", replace 


*******************************************************************************
*Create matched sample 

use "Event_Analysis_Elections_FirstEvent", clear

gen ihs_dist_statecapital = asinh(dist_statecapital)
gen ihs_gdp_2002 = asinh(gdp_2002)
gen ihs_pesotot_2000 = asinh(pesotot_2000)

gen treated = 0
replace treated = 1 if disappointed_pc_low == 1 | disappointed_pc_low == 2

*Try with coarser bins
cem ihs_dist_statecapital (#5) latitude (#5) ihs_gdp_2002 (#5) ihs_pesotot_2000 (#5) ifdm_2000 (#5) TRABPUB_2000 (#4) GINI_2000 (#4), treatment(treated) 

*Keep only matches
keep if cem_matched == 1

save "Event_Analysis_Elections_FirstEvent_Matched", replace 



********************************************************************************
*Create sample for only municipalities with wells 
use "Event_Analysis_Elections_FirstEvent", clear

bysort munic_code: egen wells_completed1 = max(number_of_wells_completed)
gen wells_completed = 0
replace wells_completed = 1 if wells_completed1 > 0

keep if wells_completed == 1

save "Event_Analysis_Elections_FirstEvent_Wells", replace