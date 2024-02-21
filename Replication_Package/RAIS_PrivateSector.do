
clear
cd "${user}\Data Directory\RAIS\RAIS Unidentified Coastal"

********************************************************************************
*Begin by cleaning oil-linked data 
use "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE1", clear 

drop oil_link_direction_CNAE1
duplicates drop cnae1, force

save "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE1_short", replace

use "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE2", clear 

drop oil_link_direction_CNAE2
duplicates drop cnae2, force

save "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE2_short", replace


********************************************************************************
*Import and process individual data
*Desired variables: number of total workers (stock) and number of layoffs and hires (flow) each year by sector and for oil-linked,
*as well as avg. wage for each of these categories.
	
	
*Run loop over all (coastal) UF initials and years to bring in all ";" delimited .txt files
local ufs "PB PE PI PR RJ RN RS SC SE SP"
local years "2000 2001 2002 2003 2004 2005"
foreach i of local ufs {
	
	foreach j of local years {
	
		import delimited "`i'`j'.txt", delimiters(";") clear
	
			*Keep only required variables 
			capture keep cnae95classe mêsadmissão município vlremunmédianom tipoadmissão motivodesligamento
			
			rename cnae95classe CNAE_95
			rename mêsadmissão month_hire
			rename município munic_resid
			rename vlremunmédianom wage_avg
			rename tipoadmissão type_hire
			rename motivodesligamento separation_cause
			
			*Clean wage variable 
			replace wage_avg = subinstr(wage_avg, ",", ".",.)
			destring wage_avg, replace
			
			*Clean sector variable 
			tostring CNAE_95, replace
			
			*Identify involuntary layoffs 
			gen laid_off = 0
			replace laid_off = 1 if separation_cause == 11 | separation_cause == 21 
			
			*Identify new hires or transfers into municipality 
			gen hired = 0
			replace hired = 1 if month_hire > 0 
			
			drop separation_cause month_hire type_hire
			rename munic_resid munic_code 
			order munic_code CNAE_95 wage_avg hired laid_off 
			gen job_id = 1
		
			*Classify workers into sectors based on CNAE_95 
			sort CNAE_95
			rename CNAE_95 cnae1
			
			*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae1)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae1) if CNAE_code_length == 4
			replace cnae1 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
			*Classify sectors 
				gen sector1 = ""
				replace sector1 = "A" if inlist(substr(cnae1, 1, 2), "01", "02")
				replace sector1 = "B" if inlist(substr(cnae1, 1, 2), "05")
				replace sector1 = "C" if inlist(substr(cnae1, 1, 2), "10", "11", "13", "14")
				replace sector1 = "D" if inlist(substr(cnae1, 1, 2), "15", "16", "17", "18", "19", "20", "21", "22", "23") | ///
										 inlist(substr(cnae1, 1, 2), "24", "25", "26", "27", "28", "29", "30", "31", "32") | ///
										 inlist(substr(cnae1, 1, 2), "33", "34", "35", "36", "37")
				replace sector1 = "E" if inlist(substr(cnae1, 1, 2), "40", "41")
				replace sector1 = "F" if inlist(substr(cnae1, 1, 2), "45")
				replace sector1 = "G" if inlist(substr(cnae1, 1, 2), "50", "51", "52")
				replace sector1 = "H" if inlist(substr(cnae1, 1, 2), "55")
				replace sector1 = "I" if inlist(substr(cnae1, 1, 2), "60", "61", "62", "63", "64")
				replace sector1 = "J" if inlist(substr(cnae1, 1, 2), "65", "66", "67")
				replace sector1 = "K" if inlist(substr(cnae1, 1, 2), "70", "71", "72", "73", "74")
				replace sector1 = "L" if inlist(substr(cnae1, 1, 2), "75")
				replace sector1 = "M" if inlist(substr(cnae1, 1, 2), "80")
				replace sector1 = "N" if inlist(substr(cnae1, 1, 2), "85")
				replace sector1 = "O" if inlist(substr(cnae1, 1, 2), "90", "91", "92", "93")
				replace sector1 = "P" if inlist(substr(cnae1, 1, 2), "95")
				replace sector1 = "Q" if inlist(substr(cnae1, 1, 2), "99")
				la var  sector1 "Economic Sector 1.0 (IBGE)"
				
				la var  cnae1 "CNAE 1.0"
				replace cnae1 = subinstr(cnae1, ".", "", .)
				replace cnae1 = subinstr(cnae1, "-", "", .)
				
				gen 	sector_IBGE = ""
				replace sector_IBGE = "agriculture"											if sector1 == "A"
				replace sector_IBGE = "fishing"												if sector1 == "B"
				replace sector_IBGE = "extractive industry" 								if sector1 == "C"
				replace sector_IBGE = "transformation industry"								if sector1 == "D"
				replace sector_IBGE = "electricity, gas, or water"							if sector1 == "E"
				replace sector_IBGE = "construction"										if sector1 == "F"
				replace sector_IBGE = "retail: vehicles, home objects"						if sector1 == "G"
				replace sector_IBGE = "lodging and food"									if sector1 == "H"
				replace sector_IBGE = "transportation, storage and communication"			if sector1 == "I"
				replace sector_IBGE = "finance"												if sector1 == "J"
				replace sector_IBGE = "real estate"											if sector1 == "K"
				replace sector_IBGE = "public administration, defense, or social security"	if sector1 == "L"
				replace sector_IBGE = "education"											if sector1 == "M"
				replace sector_IBGE = "health or social services"							if sector1 == "N"
				replace sector_IBGE = "other social services"								if sector1 == "O"
				replace sector_IBGE = "domestic services"									if sector1 == "P"
				replace sector_IBGE = "international organizations"							if sector1 == "Q"
				
				drop sector1

					la define la_sector_IBGE	1 "agriculture" ///
										2 "fishing" ///
										3 "extractive industry" ///
										4 "transformation industry" ///
										5 "electricity, gas, or water" ///
										6 "construction" ///
										7 "retail: vehicles, home objects" ///
										8 "transportation, storage and communication" ///
										9 "lodging and food" ///
										10 "information or communication" ///
										11 "finance" ///
										12 "real estate" ///
										13 "clerical, science or technical" ///
										14 "administrative" ///
										15 "public administration, defense, or social security" ///
										16 "education" ///
										17 "health or social services" ///
										18 "arts, culture or sports" ///
										19 "other services" ///
										20 "domestic services" ///
										21 "other social services" ///
										22 "international organizations", ///
				replace
			
				encode sector_IBGE, generate(enc_sector_IBGE) la(la_sector_IBGE)
				drop sector_IBGE
				ren enc_sector_IBGE sector_IBGE
				la var sector_IBGE "Sector (IBGE)"
				
				gen sector = .
				replace sector = 1 if inlist(sector_IBGE, 1, 2)
				replace sector = 2 if inlist(sector_IBGE, 3)
				replace sector = 3 if inlist(sector_IBGE, 4, 5)
				replace sector = 4 if inlist(sector_IBGE, 6)
				replace sector = 5 if inlist(sector_IBGE, 7)
				replace sector = 6 if inlist(sector_IBGE, 8, 9, 10, 11, 12, 13, 14) | ///
									  inlist(sector_IBGE, 16, 17, 18, 19, 20, 21)
				replace sector = 7 if inlist(sector_IBGE, 15)
				replace sector = 8 if inlist(sector_IBGE, 22)
				
				la define la_sector	1 "agriculture" ///
									2 "oil, mining and metals" ///
									3 "manufacturing" ///
									4 "construction" ///
									5 "retail" ///
									6 "other services" ///
									7 "government" ///
									8 "international organizations", ///
					replace
				
				la val sector la_sector
				la var sector "Sector"
			
			
			*Collapse data to municipality level and sum up each sectors total workers, total hires, total layoffs, and avg total wage, hire wage 
			gcollapse (mean) wage_avg (sum) hired laid_off job_id, by(munic_code sector)
			rename hired number_hired 
			rename laid_off number_laid_off
			rename job_id number_employed
			*rename tradeable tradeable_employed
		
		
			sort munic_code sector
			drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen sector_name = ""
			replace sector_name = "_ag" if sector == 1
			replace sector_name = "_extract" if sector == 2
			replace sector_name = "_mfg" if sector == 3
			replace sector_name = "_constr" if sector == 4
			replace sector_name = "_retail" if sector == 5
			replace sector_name = "_otherserv" if sector == 6
			replace sector_name = "_govt" if sector == 7
			drop if sector_name == ""

			
			*Reshape data from long to wide
			drop sector
			reshape wide wage_avg number_hired number_laid_off number_employed, i(munic_code) j(sector_name) string
	
			local vars "number_hired_ag number_laid_off_ag number_employed_ag number_hired_constr number_laid_off_constr number_employed_constr number_hired_extract number_laid_off_extract number_employed_extract number_hired_govt number_laid_off_govt number_employed_govt number_hired_mfg number_laid_off_mfg number_employed_mfg number_hired_otherserv number_laid_off_otherserv number_employed_otherserv number_hired_retail number_laid_off_retail number_employed_retail"
				foreach m of local vars {
					replace `m' = 0 if `m' == .
				
				}
	
	
			*Compute totals by municicpality 
			gen num_hired_tot = number_hired_ag + number_hired_constr + number_hired_extract + number_hired_govt + number_hired_mfg + number_hired_otherserv + number_hired_retail 
			gen num_laid_off_tot = number_laid_off_ag + number_laid_off_constr + number_laid_off_extract + number_laid_off_govt + number_laid_off_mfg + number_laid_off_otherserv + number_laid_off_retail 
			gen num_empl_tot = number_employed_ag + number_employed_constr + number_employed_extract + number_employed_govt + number_employed_mfg + number_employed_otherserv + number_employed_retail 
			
			gen num_hired_trade = number_hired_ag + number_hired_extract + number_hired_mfg  
			gen num_laid_off_trade = number_laid_off_ag  + number_laid_off_extract + number_laid_off_mfg  
			gen num_empl_trade = number_employed_ag + number_employed_extract + number_employed_mfg 
	
		save "`i'`j'_employment_sectors", replace 
	
		}
		
}
	
	
*Repeat for years 2006-2017
local ufs "PR RJ RN RS SC SE SP"
local years "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local ufs {
	
	foreach j of local years {
	
		import delimited "`i'`j'.txt", delimiters(";") clear
	
			*Keep only required variables 
			capture keep cnae20classe mêsadmissão município vlremunmédianom tipoadmissão motivodesligamento
			
			rename cnae20classe CNAE_2
			rename mêsadmissão month_hire
			rename município munic_resid
			rename vlremunmédianom wage_avg
			rename tipoadmissão type_hire
			rename motivodesligamento separation_cause
			
			*Clean wage variable 
			replace wage_avg = subinstr(wage_avg, ",", ".",.)
			destring wage_avg, replace
			
			*Clean sector variable 
			tostring CNAE_2, replace
			
			*Identify involuntary layoffs 
			gen laid_off = 0
			replace laid_off = 1 if separation_cause == 11 | separation_cause == 21 
			
			*Identify new hires or transfers into municipality
			capture drop if month_hire == "{ñ"
			capture drop if month_hire == "   121,9"
			capture destring month_hire, replace
			gen hired = 0
			replace hired = 1 if month_hire > 0 
			
			drop separation_cause month_hire type_hire
			rename munic_resid munic_code 
			order munic_code CNAE_2 wage_avg hired laid_off 
			gen job_id = 1
		
			*Classify workers into sectors based on CNAE_95 
			sort CNAE_2
			rename CNAE_2 cnae2
			
			*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae2)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae2) if CNAE_code_length == 4
			replace cnae2 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
					*Define sectors according to CNAE codes
				gen sector2 = ""
				replace sector2 = "A" if inlist(substr(cnae2, 1, 2), "01", "02", "03")
				replace sector2 = "B" if inlist(substr(cnae2, 1, 2), "05", "06", "07", "08", "09")
				replace sector2 = "C" if inlist(substr(cnae2, 1, 2), "10", "11", "13", "14", "15", "16", "17", "18", "19") | ///
										 inlist(substr(cnae2, 1, 2), "20", "21", "22", "23", "24", "25", "26", "27", "28") | ///
										 inlist(substr(cnae2, 1, 2), "29", "30", "31", "32", "33")
				replace sector2 = "D" if inlist(substr(cnae2, 1, 2), "35")
				replace sector2 = "E" if inlist(substr(cnae2, 1, 2), "36", "37", "38", "39")
				replace sector2 = "F" if inlist(substr(cnae2, 1, 2), "41", "42", "43")
				replace sector2 = "G" if inlist(substr(cnae2, 1, 2), "45", "46", "47")
				replace sector2 = "H" if inlist(substr(cnae2, 1, 2), "49", "50", "51", "52", "53")
				replace sector2 = "I" if inlist(substr(cnae2, 1, 2), "55", "56")
				replace sector2 = "J" if inlist(substr(cnae2, 1, 2), "58", "59", "60", "61", "62", "63")
				replace sector2 = "K" if inlist(substr(cnae2, 1, 2), "64", "65", "66")
				replace sector2 = "L" if inlist(substr(cnae2, 1, 2), "68")
				replace sector2 = "M" if inlist(substr(cnae2, 1, 2), "69", "70", "71", "72", "73", "74", "75")
				replace sector2 = "N" if inlist(substr(cnae2, 1, 2), "77", "78", "79", "80", "81", "82")
				replace sector2 = "O" if inlist(substr(cnae2, 1, 2), "84")
				replace sector2 = "P" if inlist(substr(cnae2, 1, 2), "85")
				replace sector2 = "Q" if inlist(substr(cnae2, 1, 2), "86", "87", "88")
				replace sector2 = "R" if inlist(substr(cnae2, 1, 2), "90", "91", "92", "93")
				replace sector2 = "S" if inlist(substr(cnae2, 1, 2), "94", "95", "96")
				replace sector2 = "T" if inlist(substr(cnae2, 1, 2), "97")
				replace sector2 = "U" if inlist(substr(cnae2, 1, 2), "99")
				la var sector2 "Economic Sector 2.0 (IBGE)"
				
				la var cnae2 "CNAE 2.0"
				replace cnae2 = subinstr(cnae2, ".", "", .)
				replace cnae2 = subinstr(cnae2, "-", "", .)
				
				gen 	sector_IBGE = ""
				replace sector_IBGE = "agriculture" 										if sector2 == "A"
				replace sector_IBGE = "extractive industry"									if sector2 == "B"
				replace sector_IBGE = "transformation industry"								if sector2 == "C"
				replace sector_IBGE = "electricity, gas, or water"							if sector2 == "D"
				replace sector_IBGE = "electricity, gas, or water"							if sector2 == "E"
				replace sector_IBGE = "construction"										if sector2 == "F"
				replace sector_IBGE = "retail: vehicles, home objects"						if sector2 == "G"
				replace sector_IBGE = "transportation, storage and communication"			if sector2 == "H"
				replace sector_IBGE = "lodging and food"									if sector2 == "I"
				replace sector_IBGE = "information or communication"						if sector2 == "J"
				replace sector_IBGE = "finance"												if sector2 == "K"
				replace sector_IBGE = "real estate"											if sector2 == "L"
				replace sector_IBGE = "clerical, science or technical"						if sector2 == "M"
				replace sector_IBGE = "administrative"										if sector2 == "N"
				replace sector_IBGE = "public administration, defense, or social security"	if sector2 == "O"
				replace sector_IBGE = "education"											if sector2 == "P"
				replace sector_IBGE = "health or social services"							if sector2 == "Q"
				replace sector_IBGE = "arts, culture or sports"								if sector2 == "R"
				replace sector_IBGE = "other services"										if sector2 == "S"
				replace sector_IBGE = "domestic services"									if sector2 == "T"
				replace sector_IBGE = "international organizations"							if sector2 == "U"
				
				drop sector2

					la define la_sector_IBGE	1 "agriculture" ///
										2 "fishing" ///
										3 "extractive industry" ///
										4 "transformation industry" ///
										5 "electricity, gas, or water" ///
										6 "construction" ///
										7 "retail: vehicles, home objects" ///
										8 "transportation, storage and communication" ///
										9 "lodging and food" ///
										10 "information or communication" ///
										11 "finance" ///
										12 "real estate" ///
										13 "clerical, science or technical" ///
										14 "administrative" ///
										15 "public administration, defense, or social security" ///
										16 "education" ///
										17 "health or social services" ///
										18 "arts, culture or sports" ///
										19 "other services" ///
										20 "domestic services" ///
										21 "other social services" ///
										22 "international organizations", ///
				replace
			
			encode sector_IBGE, generate(enc_sector_IBGE) la(la_sector_IBGE)
			drop sector_IBGE
			ren enc_sector_IBGE sector_IBGE
			la var sector_IBGE "Sector (IBGE)"
			
			gen sector = .
			replace sector = 1 if inlist(sector_IBGE, 1, 2)
			replace sector = 2 if inlist(sector_IBGE, 3)
			replace sector = 3 if inlist(sector_IBGE, 4, 5)
			replace sector = 4 if inlist(sector_IBGE, 6)
			replace sector = 5 if inlist(sector_IBGE, 7)
			replace sector = 6 if inlist(sector_IBGE, 8, 9, 10, 11, 12, 13, 14) | ///
								  inlist(sector_IBGE, 16, 17, 18, 19, 20, 21)
			replace sector = 7 if inlist(sector_IBGE, 15)
			replace sector = 8 if inlist(sector_IBGE, 22)
			
			la define la_sector	1 "agriculture" ///
								2 "oil, mining and metals" ///
								3 "manufacturing" ///
								4 "construction" ///
								5 "retail" ///
								6 "other services" ///
								7 "government" ///
								8 "international organizations", ///
				replace
			
			la val sector la_sector
			la var sector "Sector"
			
			*Change munic_code to numeric if necessary 
			capture destring munic_code, replace
			

			*Collapse data to municipality level and sum up each sectors total workers, total hires, total layoffs, and avg total wage, hire wage 
			gcollapse (mean) wage_avg (sum) hired laid_off job_id, by(munic_code sector)
			rename hired number_hired 
			rename laid_off number_laid_off
			rename job_id number_employed
			*rename tradeable tradeable_employed
		
		
			sort munic_code sector
			drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen sector_name = ""
			replace sector_name = "_ag" if sector == 1
			replace sector_name = "_extract" if sector == 2
			replace sector_name = "_mfg" if sector == 3
			replace sector_name = "_constr" if sector == 4
			replace sector_name = "_retail" if sector == 5
			replace sector_name = "_otherserv" if sector == 6
			replace sector_name = "_govt" if sector == 7
			drop if sector_name == ""

			
			*Reshape data from long to wide
			drop sector
			drop if sector_name == ""
			reshape wide wage_avg number_hired number_laid_off number_employed, i(munic_code) j(sector_name) string
	
			local vars "number_hired_ag number_laid_off_ag number_employed_ag number_hired_constr number_laid_off_constr number_employed_constr number_hired_extract number_laid_off_extract number_employed_extract number_hired_govt number_laid_off_govt number_employed_govt number_hired_mfg number_laid_off_mfg number_employed_mfg number_hired_otherserv number_laid_off_otherserv number_employed_otherserv number_hired_retail number_laid_off_retail number_employed_retail"
				foreach m of local vars {
					replace `m' = 0 if `m' == .
				
				}
	
	
			*Compute totals by municicpality 
			gen num_hired_tot = number_hired_ag + number_hired_constr + number_hired_extract + number_hired_govt + number_hired_mfg + number_hired_otherserv + number_hired_retail 
			gen num_laid_off_tot = number_laid_off_ag + number_laid_off_constr + number_laid_off_extract + number_laid_off_govt + number_laid_off_mfg + number_laid_off_otherserv + number_laid_off_retail 
			gen num_empl_tot = number_employed_ag + number_employed_constr + number_employed_extract + number_employed_govt + number_employed_mfg + number_employed_otherserv + number_employed_retail 
			
			gen num_hired_trade = number_hired_ag + number_hired_extract + number_hired_mfg  
			gen num_laid_off_trade = number_laid_off_ag  + number_laid_off_extract + number_laid_off_mfg  
			gen num_empl_trade = number_employed_ag + number_employed_extract + number_employed_mfg 
			
		order munic_code year 
	
		save "`i'`j'_employment_sectors", replace 
	
		}
		
}
	
	
	
**************************************************************************************
*Now repeat loops for oil_linked employment data (2000-2005)
	
local ufs "AL AP BA CE ES MA PA PB PE PI PR RJ RN RS SC SE SP"
local years "2000 2001 2002 2003 2004 2005"
foreach i of local ufs {
	
	foreach j of local years {
	
		import delimited "`i'`j'.txt", delimiters(";") clear	
		
			*Keep only required variables 
			capture keep cnae95classe mêsadmissão município vlremunmédianom tipoadmissão motivodesligamento
			
			rename cnae95classe CNAE_95
			rename mêsadmissão month_hire
			rename município munic_resid
			rename vlremunmédianom wage_avg
			rename tipoadmissão type_hire
			rename motivodesligamento separation_cause
			
			*Clean wage variable 
			replace wage_avg = subinstr(wage_avg, ",", ".",.)
			destring wage_avg, replace
			
			*Clean sector variable 
			tostring CNAE_95, replace
			
			*Identify involuntary layoffs 
			gen laid_off = 0
			replace laid_off = 1 if separation_cause == 11 | separation_cause == 21 
			
			*Identify new hires or transfers into municipality 
			gen hired = 0
			replace hired = 1 if month_hire > 0 
			
			drop separation_cause month_hire type_hire
			rename munic_resid munic_code 
			order munic_code CNAE_95 wage_avg hired laid_off 
			gen job_id = 1
		
			*Classify workers into sectors based on CNAE_95 
			sort CNAE_95
			rename CNAE_95 cnae1
			
			*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae1)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae1) if CNAE_code_length == 4
			replace cnae1 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
			
			*Merge in oil-linked codes
			merge m:1 cnae1 using "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE1_short"
			replace oil_linked_CNAE1 = 0 if oil_linked_CNAE1 == .
			drop _merge
	
			*Rename oil linked to make compatible with later years 
			rename oil_linked_CNAE1 oil_linked 

			*Collapse data to municipality level and sum up each sectors total workers, total hires, total layoffs, and avg total wage, hire wage 
			gcollapse (mean) wage_avg (sum) hired laid_off job_id, by(munic_code oil_linked)
			rename hired number_hired 
			rename laid_off number_laid_off
			rename job_id number_employed
		
		
			sort munic_code oil_linked
			drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen oil_name = ""
			drop if oil_name != "_oil"

			*Reshape data from long to wide
			drop oil_linked
			reshape wide wage_avg number_hired number_laid_off number_employed, i(munic_code) j(oil_name) string
	
		save "`i'`j'_employment_oil", replace 
	
		}
		
}
	
	
*Repeat for oil-linked for years 2006-2017
local ufs "PR RJ RN RS SC SE SP"
local years "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local ufs {
	
	foreach j of local years {
	
		import delimited "`i'`j'.txt", delimiters(";") clear	
		
			*Keep only required variables 
			capture keep cnae20classe mêsadmissão município vlremunmédianom tipoadmissão motivodesligamento
			
			rename cnae20classe CNAE_2
			rename mêsadmissão month_hire
			rename município munic_resid
			rename vlremunmédianom wage_avg
			rename tipoadmissão type_hire
			rename motivodesligamento separation_cause
			
			*Clean wage variable 
			replace wage_avg = subinstr(wage_avg, ",", ".",.)
			destring wage_avg, replace
			
			*Clean sector variable 
			tostring CNAE_2, replace
			
			*Change munic_code to numeric if necessary 
			capture destring munic_code, replace
			
			*Identify involuntary layoffs 
			gen laid_off = 0
			replace laid_off = 1 if separation_cause == 11 | separation_cause == 21 
			
			*Identify new hires or transfers into municipality 
			capture drop if month_hire == "{ñ"
			capture drop if month_hire == "   121,9"
			capture destring month_hire, replace
			gen hired = 0
			replace hired = 1 if month_hire > 0 
			
			drop separation_cause month_hire type_hire
			rename munic_resid munic_code 
			order munic_code CNAE_2 wage_avg hired laid_off 
			gen job_id = 1
		
			*Classify workers into sectors based on CNAE_95 
			sort CNAE_2
			rename CNAE_2 cnae2
			
			*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae2)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae2) if CNAE_code_length == 4
			replace cnae2 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
			*Merge in oil-linked codes
			merge m:1 cnae2 using "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE2_short"
			replace oil_linked_CNAE2 = 0 if oil_linked_CNAE2 == .
			drop _merge
	
			*Rename oil linked to make compatible with later years 
			rename oil_linked_CNAE2 oil_linked 
			
			capture destring munic_code, replace 

			*Collapse data to municipality level and sum up each sectors total workers, total hires, total layoffs, and avg total wage, hire wage 
			gcollapse (mean) wage_avg (sum) hired laid_off job_id, by(munic_code oil_linked)
			rename hired number_hired 
			rename laid_off number_laid_off
			rename job_id number_employed
		
		
			sort munic_code oil_linked
			drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen oil_name = ""
			replace oil_name = "_oil" if oil_linked == 1
			drop if oil_name != "_oil"

			*Reshape data from long to wide
			drop oil_linked
			reshape wide wage_avg number_hired number_laid_off number_employed, i(munic_code) j(oil_name) string
	
		save "`i'`j'_employment_oil", replace 
	
		}
		
}
	
********************************************************************************
*This concludes loops for employment for all states and years.
*Now append files into country-level panel 

*Define locals for all UF initials and years, and then loop over these locals to append all
*files into single file of municipal-level RAIS panel data
use "AL2000_employment_sectors.dta", clear
local ufs "AL AP BA CE ES MA PA PB PE PI PR RJ RN RS SC SE SP"
local anos "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local ufs{
	
	foreach j of local anos {
		append using "`i'`j'_employment_sectors.dta", force
	}
}
duplicates drop 

order munic_code year 
sort munic_code year

save "Munic_Employment_bySector_Panel", replace 

*Repeat to append oil_linked 
use "AL2000_employment_oil.dta", clear
local ufs "AL AP BA CE ES MA PA PB PE PI PR RJ RN RS SC SE SP"
local anos "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local ufs{
	
	foreach j of local anos {
		append using "`i'`j'_employment_oil.dta", force
	}
}
duplicates drop 

order munic_code year 
sort munic_code year
	
save "Munic_Employment_OilLinked_Panel", replace 

*Now merge oil and other sectors panels together on munic_code and year 
use "Munic_Employment_bySector_Panel", clear 

merge 1:1 munic_code year using "Munic_Employment_OilLinked_Panel"

replace number_hired_oil = 0 if _merge == 1
replace number_laid_off_oil = 0 if _merge == 1
replace number_employed_oil = 0 if _merge == 1

drop _merge 

*Compute net hires each year (hires - layoffs)
local sectors "ag constr extract govt mfg otherserv retail oil"
foreach m of local sectors {
gen nethire_`m' = number_hired_`m' - number_laid_off_`m'
}

gen nethire_tot = num_hired_tot - num_laid_off_tot
gen nethire_trade = num_hired_trade - num_laid_off_trade
	
*Save final municipality panel with individual data 
save "Munic_Employment_Panel", replace 


*********************************************************************************
*********************************************************************************
*Now import and process firm-level data. 
*Goals: net entries and number of firms by sector, total, and oil-linked. 


local years "2000 2001"
foreach j of local years {
	
		import delimited "ESTB`j'.txt", delimiters(";") clear
		
		capture keep clascnae95 municipio tamestab
		
		rename clascnae95 cnae1
		rename municipio munic_code
		rename tamestab firm_size
		
		*First add zero to agriculture codes 
			capture tostring cnae1, replace
			gen CNAE_code_length = strlen(cnae1)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae1) if CNAE_code_length == 4
			replace cnae1 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
			*Classify sectors 
				gen sector1 = ""
				replace sector1 = "A" if inlist(substr(cnae1, 1, 2), "01", "02")
				replace sector1 = "B" if inlist(substr(cnae1, 1, 2), "05")
				replace sector1 = "C" if inlist(substr(cnae1, 1, 2), "10", "11", "13", "14")
				replace sector1 = "D" if inlist(substr(cnae1, 1, 2), "15", "16", "17", "18", "19", "20", "21", "22", "23") | ///
										 inlist(substr(cnae1, 1, 2), "24", "25", "26", "27", "28", "29", "30", "31", "32") | ///
										 inlist(substr(cnae1, 1, 2), "33", "34", "35", "36", "37")
				replace sector1 = "E" if inlist(substr(cnae1, 1, 2), "40", "41")
				replace sector1 = "F" if inlist(substr(cnae1, 1, 2), "45")
				replace sector1 = "G" if inlist(substr(cnae1, 1, 2), "50", "51", "52")
				replace sector1 = "H" if inlist(substr(cnae1, 1, 2), "55")
				replace sector1 = "I" if inlist(substr(cnae1, 1, 2), "60", "61", "62", "63", "64")
				replace sector1 = "J" if inlist(substr(cnae1, 1, 2), "65", "66", "67")
				replace sector1 = "K" if inlist(substr(cnae1, 1, 2), "70", "71", "72", "73", "74")
				replace sector1 = "L" if inlist(substr(cnae1, 1, 2), "75")
				replace sector1 = "M" if inlist(substr(cnae1, 1, 2), "80")
				replace sector1 = "N" if inlist(substr(cnae1, 1, 2), "85")
				replace sector1 = "O" if inlist(substr(cnae1, 1, 2), "90", "91", "92", "93")
				replace sector1 = "P" if inlist(substr(cnae1, 1, 2), "95")
				replace sector1 = "Q" if inlist(substr(cnae1, 1, 2), "99")
				la var  sector1 "Economic Sector 1.0 (IBGE)"
				
				la var  cnae1 "CNAE 1.0"
				replace cnae1 = subinstr(cnae1, ".", "", .)
				replace cnae1 = subinstr(cnae1, "-", "", .)
				
				gen 	sector_IBGE = ""
				replace sector_IBGE = "agriculture"											if sector1 == "A"
				replace sector_IBGE = "fishing"												if sector1 == "B"
				replace sector_IBGE = "extractive industry" 								if sector1 == "C"
				replace sector_IBGE = "transformation industry"								if sector1 == "D"
				replace sector_IBGE = "electricity, gas, or water"							if sector1 == "E"
				replace sector_IBGE = "construction"										if sector1 == "F"
				replace sector_IBGE = "retail: vehicles, home objects"						if sector1 == "G"
				replace sector_IBGE = "lodging and food"									if sector1 == "H"
				replace sector_IBGE = "transportation, storage and communication"			if sector1 == "I"
				replace sector_IBGE = "finance"												if sector1 == "J"
				replace sector_IBGE = "real estate"											if sector1 == "K"
				replace sector_IBGE = "public administration, defense, or social security"	if sector1 == "L"
				replace sector_IBGE = "education"											if sector1 == "M"
				replace sector_IBGE = "health or social services"							if sector1 == "N"
				replace sector_IBGE = "other social services"								if sector1 == "O"
				replace sector_IBGE = "domestic services"									if sector1 == "P"
				replace sector_IBGE = "international organizations"							if sector1 == "Q"
				
				drop sector1

					la define la_sector_IBGE	1 "agriculture" ///
										2 "fishing" ///
										3 "extractive industry" ///
										4 "transformation industry" ///
										5 "electricity, gas, or water" ///
										6 "construction" ///
										7 "retail: vehicles, home objects" ///
										8 "transportation, storage and communication" ///
										9 "lodging and food" ///
										10 "information or communication" ///
										11 "finance" ///
										12 "real estate" ///
										13 "clerical, science or technical" ///
										14 "administrative" ///
										15 "public administration, defense, or social security" ///
										16 "education" ///
										17 "health or social services" ///
										18 "arts, culture or sports" ///
										19 "other services" ///
										20 "domestic services" ///
										21 "other social services" ///
										22 "international organizations", ///
				replace
			
				encode sector_IBGE, generate(enc_sector_IBGE) la(la_sector_IBGE)
				drop sector_IBGE
				ren enc_sector_IBGE sector_IBGE
				la var sector_IBGE "Sector (IBGE)"
				
				gen sector = .
				replace sector = 1 if inlist(sector_IBGE, 1, 2)
				replace sector = 2 if inlist(sector_IBGE, 3)
				replace sector = 3 if inlist(sector_IBGE, 4, 5)
				replace sector = 4 if inlist(sector_IBGE, 6)
				replace sector = 5 if inlist(sector_IBGE, 7)
				replace sector = 6 if inlist(sector_IBGE, 8, 9, 10, 11, 12, 13, 14) | ///
									  inlist(sector_IBGE, 16, 17, 18, 19, 20, 21)
				replace sector = 7 if inlist(sector_IBGE, 15)
				replace sector = 8 if inlist(sector_IBGE, 22)
				
				la define la_sector	1 "agriculture" ///
									2 "oil, mining and metals" ///
									3 "manufacturing" ///
									4 "construction" ///
									5 "retail" ///
									6 "other services" ///
									7 "government" ///
									8 "international organizations", ///
					replace
				
				la val sector la_sector
				la var sector "Sector"
		
		
		*Generate indicator for non-micro firm 
		gen nonmicro = 0
		replace nonmicro = 1 if firm_size > 1
		
		gen firm_indicator = 1 
		
		
		*Collapse to municipality-sector level 
		gcollapse (sum) firm_indicator nonmicro, by(munic_code sector)
		rename firm_indicator num_firms
		rename nonmicro num_firms_nonmicro
		
		sort munic_code sector
		drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen sector_name = ""
			replace sector_name = "_ag" if sector == 1
			replace sector_name = "_extract" if sector == 2
			replace sector_name = "_mfg" if sector == 3
			replace sector_name = "_constr" if sector == 4
			replace sector_name = "_retail" if sector == 5
			replace sector_name = "_otherserv" if sector == 6
			replace sector_name = "_govt" if sector == 7
			drop if sector_name == ""

			
			*Reshape data from long to wide
			drop sector
			reshape wide num_firms num_firms_nonmicro, i(munic_code) j(sector_name) string
			
			*Replace missings with zeros
			local vars "num_firms_ag num_firms_nonmicro_ag num_firms_constr num_firms_nonmicro_constr num_firms_extract num_firms_nonmicro_extract num_firms_govt num_firms_nonmicro_govt 	num_firms_mfg num_firms_nonmicro_mfg num_firms_otherserv num_firms_nonmicro_otherserv num_firms_retail num_firms_nonmicro_retail"
				foreach m of local vars {
					replace `m' = 0 if `m' == .
				
				}
				
				
			*Compute totals by municicpality 
			gen num_firms_tot = num_firms_ag + num_firms_constr + num_firms_extract + num_firms_govt + num_firms_mfg + num_firms_otherserv + num_firms_retail 
			gen num_firms_nonmicro_tot = num_firms_nonmicro_ag + num_firms_nonmicro_constr + num_firms_nonmicro_extract + num_firms_nonmicro_govt + num_firms_nonmicro_mfg + num_firms_nonmicro_otherserv + num_firms_nonmicro_retail 
			
			gen num_firms_trade = num_firms_ag + num_firms_extract + num_firms_mfg  
			gen num_firms_nonmicro_trade = num_firms_nonmicro_ag  + num_firms_nonmicro_extract + num_firms_nonmicro_mfg  
			
			save "Firms_Sectors_`j'", replace 

	
	}
	

*Repeat for years 2002-2005
local years "2004 2005"
foreach j of local years {
	
		import delimited "ESTB`j'.txt", delimiters(";") clear
		
		capture keep cnae95classe município tamanhoestabelecimento
		
		rename cnae95classe cnae1
		rename município munic_code
		rename tamanhoestabelecimento firm_size
		
		capture tostring cnae1, replace 
		
		*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae1)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae1) if CNAE_code_length == 4
			replace cnae1 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
			*Classify sectors 
				gen sector1 = ""
				replace sector1 = "A" if inlist(substr(cnae1, 1, 2), "01", "02")
				replace sector1 = "B" if inlist(substr(cnae1, 1, 2), "05")
				replace sector1 = "C" if inlist(substr(cnae1, 1, 2), "10", "11", "13", "14")
				replace sector1 = "D" if inlist(substr(cnae1, 1, 2), "15", "16", "17", "18", "19", "20", "21", "22", "23") | ///
										 inlist(substr(cnae1, 1, 2), "24", "25", "26", "27", "28", "29", "30", "31", "32") | ///
										 inlist(substr(cnae1, 1, 2), "33", "34", "35", "36", "37")
				replace sector1 = "E" if inlist(substr(cnae1, 1, 2), "40", "41")
				replace sector1 = "F" if inlist(substr(cnae1, 1, 2), "45")
				replace sector1 = "G" if inlist(substr(cnae1, 1, 2), "50", "51", "52")
				replace sector1 = "H" if inlist(substr(cnae1, 1, 2), "55")
				replace sector1 = "I" if inlist(substr(cnae1, 1, 2), "60", "61", "62", "63", "64")
				replace sector1 = "J" if inlist(substr(cnae1, 1, 2), "65", "66", "67")
				replace sector1 = "K" if inlist(substr(cnae1, 1, 2), "70", "71", "72", "73", "74")
				replace sector1 = "L" if inlist(substr(cnae1, 1, 2), "75")
				replace sector1 = "M" if inlist(substr(cnae1, 1, 2), "80")
				replace sector1 = "N" if inlist(substr(cnae1, 1, 2), "85")
				replace sector1 = "O" if inlist(substr(cnae1, 1, 2), "90", "91", "92", "93")
				replace sector1 = "P" if inlist(substr(cnae1, 1, 2), "95")
				replace sector1 = "Q" if inlist(substr(cnae1, 1, 2), "99")
				la var  sector1 "Economic Sector 1.0 (IBGE)"
				
				la var  cnae1 "CNAE 1.0"
				replace cnae1 = subinstr(cnae1, ".", "", .)
				replace cnae1 = subinstr(cnae1, "-", "", .)
				
				gen 	sector_IBGE = ""
				replace sector_IBGE = "agriculture"											if sector1 == "A"
				replace sector_IBGE = "fishing"												if sector1 == "B"
				replace sector_IBGE = "extractive industry" 								if sector1 == "C"
				replace sector_IBGE = "transformation industry"								if sector1 == "D"
				replace sector_IBGE = "electricity, gas, or water"							if sector1 == "E"
				replace sector_IBGE = "construction"										if sector1 == "F"
				replace sector_IBGE = "retail: vehicles, home objects"						if sector1 == "G"
				replace sector_IBGE = "lodging and food"									if sector1 == "H"
				replace sector_IBGE = "transportation, storage and communication"			if sector1 == "I"
				replace sector_IBGE = "finance"												if sector1 == "J"
				replace sector_IBGE = "real estate"											if sector1 == "K"
				replace sector_IBGE = "public administration, defense, or social security"	if sector1 == "L"
				replace sector_IBGE = "education"											if sector1 == "M"
				replace sector_IBGE = "health or social services"							if sector1 == "N"
				replace sector_IBGE = "other social services"								if sector1 == "O"
				replace sector_IBGE = "domestic services"									if sector1 == "P"
				replace sector_IBGE = "international organizations"							if sector1 == "Q"
				
				drop sector1

					la define la_sector_IBGE	1 "agriculture" ///
										2 "fishing" ///
										3 "extractive industry" ///
										4 "transformation industry" ///
										5 "electricity, gas, or water" ///
										6 "construction" ///
										7 "retail: vehicles, home objects" ///
										8 "transportation, storage and communication" ///
										9 "lodging and food" ///
										10 "information or communication" ///
										11 "finance" ///
										12 "real estate" ///
										13 "clerical, science or technical" ///
										14 "administrative" ///
										15 "public administration, defense, or social security" ///
										16 "education" ///
										17 "health or social services" ///
										18 "arts, culture or sports" ///
										19 "other services" ///
										20 "domestic services" ///
										21 "other social services" ///
										22 "international organizations", ///
				replace
			
				encode sector_IBGE, generate(enc_sector_IBGE) la(la_sector_IBGE)
				drop sector_IBGE
				ren enc_sector_IBGE sector_IBGE
				la var sector_IBGE "Sector (IBGE)"
				
				gen sector = .
				replace sector = 1 if inlist(sector_IBGE, 1, 2)
				replace sector = 2 if inlist(sector_IBGE, 3)
				replace sector = 3 if inlist(sector_IBGE, 4, 5)
				replace sector = 4 if inlist(sector_IBGE, 6)
				replace sector = 5 if inlist(sector_IBGE, 7)
				replace sector = 6 if inlist(sector_IBGE, 8, 9, 10, 11, 12, 13, 14) | ///
									  inlist(sector_IBGE, 16, 17, 18, 19, 20, 21)
				replace sector = 7 if inlist(sector_IBGE, 15)
				replace sector = 8 if inlist(sector_IBGE, 22)
				
				la define la_sector	1 "agriculture" ///
									2 "oil, mining and metals" ///
									3 "manufacturing" ///
									4 "construction" ///
									5 "retail" ///
									6 "other services" ///
									7 "government" ///
									8 "international organizations", ///
					replace
				
				la val sector la_sector
				la var sector "Sector"
		
		
		*Generate indicator for non-micro firm 
		gen nonmicro = 0
		replace nonmicro = 1 if firm_size > 1
		
		gen firm_indicator = 1 
		
		
		*Collapse to municipality-sector level 
		gcollapse (sum) firm_indicator nonmicro, by(munic_code sector)
		rename firm_indicator num_firms
		rename nonmicro num_firms_nonmicro
		
		sort munic_code sector
		drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen sector_name = ""
			replace sector_name = "_ag" if sector == 1
			replace sector_name = "_extract" if sector == 2
			replace sector_name = "_mfg" if sector == 3
			replace sector_name = "_constr" if sector == 4
			replace sector_name = "_retail" if sector == 5
			replace sector_name = "_otherserv" if sector == 6
			replace sector_name = "_govt" if sector == 7
			drop if sector_name == ""

			
			*Reshape data from long to wide
			drop sector
			reshape wide num_firms num_firms_nonmicro, i(munic_code) j(sector_name) string
			
			*Replace missings with zeros
			local vars "num_firms_ag num_firms_nonmicro_ag num_firms_constr num_firms_nonmicro_constr num_firms_extract num_firms_nonmicro_extract num_firms_govt num_firms_nonmicro_govt 	num_firms_mfg num_firms_nonmicro_mfg num_firms_otherserv num_firms_nonmicro_otherserv num_firms_retail num_firms_nonmicro_retail"
				foreach m of local vars {
					replace `m' = 0 if `m' == .
				
				}
				
				
			*Compute totals by municicpality 
			gen num_firms_tot = num_firms_ag + num_firms_constr + num_firms_extract + num_firms_govt + num_firms_mfg + num_firms_otherserv + num_firms_retail 
			gen num_firms_nonmicro_tot = num_firms_nonmicro_ag + num_firms_nonmicro_constr + num_firms_nonmicro_extract + num_firms_nonmicro_govt + num_firms_nonmicro_mfg + num_firms_nonmicro_otherserv + num_firms_nonmicro_retail 
			
			gen num_firms_trade = num_firms_ag + num_firms_extract + num_firms_mfg  
			gen num_firms_nonmicro_trade = num_firms_nonmicro_ag  + num_firms_nonmicro_extract + num_firms_nonmicro_mfg  
			
			save "Firms_Sectors_`j'", replace 

	
	}
	



*Repeat with years 2006-2017 (CNAE2)
local years "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach j of local years {
	
		import delimited "ESTB`j'.txt", delimiters(";") clear
		
		capture keep cnae20classe município tamanhoestabelecimento
		
		rename cnae20classe cnae2
		rename município munic_code
		rename tamanhoestabelecimento firm_size
		
		*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae2)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae2) if CNAE_code_length == 4
			replace cnae2 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
					*Define sectors according to CNAE codes
				gen sector2 = ""
				replace sector2 = "A" if inlist(substr(cnae2, 1, 2), "01", "02", "03")
				replace sector2 = "B" if inlist(substr(cnae2, 1, 2), "05", "06", "07", "08", "09")
				replace sector2 = "C" if inlist(substr(cnae2, 1, 2), "10", "11", "13", "14", "15", "16", "17", "18", "19") | ///
										 inlist(substr(cnae2, 1, 2), "20", "21", "22", "23", "24", "25", "26", "27", "28") | ///
										 inlist(substr(cnae2, 1, 2), "29", "30", "31", "32", "33")
				replace sector2 = "D" if inlist(substr(cnae2, 1, 2), "35")
				replace sector2 = "E" if inlist(substr(cnae2, 1, 2), "36", "37", "38", "39")
				replace sector2 = "F" if inlist(substr(cnae2, 1, 2), "41", "42", "43")
				replace sector2 = "G" if inlist(substr(cnae2, 1, 2), "45", "46", "47")
				replace sector2 = "H" if inlist(substr(cnae2, 1, 2), "49", "50", "51", "52", "53")
				replace sector2 = "I" if inlist(substr(cnae2, 1, 2), "55", "56")
				replace sector2 = "J" if inlist(substr(cnae2, 1, 2), "58", "59", "60", "61", "62", "63")
				replace sector2 = "K" if inlist(substr(cnae2, 1, 2), "64", "65", "66")
				replace sector2 = "L" if inlist(substr(cnae2, 1, 2), "68")
				replace sector2 = "M" if inlist(substr(cnae2, 1, 2), "69", "70", "71", "72", "73", "74", "75")
				replace sector2 = "N" if inlist(substr(cnae2, 1, 2), "77", "78", "79", "80", "81", "82")
				replace sector2 = "O" if inlist(substr(cnae2, 1, 2), "84")
				replace sector2 = "P" if inlist(substr(cnae2, 1, 2), "85")
				replace sector2 = "Q" if inlist(substr(cnae2, 1, 2), "86", "87", "88")
				replace sector2 = "R" if inlist(substr(cnae2, 1, 2), "90", "91", "92", "93")
				replace sector2 = "S" if inlist(substr(cnae2, 1, 2), "94", "95", "96")
				replace sector2 = "T" if inlist(substr(cnae2, 1, 2), "97")
				replace sector2 = "U" if inlist(substr(cnae2, 1, 2), "99")
				la var sector2 "Economic Sector 2.0 (IBGE)"
				
				la var cnae2 "CNAE 2.0"
				replace cnae2 = subinstr(cnae2, ".", "", .)
				replace cnae2 = subinstr(cnae2, "-", "", .)
				
				gen 	sector_IBGE = ""
				replace sector_IBGE = "agriculture" 										if sector2 == "A"
				replace sector_IBGE = "extractive industry"									if sector2 == "B"
				replace sector_IBGE = "transformation industry"								if sector2 == "C"
				replace sector_IBGE = "electricity, gas, or water"							if sector2 == "D"
				replace sector_IBGE = "electricity, gas, or water"							if sector2 == "E"
				replace sector_IBGE = "construction"										if sector2 == "F"
				replace sector_IBGE = "retail: vehicles, home objects"						if sector2 == "G"
				replace sector_IBGE = "transportation, storage and communication"			if sector2 == "H"
				replace sector_IBGE = "lodging and food"									if sector2 == "I"
				replace sector_IBGE = "information or communication"						if sector2 == "J"
				replace sector_IBGE = "finance"												if sector2 == "K"
				replace sector_IBGE = "real estate"											if sector2 == "L"
				replace sector_IBGE = "clerical, science or technical"						if sector2 == "M"
				replace sector_IBGE = "administrative"										if sector2 == "N"
				replace sector_IBGE = "public administration, defense, or social security"	if sector2 == "O"
				replace sector_IBGE = "education"											if sector2 == "P"
				replace sector_IBGE = "health or social services"							if sector2 == "Q"
				replace sector_IBGE = "arts, culture or sports"								if sector2 == "R"
				replace sector_IBGE = "other services"										if sector2 == "S"
				replace sector_IBGE = "domestic services"									if sector2 == "T"
				replace sector_IBGE = "international organizations"							if sector2 == "U"
				
				drop sector2

					la define la_sector_IBGE	1 "agriculture" ///
										2 "fishing" ///
										3 "extractive industry" ///
										4 "transformation industry" ///
										5 "electricity, gas, or water" ///
										6 "construction" ///
										7 "retail: vehicles, home objects" ///
										8 "transportation, storage and communication" ///
										9 "lodging and food" ///
										10 "information or communication" ///
										11 "finance" ///
										12 "real estate" ///
										13 "clerical, science or technical" ///
										14 "administrative" ///
										15 "public administration, defense, or social security" ///
										16 "education" ///
										17 "health or social services" ///
										18 "arts, culture or sports" ///
										19 "other services" ///
										20 "domestic services" ///
										21 "other social services" ///
										22 "international organizations", ///
				replace
			
			encode sector_IBGE, generate(enc_sector_IBGE) la(la_sector_IBGE)
			drop sector_IBGE
			ren enc_sector_IBGE sector_IBGE
			la var sector_IBGE "Sector (IBGE)"
			
			gen sector = .
			replace sector = 1 if inlist(sector_IBGE, 1, 2)
			replace sector = 2 if inlist(sector_IBGE, 3)
			replace sector = 3 if inlist(sector_IBGE, 4, 5)
			replace sector = 4 if inlist(sector_IBGE, 6)
			replace sector = 5 if inlist(sector_IBGE, 7)
			replace sector = 6 if inlist(sector_IBGE, 8, 9, 10, 11, 12, 13, 14) | ///
								  inlist(sector_IBGE, 16, 17, 18, 19, 20, 21)
			replace sector = 7 if inlist(sector_IBGE, 15)
			replace sector = 8 if inlist(sector_IBGE, 22)
			
			la define la_sector	1 "agriculture" ///
								2 "oil, mining and metals" ///
								3 "manufacturing" ///
								4 "construction" ///
								5 "retail" ///
								6 "other services" ///
								7 "government" ///
								8 "international organizations", ///
				replace
			
			la val sector la_sector
			la var sector "Sector"
		
		
		*Generate indicator for non-micro firm 
		gen nonmicro = 0
		replace nonmicro = 1 if firm_size > 1
		
		gen firm_indicator = 1 
		
		capture destring munic_code, replace 
		
		*Collapse to municipality-sector level 
		gcollapse (sum) firm_indicator nonmicro, by(munic_code sector)
		rename firm_indicator num_firms
		rename nonmicro num_firms_nonmicro
		
		sort munic_code sector
		drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen sector_name = ""
			replace sector_name = "_ag" if sector == 1
			replace sector_name = "_extract" if sector == 2
			replace sector_name = "_mfg" if sector == 3
			replace sector_name = "_constr" if sector == 4
			replace sector_name = "_retail" if sector == 5
			replace sector_name = "_otherserv" if sector == 6
			replace sector_name = "_govt" if sector == 7
			drop if sector_name == ""

			
			*Reshape data from long to wide
			drop sector
			reshape wide num_firms num_firms_nonmicro, i(munic_code) j(sector_name) string
			
			*Replace missings with zeros
			local vars "num_firms_ag num_firms_nonmicro_ag num_firms_constr num_firms_nonmicro_constr num_firms_extract num_firms_nonmicro_extract num_firms_govt num_firms_nonmicro_govt 	num_firms_mfg num_firms_nonmicro_mfg num_firms_otherserv num_firms_nonmicro_otherserv num_firms_retail num_firms_nonmicro_retail"
				foreach m of local vars {
					replace `m' = 0 if `m' == .
				
				}
				
				
			*Compute totals by municicpality 
			gen num_firms_tot = num_firms_ag + num_firms_constr + num_firms_extract + num_firms_govt + num_firms_mfg + num_firms_otherserv + num_firms_retail 
			gen num_firms_nonmicro_tot = num_firms_nonmicro_ag + num_firms_nonmicro_constr + num_firms_nonmicro_extract + num_firms_nonmicro_govt + num_firms_nonmicro_mfg + num_firms_nonmicro_otherserv + num_firms_nonmicro_retail 
			
			gen num_firms_trade = num_firms_ag + num_firms_extract + num_firms_mfg  
			gen num_firms_nonmicro_trade = num_firms_nonmicro_ag  + num_firms_nonmicro_extract + num_firms_nonmicro_mfg  
			
			save "Firms_Sectors_`j'", replace 

	}
	
	
********************************************************************************
*******************************************************************************
*Repeat with oil-linked rather than sectors 
*First, years 2000, 2001
local years "2000 2001"
foreach j of local years {
	
		import delimited "ESTB`j'.txt", delimiters(";") clear
		
		capture keep clascnae95 municipio tamestab
		
		rename clascnae95 cnae1
		rename municipio munic_code
		rename tamestab firm_size
		
			*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae1)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae1) if CNAE_code_length == 4
			replace cnae1 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
			
			*Merge in oil-linked codes
			merge m:1 cnae1 using "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE1_short"
			replace oil_linked_CNAE1 = 0 if oil_linked_CNAE1 == .
			drop _merge
	
			*Rename oil linked to make compatible with later years 
			rename oil_linked_CNAE1 oil_linked 
		
		
		*Generate indicator for non-micro firm 
		gen nonmicro = 0
		replace nonmicro = 1 if firm_size > 1
		
		gen firm_indicator = 1 
		
		
		*Collapse to municipality-sector level 
		gcollapse (sum) firm_indicator nonmicro, by(munic_code oil_linked)
		rename firm_indicator num_firms
		rename nonmicro num_firms_nonmicro
		
		sort munic_code oil_linked
		drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen oil_name = ""
			replace oil_name = "_oil" if oil_linked == 1
			drop if oil_name != "_oil"

			
			*Reshape data from long to wide
			drop oil_linked
			reshape wide num_firms num_firms_nonmicro, i(munic_code) j(oil_name) string
			
			save "Firms_oil_`j'", replace 
	
	}
	
	
*Repeat with oil-linked rather than sectors 
*Years 2002-2005
local years "2002 2003 2004 2005"
foreach j of local years {
	
		import delimited "ESTB`j'.txt", delimiters(";") clear
		
		capture keep cnae95classe município tamanhoestabelecimento
		
		rename cnae95classe cnae1
		rename município munic_code
		rename tamanhoestabelecimento firm_size
		
		capture tostring cnae1, replace
		
			*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae1)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae1) if CNAE_code_length == 4
			replace cnae1 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
			
			*Merge in oil-linked codes
			merge m:1 cnae1 using "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE1_short"
			replace oil_linked_CNAE1 = 0 if oil_linked_CNAE1 == .
			drop _merge
	
			*Rename oil linked to make compatible with later years 
			rename oil_linked_CNAE1 oil_linked 
		
		
		*Generate indicator for non-micro firm 
		gen nonmicro = 0
		replace nonmicro = 1 if firm_size > 1
		
		gen firm_indicator = 1 
		
		
		*Collapse to municipality-sector level 
		gcollapse (sum) firm_indicator nonmicro, by(munic_code oil_linked)
		rename firm_indicator num_firms
		rename nonmicro num_firms_nonmicro
		
		sort munic_code oil_linked
		drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen oil_name = ""
			replace oil_name = "_oil" if oil_linked == 1
			drop if oil_name != "_oil"

			
			*Reshape data from long to wide
			drop oil_linked
			reshape wide num_firms num_firms_nonmicro, i(munic_code) j(oil_name) string
			
			save "Firms_oil_`j'", replace 
	
	}
	



*Repeat with years 2006-2017 (CNAE2)
local years "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach j of local years {
	
		import delimited "ESTB`j'.txt", delimiters(";") clear
		
		capture keep cnae20classe município tamanhoestabelecimento
		
		rename cnae20classe cnae2
		rename município munic_code
		rename tamanhoestabelecimento firm_size
		
				*First add zero to agriculture codes 
			gen CNAE_code_length = strlen(cnae2)
			gen first_zero = "0"
			egen CNAE_withzero = concat(first_zero cnae2) if CNAE_code_length == 4
			replace cnae2 = CNAE_withzero if CNAE_code_length == 4
			drop CNAE_code_length first_zero CNAE_withzero
			
			
			*Merge in oil-linked codes
			merge m:1 cnae1 using "${user}\Data Directory\Treatment Variables\Oil_Linked_CNAE2_short"
			replace oil_linked_CNAE2 = 0 if oil_linked_CNAE2 == .
			drop _merge
	
			*Rename oil linked to make compatible with later years 
			rename oil_linked_CNAE2 oil_linked 
		
		
		*Generate indicator for non-micro firm 
		gen nonmicro = 0
		replace nonmicro = 1 if firm_size > 1
		
		gen firm_indicator = 1 
		
		
		*Collapse to municipality-sector level 
		gcollapse (sum) firm_indicator nonmicro, by(munic_code oil_linked)
		rename firm_indicator num_firms
		rename nonmicro num_firms_nonmicro
		
		sort munic_code oil_linked
		drop if munic_code == .
			
			gen year = `j'
			
			*Name sectors for better comprehensability 
			gen oil_name = ""
			replace oil_name = "_oil" if oil_linked == 1
			drop if oil_name != "_oil"
			
			capture destring munic_code, replace 
			
			*Reshape data from long to wide
			drop oil_linked
			reshape wide num_firms num_firms_nonmicro, i(munic_code) j(oil_name) string
			
			save "Firms_oil_`j'", replace 

	}

*********************************************************************************
*********************************************************************************

********************************************************************************
*This concludes loops for firms. Now append into munic-year firm panel

*Define locals for all UF initials and years, and then loop over these locals to append all
*files into single file of municipal-level RAIS panel data
use "Firms_Sectors_2000.dta", clear
append using "Firms_Sectors_2001.dta", force 
append using "Firms_Sectors_2002.dta", force 
append using "Firms_Sectors_2003.dta", force 
append using "Firms_Sectors_2004.dta", force 
append using "Firms_Sectors_2005.dta", force 
append using "Firms_Sectors_2006.dta", force 
append using "Firms_Sectors_2007.dta", force 
append using "Firms_Sectors_2008.dta", force 
append using "Firms_Sectors_2009.dta", force 
append using "Firms_Sectors_2010.dta", force 
append using "Firms_Sectors_2011.dta", force 
append using "Firms_Sectors_2012.dta", force 
append using "Firms_Sectors_2013.dta", force 
append using "Firms_Sectors_2014.dta", force 
append using "Firms_Sectors_2015.dta", force 
append using "Firms_Sectors_2016.dta", force 
append using "Firms_Sectors_2017.dta", force 

order munic_code year 
sort munic_code year

save "Munic_Firms_bySector_Panel", replace 

*Repeat for oil
use "Firms_oil_2000.dta", clear
append using "Firms_oil_2001.dta", force 
append using "Firms_oil_2002.dta", force 
append using "Firms_oil_2003.dta", force 
append using "Firms_oil_2004.dta", force 
append using "Firms_oil_2005.dta", force 
append using "Firms_oil_2006.dta", force 
append using "Firms_oil_2007.dta", force 
append using "Firms_oil_2008.dta", force 
append using "Firms_oil_2009.dta", force 
append using "Firms_oil_2010.dta", force 
append using "Firms_oil_2011.dta", force 
append using "Firms_oil_2012.dta", force 
append using "Firms_oil_2013.dta", force 
append using "Firms_oil_2014.dta", force 
append using "Firms_oil_2015.dta", force 
append using "Firms_oil_2016.dta", force 
append using "Firms_oil_2017.dta", force 

order munic_code year 
sort munic_code year
	
save "Munic_Firms_OilLinked_Panel", replace 

*Now merge oil and other sectors panels together on munic_code and year 
use "Munic_Firms_bySector_Panel", clear 

merge 1:1 munic_code year using "Munic_Firms_OilLinked_Panel"

*Replace missings with zero for munics with no oil-linked firms
replace num_firms_oil = 0 if _merge == 1
replace num_firms_nonmicro_oil = 0 if _merge == 1

drop _merge 

*Difference firms by year to find net entries 
*Begin by setting data as time series
tsset munic_code year 

local vars "ag extract mfg constr retail otherserv govt tot trade oil"
foreach i of local vars {

gen net_entries_`i' = num_firms_`i' - L1.num_firms_`i'
gen net_entries_nonmicro_`i' = num_firms_nonmicro_`i' - L1.num_firms_nonmicro_`i'

}

*Save final municipality panel with individual data 
save "Munic_Firms_Panel", replace 

********************************************************************************
*Finally, merge together munic employment and firms panels into complete private sector panel 
use "Munic_Employment_Panel", clear 

merge 1:1 munic_code year using "Munic_Firms_Panel"
drop _merge 

*Rename munic_code to merge with other datasets 
rename munic_code munic_code_6digit

save "Munic_RAIS_PrivateSector_Panel_2000_to_2017", replace
save "${user}\Data Directory\Treatment Variables\Munic_RAIS_PrivateSector_Panel_2000_to_2017", replace


**********************************************************************************

	
	
	
	
	
	
	
	
	
	
	
	
	
	