
********************************************************************************
clear 
cd "${user}\Data Directory\Public Goods"

local years "2007 2008 2009 2010 2011 2012 2013 2014"
foreach b of local years {
	clear
	local regions "NORDESTE NORTE SUDESTE SUL CO"
	foreach k of local regions {
	clear
	import delimited "Basic_Education_Census/`b'/DADOS/MATRICULA_`k'.CSV" 
	
	keep ano_censo cod_municipio_escola id_dependencia_adm_esc 
	gen number_students = 1
	
	gsort cod_municipio_escola ano_censo id_dependencia_adm_esc
	gcollapse (sum) number_students, by(cod_municipio_escola ano_censo id_dependencia_adm_esc)

	gen municipal = 0
	replace municipal = 1 if id_dependencia_adm_esc == 3

	gen private = 0
	replace private = 1 if id_dependencia_adm_esc == 4

	gen federal_state = 0
	replace federal_state = 1 if id_dependencia_adm_esc == 1
	replace federal_state = 1 if id_dependencia_adm_esc == 2

	gen num_municipal = municipal * number_students 
	gen num_private = private * number_students
	gen num_federal_state = federal_state * number_students

	collapse (sum) num_municipal num_private num_federal_state, by(cod_municipio_escola ano_censo)

	rename cod_municipio_escola munic_code 
	rename ano_censo year 
	sort munic_code year
	
	save "Basic_Education_Census/Matriculations_`b'_`k'", replace 
	}
	
	use "Basic_Education_Census/Matriculations_`b'_NORDESTE", clear 
	append using "Basic_Education_Census/Matriculations_`b'_NORTE", force 
	append using "Basic_Education_Census/Matriculations_`b'_SUDESTE", force 
	append using "Basic_Education_Census/Matriculations_`b'_SUL", force 
	append using "Basic_Education_Census/Matriculations_`b'_CO", force 
	
	save "Basic_Education_Census/Matriculations_`b'", replace 
}

*Repeat for 2015 data 
	clear
local regions "NORDESTE NORTE SUDESTE SUL CO"
foreach k of local regions {
	clear
	import delimited "Basic_Education_Census/2015/DADOS/MATRICULA_`k'.CSV" 
	
	keep nu_ano_censo co_municipio tp_dependencia 
	gen number_students = 1
	
	gsort co_municipio nu_ano_censo tp_dependencia
	gcollapse (sum) number_students, by(co_municipio nu_ano_censo tp_dependencia)

	gen municipal = 0
	replace municipal = 1 if tp_dependencia == 3

	gen private = 0
	replace private = 1 if tp_dependencia == 4

	gen federal_state = 0
	replace federal_state = 1 if tp_dependencia == 1
	replace federal_state = 1 if tp_dependencia == 2

	gen num_municipal = municipal * number_students 
	gen num_private = private * number_students
	gen num_federal_state = federal_state * number_students

	collapse (sum) num_municipal num_private num_federal_state, by(co_municipio nu_ano_censo)

	rename co_municipio munic_code 
	rename nu_ano_censo year 
	sort munic_code year
	
	save "Basic_Education_Census/Matriculations_2015_`k'", replace 
	}
	
	use "Basic_Education_Census/Matriculations_2015_NORDESTE", clear 
	append using "Basic_Education_Census/Matriculations_2015_NORTE", force 
	append using "Basic_Education_Census/Matriculations_2015_SUDESTE", force 
	append using "Basic_Education_Census/Matriculations_2015_SUL", force 
	append using "Basic_Education_Census/Matriculations_2015_CO", force 
	
	save "Basic_Education_Census/Matriculations_2015", replace 

*Repeat for 2016 data 
local regions "NORDESTE NORTE SUDESTE SUL CO"
foreach k of local regions {
	clear
	import delimited "Basic_Education_Census/micro_censo_escolar_2016/DADOS/MATRICULA_`k'.CSV" 
	
	keep nu_ano_censo co_municipio tp_dependencia 
	gen number_students = 1
	
	gsort co_municipio nu_ano_censo tp_dependencia
	gcollapse (sum) number_students, by(co_municipio nu_ano_censo tp_dependencia)

	gen municipal = 0
	replace municipal = 1 if tp_dependencia == 3

	gen private = 0
	replace private = 1 if tp_dependencia == 4

	gen federal_state = 0
	replace federal_state = 1 if tp_dependencia == 1
	replace federal_state = 1 if tp_dependencia == 2

	gen num_municipal = municipal * number_students 
	gen num_private = private * number_students
	gen num_federal_state = federal_state * number_students

	collapse (sum) num_municipal num_private num_federal_state, by(co_municipio nu_ano_censo)

	rename co_municipio munic_code 
	rename nu_ano_censo year 
	sort munic_code year
	
	save "Basic_Education_Census/Matriculations_2016_`k'", replace 
	}
	
	use "Basic_Education_Census/Matriculations_2016_NORDESTE", clear 
	append using "Basic_Education_Census/Matriculations_2016_NORTE", force 
	append using "Basic_Education_Census/Matriculations_2016_SUDESTE", force 
	append using "Basic_Education_Census/Matriculations_2016_SUL", force 
	append using "Basic_Education_Census/Matriculations_2016_CO", force 
	
	save "Basic_Education_Census/Matriculations_2016", replace 



*Repeat for 2017 data 
local regions "NORDESTE NORTE SUDESTE SUL CO"
foreach k of local regions {
	clear
	import delimited "Basic_Education_Census/Microdados_Censo_Escolar_2017/DADOS/MATRICULA_`k'.CSV" 
	
	keep nu_ano_censo co_municipio tp_dependencia 
	gen number_students = 1
	
	gsort co_municipio nu_ano_censo tp_dependencia
	gcollapse (sum) number_students, by(co_municipio nu_ano_censo tp_dependencia)

	gen municipal = 0
	replace municipal = 1 if tp_dependencia == 3

	gen private = 0
	replace private = 1 if tp_dependencia == 4

	gen federal_state = 0
	replace federal_state = 1 if tp_dependencia == 1
	replace federal_state = 1 if tp_dependencia == 2

	gen num_municipal = municipal * number_students 
	gen num_private = private * number_students
	gen num_federal_state = federal_state * number_students

	collapse (sum) num_municipal num_private num_federal_state, by(co_municipio nu_ano_censo)

	rename co_municipio munic_code 
	rename nu_ano_censo year 
	sort munic_code year
	
	save "Basic_Education_Census/Matriculations_2017_`k'", replace 
	}
	
	use "Basic_Education_Census/Matriculations_2017_NORDESTE", clear 
	append using "Basic_Education_Census/Matriculations_2017_NORTE", force 
	append using "Basic_Education_Census/Matriculations_2017_SUDESTE", force 
	append using "Basic_Education_Census/Matriculations_2017_SUL", force 
	append using "Basic_Education_Census/Matriculations_2017_CO", force 
	
	save "Basic_Education_Census/Matriculations_2017", replace 
	
*********************************************************************************
*Repeat for years 2004-2006
local years "2005 2006"
foreach j of local years {
	clear
	import delimited "Basic_Education_Census\CENSOESC_`j'.CSV", encoding(ISO-8859-2)
	
	*Extract state root from munic code 
	tostring codmunic, gen(codmunic_string) format(%17.0g)
	drop codmunic 
	gen UF_NO = substr(codmunic_string, 1,2)
	gen munic_root = substr(codmunic_string, -5,.)
	egen munic_code = concat(UF_NO munic_root)
	gen munic_code_6digit = substr(munic_code, 1, 6)
	destring munic_code, replace 
	destring munic_code_6digit, replace 
	
	keep munic_code munic_code_6digit dep dpe119 dpe11d dpe119 npe11d def11c def11d def11e def11f def11g def11h def11i def11j nef11c nef11d nef11e nef11f nef11g nef11h nef11i nef11j dem118 dem119 dem11a dem11b nem118 nem119 nem11a nem11b dem11c nem11c des101f des101g des101h des101i des101a nes101f nes101g nes101h nes101i nes101a

	gen year = `j'
	
	local matriculas "dpe119 dpe11d dpe119 npe11d def11c def11d def11e def11f def11g def11h def11i def11j nef11c nef11d nef11e nef11f nef11g nef11h nef11i nef11j dem118 dem119 dem11a dem11b nem118 nem119 nem11a nem11b dem11c nem11c des101f des101g des101h des101i des101a nes101f nes101g nes101h nes101i nes101a"
	foreach b of local matriculas {
		replace `b' = 0 if `b' == .
	}

	gen number_students = dpe119 + dpe11d + dpe119 + npe11d + def11c + def11d + def11e + def11f + def11g + def11h + def11i + def11j + nef11c + nef11d + nef11e + nef11f + nef11g + nef11h + nef11i + nef11j + dem118 + dem119 + dem11a + dem11b + nem118 + nem119 + nem11a + nem11b + dem11c + nem11c + des101f + des101g + des101h + des101i + des101a + nes101f + nes101g + nes101h + nes101i + nes101a
	
	gen dependency = ""
	replace dependency = "1" if dep == "Estadual"
	replace dependency = "2" if dep == "Federal"
	replace dependency = "3" if dep == "Municipal"
	replace dependency = "4" if dep == "Particular"
	destring dependency, replace 
		
	gcollapse (sum) number_students, by(munic_code_6digit year dependency)

	gen municipal = 0
	replace municipal = 1 if dependency == 3

	gen private = 0
	replace private = 1 if dependency == 4

	gen federal_state = 0
	replace federal_state = 1 if dependency == 1
	replace federal_state = 1 if dependency == 2

	gen num_municipal = municipal * number_students 
	gen num_private = private * number_students
	gen num_federal_state = federal_state * number_students

	collapse (sum) num_municipal num_private num_federal_state, by(munic_code_6digit year)

	sort munic_code_6digit year	
	
	save "Basic_Education_Census/Matriculations_`j'", replace 
}

*2004
	clear
	import delimited "Basic_Education_Census\CENSOESC_2004.CSV", encoding(ISO-8859-2)
	
	*Extract state root from munic code 
	tostring codmunic, gen(codmunic_string) format(%17.0g)
	drop codmunic 
	gen UF_NO = substr(codmunic_string, 1,2)
	gen munic_root = substr(codmunic_string, -5,.)
	egen munic_code = concat(UF_NO munic_root)
	gen munic_code_6digit = substr(munic_code, 1, 6)
	destring munic_code, replace 
	destring munic_code_6digit, replace 
	
	keep munic_code munic_code_6digit dep dpe119 dpe11d dpe119 npe11d def11c def11d def11e def11f def11g def11h def11i def11j nef11c nef11d nef11e nef11f nef11g nef11h nef11i nef11j dem118 dem119 dem11a dem11b nem118 nem119 nem11a nem11b dem11c nem11c dcn771 dcn772 dcn773 dcn774 dcn779 ncn775 ncn776 ncn777 ncn778 ncn77a

	gen year = 2004
	
	local matriculas "dpe119 dpe11d dpe119 npe11d def11c def11d def11e def11f def11g def11h def11i def11j nef11c nef11d nef11e nef11f nef11g nef11h nef11i nef11j dem118 dem119 dem11a dem11b nem118 nem119 nem11a nem11b dem11c nem11c dcn771 dcn772 dcn773 dcn774 dcn779 ncn775 ncn776 ncn777 ncn778 ncn77a"
	foreach b of local matriculas {
		replace `b' = 0 if `b' == .
	}

	gen number_students = dpe119 + dpe11d + dpe119 + npe11d + def11c + def11d + def11e + def11f + def11g + def11h + def11i + def11j + nef11c + nef11d + nef11e + nef11f + nef11g + nef11h + nef11i + nef11j + dem118 + dem119 + dem11a + dem11b + nem118 + nem119 + nem11a + nem11b + dem11c + nem11c + dcn771 + dcn772 + dcn773 + dcn774 + dcn779 + ncn775 + ncn776 + ncn777 + ncn778 + ncn77a
	
	gen dependency = ""
	replace dependency = "1" if dep == "Estadual"
	replace dependency = "2" if dep == "Federal"
	replace dependency = "3" if dep == "Municipal"
	replace dependency = "4" if dep == "Particular"
	destring dependency, replace 
		
	gcollapse (sum) number_students, by(munic_code_6digit year dependency)

	gen municipal = 0
	replace municipal = 1 if dependency == 3

	gen private = 0
	replace private = 1 if dependency == 4

	gen federal_state = 0
	replace federal_state = 1 if dependency == 1
	replace federal_state = 1 if dependency == 2

	gen num_municipal = municipal * number_students 
	gen num_private = private * number_students
	gen num_federal_state = federal_state * number_students

	collapse (sum) num_municipal num_private num_federal_state, by(munic_code_6digit year)

	sort munic_code_6digit year	
	
	save "Basic_Education_Census/Matriculations_2004", replace 


	
*********************************************************************************
*Append all years 
use "Basic_Education_Census/Matriculations_2007", clear 
append using "Basic_Education_Census/Matriculations_2008", force 
append using "Basic_Education_Census/Matriculations_2009", force 
append using "Basic_Education_Census/Matriculations_2010", force 
append using "Basic_Education_Census/Matriculations_2011", force 
append using "Basic_Education_Census/Matriculations_2012", force 
append using "Basic_Education_Census/Matriculations_2013", force 
append using "Basic_Education_Census/Matriculations_2014", force 
append using "Basic_Education_Census/Matriculations_2015", force 
append using "Basic_Education_Census/Matriculations_2016", force 
append using "Basic_Education_Census/Matriculations_2017", force 

tostring munic_code, replace 
gen munic_code_6digit = substr(munic_code, 1, 6) 
destring munic_code_6digit, replace 
destring munic_code, replace 

append using "Basic_Education_Census/Matriculations_2004", force 
append using "Basic_Education_Census/Matriculations_2005", force 
append using "Basic_Education_Census/Matriculations_2006", force 

rename num_municipal num_students_private 
rename num_private num_students_municipal
rename num_federal_state num_students_fed_state

duplicates drop munic_code_6digit year, force 
sort munic_code_6digit year 
drop munic_code 

save "Basic_Education_Census/Matriculations_Panel_2004_2017", replace 


