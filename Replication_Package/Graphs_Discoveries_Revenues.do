
clear 
cd "${user}\Data Directory\Treatment Variables"

use "Munics_Affected_by_Oil", clear

*Plot cumulative CVM announcements and volumes for affected municipalities 
keep if cvm_announcements_2000_2017 > 0

twoway (line cum_cvm_announcements year), by(municipality)

graph drop _all
local munics "ANCHIETA32 ANGRADOSREIS33 ARACAJU28 ARACRUZ32 ARARUAMA33 AREIABRANCA24 ARMACAODOSBUZIOS33 ARRAIALDOCABO33 BALNEARIOCAMBORIU42 BARRADOSCOQUEIROS28 CABOFRIO33 CAMPOSDOSGOYTACAZES33 CANANEIA35 CANAVIEIRAS29 CARAGUATATUBA35 CASIMIRODEABREU33 FUNDAO32 IGUAPE35 ILHABELA35 ILHACOMPRIDA35 ITANHAEM35 ITAPEMA42 ITAPEMIRIM32 ITAPORANGADAJUDA28 LINHARES32 MACAE33 MANGARATIBA33 MARATAIZES32 MARICA33 MONGAGUA35 NITEROI33 PACATUBA28 PARACURU23 PARATI33 PERUIBE35 PIRAMBU28 PRESIDENTEKENNEDY32 QUISSAMA33 RIODASOSTRAS33 RIODEJANEIRO33 SAOSEBASTIAO35 SAQUAREMA33 SERRA32 UBATUBA35 UNA29 VILAVELHA32 VITORIA32"
foreach i of local munics {

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(4)
twoway line cum_cvm_announcements year if municipality == "`i'", yaxis(1) yscale(range(0 25) axis(1)) ylabel(0 (5) 25, axis(1)) ytitle("Cumulative CVM Announcements") || line oil_revenue year if municipality == "`i'", yaxis(2) yscale(range(0 120000000) axis(2)) ylabel(0 (20000000) 120000000, axis(2)) ytitle("Annual Oil Revenue", axis(2)) title("`i'") xtitle("Year")  legend(order(1 "Cumulative CVM Announcements" 2 "Oil Revenues")) name(`i')

}

***********************************************************************************
use "Munics_Affected_by_Oil", clear

*Plot cumulative announced discovery volume for affected muncipalities
keep if volume_announced_2000_2017 > 0

twoway (line cum_volume_announced year), by(municipality)


graph drop _all
local munics "ANCHIETA32 ARACAJU28 ARACRUZ32 ARARUAMA33 ARMACAODOSBUZIOS33 ARRAIALDOCABO33 CABOFRIO33 CAMPOSDOSGOYTACAZES33 CANANEIA35 CASIMIRODEABREU33 ILHABELA35 ITANHAEM35 ITAPEMIRIM32 ITAPORANGADAJUDA28 MACAE33 MARATAIZES32 MARICA33 MONGAGUA35 NITEROI33 PACATUBA28 PRESIDENTEKENNEDY32 QUISSAMA33 RIODASOSTRAS33 SAOSEBASTIAO35 SAQUAREMA33 SERRA32 UBATUBA35"
foreach i of local munics {

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(4)
twoway line cum_volume_announced year if municipality == "`i'", yaxis(1) yscale(range(0 25) axis(1)) ylabel(0 (2000) 12000, axis(1)) ytitle("Cumulative Volume Announced") || line oil_revenue year if municipality == "`i'", yaxis(2) yscale(range(0 120000000) axis(2)) ylabel(0 (20000000) 120000000, axis(2)) ytitle("Annual Oil Revenue", axis(2)) title("`i'") xtitle("Year")  legend(order(1 "Cumulative Volume Announced" 2 "Oil Revenues")) name(`i'_Volume)

}

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(4)
twoway line cum_volume_announced year if municipality == "MARICA33", yaxis(1) yscale(range(0 ) axis(1)) ylabel(0 (2000) 17000, axis(1)) ytitle("Cumulative CVM Announcements") || line oil_revenue year if municipality == "MARICA33", yaxis(2) yscale(range(0 120000000) axis(2)) ylabel(0 (20000000) 120000000, axis(2)) ytitle("Annual Oil Revenue", axis(2)) title("MARICA33") xtitle("Year")  legend(order(1 "Cumulative CVM Announcements" 2 "Oil Revenues")) name(MARICA33_Volume) 


twoway line cum_volume_announced year if municipality == "ILHABELA35", ytitle("Cumulative CVM Announcements") || line cum_oil_revenue year if municipality == "ILHABELA35", yaxis(2) yscale(range(0 1200000000) axis(2)) ytitle("Cumulative Oil Revenue", axis(2))

twoway line cum_volume_announced year if municipality == "MARICA33", ytitle("Cumulative CVM Announcements") || line cum_oil_revenue year if municipality == "MARICA33", yaxis(2) yscale(range(0 1200000000) axis(2)) ytitle("Cumulative Oil Revenue", axis(2))

twoway line cum_volume_announced year if municipality == "ARACAJU28", ytitle("Cumulative CVM Announcements") || line cum_oil_revenue year if municipality == "ARACAJU28", yaxis(2) yscale(range(0 1200000000) axis(2)) ytitle("Cumulative Oil Revenue", axis(2))

twoway line cum_volume_announced year if municipality == "ITAPEMIRIM32", ytitle("Cumulative CVM Announcements") || line cum_oil_revenue year if municipality == "ITAPEMIRIM32", yaxis(2) yscale(range(0 1200000000) axis(2)) ytitle("Cumulative Oil Revenue", axis(2))

***********************************************************************************
use "Munics_Affected_by_Oil", clear

*Plot cumulative hydrocarbon detections 
keep if hydrocarbon_detections_2000_2017 > 0

twoway (line cum_hydrocarbons_detected year), by(municipality)

graph drop _all
local munics "ANCHIETA32	ANGRADOSREIS33	AQUIRAZ23	ARACAJU28	ARACATI23	ARACRUZ32	ARARUAMA33	AREIABRANCA24	ARMACAODOSBUZIOS33	ARRAIALDOCABO33	BALNEARIOCAMBORIU42	BARRADOSCOQUEIROS28	BARREIRINHAS21	BEBERIBE23	BERTIOGA35	BREJOGRANDE28	CABOFRIO33	CAIRU29	CAMPOSDOSGOYTACAZES33	CANANEIA35	CANAVIEIRAS29	CARAGUATATUBA35	CARAPEBUS33	CASIMIRODEABREU33	FUNDAO32	GUAMARE24	GUARAPARI32	GUARUJA35	HUMBERTODECAMPOS21	ICAPUI23	IGUAPE35	ILHABELA35	ILHACOMPRIDA35	ITACARE29	ITAJAI42	ITANHAEM35	ITAPEMA42	ITAPEMIRIM32	ITAPORANGADAJUDA28	ITUBERA29	LINHARES32	MACAE33	MACAU24	MANGARATIBA33	MARATAIZES32	MARAU29	MARICA33	MONGAGUA35	NAVEGANTES42	NITEROI33	PACATUBA28	PARACURU23	PARAIPABA23	PARATI33	PERUIBE35	PIRAMBU28	PIUMA32	PORTODOMANGUE24	PORTORICODOMARANHAO21	PRADO29	PRAIAGRANDE35	PRESIDENTEKENNEDY32	QUISSAMA33	RIODASOSTRAS33	RIODEJANEIRO33	SAOJOAODABARRA33	SAOSEBASTIAO35	SAQUAREMA33	SERRA32	TIBAU24	TRACUATEUA15	UBATUBA35	UNA29	VALENCA29	VILAVELHA32	VITORIA32"
foreach i of local munics {

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color hue, n(4)
twoway line cum_hydrocarbons_detected year if municipality == "`i'", yaxis(1) yscale(range(0 25) axis(1)) ylabel(0 (10) 100, axis(1)) ytitle("Cumulative Hydrocarbon Detections") || line oil_revenue year if municipality == "`i'", yaxis(2) yscale(range(0 120000000) axis(2)) ylabel(0 (20000000) 120000000, axis(2)) ytitle("Annual Oil Revenue", axis(2)) title("`i'") xtitle("Year")  legend(order(1 "Cumulative Hydrocarbon Detections" 2 "Oil Revenues")) name(`i'_Hydro)

}


***********************************************************************************
use "Munics_Affected_by_Oil", clear

*Plot cumulative well completions
keep if wells_completed_2000_2017 > 0

twoway (line cum_wells_completed year), by(municipality)


***********************************************************************************
use "Munics_Affected_by_Oil", clear

*Plot cumulative successful wells 
keep if successful_wells_2000_2017 > 0

twoway (line cum_successful_wells year), by(municipality)