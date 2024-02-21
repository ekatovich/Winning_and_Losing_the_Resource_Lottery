clear
cd "${user}\Data Directory\Census"

local years "2000 2001 2002 2003 2005 2006 2008 2009 2011 2012 2013 2014 2015 2016 2017"
*local years "2000 2001 2001 2003 2005 2006 2008 2009 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

import delimited "population_`i'.csv", clear

capture rename uf_no UF_NO
capture drop if mun_code == .
capture drop if UF_NO == .

*2.3 Remove all accents and special characters from munic using ustrnormalize:
				rename municipality munic 
				replace munic = ustrto(ustrnormalize(munic, "nfd"), "ascii", 2)	
				*Remove hyphens, apostrophes, and spaces	
				replace munic =subinstr(munic,"-","",.)
				replace munic =subinstr(munic,"'","",.)
				replace munic =subinstr(munic," ","",.)	
				*Convert all letters to uppercase
				replace munic = upper(munic)


		*2.4 If your dataset has uf number, simply rename this variable UF_NO
		*then skip to 2.6. If your dataset has uf initial or name, skip 2.4 and
		*go to step 2.5
		*rename [uf number variable name] UF_NO

		*2.5 If your dataset has uf initials, run this code:
		*(If you have uf names, first convert them to initials and then run this)
			/*	
				*Generate numeric UF labels
				generate UF_NO = .
				replace UF_NO = 11 if uf == "RO"
				replace UF_NO = 12 if uf == "AC"
				replace UF_NO = 13 if uf == "AM"
				replace UF_NO = 14 if uf == "RR"
				replace UF_NO = 15 if uf == "PA"
				replace UF_NO = 16 if uf == "AP"
				replace UF_NO = 17 if uf == "TO"

				replace UF_NO = 21 if uf == "MA"
				replace UF_NO = 22 if uf == "PI"
				replace UF_NO = 23 if uf == "CE"
				replace UF_NO = 24 if uf == "RN"
				replace UF_NO = 25 if uf == "PB"
				replace UF_NO = 26 if uf == "PE"
				replace UF_NO = 27 if uf == "AL"
				replace UF_NO = 28 if uf == "SE"
				replace UF_NO = 29 if uf == "BA"

				replace UF_NO = 31 if uf == "MG"
				replace UF_NO = 32 if uf == "ES"
				replace UF_NO = 33 if uf == "RJ"
				replace UF_NO = 35 if uf == "SP"

				replace UF_NO = 41 if uf == "PR"
				replace UF_NO = 42 if uf == "SC"
				replace UF_NO = 43 if uf == "RS"

				replace UF_NO = 50 if uf == "MS"
				replace UF_NO = 51 if uf == "MT"
				replace UF_NO = 52 if uf == "GO"
				replace UF_NO = 53 if uf == "DF"
			*/	

				
			*2.6 Generate unique municipality-state text identifier
			egen municipality = concat(munic UF_NO) 
			drop munic 
			order municipality UF_NO 
			capture destring UF_NO, replace 

		
		*2.7 Correct common naming variations to improve merging
		*These corrections should be run on all datasets prior to merging on "municipality"
		*Corrections account for 1) spelling variations, 2) abbreviations, 3) name changes, 4) data entry errors
		replace municipality = "BALNEARIOPICARRAS42" if municipality == "PICARRAS42"
		replace municipality = "PARATI33" if municipality == "PARATY33"
		replace municipality = "TRAJANODEMORAIS33" if municipality == "TRAJANODEMORAES33"
		replace municipality = "PRESIDENTECASTELOBRANCO42" if municipality == "PRESIDENTECASTELLOBRANCO42"
		replace municipality = "COUTOMAGALHAES17" if municipality == "COUTODEMAGALHAES17"
		replace municipality = "MOGIDASCRUZES35" if municipality == "MOJIDASCRUZES35"
		replace municipality = "LAGOADOITAENGA26" if municipality == "LAGOADEITAENGA26" 
		replace municipality = "BELEMDESAOFRANCISCO26" if municipality == "BELEMDOSAOFRANCISCO26"
		replace municipality = "ILHADEITAMARACA26" if municipality == "ITAMARACA26"
		replace municipality = "ITABIRINHA31" if municipality == "ITABIRINHADEMANTENA31"
		replace municipality = "SAOVALERIO17" if municipality == "SAOVALERIODANATIVIDADE17"
		replace municipality = "AROEIRASDOITAIM22" if municipality == "AROEIRASDEITAIM22"
		replace municipality = "SAOMIGUELDOGOSTOSO24" if municipality == "SAOMIGUELDETOUROS24"
		replace municipality = "SAODOMINGOS25" if municipality == "SAODOMINGOSDEPOMBAL25"
		replace municipality = "TACIMA25" if municipality == "CAMPODESANTANA25"
		replace municipality = "GOVERNADORLOMANTOJUNIOR29" if municipality == "BARROPRETO29"
		replace municipality = "ARMACAODOSBUZIOS33" if municipality == "ARMACAODEBUZIOS33"
		replace municipality = "ALTOPARAISO41" if municipality == "VILAALTA41"
		replace municipality = "ASSU24" if municipality == "ACU24"
		replace municipality = "AGUADOCEDOMARANHAO21" if municipality == "AGUADOCE21"
		replace municipality = "ALAGOINHADOPIAUI22" if municipality == "ALAGOINHA22"
		replace municipality = "ALMEIRIM15" if municipality == "ALMERIM15"
		replace municipality = "AMPARODESAOFRANCISCO28" if municipality == "AMPARODOSAOFRANCISCO28"
		replace municipality = "BADYBASSITT35" if municipality == "BADYBASSIT35"
		replace municipality = "BALNEARIOBARRADOSUL42" if municipality == "BALNEARIODEBARRADOSUL42"
		replace municipality = "BALNEARIOCAMBORIU42" if municipality == "BALNEARIODECAMBORIU42"
		replace municipality = "BARAUNA25" if municipality == "BARAUNAS25"
		replace municipality = "BELAVISTADOMARANHAO21" if municipality == "BELAVISTA21"
		replace municipality = "BERNARDINODECAMPOS35" if municipality == "BERNADINODECAMPOS35"
		replace municipality = "CABODESANTOAGOSTINHO26" if municipality == "CABO26"
		replace municipality = "CAMPOGRANDE24" if municipality == "AUGUSTOSEVERO24"
		replace municipality = "CAMPOSDOSGOYTACAZES33" if municipality == "CAMPOS33"
		replace municipality = "CANINDEDESAOFRANCISCO28" if municipality == "CANINDEDOSAOFRANCISCO28"
		replace municipality = "CONSELHEIROMAIRINCK41" if municipality == "CONSELHEIROMAYRINCK41"
		replace municipality = "DEPUTADOIRAPUANPINHEIRO23" if municipality == "DEPIRAPUANPINHEIRO23"
		replace municipality = "DIAMANTEDOESTE41" if municipality == "DIAMANTEDOOESTE41"
		replace municipality = "ELDORADODOSCARAJAS15" if municipality == "ELDORADODOCARAJAS15"
		replace municipality = "EMBUDASARTES35" if municipality == "EMBU35"
		replace municipality = "EUSEBIO23" if municipality == "EUZEBIO23"
		replace municipality = "FERNANDOPEDROZA24" if municipality == "FERNANDOPEDROSA24"
		replace municipality = "FLORINIA35" if municipality == "FLORINEA35"
		replace municipality = "GOVERNADOREDISONLOBAO21" if municipality == "GOVERNADOREDSONLOBAO21"
		replace municipality = "GRACHOCARDOSO28" if municipality == "GRACCHOCARDOSO28"
		replace municipality = "GRANJEIRO23" if municipality == "GRANGEIRO23"
		replace municipality = "HERVALDOESTE42" if municipality == "HERVALDOOESTE42"
		replace municipality = "ITAGUAJE41" if municipality == "ITAGUAGE41"
		replace municipality = "ITAPEJARADOESTE41" if municipality == "ITAPEJARADOOESTE41"
		replace municipality = "JABOATAODOSGUARARAPES26" if municipality == "JABOATAO26"
		replace municipality = "LAGEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
		replace municipality = "LUIZALVES42" if municipality == "LUISALVES42"
		replace municipality = "LUISDOMINGUESDOMARANHAO21" if municipality == "LUISDOMINGUES21"
		replace municipality = "LUIZIANIA35" if municipality == "LUISIANIA41"
		replace municipality = "MOJIMIRIM35" if municipality == "MOGIMIRIM35"
		replace municipality = "MOREIRASALES41" if municipality == "MOREIRASALLES41"
		replace municipality = "MUNHOZDEMELO41" if municipality == "MUNHOZDEMELLO41"
		replace municipality = "MUQUEMDESAOFRANCISCO29" if municipality == "MUQUEMDOSAOFRANCISCO29"
		replace municipality = "PATYDOALFERES33" if municipality == "PATIDOALFERES33"
		replace municipality = "QUIJINGUE29" if municipality == "QUINJINGUE29"
		replace municipality = "SALMOURAO35" if municipality == "SALMORAO35"
		replace municipality = "SANTANADOITARARE41" if municipality == "SANTAANADOITARARE41"
		replace municipality = "SANTACRUZDEMONTECASTELO41" if municipality == "SANTACRUZDOMONTECASTELO41"
		replace municipality = "SANTAISABELDOIVAI41" if municipality == "SANTAIZABELDOIVAI41"
		replace municipality = "SANTAISABELDOPARA15" if municipality == "SANTAIZABELDOPARA15"
		replace municipality = "SANTAMARIADEJETIBA32" if municipality == "SANTAMARIADOJETIBA32"
		replace municipality = "SANTATERESINHA29" if municipality == "SANTATEREZINHA29"
		replace municipality = "SANTOANTONIODEPOSSE35" if municipality == "SANTOANTONIODAPOSSE35"
		replace municipality = "SAOCAETANO26" if municipality == "SAOCAITANO26"
		replace municipality = "SAODOMINGOSDONORTE32" if municipality == "SAODOMINGOS32"
		replace municipality = "SAOJOSEDOCAMPESTRE24" if municipality == "SAOJOSEDECAMPESTRE24"
		replace municipality = "SAOJOSEDOBREJODOCRUZ25" if municipality == "SAOJOSEDOBREJOCRUZ25"
		replace municipality = "SAOLUIZGONZAGA43" if municipality == "SAOLUISGONZAGA43"
		replace municipality = "SAORAIMUNDODODOCABEZERRA21" if municipality == "SAORAIMUNDODADOCABEZERRA21"
		replace municipality = "SAOSEBASTIAODELAGOADEROCA25" if municipality == "SAOSEB.DELAGOADEROCA25"
		replace municipality = "SAOVICENTEDOSERIDO25" if municipality == "SERIDO25"
		replace municipality = "SENADORLAROCQUE21" if municipality == "SENADORLAROQUE21"
		replace municipality = "TEOTONIOVILELA27" if municipality == "SENADORTEOTONIOVILELA27"
		replace municipality = "SERRACAIADA24" if municipality == "SERRACAIADA24"
		replace municipality = "SUDMENNUCCI35" if municipality == "SUDMENUCCI35"
		replace municipality = "SUZANAPOLIS35" if municipality == "SUZANOPOLIS35"
		replace municipality = "TEJUCUOCA23" if municipality == "TEJUSSUOCA23"
		replace municipality = "TRINDADEDOSUL43" if municipality == "TRINDADE43"
		replace municipality = "VALPARAISO35" if municipality == "VALPARAIZO35"
		replace municipality = "VARRESAI33" if municipality == "VARREESAI33"
		replace municipality = "VISEU15" if municipality == "VIZEU15"
		replace municipality = "LAJEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
		replace municipality = "SENADORCATUNDA23" if municipality == "CATUNDA23"
		replace municipality = "LAGOAALEGRE22" if municipality == "LOGOAALEGRE22"


		*2.8 Now merge cleaned names dataset with Brazil geographical units crosswalk 
		merge m:1 municipality using "brazil_geographical_codes.dta"

		*2.9 Inspect merge failures and make name corrections as above to fix them 
		sort _merge
		
		drop if _merge != 3
		
		*2.10 Drop _merge to clean up dataset and save final dataset with 
		*numeric geographic identifiers attached to cleaned names
		drop _merge
		
		*Clean population variable 
		gen problem = 0
		replace problem = strpos(population_complete, ")") > 0
		
		
		replace population_complete =subinstr(population_complete,",","",.)
		replace population_complete =subinstr(population_complete,"*","",.)
		*replace population_complete =subinstr(population_complete,"(","",.)
		*replace population_complete =subinstr(population_complete,")","",.)
		
		drop if problem == 1
		
		destring population_complete, replace

		sort municipality 

		gen year = `i'

		save "Population_IBGE_`i'", replace 

}



*********************************************************************************
local years "2004"
foreach i of local years {

import delimited "population_`i'.csv", clear

capture rename uf_no UF_NO
capture drop if mun_code == .
capture drop if UF_NO == .

*2.3 Remove all accents and special characters from munic using ustrnormalize:
				rename municipality munic 
				replace munic = ustrto(ustrnormalize(munic, "nfd"), "ascii", 2)	
				*Remove hyphens, apostrophes, and spaces	
				replace munic =subinstr(munic,"-","",.)
				replace munic =subinstr(munic,"'","",.)
				replace munic =subinstr(munic," ","",.)	
				*Convert all letters to uppercase
				replace munic = upper(munic)


		*2.4 If your dataset has uf number, simply rename this variable UF_NO
		*then skip to 2.6. If your dataset has uf initial or name, skip 2.4 and
		*go to step 2.5
		*rename [uf number variable name] UF_NO

		*2.5 If your dataset has uf initials, run this code:
		*(If you have uf names, first convert them to initials and then run this)
			/*	
				*Generate numeric UF labels
				generate UF_NO = .
				replace UF_NO = 11 if uf == "RO"
				replace UF_NO = 12 if uf == "AC"
				replace UF_NO = 13 if uf == "AM"
				replace UF_NO = 14 if uf == "RR"
				replace UF_NO = 15 if uf == "PA"
				replace UF_NO = 16 if uf == "AP"
				replace UF_NO = 17 if uf == "TO"

				replace UF_NO = 21 if uf == "MA"
				replace UF_NO = 22 if uf == "PI"
				replace UF_NO = 23 if uf == "CE"
				replace UF_NO = 24 if uf == "RN"
				replace UF_NO = 25 if uf == "PB"
				replace UF_NO = 26 if uf == "PE"
				replace UF_NO = 27 if uf == "AL"
				replace UF_NO = 28 if uf == "SE"
				replace UF_NO = 29 if uf == "BA"

				replace UF_NO = 31 if uf == "MG"
				replace UF_NO = 32 if uf == "ES"
				replace UF_NO = 33 if uf == "RJ"
				replace UF_NO = 35 if uf == "SP"

				replace UF_NO = 41 if uf == "PR"
				replace UF_NO = 42 if uf == "SC"
				replace UF_NO = 43 if uf == "RS"

				replace UF_NO = 50 if uf == "MS"
				replace UF_NO = 51 if uf == "MT"
				replace UF_NO = 52 if uf == "GO"
				replace UF_NO = 53 if uf == "DF"
			*/	

				
			*2.6 Generate unique municipality-state text identifier
			egen municipality = concat(munic UF_NO) 
			drop munic 
			order municipality UF_NO 
			capture destring UF_NO, replace 

		
		*2.7 Correct common naming variations to improve merging
		*These corrections should be run on all datasets prior to merging on "municipality"
		*Corrections account for 1) spelling variations, 2) abbreviations, 3) name changes, 4) data entry errors
		replace municipality = "BALNEARIOPICARRAS42" if municipality == "PICARRAS42"
		replace municipality = "PARATI33" if municipality == "PARATY33"
		replace municipality = "TRAJANODEMORAIS33" if municipality == "TRAJANODEMORAES33"
		replace municipality = "PRESIDENTECASTELOBRANCO42" if municipality == "PRESIDENTECASTELLOBRANCO42"
		replace municipality = "COUTOMAGALHAES17" if municipality == "COUTODEMAGALHAES17"
		replace municipality = "MOGIDASCRUZES35" if municipality == "MOJIDASCRUZES35"
		replace municipality = "LAGOADOITAENGA26" if municipality == "LAGOADEITAENGA26" 
		replace municipality = "BELEMDESAOFRANCISCO26" if municipality == "BELEMDOSAOFRANCISCO26"
		replace municipality = "ILHADEITAMARACA26" if municipality == "ITAMARACA26"
		replace municipality = "ITABIRINHA31" if municipality == "ITABIRINHADEMANTENA31"
		replace municipality = "SAOVALERIO17" if municipality == "SAOVALERIODANATIVIDADE17"
		replace municipality = "AROEIRASDOITAIM22" if municipality == "AROEIRASDEITAIM22"
		replace municipality = "SAOMIGUELDOGOSTOSO24" if municipality == "SAOMIGUELDETOUROS24"
		replace municipality = "SAODOMINGOS25" if municipality == "SAODOMINGOSDEPOMBAL25"
		replace municipality = "TACIMA25" if municipality == "CAMPODESANTANA25"
		replace municipality = "GOVERNADORLOMANTOJUNIOR29" if municipality == "BARROPRETO29"
		replace municipality = "ARMACAODOSBUZIOS33" if municipality == "ARMACAODEBUZIOS33"
		replace municipality = "ALTOPARAISO41" if municipality == "VILAALTA41"
		replace municipality = "ASSU24" if municipality == "ACU24"
		replace municipality = "AGUADOCEDOMARANHAO21" if municipality == "AGUADOCE21"
		replace municipality = "ALAGOINHADOPIAUI22" if municipality == "ALAGOINHA22"
		replace municipality = "ALMEIRIM15" if municipality == "ALMERIM15"
		replace municipality = "AMPARODESAOFRANCISCO28" if municipality == "AMPARODOSAOFRANCISCO28"
		replace municipality = "BADYBASSITT35" if municipality == "BADYBASSIT35"
		replace municipality = "BALNEARIOBARRADOSUL42" if municipality == "BALNEARIODEBARRADOSUL42"
		replace municipality = "BALNEARIOCAMBORIU42" if municipality == "BALNEARIODECAMBORIU42"
		replace municipality = "BARAUNA25" if municipality == "BARAUNAS25"
		replace municipality = "BELAVISTADOMARANHAO21" if municipality == "BELAVISTA21"
		replace municipality = "BERNARDINODECAMPOS35" if municipality == "BERNADINODECAMPOS35"
		replace municipality = "CABODESANTOAGOSTINHO26" if municipality == "CABO26"
		replace municipality = "CAMPOGRANDE24" if municipality == "AUGUSTOSEVERO24"
		replace municipality = "CAMPOSDOSGOYTACAZES33" if municipality == "CAMPOS33"
		replace municipality = "CANINDEDESAOFRANCISCO28" if municipality == "CANINDEDOSAOFRANCISCO28"
		replace municipality = "CONSELHEIROMAIRINCK41" if municipality == "CONSELHEIROMAYRINCK41"
		replace municipality = "DEPUTADOIRAPUANPINHEIRO23" if municipality == "DEPIRAPUANPINHEIRO23"
		replace municipality = "DIAMANTEDOESTE41" if municipality == "DIAMANTEDOOESTE41"
		replace municipality = "ELDORADODOSCARAJAS15" if municipality == "ELDORADODOCARAJAS15"
		replace municipality = "EMBUDASARTES35" if municipality == "EMBU35"
		replace municipality = "EUSEBIO23" if municipality == "EUZEBIO23"
		replace municipality = "FERNANDOPEDROZA24" if municipality == "FERNANDOPEDROSA24"
		replace municipality = "FLORINIA35" if municipality == "FLORINEA35"
		replace municipality = "GOVERNADOREDISONLOBAO21" if municipality == "GOVERNADOREDSONLOBAO21"
		replace municipality = "GRACHOCARDOSO28" if municipality == "GRACCHOCARDOSO28"
		replace municipality = "GRANJEIRO23" if municipality == "GRANGEIRO23"
		replace municipality = "HERVALDOESTE42" if municipality == "HERVALDOOESTE42"
		replace municipality = "ITAGUAJE41" if municipality == "ITAGUAGE41"
		replace municipality = "ITAPEJARADOESTE41" if municipality == "ITAPEJARADOOESTE41"
		replace municipality = "JABOATAODOSGUARARAPES26" if municipality == "JABOATAO26"
		replace municipality = "LAGEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
		replace municipality = "LUIZALVES42" if municipality == "LUISALVES42"
		replace municipality = "LUISDOMINGUESDOMARANHAO21" if municipality == "LUISDOMINGUES21"
		replace municipality = "LUIZIANIA35" if municipality == "LUISIANIA41"
		replace municipality = "MOJIMIRIM35" if municipality == "MOGIMIRIM35"
		replace municipality = "MOREIRASALES41" if municipality == "MOREIRASALLES41"
		replace municipality = "MUNHOZDEMELO41" if municipality == "MUNHOZDEMELLO41"
		replace municipality = "MUQUEMDESAOFRANCISCO29" if municipality == "MUQUEMDOSAOFRANCISCO29"
		replace municipality = "PATYDOALFERES33" if municipality == "PATIDOALFERES33"
		replace municipality = "QUIJINGUE29" if municipality == "QUINJINGUE29"
		replace municipality = "SALMOURAO35" if municipality == "SALMORAO35"
		replace municipality = "SANTANADOITARARE41" if municipality == "SANTAANADOITARARE41"
		replace municipality = "SANTACRUZDEMONTECASTELO41" if municipality == "SANTACRUZDOMONTECASTELO41"
		replace municipality = "SANTAISABELDOIVAI41" if municipality == "SANTAIZABELDOIVAI41"
		replace municipality = "SANTAISABELDOPARA15" if municipality == "SANTAIZABELDOPARA15"
		replace municipality = "SANTAMARIADEJETIBA32" if municipality == "SANTAMARIADOJETIBA32"
		replace municipality = "SANTATERESINHA29" if municipality == "SANTATEREZINHA29"
		replace municipality = "SANTOANTONIODEPOSSE35" if municipality == "SANTOANTONIODAPOSSE35"
		replace municipality = "SAOCAETANO26" if municipality == "SAOCAITANO26"
		replace municipality = "SAODOMINGOSDONORTE32" if municipality == "SAODOMINGOS32"
		replace municipality = "SAOJOSEDOCAMPESTRE24" if municipality == "SAOJOSEDECAMPESTRE24"
		replace municipality = "SAOJOSEDOBREJODOCRUZ25" if municipality == "SAOJOSEDOBREJOCRUZ25"
		replace municipality = "SAOLUIZGONZAGA43" if municipality == "SAOLUISGONZAGA43"
		replace municipality = "SAORAIMUNDODODOCABEZERRA21" if municipality == "SAORAIMUNDODADOCABEZERRA21"
		replace municipality = "SAOSEBASTIAODELAGOADEROCA25" if municipality == "SAOSEB.DELAGOADEROCA25"
		replace municipality = "SAOVICENTEDOSERIDO25" if municipality == "SERIDO25"
		replace municipality = "SENADORLAROCQUE21" if municipality == "SENADORLAROQUE21"
		replace municipality = "TEOTONIOVILELA27" if municipality == "SENADORTEOTONIOVILELA27"
		replace municipality = "SERRACAIADA24" if municipality == "SERRACAIADA24"
		replace municipality = "SUDMENNUCCI35" if municipality == "SUDMENUCCI35"
		replace municipality = "SUZANAPOLIS35" if municipality == "SUZANOPOLIS35"
		replace municipality = "TEJUCUOCA23" if municipality == "TEJUSSUOCA23"
		replace municipality = "TRINDADEDOSUL43" if municipality == "TRINDADE43"
		replace municipality = "VALPARAISO35" if municipality == "VALPARAIZO35"
		replace municipality = "VARRESAI33" if municipality == "VARREESAI33"
		replace municipality = "VISEU15" if municipality == "VIZEU15"
		replace municipality = "LAJEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
		replace municipality = "SENADORCATUNDA23" if municipality == "CATUNDA23"
		replace municipality = "LAGOAALEGRE22" if municipality == "LOGOAALEGRE22"


		*2.8 Now merge cleaned names dataset with Brazil geographical units crosswalk 
		merge m:1 municipality using "brazil_geographical_codes.dta"

		*2.9 Inspect merge failures and make name corrections as above to fix them 
		sort _merge
		
		drop if _merge != 3
		
		*2.10 Drop _merge to clean up dataset and save final dataset with 
		*numeric geographic identifiers attached to cleaned names
		drop _merge

		sort municipality 

		gen year = `i'

		save "Population_IBGE_`i'", replace 

}

*********************************************************************************
*Repeat for 2010 census population data 

import delimited "population_2010.csv", varnames(1) clear

drop if municipality == ""

*2.3 Remove all accents and special characters from munic using ustrnormalize:
				rename municipality munic 
				replace munic = ustrto(ustrnormalize(munic, "nfd"), "ascii", 2)	
				*Remove hyphens, apostrophes, and spaces	
				replace munic =subinstr(munic,"-","",.)
				replace munic =subinstr(munic,"'","",.)
				replace munic =subinstr(munic," ","",.)	
				*Convert all letters to uppercase
				replace munic = upper(munic)


		*2.4 If your dataset has uf number, simply rename this variable UF_NO
		*then skip to 2.6. If your dataset has uf initial or name, skip 2.4 and
		*go to step 2.5
		*rename [uf number variable name] UF_NO

		*2.5 If your dataset has uf initials, run this code:
		*(If you have uf names, first convert them to initials and then run this)
				
				*Generate numeric UF labels
				generate UF_NO = .
				replace UF_NO = 11 if uf == "RO"
				replace UF_NO = 12 if uf == "AC"
				replace UF_NO = 13 if uf == "AM"
				replace UF_NO = 14 if uf == "RR"
				replace UF_NO = 15 if uf == "PA"
				replace UF_NO = 16 if uf == "AP"
				replace UF_NO = 17 if uf == "TO"

				replace UF_NO = 21 if uf == "MA"
				replace UF_NO = 22 if uf == "PI"
				replace UF_NO = 23 if uf == "CE"
				replace UF_NO = 24 if uf == "RN"
				replace UF_NO = 25 if uf == "PB"
				replace UF_NO = 26 if uf == "PE"
				replace UF_NO = 27 if uf == "AL"
				replace UF_NO = 28 if uf == "SE"
				replace UF_NO = 29 if uf == "BA"

				replace UF_NO = 31 if uf == "MG"
				replace UF_NO = 32 if uf == "ES"
				replace UF_NO = 33 if uf == "RJ"
				replace UF_NO = 35 if uf == "SP"

				replace UF_NO = 41 if uf == "PR"
				replace UF_NO = 42 if uf == "SC"
				replace UF_NO = 43 if uf == "RS"

				replace UF_NO = 50 if uf == "MS"
				replace UF_NO = 51 if uf == "MT"
				replace UF_NO = 52 if uf == "GO"
				replace UF_NO = 53 if uf == "DF"
			

				
			*2.6 Generate unique municipality-state text identifier
			egen municipality = concat(munic UF_NO) 
			drop munic 
			order municipality UF_NO 
			capture destring UF_NO, replace 

		
		*2.7 Correct common naming variations to improve merging
		*These corrections should be run on all datasets prior to merging on "municipality"
		*Corrections account for 1) spelling variations, 2) abbreviations, 3) name changes, 4) data entry errors
		replace municipality = "BALNEARIOPICARRAS42" if municipality == "PICARRAS42"
		replace municipality = "PARATI33" if municipality == "PARATY33"
		replace municipality = "TRAJANODEMORAIS33" if municipality == "TRAJANODEMORAES33"
		replace municipality = "PRESIDENTECASTELOBRANCO42" if municipality == "PRESIDENTECASTELLOBRANCO42"
		replace municipality = "COUTOMAGALHAES17" if municipality == "COUTODEMAGALHAES17"
		replace municipality = "MOGIDASCRUZES35" if municipality == "MOJIDASCRUZES35"
		replace municipality = "LAGOADOITAENGA26" if municipality == "LAGOADEITAENGA26" 
		replace municipality = "BELEMDESAOFRANCISCO26" if municipality == "BELEMDOSAOFRANCISCO26"
		replace municipality = "ILHADEITAMARACA26" if municipality == "ITAMARACA26"
		replace municipality = "ITABIRINHA31" if municipality == "ITABIRINHADEMANTENA31"
		replace municipality = "SAOVALERIO17" if municipality == "SAOVALERIODANATIVIDADE17"
		replace municipality = "AROEIRASDOITAIM22" if municipality == "AROEIRASDEITAIM22"
		replace municipality = "SAOMIGUELDOGOSTOSO24" if municipality == "SAOMIGUELDETOUROS24"
		replace municipality = "SAODOMINGOS25" if municipality == "SAODOMINGOSDEPOMBAL25"
		replace municipality = "TACIMA25" if municipality == "CAMPODESANTANA25"
		replace municipality = "GOVERNADORLOMANTOJUNIOR29" if municipality == "BARROPRETO29"
		replace municipality = "ARMACAODOSBUZIOS33" if municipality == "ARMACAODEBUZIOS33"
		replace municipality = "ALTOPARAISO41" if municipality == "VILAALTA41"
		replace municipality = "ASSU24" if municipality == "ACU24"
		replace municipality = "AGUADOCEDOMARANHAO21" if municipality == "AGUADOCE21"
		replace municipality = "ALAGOINHADOPIAUI22" if municipality == "ALAGOINHA22"
		replace municipality = "ALMEIRIM15" if municipality == "ALMERIM15"
		replace municipality = "AMPARODESAOFRANCISCO28" if municipality == "AMPARODOSAOFRANCISCO28"
		replace municipality = "BADYBASSITT35" if municipality == "BADYBASSIT35"
		replace municipality = "BALNEARIOBARRADOSUL42" if municipality == "BALNEARIODEBARRADOSUL42"
		replace municipality = "BALNEARIOCAMBORIU42" if municipality == "BALNEARIODECAMBORIU42"
		replace municipality = "BARAUNA25" if municipality == "BARAUNAS25"
		replace municipality = "BELAVISTADOMARANHAO21" if municipality == "BELAVISTA21"
		replace municipality = "BERNARDINODECAMPOS35" if municipality == "BERNADINODECAMPOS35"
		replace municipality = "CABODESANTOAGOSTINHO26" if municipality == "CABO26"
		replace municipality = "CAMPOGRANDE24" if municipality == "AUGUSTOSEVERO24"
		replace municipality = "CAMPOSDOSGOYTACAZES33" if municipality == "CAMPOS33"
		replace municipality = "CANINDEDESAOFRANCISCO28" if municipality == "CANINDEDOSAOFRANCISCO28"
		replace municipality = "CONSELHEIROMAIRINCK41" if municipality == "CONSELHEIROMAYRINCK41"
		replace municipality = "DEPUTADOIRAPUANPINHEIRO23" if municipality == "DEPIRAPUANPINHEIRO23"
		replace municipality = "DIAMANTEDOESTE41" if municipality == "DIAMANTEDOOESTE41"
		replace municipality = "ELDORADODOSCARAJAS15" if municipality == "ELDORADODOCARAJAS15"
		replace municipality = "EMBUDASARTES35" if municipality == "EMBU35"
		replace municipality = "EUSEBIO23" if municipality == "EUZEBIO23"
		replace municipality = "FERNANDOPEDROZA24" if municipality == "FERNANDOPEDROSA24"
		replace municipality = "FLORINIA35" if municipality == "FLORINEA35"
		replace municipality = "GOVERNADOREDISONLOBAO21" if municipality == "GOVERNADOREDSONLOBAO21"
		replace municipality = "GRACHOCARDOSO28" if municipality == "GRACCHOCARDOSO28"
		replace municipality = "GRANJEIRO23" if municipality == "GRANGEIRO23"
		replace municipality = "HERVALDOESTE42" if municipality == "HERVALDOOESTE42"
		replace municipality = "ITAGUAJE41" if municipality == "ITAGUAGE41"
		replace municipality = "ITAPEJARADOESTE41" if municipality == "ITAPEJARADOOESTE41"
		replace municipality = "JABOATAODOSGUARARAPES26" if municipality == "JABOATAO26"
		replace municipality = "LAGEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
		replace municipality = "LUIZALVES42" if municipality == "LUISALVES42"
		replace municipality = "LUISDOMINGUESDOMARANHAO21" if municipality == "LUISDOMINGUES21"
		replace municipality = "LUIZIANIA35" if municipality == "LUISIANIA41"
		replace municipality = "MOJIMIRIM35" if municipality == "MOGIMIRIM35"
		replace municipality = "MOREIRASALES41" if municipality == "MOREIRASALLES41"
		replace municipality = "MUNHOZDEMELO41" if municipality == "MUNHOZDEMELLO41"
		replace municipality = "MUQUEMDESAOFRANCISCO29" if municipality == "MUQUEMDOSAOFRANCISCO29"
		replace municipality = "PATYDOALFERES33" if municipality == "PATIDOALFERES33"
		replace municipality = "QUIJINGUE29" if municipality == "QUINJINGUE29"
		replace municipality = "SALMOURAO35" if municipality == "SALMORAO35"
		replace municipality = "SANTANADOITARARE41" if municipality == "SANTAANADOITARARE41"
		replace municipality = "SANTACRUZDEMONTECASTELO41" if municipality == "SANTACRUZDOMONTECASTELO41"
		replace municipality = "SANTAISABELDOIVAI41" if municipality == "SANTAIZABELDOIVAI41"
		replace municipality = "SANTAISABELDOPARA15" if municipality == "SANTAIZABELDOPARA15"
		replace municipality = "SANTAMARIADEJETIBA32" if municipality == "SANTAMARIADOJETIBA32"
		replace municipality = "SANTATERESINHA29" if municipality == "SANTATEREZINHA29"
		replace municipality = "SANTOANTONIODEPOSSE35" if municipality == "SANTOANTONIODAPOSSE35"
		replace municipality = "SAOCAETANO26" if municipality == "SAOCAITANO26"
		replace municipality = "SAODOMINGOSDONORTE32" if municipality == "SAODOMINGOS32"
		replace municipality = "SAOJOSEDOCAMPESTRE24" if municipality == "SAOJOSEDECAMPESTRE24"
		replace municipality = "SAOJOSEDOBREJODOCRUZ25" if municipality == "SAOJOSEDOBREJOCRUZ25"
		replace municipality = "SAOLUIZGONZAGA43" if municipality == "SAOLUISGONZAGA43"
		replace municipality = "SAORAIMUNDODODOCABEZERRA21" if municipality == "SAORAIMUNDODADOCABEZERRA21"
		replace municipality = "SAOSEBASTIAODELAGOADEROCA25" if municipality == "SAOSEB.DELAGOADEROCA25"
		replace municipality = "SAOVICENTEDOSERIDO25" if municipality == "SERIDO25"
		replace municipality = "SENADORLAROCQUE21" if municipality == "SENADORLAROQUE21"
		replace municipality = "TEOTONIOVILELA27" if municipality == "SENADORTEOTONIOVILELA27"
		replace municipality = "SERRACAIADA24" if municipality == "SERRACAIADA24"
		replace municipality = "SUDMENNUCCI35" if municipality == "SUDMENUCCI35"
		replace municipality = "SUZANAPOLIS35" if municipality == "SUZANOPOLIS35"
		replace municipality = "TEJUCUOCA23" if municipality == "TEJUSSUOCA23"
		replace municipality = "TRINDADEDOSUL43" if municipality == "TRINDADE43"
		replace municipality = "VALPARAISO35" if municipality == "VALPARAIZO35"
		replace municipality = "VARRESAI33" if municipality == "VARREESAI33"
		replace municipality = "VISEU15" if municipality == "VIZEU15"
		replace municipality = "LAJEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
		replace municipality = "SENADORCATUNDA23" if municipality == "CATUNDA23"
		replace municipality = "LAGOAALEGRE22" if municipality == "LOGOAALEGRE22"


		*2.8 Now merge cleaned names dataset with Brazil geographical units crosswalk 
		merge m:1 municipality using "brazil_geographical_codes.dta"

		*2.9 Inspect merge failures and make name corrections as above to fix them 
		sort _merge
		
		drop if _merge != 3
		
		*2.10 Drop _merge to clean up dataset and save final dataset with 
		*numeric geographic identifiers attached to cleaned names
		drop _merge
		
		replace population_complete =subinstr(population_complete,",","",.)
		replace population_complete =subinstr(population_complete,"*","",.)
		replace population_complete =subinstr(population_complete,"(","",.)
		replace population_complete =subinstr(population_complete,")","",.)
		destring population_complete, replace

		sort municipality 

		gen year = 2010

		save "Population_IBGE_2010", replace 
		
*********************************************************************************
*Repeat with empty data for 2007 
import delimited "population_2007.csv", clear

capture rename uf_no UF_NO
capture drop if mun_code == .
capture drop if UF_NO == .

*2.3 Remove all accents and special characters from munic using ustrnormalize:
				rename municipality munic 
				replace munic = ustrto(ustrnormalize(munic, "nfd"), "ascii", 2)	
				*Remove hyphens, apostrophes, and spaces	
				replace munic =subinstr(munic,"-","",.)
				replace munic =subinstr(munic,"'","",.)
				replace munic =subinstr(munic," ","",.)	
				*Convert all letters to uppercase
				replace munic = upper(munic)


		*2.4 If your dataset has uf number, simply rename this variable UF_NO
		*then skip to 2.6. If your dataset has uf initial or name, skip 2.4 and
		*go to step 2.5
		*rename [uf number variable name] UF_NO

		*2.5 If your dataset has uf initials, run this code:
		*(If you have uf names, first convert them to initials and then run this)
			/*	
				*Generate numeric UF labels
				generate UF_NO = .
				replace UF_NO = 11 if uf == "RO"
				replace UF_NO = 12 if uf == "AC"
				replace UF_NO = 13 if uf == "AM"
				replace UF_NO = 14 if uf == "RR"
				replace UF_NO = 15 if uf == "PA"
				replace UF_NO = 16 if uf == "AP"
				replace UF_NO = 17 if uf == "TO"

				replace UF_NO = 21 if uf == "MA"
				replace UF_NO = 22 if uf == "PI"
				replace UF_NO = 23 if uf == "CE"
				replace UF_NO = 24 if uf == "RN"
				replace UF_NO = 25 if uf == "PB"
				replace UF_NO = 26 if uf == "PE"
				replace UF_NO = 27 if uf == "AL"
				replace UF_NO = 28 if uf == "SE"
				replace UF_NO = 29 if uf == "BA"

				replace UF_NO = 31 if uf == "MG"
				replace UF_NO = 32 if uf == "ES"
				replace UF_NO = 33 if uf == "RJ"
				replace UF_NO = 35 if uf == "SP"

				replace UF_NO = 41 if uf == "PR"
				replace UF_NO = 42 if uf == "SC"
				replace UF_NO = 43 if uf == "RS"

				replace UF_NO = 50 if uf == "MS"
				replace UF_NO = 51 if uf == "MT"
				replace UF_NO = 52 if uf == "GO"
				replace UF_NO = 53 if uf == "DF"
			*/	

				
			*2.6 Generate unique municipality-state text identifier
			egen municipality = concat(munic UF_NO) 
			drop munic 
			order municipality UF_NO 
			capture destring UF_NO, replace 

		
		*2.7 Correct common naming variations to improve merging
		*These corrections should be run on all datasets prior to merging on "municipality"
		*Corrections account for 1) spelling variations, 2) abbreviations, 3) name changes, 4) data entry errors
		replace municipality = "BALNEARIOPICARRAS42" if municipality == "PICARRAS42"
		replace municipality = "PARATI33" if municipality == "PARATY33"
		replace municipality = "TRAJANODEMORAIS33" if municipality == "TRAJANODEMORAES33"
		replace municipality = "PRESIDENTECASTELOBRANCO42" if municipality == "PRESIDENTECASTELLOBRANCO42"
		replace municipality = "COUTOMAGALHAES17" if municipality == "COUTODEMAGALHAES17"
		replace municipality = "MOGIDASCRUZES35" if municipality == "MOJIDASCRUZES35"
		replace municipality = "LAGOADOITAENGA26" if municipality == "LAGOADEITAENGA26" 
		replace municipality = "BELEMDESAOFRANCISCO26" if municipality == "BELEMDOSAOFRANCISCO26"
		replace municipality = "ILHADEITAMARACA26" if municipality == "ITAMARACA26"
		replace municipality = "ITABIRINHA31" if municipality == "ITABIRINHADEMANTENA31"
		replace municipality = "SAOVALERIO17" if municipality == "SAOVALERIODANATIVIDADE17"
		replace municipality = "AROEIRASDOITAIM22" if municipality == "AROEIRASDEITAIM22"
		replace municipality = "SAOMIGUELDOGOSTOSO24" if municipality == "SAOMIGUELDETOUROS24"
		replace municipality = "SAODOMINGOS25" if municipality == "SAODOMINGOSDEPOMBAL25"
		replace municipality = "TACIMA25" if municipality == "CAMPODESANTANA25"
		replace municipality = "GOVERNADORLOMANTOJUNIOR29" if municipality == "BARROPRETO29"
		replace municipality = "ARMACAODOSBUZIOS33" if municipality == "ARMACAODEBUZIOS33"
		replace municipality = "ALTOPARAISO41" if municipality == "VILAALTA41"
		replace municipality = "ASSU24" if municipality == "ACU24"
		replace municipality = "AGUADOCEDOMARANHAO21" if municipality == "AGUADOCE21"
		replace municipality = "ALAGOINHADOPIAUI22" if municipality == "ALAGOINHA22"
		replace municipality = "ALMEIRIM15" if municipality == "ALMERIM15"
		replace municipality = "AMPARODESAOFRANCISCO28" if municipality == "AMPARODOSAOFRANCISCO28"
		replace municipality = "BADYBASSITT35" if municipality == "BADYBASSIT35"
		replace municipality = "BALNEARIOBARRADOSUL42" if municipality == "BALNEARIODEBARRADOSUL42"
		replace municipality = "BALNEARIOCAMBORIU42" if municipality == "BALNEARIODECAMBORIU42"
		replace municipality = "BARAUNA25" if municipality == "BARAUNAS25"
		replace municipality = "BELAVISTADOMARANHAO21" if municipality == "BELAVISTA21"
		replace municipality = "BERNARDINODECAMPOS35" if municipality == "BERNADINODECAMPOS35"
		replace municipality = "CABODESANTOAGOSTINHO26" if municipality == "CABO26"
		replace municipality = "CAMPOGRANDE24" if municipality == "AUGUSTOSEVERO24"
		replace municipality = "CAMPOSDOSGOYTACAZES33" if municipality == "CAMPOS33"
		replace municipality = "CANINDEDESAOFRANCISCO28" if municipality == "CANINDEDOSAOFRANCISCO28"
		replace municipality = "CONSELHEIROMAIRINCK41" if municipality == "CONSELHEIROMAYRINCK41"
		replace municipality = "DEPUTADOIRAPUANPINHEIRO23" if municipality == "DEPIRAPUANPINHEIRO23"
		replace municipality = "DIAMANTEDOESTE41" if municipality == "DIAMANTEDOOESTE41"
		replace municipality = "ELDORADODOSCARAJAS15" if municipality == "ELDORADODOCARAJAS15"
		replace municipality = "EMBUDASARTES35" if municipality == "EMBU35"
		replace municipality = "EUSEBIO23" if municipality == "EUZEBIO23"
		replace municipality = "FERNANDOPEDROZA24" if municipality == "FERNANDOPEDROSA24"
		replace municipality = "FLORINIA35" if municipality == "FLORINEA35"
		replace municipality = "GOVERNADOREDISONLOBAO21" if municipality == "GOVERNADOREDSONLOBAO21"
		replace municipality = "GRACHOCARDOSO28" if municipality == "GRACCHOCARDOSO28"
		replace municipality = "GRANJEIRO23" if municipality == "GRANGEIRO23"
		replace municipality = "HERVALDOESTE42" if municipality == "HERVALDOOESTE42"
		replace municipality = "ITAGUAJE41" if municipality == "ITAGUAGE41"
		replace municipality = "ITAPEJARADOESTE41" if municipality == "ITAPEJARADOOESTE41"
		replace municipality = "JABOATAODOSGUARARAPES26" if municipality == "JABOATAO26"
		replace municipality = "LAGEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
		replace municipality = "LUIZALVES42" if municipality == "LUISALVES42"
		replace municipality = "LUISDOMINGUESDOMARANHAO21" if municipality == "LUISDOMINGUES21"
		replace municipality = "LUIZIANIA35" if municipality == "LUISIANIA41"
		replace municipality = "MOJIMIRIM35" if municipality == "MOGIMIRIM35"
		replace municipality = "MOREIRASALES41" if municipality == "MOREIRASALLES41"
		replace municipality = "MUNHOZDEMELO41" if municipality == "MUNHOZDEMELLO41"
		replace municipality = "MUQUEMDESAOFRANCISCO29" if municipality == "MUQUEMDOSAOFRANCISCO29"
		replace municipality = "PATYDOALFERES33" if municipality == "PATIDOALFERES33"
		replace municipality = "QUIJINGUE29" if municipality == "QUINJINGUE29"
		replace municipality = "SALMOURAO35" if municipality == "SALMORAO35"
		replace municipality = "SANTANADOITARARE41" if municipality == "SANTAANADOITARARE41"
		replace municipality = "SANTACRUZDEMONTECASTELO41" if municipality == "SANTACRUZDOMONTECASTELO41"
		replace municipality = "SANTAISABELDOIVAI41" if municipality == "SANTAIZABELDOIVAI41"
		replace municipality = "SANTAISABELDOPARA15" if municipality == "SANTAIZABELDOPARA15"
		replace municipality = "SANTAMARIADEJETIBA32" if municipality == "SANTAMARIADOJETIBA32"
		replace municipality = "SANTATERESINHA29" if municipality == "SANTATEREZINHA29"
		replace municipality = "SANTOANTONIODEPOSSE35" if municipality == "SANTOANTONIODAPOSSE35"
		replace municipality = "SAOCAETANO26" if municipality == "SAOCAITANO26"
		replace municipality = "SAODOMINGOSDONORTE32" if municipality == "SAODOMINGOS32"
		replace municipality = "SAOJOSEDOCAMPESTRE24" if municipality == "SAOJOSEDECAMPESTRE24"
		replace municipality = "SAOJOSEDOBREJODOCRUZ25" if municipality == "SAOJOSEDOBREJOCRUZ25"
		replace municipality = "SAOLUIZGONZAGA43" if municipality == "SAOLUISGONZAGA43"
		replace municipality = "SAORAIMUNDODODOCABEZERRA21" if municipality == "SAORAIMUNDODADOCABEZERRA21"
		replace municipality = "SAOSEBASTIAODELAGOADEROCA25" if municipality == "SAOSEB.DELAGOADEROCA25"
		replace municipality = "SAOVICENTEDOSERIDO25" if municipality == "SERIDO25"
		replace municipality = "SENADORLAROCQUE21" if municipality == "SENADORLAROQUE21"
		replace municipality = "TEOTONIOVILELA27" if municipality == "SENADORTEOTONIOVILELA27"
		replace municipality = "SERRACAIADA24" if municipality == "SERRACAIADA24"
		replace municipality = "SUDMENNUCCI35" if municipality == "SUDMENUCCI35"
		replace municipality = "SUZANAPOLIS35" if municipality == "SUZANOPOLIS35"
		replace municipality = "TEJUCUOCA23" if municipality == "TEJUSSUOCA23"
		replace municipality = "TRINDADEDOSUL43" if municipality == "TRINDADE43"
		replace municipality = "VALPARAISO35" if municipality == "VALPARAIZO35"
		replace municipality = "VARRESAI33" if municipality == "VARREESAI33"
		replace municipality = "VISEU15" if municipality == "VIZEU15"
		replace municipality = "LAJEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
		replace municipality = "SENADORCATUNDA23" if municipality == "CATUNDA23"
		replace municipality = "LAGOAALEGRE22" if municipality == "LOGOAALEGRE22"


		*2.8 Now merge cleaned names dataset with Brazil geographical units crosswalk 
		merge m:1 municipality using "brazil_geographical_codes.dta"

		*2.9 Inspect merge failures and make name corrections as above to fix them 
		sort _merge
		
		drop if _merge != 3
		
		*2.10 Drop _merge to clean up dataset and save final dataset with 
		*numeric geographic identifiers attached to cleaned names
		drop _merge
		
		sort municipality 

		gen year = 2007

		save "Population_IBGE_2007", replace 
		
		
*********************************************************************************
use "Population_IBGE_2000", clear 
append using "Population_IBGE_2001", force
append using "Population_IBGE_2002", force
append using "Population_IBGE_2003", force
append using "Population_IBGE_2004", force
append using "Population_IBGE_2005", force
append using "Population_IBGE_2006", force
append using "Population_IBGE_2007", force
append using "Population_IBGE_2008", force
append using "Population_IBGE_2009", force
append using "Population_IBGE_2010", force
append using "Population_IBGE_2011", force
append using "Population_IBGE_2012", force
append using "Population_IBGE_2013", force
append using "Population_IBGE_2014", force
append using "Population_IBGE_2015", force
append using "Population_IBGE_2016", force
append using "Population_IBGE_2017", force

drop uf v6 v7 micro_code meso_code mun_code problem 
sort municipality year

rename population_complete population_IBGE

save "Population_IBGE_Panel", replace 

********************************************************************************
*Bring in and save population from FINBRA 
use "${user}\Data Directory\Public Finances\PublicFinances_1998_2017", clear
keep if year > 1999
destring UF_NO, replace 

merge m:1 municipality using "brazil_geographical_codes.dta"

drop if _merge != 3
drop _merge 
drop munic_code_6digit micro_code meso_code

keep munic_code POPULACAO year
rename POPULACAO population_FINBRA

*Merge with IBGE population data 
merge 1:1 munic_code year using "Population_IBGE_Panel"

order year munic_code municipality population_IBGE population_FINBRA
sort municipality year

drop if _merge == 1

gen population = population_IBGE
replace population = population_FINBRA if population == .

keep year munic_code munic_code_6digit population 

rename population population_complete

************************************
*2007 is still not working, so take average of 2006 and 2008 values for each municipality 
bysort munic_code: egen pop_mean_2006_2008_tmp = mean(population_complete) if year == 2006 | year == 2008
bysort munic_code: egen pop_mean_2006_2008 = max(pop_mean_2006_2008_tmp)
replace population_complete = pop_mean_2006_2008 if year == 2007
drop pop_mean_2006_2008 pop_mean_2006_2008_tmp 


save "Population_Complete_Panel", replace 