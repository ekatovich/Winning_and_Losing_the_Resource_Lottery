*Create prices and discoveries graph
clear
cd "${user}\Data Directory"

*Graph at quarter level
clear
import delimited "Oil Production Value\Brent_Price_Series_Stata.csv"

*Extract year
gen date2 = daily(date, "MDY")
format date2 %td

gen year=year(date2) 
gen quarter = quarter(date2)

egen time_id = group(year quarter)

*Drop years before 2002 quarter 4 to match with data availability on discoveries
drop if year < 2000

*Find average price for each year
destring brent_price_usd, replace
bysort time_id: egen brent_quarter_avg = mean(brent_price_usd)

*Collapse data to annual level
collapse (mean) brent_quarter_avg year quarter, by(time_id)

save "Oil Production Value\Brent_Crude_Price_Series.dta", replace

twoway line brent_quarter_avg time_id

****************************************
*Import and organize discoveries data
use "Discoveries\Discovery_Announcements", clear

gen quarter = quarter(announcement_date) 
gen year = year(announcement_date) 

egen time_id = group(year quarter)

*Save cleaned discoveries data 
save "Discoveries\Discoveries_Timeline_withDates", replace 

collapse (sum) announced_new_volume_mmboe (mean) year quarter, by(time_id)

save "Discoveries\Discoveries_Timeline", replace

******************************************************************************
*Merge two datasets using time_id as common key
merge 1:1 year quarter using "Oil Production Value\Brent_Crude_Price_Series.dta"

sort year quarter 

*Generate year quarter time variable
gen year_quarter = yq(year, quarter)
format year_quarter %tq

drop if year > 2017
drop _merge

grstyle init
grstyle set plain, horizontal compact minor
grstyle set legend 6, nobox
grstyle set color hue, n(3)
*grstyle set color green
grstyle color background white
twoway (bar announced_new_volume_mmboe year_quarter, yaxis(1) ytitle("Millions of Barrels of Oil Equivalent", axis(1)) yscale(range(0 9000))) (line brent_quarter_avg year_quarter, yaxis(2) yscale(range(0 220)) ytitle("Nominal US Dollars", axis(2)) lcolor(black)), legend(label(1 "Size of Announced Discoveries") label(2 "Brent Crude Oil Price")) xtitle("") graphregion(color(white)) xlabel() xscale()


*Plot at year-level 
collapse (mean) brent_quarter_avg (sum) announced_new_volume_mmboe, by(year)

grstyle init
grstyle set plain, horizontal compact minor
grstyle set legend 6, nobox
grstyle set color hue, n(3)
*grstyle set color green
grstyle color background white
twoway (bar announced_new_volume_mmboe year, yaxis(1) ytitle("Millions of Barrels of Oil Equivalent", axis(1)) yscale(range(0 9000))) (line brent_quarter_avg year, yaxis(2) yscale(range(0 220)) ytitle("Nominal US Dollars", axis(2)) lcolor(black)), legend(label(1 "Size of Announced Discoveries") label(2 "Brent Crude Oil Price")) xtitle("") graphregion(color(white)) 

*********************************************************************************
use "Discoveries\Discoveries_Timeline_withDates", clear

collapse (sum) announced_new_volume_mmboe (mean) year quarter, by(time_id field_exploration)

sort year quarter 

*Generate year quarter time variable
gen year_quarter = yq(year, quarter)
format year_quarter %tq

*drop if announced_new_volume_mmboe == 0
drop year quarter time_id 
rename announced_new_volume_mmboe a_

replace field_exploration = "OTHER" if field_exploration == ""

reshape wide a_, i(year_quarter) j(field_exploration) string


local field "a_ALBACORA a_ALBACORALESTE a_ALTODECANAVIEIRAS a_ARUANA a_BALEIAFRANCA a_BARRACUDA a_BEMTEVI a_CARATINGA a_CARCARA a_CARIOCA a_ENTORNODEIARA a_ENTORNODEIARA1  a_ENTORNODEIARA2 a_ENTORNODEIARA3 a_FARFAN a_FLORIM a_FRANCO a_GOLFINHO a_GRANAPADANO a_GUARA a_IARA a_JUBARTE a_JUPITER a_LIBRA a_MARIMBA a_MARLIM a_MARLIMLESTE a_MARLIMSUL a_MARUJA a_MURIU a_NATAL a_NEDETUPI a_OLIVA a_PAMPO a_PAODEACUCAR a_PAPATERRA a_PARATI a_PARQUEDASBALEIAS a_PIRACUCA a_PIRANEMA a_PITU a_POCOVERDE a_SULDEGUARA a_SULDETUPI a_TIROESIDON a_TUPI a_WAIKIKI a_OTHER"
foreach j of local field {
	replace `j' = 0 if `j' == .
}

/*
levelsof year_quarter, local(times)
foreach time of local times {
    label define T `time' `"`= strofreal(`time',"%tq")'"', add
}
label values year_quarter T
*/
/*
local call
. forvalues j = 1/60 {
2. local show = `j´ + 170
3. if mod(`j´, 2) local call `call´ `j´ "`show´"
4. else local call `call´ `j´ " "
5. }
*/
*a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU + a_POCOVERDE + a_SULDEGUARA + a_SULDETUPI + a_TIROESIDON + a_TUPI + a_WAIKIKI + a_OTHER

gen a_1 = a_ALBACORA
gen a_2 = a_ALBACORA + a_ALBACORALESTE
gen a_3 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS
gen a_4 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA
gen a_5 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA
gen a_6 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA
gen a_7 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI
gen a_8 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA
gen a_9 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA
gen a_10 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA
gen a_11 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA
gen a_12 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1
gen a_13 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2
gen a_14 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3
gen a_15 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN
gen a_16 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM
gen a_17 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO
gen a_18 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO
gen a_19 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO
gen a_20 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA
gen a_21 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA
gen a_22 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE
gen a_23 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER
gen a_24 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA
gen a_25 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA
gen a_26 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM
gen a_27 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE
gen a_28 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL
gen a_29 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA
gen a_30 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU 
gen a_31 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL
gen a_32 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI
gen a_33 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA
gen a_34 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO
gen a_35 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR
gen a_36 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA
gen a_37 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI
gen a_38 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS
gen a_39 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA 
gen a_40 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA
gen a_41 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU
gen a_42 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU + a_POCOVERDE
gen a_43 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU + a_POCOVERDE + a_SULDEGUARA
gen a_44 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU + a_POCOVERDE + a_SULDEGUARA + a_SULDETUPI
gen a_45 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU + a_POCOVERDE + a_SULDEGUARA + a_SULDETUPI + a_TIROESIDON
gen a_46 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU + a_POCOVERDE + a_SULDEGUARA + a_SULDETUPI + a_TIROESIDON + a_TUPI
gen a_47 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU + a_POCOVERDE + a_SULDEGUARA + a_SULDETUPI + a_TIROESIDON + a_TUPI + a_WAIKIKI
gen a_48 = a_ALBACORA + a_ALBACORALESTE + a_ALTODECANAVIEIRAS + a_ARUANA + a_BALEIAFRANCA + a_BARRACUDA + a_BEMTEVI + a_CARATINGA + a_CARCARA + a_CARIOCA + a_ENTORNODEIARA + a_ENTORNODEIARA1 + a_ENTORNODEIARA2 + a_ENTORNODEIARA3 + a_FARFAN + a_FLORIM + a_FRANCO + a_GOLFINHO + a_GRANAPADANO + a_GUARA + a_IARA + a_JUBARTE + a_JUPITER + a_LIBRA + a_MARIMBA + a_MARLIM + a_MARLIMLESTE + a_MARLIMSUL + a_MARUJA + a_MURIU + a_NATAL + a_NEDETUPI + a_OLIVA + a_PAMPO + a_PAODEACUCAR + a_PAPATERRA + a_PARATI + a_PARQUEDASBALEIAS + a_PIRACUCA + a_PIRANEMA + a_PITU + a_POCOVERDE + a_SULDEGUARA + a_SULDETUPI + a_TIROESIDON + a_TUPI + a_WAIKIKI + a_OTHER


grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 3, nobox
*grstyle set color #bd1e24, luminate(10(5)100, level) name(Luminance 10-100)
grstyle set color HSV intense
grstyle set inten 10: bar
grstyle set compact
twoway bar a_48 year_quarter || bar a_47 year_quarter || bar a_46 year_quarter || bar a_45 year_quarter || bar a_44 year_quarter || bar a_43 year_quarter || bar a_42 year_quarter || bar a_41 year_quarter || bar a_40 year_quarter || bar a_39 year_quarter || bar a_38 year_quarter || bar a_37 year_quarter || bar a_36 year_quarter || bar a_35 year_quarter || bar a_34 year_quarter || bar a_33 year_quarter || bar a_32 year_quarter || bar a_31 year_quarter || bar a_30 year_quarter || bar a_29 year_quarter || bar a_28 year_quarter || bar a_27 year_quarter || bar a_26 year_quarter || bar a_25 year_quarter || bar a_24 year_quarter || bar a_23 year_quarter || bar a_22 year_quarter || bar a_21 year_quarter || bar a_20 year_quarter || bar a_19 year_quarter || bar a_18 year_quarter || bar a_17 year_quarter || bar a_16 year_quarter || bar a_15 year_quarter || bar a_14 year_quarter || bar a_13 year_quarter || bar a_12 year_quarter || bar a_11 year_quarter || bar a_10 year_quarter || bar a_9 year_quarter || bar a_8 year_quarter || bar a_7 year_quarter || bar a_6 year_quarter || bar a_5 year_quarter || bar a_4 year_quarter || bar a_3 year_quarter || bar a_2 year_quarter || bar a_1 year_quarter || (pcarrowi 4280 186.3 4100 191, color(black), size(vsmall), msize(vtiny)) || (pcarrowi 6570 197 6000 192, color(black), size(vsmall), msize(vtiny)) || (pcarrowi 4970 206.3 4600 203 , color(black), size(vsmall), msize(vtiny)) || (pcarrowi 4880 197 4000 201, color(black), size(vsmall), msize(vtiny)) || (pcarrowi 2600 196.15 2400 194, color(black), size(vsmall), msize(vtiny)) || (pcarrowi 2890 219 2600 214, color(black), size(vsmall), msize(vtiny)) , legend(off) ytitle("Millions of Barrels of Oil Equivalent") xtitle("") xlabel(170 (8) 230) text(4300 185 "TUPI", size(vsmall)) text(6700 197 "JUPITER", size(vsmall)) text(2600 197.5 "IARA", size(vsmall)) text(5000 197 "FRANCO", size(vsmall)) text(5000 208 "LIBRA", size(vsmall)) text(3000 219 "BARRA", size(vsmall)) 





