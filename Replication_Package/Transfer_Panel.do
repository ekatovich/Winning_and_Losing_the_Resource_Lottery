clear
cd "${user}\Data Directory\Public Finances\Transfers"

local years1 "2000 2001 2002 2003 2004 2005"
foreach i of local years1 {

import delimited "${user}\Data Directory\Public Finances\Transfers\TransferenciaMensalMunicipios`i'.csv.csv", encoding(ISO-8859-2) clear

rename município municipality
rename ano year
rename męs month
rename şdecęndio first_transfer
rename v6 second_transfer
rename v7 third_transfer
rename itemtransferęncia transfer_item
rename transferęncia transfer
drop v10

collapse (firstnm) year uf (sum) first_transfer second_transfer third_transfer, by(municipality transfer)

*Sum transfers 
gen transfer_value = first_transfer + second_transfer + third_transfer

save "Transfers_Raw_`i'", replace
}


local years1 "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015"
foreach i of local years1 {

import delimited "${user}\Data Directory\Public Finances\Transfers\TransferenciaMunicipios`i'.csv.csv", encoding(ISO-8859-2) clear

rename município municipality
rename ano year
rename męs month
rename şdecęndio first_transfer
rename v6 second_transfer
rename v7 third_transfer
rename itemtransferęncia transfer_item
rename transferęncia transfer
drop v10

collapse (firstnm) year uf (sum) first_transfer second_transfer third_transfer, by(municipality transfer)

*Sum transfers 
gen transfer_value = first_transfer + second_transfer + third_transfer

save "Transfers_Raw_`i'", replace
}

************************************************************************************

*Import and clean 2016-2017 files

import delimited "${user}\Data Directory\Public Finances\Transfers\TransferenciaMunicipiosjan-jul2016.csv.csv", clear
rename município municipality
rename ano year
rename mês month
rename ºdecêndio first_transfer
rename v6 second_transfer
rename v7 third_transfer
rename itemtransferência transfer_item
rename transferência transfer
drop v10
save "Transfers_2016first7", replace


local months "08 09 10 11 12"
foreach i of local months {

import delimited "${user}\Data Directory\Public Finances\Transfers\TransferenciaMensalMunicipios2016`i'.csv.csv", encoding(ISO-8859-2) clear

rename município municipality
rename ano year
rename męs month
rename şdecęndio first_transfer
rename v6 second_transfer
rename v7 third_transfer
rename itemtransferęncia transfer_item
rename transferęncia transfer
drop v10

save "Transfers_2016month`i'", replace
}

local months "01 02 03 04 05 06 07 08 09 10 11 12"
foreach i of local months {

import delimited "${user}\Data Directory\Public Finances\Transfers\TransferenciaMensalMunicipios2017`i'.csv.csv", encoding(ISO-8859-2) clear

rename município municipality
rename ano year
rename męs month
rename şdecęndio first_transfer
rename v6 second_transfer
rename v7 third_transfer
rename itemtransferęncia transfer_item
rename transferęncia transfer
drop v10

save "Transfers_2017month`i'", replace
}

*Append monthly files for 2016 and 2017 
use "Transfers_2016first7", clear
append using "Transfers_2016month08", force
append using "Transfers_2016month09", force
append using "Transfers_2016month10", force
append using "Transfers_2016month11", force
append using "Transfers_2016month12", force

collapse (firstnm) year uf (sum) first_transfer second_transfer third_transfer, by(municipality transfer)

*Sum transfers 
gen transfer_value = first_transfer + second_transfer + third_transfer

save "Transfers_Raw_2016", replace

use "Transfers_2017month01", clear
append using "Transfers_2017month02", force
append using "Transfers_2017month03", force
append using "Transfers_2017month04", force
append using "Transfers_2017month05", force
append using "Transfers_2017month06", force
append using "Transfers_2017month07", force
append using "Transfers_2017month08", force
append using "Transfers_2017month09", force
append using "Transfers_2017month10", force
append using "Transfers_2017month11", force
append using "Transfers_2017month12", force

collapse (firstnm) year uf (sum) first_transfer second_transfer third_transfer, by(municipality transfer)

*Sum transfers 
gen transfer_value = first_transfer + second_transfer + third_transfer

save "Transfers_Raw_2017", replace

*******************************************************************************
*Append annual raw files into panel

use "Transfers_Raw_2000", clear
append using "Transfers_Raw_2001", force
append using "Transfers_Raw_2002", force
append using "Transfers_Raw_2003", force
append using "Transfers_Raw_2004", force
append using "Transfers_Raw_2005", force
append using "Transfers_Raw_2006", force
append using "Transfers_Raw_2007", force
append using "Transfers_Raw_2008", force
append using "Transfers_Raw_2009", force
append using "Transfers_Raw_2010", force
append using "Transfers_Raw_2011", force
append using "Transfers_Raw_2012", force
append using "Transfers_Raw_2013", force
append using "Transfers_Raw_2014", force
append using "Transfers_Raw_2015", force
append using "Transfers_Raw_2016", force
append using "Transfers_Raw_2017", force

drop first_transfer second_transfer third_transfer
sort municipality year

save "Transfers_Raw_2000_to_2017", replace

********************************************************************************
*Transform each transfer into a separate column 
use "Transfers_Raw_2000_to_2017", clear
*Types of transfer:  AFM/AFE CIDE-Combustíveis FEX FPM FUNDEB FUNDEF IOF-Ouro ITR LC 87/96 (Lei Kandir) Royalties 
bysort municipality year: gen AFM_AFE = transfer_value if transfer == "AFM/AFE"
bysort municipality year: gen CIDE_fuel = transfer_value if transfer == "CIDE-Combustíveis"
bysort municipality year: gen FEX = transfer_value if transfer == "FEX"
bysort municipality year: gen FPM = transfer_value if transfer == "FPM"
bysort municipality year: gen FUNDEB = transfer_value if transfer == "FUNDEB"
bysort municipality year: gen FUNDEF = transfer_value if transfer == "FUNDEF"
bysort municipality year: gen IOF_ouro = transfer_value if transfer == "IOF-Ouro"
bysort municipality year: gen ITR = transfer_value if transfer == "ITR"
bysort municipality year: gen LeiKandir = transfer_value if transfer == "LC 87/96 (Lei Kandir)"
bysort municipality year: gen Royalties = transfer_value if transfer == "Royalties"

collapse (firstnm) uf AFM_AFE CIDE_fuel FEX FPM FUNDEB FUNDEF IOF_ouro ITR LeiKandir Royalties (sum) transfer_value, by(municipality year)

rename transfer_value total_transfers
local transfers "AFM_AFE CIDE_fuel FEX FPM FUNDEB FUNDEF IOF_ouro ITR LeiKandir Royalties"
foreach j of local transfers {
replace `j' = 0 if `j' == .
}

gen transfers_nonroyalty = AFM_AFE + CIDE_fuel + FEX + FPM + FUNDEB + FUNDEF + IOF_ouro + ITR + LeiKandir

***********************************************************************************
*Deflate monetary values to constant 2010 reais using the IBGE Indice Nacional de Precos ao Consumidor:
*https://www.ibge.gov.br/estatisticas/economicas/precos-e-custos/9258-indice-nacional-de-precos-ao-consumidor.html?t=downloads
local transfer_vars "AFM_AFE CIDE_fuel FEX FPM FUNDEB FUNDEF IOF_ouro ITR LeiKandir Royalties total_transfers transfers_nonroyalty"
foreach i of local transfer_vars {

replace `i' = (`i'/51.14760814)*100 if year == 2000
replace `i' = (`i'/53.93022184)*100 if year == 2001 
replace `i' = (`i'/59.19750637)*100 if year == 2002
replace `i' = (`i'/68.86416877)*100 if year == 2003
replace `i' = (`i'/74.79838452)*100 if year == 2004
replace `i' = (`i'/79.18080109)*100 if year == 2005 
replace `i' = (`i'/83.01981592)*100 if year == 2006 
replace `i' = (`i'/85.44880247)*100 if year == 2007
replace `i' = (`i'/90.03283452)*100 if year == 2008 
replace `i' = (`i'/95.82015899)*100 if year == 2009 
replace `i' = (`i'/100)*100 if year == 2010
replace `i' = (`i'/106.5285014)*100 if year == 2011
replace `i' = (`i'/112.5241619)*100 if year == 2012
replace `i' = (`i'/119.9852149)*100 if year == 2013
replace `i' = (`i'/126.2957795)*100 if year == 2014
replace `i' = (`i'/135.2948706)*100 if year == 2015
replace `i' = (`i'/150.5955657)*100 if year == 2016
replace `i' = (`i'/158.7811544)*100 if year == 2017
}


********************************************************************************
*Clean and regularize municipality names 

*First, create UF_NO 
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
		
		rename municipality munic 
		
		*Remove all accents and special characters from munic using ustrnormalize:
				replace munic = ustrto(ustrnormalize(munic, "nfd"), "ascii", 2)	
				*Remove hyphens, apostrophes, and spaces	
				replace munic =subinstr(munic,"-","",.)
				replace munic =subinstr(munic,"'","",.)
				replace munic =subinstr(munic," ","",.)	
				*Convert all letters to uppercase
				replace munic = upper(munic)
				
				
				*Generate unique municipality-state text identifier
			egen municipality = concat(munic UF_NO) 
			drop munic 
			order municipality UF_NO 
			
			*Correct common naming variations to improve merging
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


		*Collapse again to fix naming duplication 
		collapse (firstnm) uf UF_NO (sum) AFM_AFE CIDE_fuel FEX FPM FUNDEB FUNDEF IOF_ouro ITR LeiKandir Royalties total_transfers transfers_nonroyalty, by(municipality year)
		
		*Now merge cleaned names dataset with Brazil geographical units crosswalk 
		merge m:1 municipality using "${user}\Data Directory\Treatment Variables\brazil_geographical_codes.dta"

		*Inspect merge failures and make name corrections as above to fix them 
		sort _merge
		drop if _merge != 3
		
		*Drop _merge to clean up dataset and save final dataset with 
		*numeric geographic identifiers attached to cleaned names
		drop _merge

	sort municipality year
	drop micro_code meso_code

*This dataset contains municipality-year level disaggregated federal > municipality transfers for years 2000-2015, deflated to constant 2010 BRL.
save "Transfers_Disaggregated_2000_to_2017", replace 












