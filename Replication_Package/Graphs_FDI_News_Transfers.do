
*Import data on discovery announcements 
use "${user}\Data Directory\Discoveries\Discovery_Announcements", clear

gen quarter = quarter(announcement_date) 
gen year = year(announcement_date) 

egen time_id = group(year quarter)

collapse (sum) announced_new_volume_mmboe (mean) year quarter, by(time_id)

*Collapse to year level 
collapse (sum) announced_new_volume_mmboe, by(year)

save "${user}\Data Directory\Discoveries\AnnualDiscoveries", replace 

*save "Discoveries\Discoveries_Timeline", replace

********************************************
clear
import delimited "${user}\Data Directory\Texts\FDI.csv", encoding(UTF-8)

local vars "argentina brazil chile colombia mexico peru"
foreach i of local vars {
	replace `i' = `i' / 1000000000
}

*Merge with annual discoveries 
merge 1:1 year using "${user}\Data Directory\Discoveries\AnnualDiscoveries"
drop _merge 
replace announced_new_volume_mmboe = 0 if announced_new_volume_mmboe == .

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color lin fruits, select(7 2 1 3 4 5 6)
grstyle set inten 30: line
grstyle set compact
twoway (bar announced_new_volume_mmboe year if year > 1989, yaxis(2)) || (line argentina brazil chile colombia mexico peru year if year > 1989, yaxis(1)), xtitle("") ytitle("FDI Net Inflows (Billions Current US$)", axis(1) size(medsmall)) ytitle("Announced Discoveries (Millions BOE)", size(medsmall) axis(2)) legend(order(2 "Argentina" 3 "Brazil" 4 "Chile" 5 "Colombia" 6 "Mexico" 7 "Peru"))


**************************************************************************************
clear
import delimited "${user}\Data Directory\Texts\NewsStories.csv"

graph drop _all 

grstyle init
grstyle set plain, noextend
grstyle set legend 6, nobox
grstyle set color lin fruits, select(3)
grstyle color background white
grstyle set inten 75: line
grstyle set compact
twoway bar globo_oil year, xtitle("") ytitle("Number of Stories Mentioning" `""Oil Discovery" or "Pre-Salt""') barwidth(.5) xscale(r(2005 2018)) xlabel(2005 (2) 2018) name(stories)

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color lin fruits, select(4)
grstyle set inten 50: line
grstyle set compact
twoway bar share_globo_oil year, xtitle("") ytitle("% of Total Stories Mentioning" `""Oil Discovery" or "Pre-Salt""', size(medium)) barwidth(.5) xscale(r(2005 2018)) xlabel(2005 (2) 2018) name(share_stories)

graph combine stories share_stories

*********************************************************************************
*Graph transfers 
clear
use "${user}\Data Directory\Public Finances\Transfers\Transfers_Disaggregated_2000_to_2017", clear

*Sum FUNDEF and FUNDEB 
gen ed_transfers = FUNDEF + FUNDEB

*Sum transfers to municipal government at type level 
gen collapser = 1
collapse (mean) AFM_AFE CIDE_fuel FEX FPM FUNDEB FUNDEF IOF_ouro LeiKandir ITR Royalties ed_transfers, by(collapser)
 

*Divide all values by 1000 
local vars "FPM FUNDEB FUNDEF Royalties LeiKandir FEX ITR AFM_AFE CIDE_fuel ed_transfers"
foreach i of local vars {
	replace `i' = `i' / 1000
}

rename AFM_AFE AFM 

*Calculate percentages 
gen total_transfer = FPM + ed_transfers + Royalties + LeiKandir + FEX + ITR + AFM + CIDE_fuel
local vars "FPM ed_transfers Royalties LeiKandir FEX ITR AFM CIDE_fuel"
foreach i of local vars {
	gen share`i' = (`i' / total_transfer) * 100
}

*Graph values 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color lin fruits
grstyle set inten 75: line
grstyle set compact
graph bar ed_transfers FPM Royalties LeiKandir FEX ITR AFM CIDE_fuel, ytitle("Constant 2010 BRL (1000s)") blabel(name, size(vsmall)) nolabel

*************************************************
