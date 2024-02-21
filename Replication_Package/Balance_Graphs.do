
clear 
import excel "${user}\Data Directory\Texts\Balance_Samples.xlsx", sheet("Sheet1") firstrow clear

drop if relative_time < -15
drop if relative_time > 15

graph drop _all

grstyle init
grstyle set plain, noextend
grstyle set legend 6, nobox
grstyle set color cranberry green
grstyle set inten 60
twoway (bar all_num_disappointed relative_time) (bar all_num_satisfied relative_time) (scatteri 0 10.5 35 10.5, c(l) m(i) lcolor(black)) (scatteri 0 -5.5 35 -5.5, c(l) m(i) lcolor(black)), xscale(r(-15 15)) xtitle("Years Relative to First Discovery Announcement") ytitle("Number of Treated Units") legend(order(1 "Disappointed" 2 "Satisfied")) ylabel(0 (5) 35) xlabel(-15 (5) 15) title("Coastal State Municipalities", size(medium small)) name(balance_all)

grstyle init
grstyle set plain, noextend
grstyle set legend 6, nobox
grstyle set color cranberry green
grstyle set inten 60
twoway (bar match_num_disappointed match_num_satisfied relative_time) (scatteri 0 10.5 35 10.5, c(l) m(i) lcolor(black)) (scatteri 0 -5.5 35 -5.5, c(l) m(i) lcolor(black)), xscale(r(-15 15)) xtitle("Years Relative to First Discovery Announcement") legend(order(1 "Disappointed" 2 "Satisfied")) ylabel(0 (5) 35) xlabel(-15 (5) 15) title("Matched Municipalities", size(medium small)) name(balance_matched)

grc1leg2 balance_all balance_matched 

*********************************************8
graph drop _all

*Graph disappointed and satisfied separately 
grstyle init
grstyle set plain, noextend
grstyle set color cranberry
grstyle set inten 60
twoway (bar all_num_disappointed relative_time) (scatteri 0 10.5 35 10.5, c(l) m(i) lcolor(black)) (scatteri 0 -5.5 35 -5.5, c(l) m(i) lcolor(black)), xscale(r(-15 15)) xtitle("Years Relative to First Discovery Announcement") ytitle("Number of Treated Units") ylabel(0 (5) 35) xlabel(-15 (5) 15) title("Disappointed Municipalities", size(medium small)) name(balance_disappointed) legend(off)

grstyle init
grstyle set plain, noextend
grstyle set color green
grstyle set inten 60
twoway (bar all_num_satisfied relative_time) (scatteri 0 10.5 35 10.5, c(l) m(i) lcolor(black)) (scatteri 0 -5.5 35 -5.5, c(l) m(i) lcolor(black)), xscale(r(-15 15)) xtitle("Years Relative to First Discovery Announcement") ytitle("Number of Treated Units") ylabel(0 (5) 35) xlabel(-15 (5) 15) title("Satisfied Municipalities", size(medium small)) name(balance_satisfied) legend(off)

graph combine balance_disappointed balance_satisfied, name(balance_graphs)
graph display balance_graphs, ysize(4) xsize(8)

*********************************************************************************
*Create balance for specific baseline variables 
*All coastal state municipalities
use "Event_Analysis_Matching_FirstEvent", clear

*First analyze treated units 
keep if disappointed_pc_low == 1 | disappointed_pc_low == 2

*Create relative time indicator 
*First for treated units
drop relative_time
gen relative_time = .
replace relative_time = 0 if event_time_0 == 1
replace relative_time = 1 if event_time_1a == 1
replace relative_time = 2 if event_time_2a == 1
replace relative_time = 3 if event_time_3a == 1
replace relative_time = 4 if event_time_4a == 1
replace relative_time = 5 if event_time_5a == 1
replace relative_time = 6 if event_time_6a == 1
replace relative_time = 7 if event_time_7a == 1
replace relative_time = 8 if event_time_8a == 1
replace relative_time = 9 if event_time_9a == 1
replace relative_time = 10 if event_time_10a == 1
replace relative_time = 11 if event_time_11a == 1
replace relative_time = 12 if event_time_12a == 1
replace relative_time = 13 if event_time_13a == 1
replace relative_time = 14 if event_time_14a == 1
replace relative_time = 15 if event_time_15a == 1

replace relative_time = -1 if event_time_1b == 1
replace relative_time = -2 if event_time_2b == 1
replace relative_time = -3 if event_time_3b == 1
replace relative_time = -4 if event_time_4b == 1
replace relative_time = -5 if event_time_5b == 1
replace relative_time = -6 if event_time_6b == 1
replace relative_time = -7 if event_time_7b == 1
replace relative_time = -8 if event_time_8b == 1
replace relative_time = -9 if event_time_9b == 1
replace relative_time = -10 if event_time_10b == 1
replace relative_time = -11 if event_time_11b == 1
replace relative_time = -12 if event_time_12b == 1
replace relative_time = -13 if event_time_13b == 1
replace relative_time = -14 if event_time_14b == 1
replace relative_time = -15 if event_time_15b == 1

*Find year 2000 values for variables of interest 
bysort munic_code: gen urban_share_2000_t = urban_share if year == 2000
bysort munic_code: gen ihs_population_complete_2000_t = ihs_population_complete if year == 2000
bysort munic_code: egen urban_share_2000 = max(urban_share_2000_t)
bysort munic_code: egen ihs_population_complete_2000 = max(ihs_population_complete_2000_t)
drop urban_share_2000_t ihs_population_complete_2000_t

keep munic_code year relative_time disappointed_pc_low latitude ihs_population_complete_2000 ihs_gdp_2002 ifdm_2000 urban_share_2000
sort munic_code year

********************************
*Disappointed
local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum latitude if relative_time == `j' & disappointed_pc_low == 1
}

local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum ihs_population_complete_2000 if relative_time == `j' & disappointed_pc_low == 1
}

local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum ifdm_2000 if relative_time == `j' & disappointed_pc_low == 1
}

local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum ihs_gdp_2002 if relative_time == `j' & disappointed_pc_low == 1
}

*local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
*foreach j of local relative {
*	sum urban_share_2000 if relative_time == `j' & disappointed_pc_low == 1
*}

*************************************
*Satisfied
local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum latitude if relative_time == `j' & disappointed_pc_low == 2
}

local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum ihs_population_complete_2000 if relative_time == `j' & disappointed_pc_low == 2
}

local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum ifdm_2000 if relative_time == `j' & disappointed_pc_low == 2
}

local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum ihs_gdp_2002 if relative_time == `j' & disappointed_pc_low == 2
}

local relative "-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
foreach j of local relative {
	sum urban_share_2000 if relative_time == `j' & disappointed_pc_low == 2
}

*Import balance variables 
clear
import excel "${user}\Data Directory\Texts\Balance_Variables_Disappointed.xlsx", sheet("Sheet1") firstrow 

*Reshape 
reshape long t, i(variable) j(relative_time)

drop if relative_time < 2
drop if relative_time > 29
replace relative_time = relative_time - 15

graph drop _all 

grstyle init
grstyle set plain, noextend
grstyle set color cranberry
grstyle set inten 60
twoway line t relative_time if variable == "GDP per capita", xscale(r(-13 14)) xlabel(-13 (1) 14, labsize(small)) yscale(r(10 15)) ylabel(10 (5) 15, labsize(medlarge)) xline(-5 10, lcolor(black) lpattern(dash)) xtitle("") ytitle("asinh(BRL$)", size(medlarge)) title("GDP", size(medlarge)) name(gdp) legend(off)

grstyle init
grstyle set plain, noextend
grstyle set color cranberry
grstyle set inten 60
twoway line t relative_time if variable == "Latitude", xscale(r(-13 14)) xlabel(-13 (1) 14, labsize(small)) yscale(r(-24 -10)) ylabel(-24 (14) -10, labsize(medlarge)) xline(-5 10, lcolor(black) lpattern(dash)) xtitle("") ytitle("Degrees", size(medlarge)) title("Latitude", size(medlarge)) name(latitude)

grstyle init
grstyle set plain, noextend
grstyle set color cranberry
grstyle set inten 60
twoway line t relative_time if variable == "Population", xscale(r(-13 14)) xlabel(-13 (1) 14, labsize(small)) yscale(r(9 13)) ylabel(9 (4) 13, labsize(medlarge)) xline(-5 10, lcolor(black) lpattern(dash)) xtitle("") ytitle("asinh(Population)", size(medlarge)) title("Population", size(medlarge)) name(population)

grstyle init
grstyle set plain, noextend
grstyle set color cranberry
grstyle set inten 60
twoway line t relative_time if variable == "Municipal Development Index", xscale(r(-13 14)) xlabel(-13 (1) 14, labsize(small)) yscale(r(.45 .7)) ylabel(.45 (0.25) .7, labsize(medlarge))xline(-5 10, lcolor(black) lpattern(dash)) xtitle("") ytitle("Index Score", size(medlarge)) title("Municipal Development Index", size(medlarge)) name(mdi) xtitle("Years Relative to First Discovery Announcement", size(medlarge)) 

graph combine latitude gdp population mdi, cols(1) name(balance_vars_disappointment)
graph display balance_vars_disappointment, ysize(6) xsize(5)

*Repeat for satisfied 
*Import balance variables 
clear
import excel "${user}\Data Directory\Texts\Balance_Variables_Satisfied.xlsx", sheet("Sheet1") firstrow 

*Reshape 
reshape long t, i(variable) j(relative_time)

drop if relative_time < 3
replace relative_time = relative_time - 15

graph drop _all 

grstyle init
grstyle set plain, noextend
grstyle set color green
grstyle set inten 60
twoway line t relative_time if variable == "GDP per capita", xscale(r(-13 15)) xlabel(-13 (1) 15, labsize(small)) yscale(r(10 15)) ylabel(10 (5) 15, labsize(medlarge)) xline(-5 10, lcolor(black) lpattern(dash)) xtitle("") ytitle("asinh(BRL$)", size(medlarge)) title("GDP", size(medlarge)) name(gdp) legend(off)

grstyle init
grstyle set plain, noextend
grstyle set color green
grstyle set inten 60
twoway line t relative_time if variable == "Latitude", xscale(r(-13 14)) xlabel(-13 (1) 14, labsize(small)) yscale(r(-24 -10)) ylabel(-24 (14) -10, labsize(medlarge)) xline(-5 10, lcolor(black) lpattern(dash)) xtitle("") ytitle("Degrees", size(medlarge)) title("Latitude", size(medlarge)) name(latitude)

grstyle init
grstyle set plain, noextend
grstyle set color green
grstyle set inten 60
twoway line t relative_time if variable == "Population", xscale(r(-13 14)) xlabel(-13 (1) 14, labsize(small)) yscale(r(9 13)) ylabel(9 (4) 13, labsize(medlarge)) xline(-5 10, lcolor(black) lpattern(dash)) xtitle("") ytitle("asinh(Population)", size(medlarge)) title("Population", size(medlarge)) name(population)

grstyle init
grstyle set plain, noextend
grstyle set color green
grstyle set inten 60
twoway line t relative_time if variable == "Municipal Development Index", xscale(r(-13 14)) xlabel(-13 (1) 14, labsize(small)) yscale(r(.45 .7)) ylabel(.45 (0.25) .7, labsize(medlarge)) xline(-5 10, lcolor(black) lpattern(dash)) xtitle("") ytitle("Index Score", size(medlarge)) title("Municipal Development Index", size(medlarge)) name(mdi) xtitle("Years Relative to First Discovery Announcement", size(medlarge)) 

graph combine latitude gdp population mdi, cols(1) name(balance_vars_satisfied)
graph display balance_vars_satisfied, ysize(6) xsize(5)