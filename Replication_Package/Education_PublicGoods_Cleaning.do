clear 
cd "${user}\Data Directory\Public Goods"

********************************************************************************
*Clean IDEB test and performance indicators 
********************************************************************************
clear
import delimited "IDEB\municipio.csv"

keep if rede == "municipal"

drop if ano > 2017
drop projecao 

rename id_municipio munic_code 
rename ano year 

drop indicador_rendimento

rename taxa_aprovacao school_completion_rate
rename nota_saeb_matematica saeb_math_score
rename nota_saeb_lingua_portuguesa saeb_portuguese_score 
rename nota_saeb_media_padronizada saeb_avg_score

*Take average of elementary and high school rates 
collapse (mean) school_completion_rate saeb_math_score saeb_portuguese_score saeb_avg_score ideb, by(munic_code year)

save "IDEB\IDEB_Panel", replace 
********************************************************************************

********************************************************************************
*Basic Education Census 
********************************************************************************

**********************
*2000
**********************
*Import schools dataset 
clear
import delimited "Basic_Education_Census\CENSOESC_2000.CSV", encoding(ISO-8859-2)

*Keep only municipal schools 
keep if dep == "Municipal"

*Extract state root from munic code 
tostring codmunic, gen(codmunic_string) format(%17.0g)
drop codmunic 
gen UF_NO = substr(codmunic_string, 1,2)
gen munic_root = substr(codmunic_string, -5,.)
egen munic_code = concat(UF_NO munic_root)
destring munic_code, replace 

*Keep variables of interest 
keep munic munic_code UF_NO nivelcre nivelpre nivelalf niv_f1a4 niv_f5a8 nivelmed nivmedpr supl_ava sprepexc esp_excl esp_t_es esp_s_re esp_a_in ed_indig ed_in_lm ed_in_lp mat_etni esc_t_in bibliote lab_info lab_cien vdg1c3 vdg1c4 vdg155 vdg156 vdg157 vdg165 vdg166 vdg167 vdg175 vdg176 vdg177

gen year = 2000 
order munic_code munic UF_NO year
sort munic_code 

*Compute first indicators: share of relevant school types (not creche, preschool, or special courses) with library, computer lab, and science lab 
gen relevant_type = "0"
replace relevant_type = "1" if niv_f1a4 == "s" | niv_f5a8 == "s" | nivelmed == "s" | nivmedpr == "s" // elementary 1-4, elementary 5-8, high school, professional high school 
gen library = "0"
replace library = "1" if bibliote == "s"
gen computer_lab = "0"
replace computer_lab = "1" if lab_info == "s"
gen science_lab = "0"
replace science_lab = "1" if lab_cien == "s"

destring relevant_type, replace 
destring library, replace 
destring computer_lab, replace 
destring science_lab, replace 

gen library_relevant = library * relevant_type
gen computer_lab_relevant = computer_lab * relevant_type 
gen science_lab_relevant = science_lab * relevant_type

gen infrastructure_index = library_relevant + computer_lab_relevant + science_lab_relevant

********************************************************************************
*Compute second indicators: share of relevant teachers with completed tertiary education 
*First, compute number of teachers in elementary and middle school 
gen num_teachers = vdg1c3 + vdg1c4  

*Next, compute number of teachers with tertiary education 
gen num_superior = vdg155 + vdg156 + vdg157 + vdg165 + vdg166 + vdg167 + vdg175 + vdg176 + vdg177 

*Finally, compute share of teachers with tertiary education 
gen teachers_share_superior = num_superior / num_teachers 

drop if teachers_share_superior > 1 & teachers_share_superior != .

*Collapse to municipality level 
collapse (firstnm) UF_NO (mean) library_relevant computer_lab_relevant science_lab_relevant infrastructure_index teachers_share_superior, by(munic_code year)

save "Basic_Education_Census\Education_Indicators_2000", replace 

*********************************************************************************
*Repeat for 2001-2003
*Import schools dataset 
local years "2001 2002 2003"
foreach j of local years {
clear
import delimited "Basic_Education_Census\CENSOESC_`j'.CSV", encoding(ISO-8859-2)

*Keep only municipal schools 
keep if dep == "Municipal"

*Extract state root from munic code 
tostring codmunic, gen(codmunic_string) format(%17.0g)
drop codmunic 
gen UF_NO = substr(codmunic_string, 1,2)
gen munic_root = substr(codmunic_string, -5,.)
egen munic_code = concat(UF_NO munic_root)
destring munic_code, replace 

*Keep variables of interest 
keep munic munic_code UF_NO nivelcre nivelpre nivelalf niv_f1a4 niv_f5a8 nivelmed nivmedpr supl_ava sprepexc esp_excl esp_t_es esp_s_re esp_a_in ed_indig ed_in_lm ed_in_lp mat_etni esc_t_in bibliote lab_info lab_cien vdg1c3 vdg1c4 vdg1cb vdg155 vdg156 vdg157 vdg165 vdg166 vdg167 vdg175 vdg176 vdg177 vdg1g7 vdg1g7 vdg1g7

gen year = `j'
order munic_code munic UF_NO year
sort munic_code 

*Compute first indicators: share of relevant school types (not creche, preschool, or special courses) with library, computer lab, and science lab 
gen relevant_type = "0"
replace relevant_type = "1" if niv_f1a4 == "s" | niv_f5a8 == "s" | nivelmed == "s" | nivmedpr == "s" // elementary 1-4, elementary 5-8, high school, professional high school 
gen library = "0"
replace library = "1" if bibliote == "s"
gen computer_lab = "0"
replace computer_lab = "1" if lab_info == "s"
gen science_lab = "0"
replace science_lab = "1" if lab_cien == "s"

destring relevant_type, replace 
destring library, replace 
destring computer_lab, replace 
destring science_lab, replace 

gen library_relevant = library * relevant_type
gen computer_lab_relevant = computer_lab * relevant_type 
gen science_lab_relevant = science_lab * relevant_type

gen infrastructure_index = library_relevant + computer_lab_relevant + science_lab_relevant

********************************************************************************
*Compute second indicators: share of relevant teachers with completed tertiary education 
*First, compute number of teachers in elementary and middle school 
gen num_teachers = vdg1c3 + vdg1c4 + vdg1cb

*Next, compute number of teachers with tertiary education 
gen num_superior = vdg155 + vdg156 + vdg157 + vdg165 + vdg166 + vdg167 + vdg175 + vdg176 + vdg177 + vdg1g7 + vdg1g7 + vdg1g7

*Finally, compute share of teachers with tertiary education 
gen teachers_share_superior = num_superior / num_teachers 

drop if teachers_share_superior > 1 & teachers_share_superior != .

*Collapse to municipality level 
collapse (firstnm) UF_NO (mean) library_relevant computer_lab_relevant science_lab_relevant infrastructure_index teachers_share_superior, by(munic_code year)

save "Basic_Education_Census\Education_Indicators_`j'", replace 
}

*********************************************************************************
*Repeat for 2004-2006
*Import schools dataset 
local years "2004 2005 2006"
foreach j of local years {
clear
import delimited "Basic_Education_Census\CENSOESC_`j'.CSV", encoding(ISO-8859-2)

*Keep only municipal schools 
keep if dep == "Municipal"

*Extract state root from munic code 
tostring codmunic, gen(codmunic_string) format(%17.0g)
drop codmunic 
gen UF_NO = substr(codmunic_string, 1,2)
gen munic_root = substr(codmunic_string, -5,.)
egen munic_code = concat(UF_NO munic_root)
destring munic_code, replace 

*Keep variables of interest 
keep munic munic_code UF_NO niv_f1a4_8 niv_f5a8_8 niv_f9ini niv_f9fim nivelmed biblio lab_info lab_cien vdg1c3 vdg1c4 vdg155 vdg156 vdg157 vdg165 vdg166 vdg167 vdg1l5 vdg1l6 vdg1l7 vdg1m5 vdg1m6 vdg1m7 vdg175 vdg176 vdg177

gen year = `j'
order munic_code munic UF_NO year
sort munic_code 

*Compute first indicators: share of relevant school types (not creche, preschool, or special courses) with library, computer lab, and science lab 
gen relevant_type = "0"
replace relevant_type = "1" if niv_f1a4_8 == "s" | niv_f5a8_8 == "s" | niv_f9ini == "s" | niv_f9fim == "s" | nivelmed == "s" // elementary 1-4, elementary 5-8, high school, profess. high school 
gen library = "0"
replace library = "1" if biblio == "s"
gen computer_lab = "0"
replace computer_lab = "1" if lab_info == "s"
gen science_lab = "0"
replace science_lab = "1" if lab_cien == "s"

destring relevant_type, replace 
destring library, replace 
destring computer_lab, replace 
destring science_lab, replace 

gen library_relevant = library * relevant_type
gen computer_lab_relevant = computer_lab * relevant_type 
gen science_lab_relevant = science_lab * relevant_type

gen infrastructure_index = library_relevant + computer_lab_relevant + science_lab_relevant

********************************************************************************
*Compute second indicators: share of relevant teachers with completed tertiary education 
*First, compute number of teachers in elementary and middle school 
gen num_teachers = vdg1c3 + vdg1c4 

*Next, compute number of teachers with tertiary education 
gen num_superior = vdg155 + vdg156 + vdg157 + vdg165 + vdg166 + vdg167 + vdg1l5 + vdg1l6 + vdg1l7 + vdg1m5 + vdg1m6 + vdg1m7 + vdg175 + vdg176 + vdg177

*Finally, compute share of teachers with tertiary education 
gen teachers_share_superior = num_superior / num_teachers 

drop if teachers_share_superior > 1 & teachers_share_superior != .

*Collapse to municipality level 
collapse (firstnm) UF_NO (mean) library_relevant computer_lab_relevant science_lab_relevant infrastructure_index teachers_share_superior, by(munic_code year)

save "Basic_Education_Census\Education_Indicators_`j'", replace 
}

********************************************************************************
*Import, clean, and organize data from 2007-2014
local years "2007 2008 2009 2010 2011 2012 2013 2014"
foreach f of local years {
clear
import delimited "Basic_Education_Census/`f'/DADOS/ESCOLAS.CSV"

keep if id_dependencia_adm == 3

rename fk_cod_municipio munic_code 

gen year = `f'

keep munic_code year id_laboratorio_informatica id_laboratorio_ciencias id_biblioteca id_reg_fund_8_anos id_reg_fund_9_anos id_reg_medio_medio id_reg_medio_integrado id_reg_medio_normal id_reg_medio_prof

gen relevant_type = 0
replace relevant_type = 1 if id_reg_fund_8_anos == 1 | id_reg_fund_9_anos == 1 | id_reg_medio_medio == 1 | id_reg_medio_integrado == 1 | id_reg_medio_normal == 1 | id_reg_medio_prof == 1 

gen library = 0
replace library = 1 if id_biblioteca == 1
gen computer_lab = 0
replace computer_lab = 1 if id_laboratorio_informatica == 1
gen science_lab = 0
replace science_lab = 1 if id_laboratorio_ciencias == 1

gen library_relevant = library * relevant_type 
gen computer_lab_relevant = computer_lab * relevant_type
gen science_lab_relevant = science_lab * relevant_type 

gen infrastructure_index = library_relevant + computer_lab_relevant + science_lab_relevant

*Collapse to municipality level 
collapse (mean) library_relevant computer_lab_relevant science_lab_relevant infrastructure_index, by(munic_code year)

save "Basic_Education_Census/School_Infrasctructure_`f'", replace 
}

*******************************************************************************
*Use teacher-level data to calculate superior education shares of total elementary and high school teachers 
local years "2007 2008 2009 2010 2011 2012 2013 2014"
foreach b of local years {
	clear
	local regions "NORDESTE NORTE SUDESTE SUL CO"
	foreach k of local regions {
	import delimited "Basic_Education_Census/`b'/DADOS/DOCENTES_`k'.CSV" 

		*keep only municipal schools 
		keep if id_dependencia_adm == 3
		rename fk_cod_municipio munic_code 
		
		gen year = `b'

		*First, identify elementary and high school teachers 
		gen fundamental_or_medio = 0
		local types "4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 41 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39"
		foreach m of local types {
		 replace fundamental_or_medio = 1 if fk_cod_etapa_ensino == `m'  
		}
		
		*Keep only teachers of interest (fundamental and medio)
		keep if fundamental_or_medio == 1

		*Identify higher education status 
		gen superior = 0
		replace superior = 1 if fk_cod_escolaridade == 6 | fk_cod_escolaridade == 7
		
		*Collapse to municipality level 
		collapse (mean) superior, by(munic_code year)
			
		save "Basic_Education_Census/Teacher_HigherEd_Share_`b'_`k'", replace 
		clear
	}

	*Append regions into nationwide dataset 
	use "Basic_Education_Census/Teacher_HigherEd_Share_`b'_NORDESTE", clear
	append using "Basic_Education_Census/Teacher_HigherEd_Share_`b'_NORTE", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_`b'_SUDESTE", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_`b'_SUL", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_`b'_CO", force

	sort munic_code 

	save "Basic_Education_Census/Teacher_HigherEd_Share_`b'", replace 

*Merge with infrastructure data 
merge 1:1 munic_code year using "Basic_Education_Census/School_Infrasctructure_`b'"
drop _merge 

save "Basic_Education_Census/Education_Indicators_`b'", replace 
}

********************************************************************************
*Import, clean, and organize data from 2015
********************************************************************************
clear
import delimited "Basic_Education_Census/2015/DADOS/ESCOLAS.CSV"

keep if tp_dependencia == 3

rename co_municipio munic_code 

gen year = 2015

keep munic_code year in_laboratorio_informatica in_laboratorio_ciencias in_biblioteca in_comum_fund_ai in_comum_fund_af in_comum_medio_medio in_comum_medio_integrado in_comum_medio_normal

gen relevant_type = 0
replace relevant_type = 1 if in_comum_fund_ai == 1 | in_comum_fund_af == 1 | in_comum_medio_medio == 1 | in_comum_medio_integrado == 1 | in_comum_medio_normal == 1 

gen library = 0
replace library = 1 if in_biblioteca == 1
gen computer_lab = 0
replace computer_lab = 1 if in_laboratorio_informatica == 1
gen science_lab = 0
replace science_lab = 1 if in_laboratorio_ciencias == 1

gen library_relevant = library * relevant_type 
gen computer_lab_relevant = computer_lab * relevant_type
gen science_lab_relevant = science_lab * relevant_type 

gen infrastructure_index = library_relevant + computer_lab_relevant + science_lab_relevant

*Collapse to municipality level 
collapse (mean) library_relevant computer_lab_relevant science_lab_relevant infrastructure_index, by(munic_code year)

save "Basic_Education_Census/School_Infrasctructure_2015", replace 


*******************************************************************************
*Use teacher-level data to calculate superior education shares of total elementary and high school teachers 
	clear
	local regions "NORDESTE NORTE SUDESTE SUL CO"
	foreach k of local regions {
	import delimited "Basic_Education_Census/2015/DADOS/DOCENTES_`k'.CSV" 

		*keep only municipal schools 
		keep if tp_dependencia == 3
		rename co_municipio munic_code 
		
		gen year = 2015

		*First, identify elementary and high school teachers 
		gen fundamental_or_medio = 0
		local types "4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38"
		foreach m of local types {
		 replace fundamental_or_medio = 1 if tp_etapa_ensino == `m'  
		}
		
		*Keep only teachers of interest (fundamental and medio)
		keep if fundamental_or_medio == 1

		*Identify higher education status 
		gen superior = 0
		replace superior = 1 if tp_escolaridade == 4
		
		*Collapse to municipality level 
		collapse (mean) superior, by(munic_code year)
			
		save "Basic_Education_Census/Teacher_HigherEd_Share_2015_`k'", replace 
		clear
	}

	*Append regions into nationwide dataset 
	use "Basic_Education_Census/Teacher_HigherEd_Share_2015_NORDESTE", clear
	append using "Basic_Education_Census/Teacher_HigherEd_Share_2015_NORTE", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_2015_SUDESTE", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_2015_SUL", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_2015_CO", force

	sort munic_code 

	save "Basic_Education_Census/Teacher_HigherEd_Share_2015", replace 

*Merge with infrastructure data 
merge 1:1 munic_code year using "Basic_Education_Census/School_Infrasctructure_2015"
drop _merge 

save "Basic_Education_Census/Education_Indicators_2015", replace 


********************************************************************************
*Import, clean, and organize data from 2016-2017
********************************************************************************
*Import, clean, and organize data from 2016-2017
local years "2016 2017"
foreach f of local years {
clear
import delimited "Basic_Education_Census/`f'/ESCOLAS.CSV"

keep if tp_dependencia == 3

rename co_municipio munic_code 

gen year = `f'

keep munic_code year in_laboratorio_informatica in_laboratorio_ciencias in_biblioteca in_comum_fund_ai in_comum_fund_af in_comum_medio_medio in_comum_medio_integrado in_comum_medio_normal

gen relevant_type = 0
replace relevant_type = 1 if in_comum_fund_ai == 1 | in_comum_fund_af == 1 | in_comum_medio_medio == 1 | in_comum_medio_integrado == 1 | in_comum_medio_normal == 1 

gen library = 0
replace library = 1 if in_biblioteca == 1
gen computer_lab = 0
replace computer_lab = 1 if in_laboratorio_informatica == 1
gen science_lab = 0
replace science_lab = 1 if in_laboratorio_ciencias == 1

gen library_relevant = library * relevant_type 
gen computer_lab_relevant = computer_lab * relevant_type
gen science_lab_relevant = science_lab * relevant_type 

gen infrastructure_index = library_relevant + computer_lab_relevant + science_lab_relevant

*Collapse to municipality level 
collapse (mean) library_relevant computer_lab_relevant science_lab_relevant infrastructure_index, by(munic_code year)

save "Basic_Education_Census/School_Infrasctructure_`f'", replace 
}

*******************************************************************************
*Use teacher-level data to calculate superior education shares of total elementary and high school teachers 
local years "2016 2017"
foreach b of local years {
	clear
	local regions "NORDESTE NORTE SUDESTE SUL CO"
	foreach k of local regions {
	import delimited "Basic_Education_Census/`b'/DOCENTES_`k'.CSV" 

		*keep only municipal schools 
		keep if tp_dependencia == 3
		rename co_municipio munic_code 
		
		gen year = `b'

		*First, identify elementary and high school teachers 
		gen fundamental_or_medio = 0
		local types "4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38"
		foreach m of local types {
		 replace fundamental_or_medio = 1 if tp_etapa_ensino == `m'  
		}
		
		*Keep only teachers of interest (fundamental and medio)
		keep if fundamental_or_medio == 1

		*Identify higher education status 
		gen superior = 0
		replace superior = 1 if tp_escolaridade == 4
		
		*Collapse to municipality level 
		collapse (mean) superior, by(munic_code year)
			
		save "Basic_Education_Census/Teacher_HigherEd_Share_`b'_`k'", replace 
		clear
	}

	*Append regions into nationwide dataset 
	use "Basic_Education_Census/Teacher_HigherEd_Share_`b'_NORDESTE", clear
	append using "Basic_Education_Census/Teacher_HigherEd_Share_`b'_NORTE", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_`b'_SUDESTE", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_`b'_SUL", force
	append using "Basic_Education_Census/Teacher_HigherEd_Share_`b'_CO", force

	sort munic_code 

	save "Basic_Education_Census/Teacher_HigherEd_Share_`b'", replace 

*Merge with infrastructure data 
merge 1:1 munic_code year using "Basic_Education_Census/School_Infrasctructure_`b'"
drop _merge 

save "Basic_Education_Census/Education_Indicators_`b'", replace 
}


********************************************************************************
use "Basic_Education_Census/Education_Indicators_2000", clear 
append using "Basic_Education_Census/Education_Indicators_2001", force 
append using "Basic_Education_Census/Education_Indicators_2002", force 
append using "Basic_Education_Census/Education_Indicators_2003", force 
append using "Basic_Education_Census/Education_Indicators_2004", force 
append using "Basic_Education_Census/Education_Indicators_2005", force 
append using "Basic_Education_Census/Education_Indicators_2006", force 
append using "Basic_Education_Census/Education_Indicators_2007", force 
append using "Basic_Education_Census/Education_Indicators_2008", force 
append using "Basic_Education_Census/Education_Indicators_2009", force 
append using "Basic_Education_Census/Education_Indicators_2010", force 
append using "Basic_Education_Census/Education_Indicators_2011", force 
append using "Basic_Education_Census/Education_Indicators_2012", force 
append using "Basic_Education_Census/Education_Indicators_2013", force 
append using "Basic_Education_Census/Education_Indicators_2014", force 
append using "Basic_Education_Census/Education_Indicators_2015", force
append using "Basic_Education_Census/Education_Indicators_2016", force
append using "Basic_Education_Census/Education_Indicators_2017", force

replace teachers_share_superior = superior if year > 2006 
drop superior

sort munic_code year
drop UF_NO

*Merge with data from IDEB 
merge 1:1 munic_code year using "IDEB\IDEB_Panel"
drop _merge 
sort munic_code year 

tostring munic_code, replace 
gen munic_code_6digit = substr(munic_code, 1, 6)
destring munic_code_6digit, replace 
drop munic_code 

order munic_code_6digit

save "Education_PublicGoods_Panel_2000_2017", replace 