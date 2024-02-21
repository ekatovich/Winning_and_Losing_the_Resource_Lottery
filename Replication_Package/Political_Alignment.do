*Political Alignment


clear
cd "${user}\Data Directory\Treatment Variables"


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

keep winner municipality year office_code office_description party_number party_initials party_name munic_code 

keep if winner == 1

keep if office_code == 11

*Input additional years to fill down
input 
. . 2000 . . . . . . 
. . 2001 . . . . . . 
. . 2002 . . . . . . 
. . 2003 . . . . . . 
. . 2004 . . . . . . 
. . 2005 . . . . . . 
. . 2006 . . . . . . 
. . 2007 . . . . . . 
. . 2008 . . . . . . 
. . 2009 . . . . . . 
. . 2010 . . . . . . 
. . 2011 . . . . . . 
. . 2012 . . . . . . 
. . 2013 . . . . . . 
. . 2014 . . . . . . 
. . 2015 . . . . . . 
. . 2016 . . . . . . 
. . 2017 . . . . . . 
end

sort municipality year
drop office_code office_description winner party_number

duplicates drop  year municipality, force

*Now tsfill and carryforward to fill in all years 
tsset munic_code year
tsfill, full

*Now carryforward ruling parties until next election 
carryforward municipality, gen(municipality_1)
carryforward party_name, gen(party_name_1)
carryforward party_initials, gen(party_initials_1)
carryforward munic_code, gen(munic_code_1)

drop municipality party_name party_initials munic_code
rename municipality_1 municipality 
rename party_name_1 party_name_munic
rename party_initials_1 party_initials_munic
rename munic_code_1 munic_code

drop if municipality == "."
drop if municipality == ""
sort municipality year

*Extract state from munic_code 
tostring munic_code, replace 
gen uf_no = substr(munic_code, 1, 2)
destring munic_code, replace

destring uf_no, replace
gen uf = ""
replace uf = "RO" if uf_no == 11
replace uf = "AC" if uf_no == 12
replace uf = "AM" if uf_no == 13
replace uf = "RR" if uf_no == 14
replace uf = "PA" if uf_no == 15
replace uf = "AP" if uf_no == 16
replace uf = "TO" if uf_no == 17

replace uf = "MA" if uf_no == 21
replace uf = "PI" if uf_no == 22
replace uf = "CE" if uf_no == 23
replace uf = "RN" if uf_no == 24
replace uf = "PB" if uf_no == 25
replace uf = "PE" if uf_no == 26
replace uf = "AL" if uf_no == 27
replace uf = "SE" if uf_no == 28
replace uf = "BA" if uf_no == 29

replace uf = "MG" if uf_no == 31
replace uf = "ES" if uf_no == 32
replace uf = "RJ" if uf_no == 33
replace uf = "SP" if uf_no == 35

replace uf = "PR" if uf_no == 41
replace uf = "SC" if uf_no == 42
replace uf = "RS" if uf_no == 43

replace uf = "MS" if uf_no == 50
replace uf = "MT" if uf_no == 51
replace uf = "GO" if uf_no == 52
replace uf = "DF" if uf_no == 53

save "Party_Representation_Municipality_Level", replace 

************************************************************************************
************************************************************************************

*Now repeat with state-level data 

*First, import and clean raw state and federal level data 
local ufs "AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO"
local anos "1998 2002 2006 2010"

foreach i of local ufs{
	
	foreach j of local anos {
	
		clear
		import delimited "${user}/Data Directory/TSE/Candidates/State_and_Federal_Candidates/consulta_cand_`j'_`i'.txt", delimiters(";")

		keep v3 v6 v10 v19 v20 v42 v43
		
		rename v3 year 
		rename v6 uf
		rename v10 office_description 
		rename v19 party_initials 
		rename v20 party_name 
		rename v42 results_code 
		rename v43 results_description
		
		keep if office_description == "GOVERNADOR"
		
		
		gen winner = 0
		replace winner = 1 if results_description == "ELEITO" | results_description == "ELEITO POR MÉDIA" | results_description == "ELEITO POR QP"
		
		drop if winner == 0
		
		drop results_code results_description winner
		
		save "state_governor_`i'_`j'.dta", replace
		
		}
		
		}
		
		
*Repeat for 2014, which holds raw data in csv files 
local ufs "AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO"
local anos "2014"
foreach i of local ufs{
	
	foreach j of local anos {
	
		clear	
import delimited "${user}/Data Directory/TSE/Candidates/State_and_Federal_Candidates/consulta_cand_`j'_`i'.csv", delimiters(";")

keep ano_eleicao sg_uf ds_cargo sg_partido nm_partido ds_sit_tot_turno

rename ano_eleicao year
rename sg_uf uf
rename ds_cargo office_description
rename sg_partido party_initials
rename nm_partido party_name
rename ds_sit_tot_turno	results_description
		
keep if office_description == "GOVERNADOR"
		
		
		gen winner = 0
		replace winner = 1 if results_description == "ELEITO" | results_description == "ELEITO POR MÉDIA" | results_description == "ELEITO POR QP"
		
		drop if winner == 0
		
		drop results_description winner
		
		save "state_governor_`i'_`j'.dta", replace
		
		}
		
		}
		

		
		
*Append all state-years into panel 
*Loop over all UF initials and years to append all candidate vote datasets into single .dta file
use "state_governor_AC_1998.dta", clear
local ufs "AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO"
local anos "1998 2002 2006 2010 2014"
foreach i of local ufs{
	
	foreach j of local anos {
		append using "state_governor_`i'_`j'.dta", force
	}
}

*Drop duplicates (since AC_2000 gets brought in twice) and order variables to improve readability
order uf year
duplicates drop
sort uf year

*Now tsset, tsfill, and carryforward
*Generate numeric state id 
duplicates drop uf year, force
drop office_description

*Input additional years to fill down
input 
. 1998 . . . .  
. 1999 . . . .  
. 2000 . . . .  
. 2001 . . . .  
. 2002 . . . .  
. 2003 . . . .  
. 2004 . . . .  
. 2005 . . . .  
. 2006 . . . .  
. 2007 . . . .  
. 2008 . . . .  
. 2009 . . . .  
. 2010 . . . .  
. 2011 . . . .  
. 2012 . . . .  
. 2013 . . . .  
. 2014 . . . .  
. 2015 . . . .  
. 2016 . . . .  
. 2017 . . . .  
end

egen state_id = group(uf)
tsset state_id year 

tsfill, full

*Now carryforward ruling parties until next election 
carryforward uf, gen(uf_1)
carryforward party_name, gen(party_name_1)
carryforward party_initials, gen(party_initials_1)

drop uf party_name party_initials
rename uf_1 uf
rename party_name_1 party_name_state
rename party_initials_1 party_initials_state

drop state_id 

save "Party_Representation_State_Level", replace 

*********************************************************************************
*********************************************************************************
*Manually input federal level dataset (varying only by year) 
clear 

input year str16 party_initials_fed 
2000 "PSDB"
2001 "PSDB"
2002 "PSDB"
2003 "PT"
2004 "PT"
2005 "PT"
2006 "PT"
2007 "PT"
2008 "PT"
2009 "PT"
2010 "PT"
2011 "PT"
2012 "PT"
2013 "PT"
2014 "PT"
2015 "PT"
2016 "PT"
2017 "PMDB"
end

save "Party_Representation_Federal_Level", replace

*********************************************************************************
*********************************************************************************
*Now merge mayors and governors' parties on uf and year 

use "Party_Representation_Municipality_Level", clear 

merge m:1 uf year using "Party_Representation_State_Level"
drop _merge

merge m:1 year using "Party_Representation_Federal_Level"
drop _merge

drop if year < 2000 
drop if municipality == ""
order year municipality munic_code uf_no uf
sort municipality year

gen munic_state_align = 0
replace munic_state_align = 1 if party_initials_munic == party_initials_state

gen munic_fed_align = 0
replace munic_fed_align = 1 if party_initials_munic == party_initials_fed

save "Party_Alignment_Panel_Munic_State_Fed", replace
***********************************************************************************
***********************************************************************************