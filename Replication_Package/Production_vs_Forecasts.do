
clear

import delimited "${user}\Data Directory\Discoveries\Production_Forecasts.csv", clear

*Divide all values by 1000 to get millions of boe/day
local vars "actual_anp petrobras_2006 petrobras_2007 petrobras_2008 petrobras_2009 petrobras_2010 petrobras_2011 petrobras_2012 adilson_2008 deloitte_2017 energyinsight_2008"
foreach i of local vars {
replace `i' = `i' / 1000
}

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 3, nobox
grstyle set color blue green orange red purple magenta cyan olive lavender sienna black
grstyle set lpattern dash dash dash dash dash dash dash dash dash dash solid
grstyle set linewidth medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin medthick
twoway line petrobras_2006 year || line petrobras_2007 year || line petrobras_2008 year || line petrobras_2009 year || line petrobras_2010 year || line petrobras_2011 year || line petrobras_2012 year || line adilson_2008 year || line deloitte_2017 year || line energyinsight_2008 year || line actual_anp year, xtitle("Year") ytitle("Million BOE/Day") yscale(r(1 5)) legend(lab(1 "Petrobras 2006") lab(2 "Petrobras 2007") lab(3 "Petrobras 2008") lab(4 "Petrobras 2009") lab(5 "Petrobras 2010") lab(6 "Petrobras 2011") lab(7 "Petrobras 2012") lab(8 "UFRJ 2008") lab(9 "Deloitte 2017") lab(10 "Energy Insight 2008") lab(11 "Realized Production")) legend(size(small))


