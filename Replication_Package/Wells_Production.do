*Importing and cleaning well-level production data
cd "${user}\Data Directory\Oil Production Value\Well_Level_Production"

local years "2005 2006 2007 2008 2009"
foreach m of local years {

	import excel "producao-pocos-`m'/`m'/`m'_producao_mar.xlsx", sheet("SIGEP") firstrow clear

	rename Estado state
	rename Bacia basin
	rename nome_ANP well_ANP
	rename nome_Operator well_Operator
	rename Campo field
	rename Operador operator
	rename Período period
	rename Petróleobbldia petroleum_bblday
	rename N gas_mm3day

	drop NúmerodoContrato M GásNaturalMmdia Condensadobbldia Óleobbldia VolumeGásRoyaltiesMmdia Águabbldia InstalaçãoDestino TipoInstalação TempodeProduçãohspormês
	
	gen period1 = date(period, "YM")
	format period1 %td
	drop period
	rename period1 period
	
	gen oil_bblmonth = petroleum_bblday * 30.4167
	gen gas_mm3month = gas_mm3day * 30.4167
	
	collapse (firstnm) state basin well_Operator field operator (sum) oil_bblmonth gas_mm3month, by(well_ANP)
	
	rename oil_bblmonth oil_bbl
	rename gas_mm3month gas_mm3

	order well_ANP well_Operator 
	
	gen year = `m'

	save "well_production_`m'", replace

}


local years "2010 2011 2012 2013 2014 2015"
foreach j of local years {

	local months "01 02 03 04 05 06 07 08 09 10 11 12"
	foreach i of local months {
	
		import excel "producao-pocos-`j'/`j'/`j'_`i'_producao_mar.xlsx", clear
	
		gen row_id = _n
		drop if row_id == 1 | row_id == 2 | row_id == 3 | row_id == 4 | row_id == 5 | row_id == 6

		rename A state
		rename B basin
		rename C well_ANP
		rename D well_Operator 
		rename E field
		rename F operator
		rename G contract_number
		rename H period
		rename K petroleum_bblday
		rename N gas_mm3day

		drop I J L M O P Q R S row_id 
		
		gen period1 = date(period, "YM")
		format period1 %td
		drop period
		rename period1 period
		
		destring petroleum_bblday, replace
		destring gas_mm3day, replace
		
		gen oil_bblmonth = petroleum_bblday * 30.4167
		gen gas_mm3month = gas_mm3day * 30.4167
		
		save "well_production_monthly_`i'_`j'", replace

	}

}


local years "2010 2011 2012 2013 2014 2015"
foreach p of local years {

	use "well_production_monthly_01_`p'", clear
	append using "well_production_monthly_02_`p'", force
	append using "well_production_monthly_03_`p'", force
	append using "well_production_monthly_04_`p'", force
	append using "well_production_monthly_05_`p'", force
	append using "well_production_monthly_06_`p'", force
	append using "well_production_monthly_07_`p'", force
	append using "well_production_monthly_08_`p'", force
	append using "well_production_monthly_09_`p'", force
	append using "well_production_monthly_10_`p'", force
	append using "well_production_monthly_11_`p'", force
	append using "well_production_monthly_12_`p'", force

	collapse (firstnm) state basin well_Operator field operator (sum) oil_bblmonth gas_mm3month, by(well_ANP)
		
	rename oil_bblmonth oil_bbl
	rename gas_mm3month gas_mm3
		
	order well_ANP well_Operator 
	
	gen year = `p'

	save "well_production_`p'", replace
}


local years "2016 2017 2018"
foreach h of local years {
	
	import excel "producao-pocos-`h'/`h'/`h'_producao_mar.xlsx", sheet("SIGEP") firstrow clear
	
	rename Estado state
	rename Bacia basin
	rename nome_ANP well_ANP
	rename nome_Operator well_Operator
	rename Campo field
	rename Operador operator
	rename NúmerodoContrato contract_number
	rename Período period
	rename Petróleobbldia petroleum_bblday
	rename GásNaturalMmdia gas_mm3day

	drop Óleobbldia Condensadobbldia Óleobbldia Condensadobbldia VolumeGásRoyaltiesMmdia Águabbldia InstalaçãoDestino TipoInstalação TempodeProduçãohspormês
 
	gen period1 = date(period, "YM")
	format period1 %td
	drop period
	rename period1 period
	
	gen oil_bblmonth = petroleum_bblday * 30.4167
	gen gas_mm3month = gas_mm3day * 30.4167

	collapse (firstnm) state basin well_Operator field operator (sum) oil_bblmonth gas_mm3month, by(well_ANP)
		
	rename oil_bblmonth oil_bbl
	rename gas_mm3month gas_mm3
		
	order well_ANP well_Operator 
	
	gen year = `h'

	save "well_production_`h'", replace

}

use "well_production_2005", clear
append using "well_production_2006", force
append using "well_production_2007", force
append using "well_production_2008", force
append using "well_production_2009", force
append using "well_production_2010", force
append using "well_production_2011", force
append using "well_production_2012", force
append using "well_production_2013", force
append using "well_production_2014", force
append using "well_production_2015", force
append using "well_production_2016", force
append using "well_production_2017", force
append using "well_production_2018", force

drop if well_ANP == ""

sort well_ANP year

reshape wide oil_bbl gas_mm3, i(well_ANP well_Operator state basin field operator) j(year)

*Collapse to remove duplicates
collapse (firstnm) well_Operator state basin field operator (sum) oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018, by(well_ANP)

rename well_ANP well_anp
rename well_Operator well_operator

*Clean well and field names
local clean_vars "well_anp well_operator field"
foreach j of local clean_vars {
*Remove all accents and special characters using ustrnormalize:
replace `j' = ustrto(ustrnormalize(`j', "nfd"), "ascii", 2)	
*Remove hyphens
replace `j' = subinstr(`j', "-","",.)
*Remove question marks
replace `j' = subinstr(`j', "?","",.)
*Remove spaces
replace `j' = subinstr(`j', " ","",.)
*Capitalize letters 
replace `j' = upper(`j')
}

*Drop wells that have zero production 
drop if oil_bbl2005 == 0 & gas_mm32005 == 0 & oil_bbl2006 == 0 & gas_mm32006 == 0 & oil_bbl2007 == 0 & gas_mm32007 == 0 & oil_bbl2008 == 0 & gas_mm32008 == 0 & oil_bbl2009 == 0 & gas_mm32009 == 0 & oil_bbl2010 == 0 & gas_mm32010 == 0 & oil_bbl2011 == 0 & gas_mm32011 == 0 & oil_bbl2012 == 0 & gas_mm32012 == 0 & oil_bbl2013 == 0 & gas_mm32013 == 0 & oil_bbl2014 == 0 & gas_mm32014 == 0 & oil_bbl2015 == 0 & gas_mm32015 == 0 & oil_bbl2016 == 0 & gas_mm32016 == 0 & oil_bbl2017 == 0 & gas_mm32017 == 0 & oil_bbl2018 == 0 & gas_mm32018 == 0


save "wells_production", replace
********************************************************************************
use "wells_production", clear

egen sum_oil_2017 = sum(oil_bbl2017)
egen sum_oil_2018 = sum(oil_bbl2018)
egen sum_oil_2016 = sum(oil_bbl2016)
egen sum_oil_2015 = sum(oil_bbl2015)
egen sum_oil_2014 = sum(oil_bbl2014)
egen sum_oil_2013 = sum(oil_bbl2013)
egen sum_oil_2012 = sum(oil_bbl2012)

collapse (firstnm) state basin field operator (sum) oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018, by(well_anp)

drop state basin field operator

save "wells_production_unique_ANP", replace 


use "wells_production", clear

collapse (firstnm) state basin field operator (sum) oil_bbl2005 gas_mm32005 oil_bbl2006 gas_mm32006 oil_bbl2007 gas_mm32007 oil_bbl2008 gas_mm32008 oil_bbl2009 gas_mm32009 oil_bbl2010 gas_mm32010 oil_bbl2011 gas_mm32011 oil_bbl2012 gas_mm32012 oil_bbl2013 gas_mm32013 oil_bbl2014 gas_mm32014 oil_bbl2015 gas_mm32015 oil_bbl2016 gas_mm32016 oil_bbl2017 gas_mm32017 oil_bbl2018 gas_mm32018, by(well_operator)

drop state basin field operator

save "wells_production_unique_operator", replace 


********************************************************************************









