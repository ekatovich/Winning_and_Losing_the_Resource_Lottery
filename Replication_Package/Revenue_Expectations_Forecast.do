clear 
cd "${user}\Data Directory\Treatment Variables"

*First, clean up basin-level delay times to facilitate merge into munics data
use "${user}\Data Directory\Discoveries\Discovery_Production_Delay", clear

keep basin year_discovery cumulative_avg_gap_yrs
rename year_discovery year 

save "Basin_Level_Delay", replace

********************************************************************************
use "Munics_Affected_by_Oil", clear

*Keep only if discovery volume announced
keep if cvm_announcements_2000_2017 > 0

keep munic_code municipality basin year brentcrudeprice xchange inpc_deflator selic number_cvm_announcements cum_cvm_announcements cvm_announcements_2000_2017 announced_new_volume_mmboe imputed_volume_mmboe oil_revenue POPULACAO revenue_budget gdp RECORCAMENTARIA

rename POPULACAO population
rename RECORCAMENTARIA revenue_budget_FINBRA

*Fill in missing basin values 
bysort munic_code (basin) : replace basin = basin[_N] if missing(basin) 

replace basin = "Camamu-Almada" if basin == "Camamu"
replace basin = "Camamu-Almada" if basin == "Almada"
replace basin = "Sergipe-Alagoas" if basin == "Sergipe"
replace basin = "Sergipe-Alagoas" if basin == "Alagoas"

*Apply average wait times to Una and Canavieiras, in Jequitinhonha basin, from neighboring Camamu-Almada basin 
replace basin = "Camamu-Almada" if basin == "Jequitinhonha"

*Merge in basin-level delay times
merge m:1 basin year using "Basin_Level_Delay"
drop if _merge == 2 

*Now change basin back to Jequitinhonha for Una and Canavieiras 
replace basin = "Jequitinhonha" if municipality == "CANAVIEIRAS29" | municipality == "UNA29"


drop _merge

sort munic_code year

rename cumulative_avg_gap_yrs avg_delay

order munic_code municipality year number_cvm_announcements announced_new_volume_mmboe imputed_volume_mmboe basin oil_revenue avg_delay brentcrudeprice xchange inpc_deflator selic gdp population revenue_budget revenue_budget_FINBRA

*For now: this is a temporary solution
*Fill down missing population, budget, and gdp values 
*tsset munic_code year
bysort munic_code: carryforward population gdp revenue_budget revenue_budget_FINBRA, gen(population_new gdp_new revenue_budget_new revenue_budget_FINBRA_new)
drop population gdp revenue_budget revenue_budget_FINBRA
rename population_new population 
rename gdp_new gdp
rename revenue_budget_new revenue_IPEA
rename revenue_budget_FINBRA_new revenue_FINBRA

********************************************************************************
*Set data to time series to allow time series operators 
sort munic_code year
tsset munic_code year

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {
bysort munic_code: gen vol_`i' = imputed_volume_mmboe if year == `i'
}


*Create variables for each year's average basin-level delay, then round to nearest integer 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen avg_delay_tmp_`k' = avg_delay if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen avg_delay_`m' = max(avg_delay_tmp_`m')
}

drop avg_delay_tmp*

*Round average delay values to nearest integer 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
replace avg_delay_`m' = round(avg_delay_`m', 1)
}


*Create yearly variables for Brent Crude reference prices and exchange rates 
*Create variables for each year's average basin-level delay, then round to nearest integer 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen brent_tmp_`k' = brentcrudeprice if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen brentcrudeprice_`m' = max(brent_tmp_`m')
}

drop brent_tmp_*

*Create variables for each year's average basin-level delay, then round to nearest integer 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen xchange_tmp_`k' = xchange if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen xchange_`m' = max(xchange_tmp_`m')
}

drop xchange_tmp_*

********************************************************************************

save "Expectations_Intermediate_Data", replace 

*************************************************************************************
*Repeat next steps for lower, middle, and high parameter values 
*Lower = 0.01 for peak prod, 0.1 for confrontation 
*Middle = 0.02 for peak prod, 0.2 for confrontation
*High = 0.03 for peak prod, 0.3 for confrontation 

**************************************************************************************
**************************************************************************************
*1st LOW

use "Expectations_Intermediate_Data", clear 

*Create a stream of expected production from each year's discoveries 
*First, create variables and fill in with zeros
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
gen expected_prod_`m' = 0
}

*Create variables with peak production for each year's discoveries 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen peak_prod_`m'_tmp = max(vol_`m')
}

*Assume an annual extraction rate at peak production equivalent to 4% of a field's recoverable reserves. This implies
*that, in 20 years, 56% of the fields recoverable reserves would be extracted at peak rates. 
*This assumption can be adjusted/calibrated.
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
gen peak_prod_`m' = peak_prod_`m'_tmp * 0.01
drop peak_prod_`m'_tmp
}


local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

gen expected_prod_`i'_tmp = 0 if year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(1/(avg_delay_`i')) if L1.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(2/(avg_delay_`i')) if L2.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(3/(avg_delay_`i')) if L3.year == `i' 
replace expected_prod_`i'_tmp = (peak_prod_`i')*(4/(avg_delay_`i')) if L4.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(5/(avg_delay_`i')) if L5.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(6/(avg_delay_`i')) if L6.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(7/(avg_delay_`i')) if L7.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(8/(avg_delay_`i')) if L8.year == `i' 

replace expected_prod_`i' = expected_prod_`i'_tmp if expected_prod_`i'_tmp <= peak_prod_`i' 
replace expected_prod_`i' = peak_prod_`i' if year > `i' & expected_prod_`i'_tmp > peak_prod_`i' 

}

*Drop intermediate variables
drop vol_2* peak_prod* avg_delay_2*
drop expected_prod_2000_tmp expected_prod_2001_tmp expected_prod_2002_tmp expected_prod_2003_tmp expected_prod_2004_tmp expected_prod_2005_tmp expected_prod_2006_tmp expected_prod_2007_tmp expected_prod_2008_tmp expected_prod_2009_tmp expected_prod_2010_tmp expected_prod_2011_tmp expected_prod_2012_tmp expected_prod_2013_tmp expected_prod_2014_tmp expected_prod_2015_tmp expected_prod_2016_tmp expected_prod_2017_tmp


*Sum all year-specific production streams into a single expected production stream 
*gen expected_production = expected_prod_2000 + expected_prod_2001 + expected_prod_2002 + expected_prod_2003 + expected_prod_2004 + expected_prod_2005 + expected_prod_2006 + expected_prod_2007 + expected_prod_2008 + expected_prod_2009 + expected_prod_2010 + expected_prod_2011 + expected_prod_2012 + expected_prod_2013 + expected_prod_2014 + expected_prod_2015 + expected_prod_2016 + expected_prod_2017

***********************************************************************************
*Compute royalties based on expected production for each discovery-year
*Compute royalty streams for each discovery-year separately in order to fix the prices and exchange rates in that year. 

*First create and assign tax rates (aliquotas)
*Basin-level average rates taken from ANP Guide to Royalty Distribution (2001)

*Assign aliquotas (tax rates) by basin 
*Campos: 9.9
*Ceara: 10
*Espirito Santo: 9.3
*Parana: 6.8
*Potiguar: 9.4
*Reconcavo: 9.3
*Santos: 8.3
*Sergipe-Alagoas: 9.5
gen royalty_share = 0
replace royalty_share = 0.099 if basin == "Campos"
replace royalty_share = 0.1 if basin == "Ceara"
replace royalty_share = 0.093 if basin == "Espirito Santo"
replace royalty_share = 0.094 if basin == "Potiguar"
replace royalty_share = 0.083 if basin == "Santos"
replace royalty_share = 0.095 if basin == "Sergipe-Alagoas"

/*
Assume for now that confrontation shares are 1 for affected municipalities. This can be improved later.
Assume for now that royalty shares are 0.075 (Improve this later with field-specific aliquotas)
Royalty formula for first 5% (to municipality confronting well): 
Volume of Production (BOE) * Reference Price [brent crude] * Exchange rate * Share to Confronting Municipalities [30%] * (5% tax rate)
Royalty formula for past 5% (to municipality confronting field): 
Volume of Production (BOE) * Reference Price [brent crude] * Exchange rate * Share to Confronting Municipalities [22.5%] * (Field-specific tax rate [aliquota] - 5% tax rate)*Confronting Share 
*Assume here for simplicity that expected confronting share is 0.5 (improve this later)
*/
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

gen expected_royalties_to5_`i' = (expected_prod_`i'*1000000) * (brentcrudeprice_`i'*xchange_`i') * 0.30*(0.05)
gen expected_royalties_past5_`i' = (expected_prod_`i'*1000000) * (brentcrudeprice_`i'*xchange_`i') * 0.225*(royalty_share - 0.05)*0.1
gen expected_royalties_`i' = expected_royalties_to5_`i' + expected_royalties_past5_`i'
}

*Now, sum all expected royalty streams
gen expected_royalties = expected_royalties_2000 + expected_royalties_2001 + expected_royalties_2002 + expected_royalties_2003 + expected_royalties_2004 + expected_royalties_2005 + expected_royalties_2006 + expected_royalties_2007 + expected_royalties_2008 + expected_royalties_2009 + expected_royalties_2010 + expected_royalties_2011 + expected_royalties_2012 + expected_royalties_2013 + expected_royalties_2014 + expected_royalties_2015 + expected_royalties_2016 + expected_royalties_2017

*Drop intermediate variables 
drop brentcrudeprice_* xchange_* 

*Expected royalties represent royalties expected to derive from new discoveries. To compare these to realized royalties, add to what they're receiving
*in the year of the first discovery
*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_announcements if cum_cvm_announcements != 0 & L1.cum_cvm_announcements == 0
replace first_CVM = 0 if first_CVM == .
replace first_CVM = 1 if first_CVM > 0

*Generate first year indicator
gen first_CVM_year = year if first_CVM == 1
bysort munic_code: egen year_firstCVM = max(first_CVM_year)


*In year of first discovery, add expected stream value to current oil revenue 
*To do so, create variables for each year's oil revenues 
*Create variables for each year's average basin-level delay, then round to nearest integer 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen oilrev_tmp_`k' = oil_revenue if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen oil_revenue_`m' = max(oilrev_tmp_`m')
}

drop oilrev_tmp_*


gen baseline_royalties_tmp = oil_revenue if first_CVM == 1
bysort munic_code: egen baseline_royalties = max(baseline_royalties_tmp)

gen expected_oilrevenue_total = expected_royalties + baseline_royalties 
replace expected_oilrevenue_total = oil_revenue if year < year_firstCVM

*Drop intermediate variables 
drop oil_revenue_2* baseline_royalties_tmp baseline_royalties  

*******************************************************************************
*Compute oil revenues per capita and as a share of municipal revenue 
*For now, use Receita Orcamentaria (later, see if this is best)
gen oil_revenue_pc = oil_revenue / population
gen oil_revenue_budgetshare = oil_revenue / revenue_IPEA

*******************************************************************************
*Next, compute expected royalties as per capita and budget share 
*Compute these based on levels of population and budget fixed at year of discovery
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen population_tmp_`k' = population if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen population_`m' = max(population_tmp_`m')
replace population_`m' = 0 if `m' != year_firstCVM
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen revenue_IPEA_tmp_`k' = revenue_IPEA if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen revenue_IPEA_`m' = max(revenue_IPEA_tmp_`m')
replace revenue_IPEA_`m' = 0 if `m' != year_firstCVM
}

drop population_tmp_* 
drop revenue_IPEA_tmp_*


gen population_disc_yr = population_2000 + population_2001 + population_2002 + population_2003 + population_2004 + population_2005 + population_2006 + population_2007 + population_2008 + population_2009 + population_2010 + population_2011 + population_2012 + population_2013 + population_2014 + population_2015 + population_2016 + population_2017

gen revenue_IPEA_disc_yr = revenue_IPEA_2000 + revenue_IPEA_2001 + revenue_IPEA_2002 + revenue_IPEA_2003 + revenue_IPEA_2004 + revenue_IPEA_2005 + revenue_IPEA_2006 + revenue_IPEA_2007 + revenue_IPEA_2008 + revenue_IPEA_2009 + revenue_IPEA_2010 + revenue_IPEA_2011 + revenue_IPEA_2012 + revenue_IPEA_2013 + revenue_IPEA_2014 + revenue_IPEA_2015 + revenue_IPEA_2016 + revenue_IPEA_2017

gen expected_oilrev_pc = expected_oilrevenue_total / population if year < year_firstCVM
replace expected_oilrev_pc = expected_oilrevenue_total / population_disc_yr if year >= year_firstCVM

gen expected_oilrev_budget = expected_oilrevenue_total / revenue_IPEA if year < year_firstCVM 
replace expected_oilrev_budget = expected_oilrevenue_total / revenue_IPEA_disc_yr if year >= year_firstCVM

drop population_2* revenue_IPEA_2* first_CVM_year

	rename expected_oilrevenue_total exp_oilrev_total_low
	rename expected_oilrev_pc exp_oilrev_pc_low
	rename expected_oilrev_budget exp_oilrev_budg_low

*Save dataset with expected stream of oil revenues
save "Expected_Oil_Revenues_Low", replace 

********************************************************************************
use "Expected_Oil_Revenues_Low", clear

*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp = oil_revenue if year == year_firstCVM 
bysort munic_code: egen oil_rev_event = max(oil_rev_event_tmp)
drop oil_rev_event_tmp 

bysort munic_code: gen oil_rev_2017_tmp = oil_revenue if year == 2017
bysort munic_code: egen oil_rev_2017 = max(oil_rev_2017_tmp)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp = exp_oilrev_total_low if year == 2017
bysort munic_code: egen exp_oilrev_2017 = max(exp_oilrev_2017_tmp)
drop exp_oilrev_2017_tmp 

gen disappointment_total_low = ((oil_rev_2017 + 1) / (oil_rev_event + 1)) / ((exp_oilrev_2017) / (oil_rev_event + 1))

*Compute alternative measure of disappointment: symmetric percentage error (not absolute, want to retain direction of error)
*gen forecast_error_SPE = 

*Generate different disappointment indicators 
gen disappointed_total_low = 0
replace disappointed_total_low = 1 if disappointment_total_low < 0.4
replace disappointed_total_low = 2 if disappointment_total_low >= 0.4

gen disappointed_total_low3 = 0
replace disappointed_total_low3 = 1 if disappointment_total_low < 0.3
replace disappointed_total_low3 = 2 if disappointment_total_low > 0.75 
replace disappointed_total_low3 = 3 if disappointment_total_low >= 0.3 & disappointment_total_low <= 0.75

********************************************************************************
*Repeat calculations for per capita disappointment 
*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp_pc = oil_revenue_pc if year == year_firstCVM 
bysort munic_code: egen oil_rev_pc_event = max(oil_rev_event_tmp_pc)
drop oil_rev_event_tmp_pc 

bysort munic_code: gen oil_rev_2017_tmp_pc = oil_revenue_pc if year == 2017
bysort munic_code: egen oil_rev_pc_2017 = max(oil_rev_2017_tmp_pc)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp_pc = exp_oilrev_pc_low if year == 2017
bysort munic_code: egen exp_oilrev_pc_2017 = max(exp_oilrev_2017_tmp_pc)
drop exp_oilrev_2017_tmp 

gen disappointment_pc_low = ((oil_rev_pc_2017 + 1) / (oil_rev_pc_event + 1)) / ((exp_oilrev_pc_2017) / (oil_rev_pc_event + 1))

*Generate different disappointment indicators 
gen disappointed_pc_low = 0
replace disappointed_pc_low = 1 if disappointment_pc_low < 0.4
replace disappointed_pc_low = 2 if disappointment_pc_low >= 0.4

gen disappointed_pc_low3 = 0
replace disappointed_pc_low3 = 1 if disappointment_pc_low < 0.3
replace disappointed_pc_low3 = 2 if disappointment_pc_low > 0.75 
replace disappointed_pc_low3 = 3 if disappointment_pc_low >= 0.3 & disappointment_pc_low <= 0.75

********************************************************************************
*Repeat calculations for budget share disappointment
*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp_budg = oil_revenue_budgetshare if year == year_firstCVM 
bysort munic_code: egen oil_rev_budg_event = max(oil_rev_event_tmp_budg)
drop oil_rev_event_tmp_budg 

bysort munic_code: gen oil_rev_2017_tmp_budg = oil_revenue_budgetshare if year == 2017
bysort munic_code: egen oil_rev_budg_2017 = max(oil_rev_2017_tmp_budg)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp_budg = exp_oilrev_budg_low if year == 2017
bysort munic_code: egen exp_oilrev_budg_2017 = max(exp_oilrev_2017_tmp_budg)
drop exp_oilrev_2017_tmp 

*TEMPORARY: FIND BETTER SOLUTION FOR ZEROS
gen disappointment_budg_low = ((oil_rev_budg_2017 + 0.01) / (oil_rev_budg_event + 0.01)) / ((exp_oilrev_budg_2017) / (oil_rev_budg_event + 0.01))

*Generate different disappointment indicators 
gen disappointed_budg_low = 0
replace disappointed_budg_low = 1 if disappointment_budg_low < 0.4
replace disappointed_budg_low = 2 if disappointment_budg_low >= 0.4

gen disappointed_budg_low3 = 0
replace disappointed_budg_low3 = 1 if disappointment_budg_low < 0.3
replace disappointed_budg_low3 = 2 if disappointment_budg_low > 0.75 
replace disappointed_budg_low3 = 3 if disappointment_budg_low >= 0.3 & disappointment_budg_low <= 0.75


save "Expected_Oil_Revenues_withDisappointment_Low", replace 

********************************************************************************
********************************************************************************


**************************************************************************************
**************************************************************************************
*2nd MAIN

use "Expectations_Intermediate_Data", clear 

*Create a stream of expected production from each year's discoveries 
*First, create variables and fill in with zeros
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
gen expected_prod_`m' = 0
}

*Create variables with peak production for each year's discoveries 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen peak_prod_`m'_tmp = max(vol_`m')
}

*Assume an annual extraction rate at peak production equivalent to 4% of a field's recoverable reserves. This implies
*that, in 20 years, 56% of the fields recoverable reserves would be extracted at peak rates. 
*This assumption can be adjusted/calibrated.
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
gen peak_prod_`m' = peak_prod_`m'_tmp * 0.02
drop peak_prod_`m'_tmp
}


local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

gen expected_prod_`i'_tmp = 0 if year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(1/(avg_delay_`i')) if L1.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(2/(avg_delay_`i')) if L2.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(3/(avg_delay_`i')) if L3.year == `i' 
replace expected_prod_`i'_tmp = (peak_prod_`i')*(4/(avg_delay_`i')) if L4.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(5/(avg_delay_`i')) if L5.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(6/(avg_delay_`i')) if L6.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(7/(avg_delay_`i')) if L7.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(8/(avg_delay_`i')) if L8.year == `i' 

replace expected_prod_`i' = expected_prod_`i'_tmp if expected_prod_`i'_tmp <= peak_prod_`i' 
replace expected_prod_`i' = peak_prod_`i' if year > `i' & expected_prod_`i'_tmp > peak_prod_`i' 

}

*Drop intermediate variables
drop vol_2* peak_prod* avg_delay_2*
drop expected_prod_2000_tmp expected_prod_2001_tmp expected_prod_2002_tmp expected_prod_2003_tmp expected_prod_2004_tmp expected_prod_2005_tmp expected_prod_2006_tmp expected_prod_2007_tmp expected_prod_2008_tmp expected_prod_2009_tmp expected_prod_2010_tmp expected_prod_2011_tmp expected_prod_2012_tmp expected_prod_2013_tmp expected_prod_2014_tmp expected_prod_2015_tmp expected_prod_2016_tmp expected_prod_2017_tmp


*Sum all year-specific production streams into a single expected production stream 
*gen expected_production = expected_prod_2000 + expected_prod_2001 + expected_prod_2002 + expected_prod_2003 + expected_prod_2004 + expected_prod_2005 + expected_prod_2006 + expected_prod_2007 + expected_prod_2008 + expected_prod_2009 + expected_prod_2010 + expected_prod_2011 + expected_prod_2012 + expected_prod_2013 + expected_prod_2014 + expected_prod_2015 + expected_prod_2016 + expected_prod_2017

***********************************************************************************
*Compute royalties based on expected production for each discovery-year
*Compute royalty streams for each discovery-year separately in order to fix the prices and exchange rates in that year. 

*First create and assign tax rates (aliquotas)
*Basin-level average rates taken from ANP Guide to Royalty Distribution (2001)

*Assign aliquotas (tax rates) by basin 
*Campos: 9.9
*Ceara: 10
*Espirito Santo: 9.3
*Parana: 6.8
*Potiguar: 9.4
*Reconcavo: 9.3
*Santos: 8.3
*Sergipe-Alagoas: 9.5
gen royalty_share = 0
replace royalty_share = 0.099 if basin == "Campos"
replace royalty_share = 0.1 if basin == "Ceara"
replace royalty_share = 0.093 if basin == "Espirito Santo"
replace royalty_share = 0.094 if basin == "Potiguar"
replace royalty_share = 0.083 if basin == "Santos"
replace royalty_share = 0.095 if basin == "Sergipe-Alagoas"

/*
Assume for now that confrontation shares are 1 for affected municipalities. This can be improved later.
Assume for now that royalty shares are 0.075 (Improve this later with field-specific aliquotas)
Royalty formula for first 5% (to municipality confronting well): 
Volume of Production (BOE) * Reference Price [brent crude] * Exchange rate * Share to Confronting Municipalities [30%] * (5% tax rate)
Royalty formula for past 5% (to municipality confronting field): 
Volume of Production (BOE) * Reference Price [brent crude] * Exchange rate * Share to Confronting Municipalities [22.5%] * (Field-specific tax rate [aliquota] - 5% tax rate)*Confronting Share 
*Assume here for simplicity that expected confronting share is 0.5 (improve this later)
*/
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

gen expected_royalties_to5_`i' = (expected_prod_`i'*1000000) * (brentcrudeprice_`i'*xchange_`i') * 0.30*(0.05)
gen expected_royalties_past5_`i' = (expected_prod_`i'*1000000) * (brentcrudeprice_`i'*xchange_`i') * 0.225*(royalty_share - 0.05)*0.2
gen expected_royalties_`i' = expected_royalties_to5_`i' + expected_royalties_past5_`i'
}

*Now, sum all expected royalty streams
gen expected_royalties = expected_royalties_2000 + expected_royalties_2001 + expected_royalties_2002 + expected_royalties_2003 + expected_royalties_2004 + expected_royalties_2005 + expected_royalties_2006 + expected_royalties_2007 + expected_royalties_2008 + expected_royalties_2009 + expected_royalties_2010 + expected_royalties_2011 + expected_royalties_2012 + expected_royalties_2013 + expected_royalties_2014 + expected_royalties_2015 + expected_royalties_2016 + expected_royalties_2017

*Drop intermediate variables 
drop brentcrudeprice_* xchange_* 

*Expected royalties represent royalties expected to derive from new discoveries. To compare these to realized royalties, add to what they're receiving
*in the year of the first discovery
*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_announcements if cum_cvm_announcements != 0 & L1.cum_cvm_announcements == 0
replace first_CVM = 0 if first_CVM == .
replace first_CVM = 1 if first_CVM > 0

*Generate first year indicator
gen first_CVM_year = year if first_CVM == 1
bysort munic_code: egen year_firstCVM = max(first_CVM_year)


*In year of first discovery, add expected stream value to current oil revenue 
*To do so, create variables for each year's oil revenues 
*Create variables for each year's average basin-level delay, then round to nearest integer 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen oilrev_tmp_`k' = oil_revenue if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen oil_revenue_`m' = max(oilrev_tmp_`m')
}

drop oilrev_tmp_*


gen baseline_royalties_tmp = oil_revenue if first_CVM == 1
bysort munic_code: egen baseline_royalties = max(baseline_royalties_tmp)

gen expected_oilrevenue_total = expected_royalties + baseline_royalties 
replace expected_oilrevenue_total = oil_revenue if year < year_firstCVM

*Drop intermediate variables 
drop oil_revenue_2* baseline_royalties_tmp baseline_royalties  

*******************************************************************************
*Compute oil revenues per capita and as a share of municipal revenue 
*For now, use Receita Orcamentaria (later, see if this is best)
gen oil_revenue_pc = oil_revenue / population
gen oil_revenue_budgetshare = oil_revenue / revenue_IPEA

*******************************************************************************
*Next, compute expected royalties as per capita and budget share 
*Compute these based on levels of population and budget fixed at year of discovery
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen population_tmp_`k' = population if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen population_`m' = max(population_tmp_`m')
replace population_`m' = 0 if `m' != year_firstCVM
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen revenue_IPEA_tmp_`k' = revenue_IPEA if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen revenue_IPEA_`m' = max(revenue_IPEA_tmp_`m')
replace revenue_IPEA_`m' = 0 if `m' != year_firstCVM
}

drop population_tmp_* 
drop revenue_IPEA_tmp_*


gen population_disc_yr = population_2000 + population_2001 + population_2002 + population_2003 + population_2004 + population_2005 + population_2006 + population_2007 + population_2008 + population_2009 + population_2010 + population_2011 + population_2012 + population_2013 + population_2014 + population_2015 + population_2016 + population_2017

gen revenue_IPEA_disc_yr = revenue_IPEA_2000 + revenue_IPEA_2001 + revenue_IPEA_2002 + revenue_IPEA_2003 + revenue_IPEA_2004 + revenue_IPEA_2005 + revenue_IPEA_2006 + revenue_IPEA_2007 + revenue_IPEA_2008 + revenue_IPEA_2009 + revenue_IPEA_2010 + revenue_IPEA_2011 + revenue_IPEA_2012 + revenue_IPEA_2013 + revenue_IPEA_2014 + revenue_IPEA_2015 + revenue_IPEA_2016 + revenue_IPEA_2017

gen expected_oilrev_pc = expected_oilrevenue_total / population if year < year_firstCVM
replace expected_oilrev_pc = expected_oilrevenue_total / population_disc_yr if year >= year_firstCVM

gen expected_oilrev_budget = expected_oilrevenue_total / revenue_IPEA if year < year_firstCVM 
replace expected_oilrev_budget = expected_oilrevenue_total / revenue_IPEA_disc_yr if year >= year_firstCVM

drop population_2* revenue_IPEA_2* first_CVM_year

	rename expected_oilrevenue_total exp_oilrev_total_med
	rename expected_oilrev_pc exp_oilrev_pc_med
	rename expected_oilrev_budget exp_oilrev_budg_med

*Save dataset with expected stream of oil revenues
save "Expected_Oil_Revenues_Medium", replace 

********************************************************************************
use "Expected_Oil_Revenues_Medium", clear

*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp = oil_revenue if year == year_firstCVM 
bysort munic_code: egen oil_rev_event = max(oil_rev_event_tmp)
drop oil_rev_event_tmp 

bysort munic_code: gen oil_rev_2017_tmp = oil_revenue if year == 2017
bysort munic_code: egen oil_rev_2017 = max(oil_rev_2017_tmp)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp = exp_oilrev_total_med if year == 2017
bysort munic_code: egen exp_oilrev_2017 = max(exp_oilrev_2017_tmp)
drop exp_oilrev_2017_tmp 

gen disappointment_total_med = ((oil_rev_2017 + 1) / (oil_rev_event + 1)) / ((exp_oilrev_2017) / (oil_rev_event + 1))

*Generate different disappointment indicators 
gen disappointed_total_med = 0
replace disappointed_total_med = 1 if disappointment_total_med < 0.4
replace disappointed_total_med = 2 if disappointment_total_med >= 0.4

gen disappointed_total_med3 = 0
replace disappointed_total_med3 = 1 if disappointment_total_med < 0.3
replace disappointed_total_med3 = 2 if disappointment_total_med > 0.75 
replace disappointed_total_med3 = 3 if disappointment_total_med >= 0.3 & disappointment_total_med <= 0.75

********************************************************************************
*Repeat calculations for per capita disappointment 
*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp_pc = oil_revenue_pc if year == year_firstCVM 
bysort munic_code: egen oil_rev_pc_event = max(oil_rev_event_tmp_pc)
drop oil_rev_event_tmp_pc 

bysort munic_code: gen oil_rev_2017_tmp_pc = oil_revenue_pc if year == 2017
bysort munic_code: egen oil_rev_pc_2017 = max(oil_rev_2017_tmp_pc)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp_pc = exp_oilrev_pc_med if year == 2017
bysort munic_code: egen exp_oilrev_pc_2017 = max(exp_oilrev_2017_tmp_pc)
drop exp_oilrev_2017_tmp 

gen disappointment_pc_med = ((oil_rev_pc_2017 + 1) / (oil_rev_pc_event + 1)) / ((exp_oilrev_pc_2017) / (oil_rev_pc_event + 1))

*Generate different disappointment indicators 
gen disappointed_pc_med = 0
replace disappointed_pc_med = 1 if disappointment_pc_med < 0.4
replace disappointed_pc_med = 2 if disappointment_pc_med >= 0.4

gen disappointed_pc_med3 = 0
replace disappointed_pc_med3 = 1 if disappointment_pc_med < 0.3
replace disappointed_pc_med3 = 2 if disappointment_pc_med > 0.75 
replace disappointed_pc_med3 = 3 if disappointment_pc_med >= 0.3 & disappointment_pc_med <= 0.75

********************************************************************************
*Repeat calculations for budget share disappointment
*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp_budg = oil_revenue_budgetshare if year == year_firstCVM 
bysort munic_code: egen oil_rev_budg_event = max(oil_rev_event_tmp_budg)
drop oil_rev_event_tmp_budg 

bysort munic_code: gen oil_rev_2017_tmp_budg = oil_revenue_budgetshare if year == 2017
bysort munic_code: egen oil_rev_budg_2017 = max(oil_rev_2017_tmp_budg)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp_budg = exp_oilrev_budg_med if year == 2017
bysort munic_code: egen exp_oilrev_budg_2017 = max(exp_oilrev_2017_tmp_budg)
drop exp_oilrev_2017_tmp 

*TEMPORARY: FIND BETTER SOLUTION FOR ZEROS
gen disappointment_budg_med = ((oil_rev_budg_2017 + 0.01) / (oil_rev_budg_event + 0.01)) / ((exp_oilrev_budg_2017) / (oil_rev_budg_event + 0.01))

*Generate different disappointment indicators 
gen disappointed_budg_med = 0
replace disappointed_budg_med = 1 if disappointment_budg_med < 0.4
replace disappointed_budg_med = 2 if disappointment_budg_med >= 0.4

gen disappointed_budg_med3 = 0
replace disappointed_budg_med3 = 1 if disappointment_budg_med < 0.3
replace disappointed_budg_med3 = 2 if disappointment_budg_med > 0.75 
replace disappointed_budg_med3 = 3 if disappointment_budg_med >= 0.3 & disappointment_budg_med <= 0.75


save "Expected_Oil_Revenues_withDisappointment_Medium", replace 

********************************************************************************
********************************************************************************


**************************************************************************************
**************************************************************************************
*3rd High

use "Expectations_Intermediate_Data", clear 

*Create a stream of expected production from each year's discoveries 
*First, create variables and fill in with zeros
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
gen expected_prod_`m' = 0
}

*Create variables with peak production for each year's discoveries 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen peak_prod_`m'_tmp = max(vol_`m')
}

*Assume an annual extraction rate at peak production equivalent to 4% of a field's recoverable reserves. This implies
*that, in 20 years, 56% of the fields recoverable reserves would be extracted at peak rates. 
*This assumption can be adjusted/calibrated.
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
gen peak_prod_`m' = peak_prod_`m'_tmp * 0.03
drop peak_prod_`m'_tmp
}


local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

gen expected_prod_`i'_tmp = 0 if year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(1/(avg_delay_`i')) if L1.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(2/(avg_delay_`i')) if L2.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(3/(avg_delay_`i')) if L3.year == `i' 
replace expected_prod_`i'_tmp = (peak_prod_`i')*(4/(avg_delay_`i')) if L4.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(5/(avg_delay_`i')) if L5.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(6/(avg_delay_`i')) if L6.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(7/(avg_delay_`i')) if L7.year == `i'
replace expected_prod_`i'_tmp = (peak_prod_`i')*(8/(avg_delay_`i')) if L8.year == `i' 

replace expected_prod_`i' = expected_prod_`i'_tmp if expected_prod_`i'_tmp <= peak_prod_`i' 
replace expected_prod_`i' = peak_prod_`i' if year > `i' & expected_prod_`i'_tmp > peak_prod_`i' 

}

*Drop intermediate variables
drop vol_2* peak_prod* avg_delay_2*
drop expected_prod_2000_tmp expected_prod_2001_tmp expected_prod_2002_tmp expected_prod_2003_tmp expected_prod_2004_tmp expected_prod_2005_tmp expected_prod_2006_tmp expected_prod_2007_tmp expected_prod_2008_tmp expected_prod_2009_tmp expected_prod_2010_tmp expected_prod_2011_tmp expected_prod_2012_tmp expected_prod_2013_tmp expected_prod_2014_tmp expected_prod_2015_tmp expected_prod_2016_tmp expected_prod_2017_tmp


*Sum all year-specific production streams into a single expected production stream 
*gen expected_production = expected_prod_2000 + expected_prod_2001 + expected_prod_2002 + expected_prod_2003 + expected_prod_2004 + expected_prod_2005 + expected_prod_2006 + expected_prod_2007 + expected_prod_2008 + expected_prod_2009 + expected_prod_2010 + expected_prod_2011 + expected_prod_2012 + expected_prod_2013 + expected_prod_2014 + expected_prod_2015 + expected_prod_2016 + expected_prod_2017

***********************************************************************************
*Compute royalties based on expected production for each discovery-year
*Compute royalty streams for each discovery-year separately in order to fix the prices and exchange rates in that year. 

*First create and assign tax rates (aliquotas)
*Basin-level average rates taken from ANP Guide to Royalty Distribution (2001)

*Assign aliquotas (tax rates) by basin 
*Campos: 9.9
*Ceara: 10
*Espirito Santo: 9.3
*Parana: 6.8
*Potiguar: 9.4
*Reconcavo: 9.3
*Santos: 8.3
*Sergipe-Alagoas: 9.5
gen royalty_share = 0
replace royalty_share = 0.099 if basin == "Campos"
replace royalty_share = 0.1 if basin == "Ceara"
replace royalty_share = 0.093 if basin == "Espirito Santo"
replace royalty_share = 0.094 if basin == "Potiguar"
replace royalty_share = 0.083 if basin == "Santos"
replace royalty_share = 0.095 if basin == "Sergipe-Alagoas"

/*
Assume for now that confrontation shares are 1 for affected municipalities. This can be improved later.
Assume for now that royalty shares are 0.075 (Improve this later with field-specific aliquotas)
Royalty formula for first 5% (to municipality confronting well): 
Volume of Production (BOE) * Reference Price [brent crude] * Exchange rate * Share to Confronting Municipalities [30%] * (5% tax rate)
Royalty formula for past 5% (to municipality confronting field): 
Volume of Production (BOE) * Reference Price [brent crude] * Exchange rate * Share to Confronting Municipalities [22.5%] * (Field-specific tax rate [aliquota] - 5% tax rate)*Confronting Share 
*Assume here for simplicity that expected confronting share is 0.5 (improve this later)
*/
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach i of local years {

gen expected_royalties_to5_`i' = (expected_prod_`i'*1000000) * (brentcrudeprice_`i'*xchange_`i') * 0.30*(0.05)
gen expected_royalties_past5_`i' = (expected_prod_`i'*1000000) * (brentcrudeprice_`i'*xchange_`i') * 0.225*(royalty_share - 0.05)*0.3
gen expected_royalties_`i' = expected_royalties_to5_`i' + expected_royalties_past5_`i'
}

*Now, sum all expected royalty streams
gen expected_royalties = expected_royalties_2000 + expected_royalties_2001 + expected_royalties_2002 + expected_royalties_2003 + expected_royalties_2004 + expected_royalties_2005 + expected_royalties_2006 + expected_royalties_2007 + expected_royalties_2008 + expected_royalties_2009 + expected_royalties_2010 + expected_royalties_2011 + expected_royalties_2012 + expected_royalties_2013 + expected_royalties_2014 + expected_royalties_2015 + expected_royalties_2016 + expected_royalties_2017

*Drop intermediate variables 
drop brentcrudeprice_* xchange_* 

*Expected royalties represent royalties expected to derive from new discoveries. To compare these to realized royalties, add to what they're receiving
*in the year of the first discovery
*Identify year of first CVM announcement by municipality 
bysort munic_code: gen first_CVM = cum_cvm_announcements if cum_cvm_announcements != 0 & L1.cum_cvm_announcements == 0
replace first_CVM = 0 if first_CVM == .
replace first_CVM = 1 if first_CVM > 0

*Generate first year indicator
gen first_CVM_year = year if first_CVM == 1
bysort munic_code: egen year_firstCVM = max(first_CVM_year)


*In year of first discovery, add expected stream value to current oil revenue 
*To do so, create variables for each year's oil revenues 
*Create variables for each year's average basin-level delay, then round to nearest integer 
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen oilrev_tmp_`k' = oil_revenue if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen oil_revenue_`m' = max(oilrev_tmp_`m')
}

drop oilrev_tmp_*


gen baseline_royalties_tmp = oil_revenue if first_CVM == 1
bysort munic_code: egen baseline_royalties = max(baseline_royalties_tmp)

gen expected_oilrevenue_total = expected_royalties + baseline_royalties 
replace expected_oilrevenue_total = oil_revenue if year < year_firstCVM

*Drop intermediate variables 
drop oil_revenue_2* baseline_royalties_tmp baseline_royalties  

*******************************************************************************
*Compute oil revenues per capita and as a share of municipal revenue 
*For now, use Receita Orcamentaria (later, see if this is best)
gen oil_revenue_pc = oil_revenue / population
gen oil_revenue_budgetshare = oil_revenue / revenue_IPEA

*******************************************************************************
*Next, compute expected royalties as per capita and budget share 
*Compute these based on levels of population and budget fixed at year of discovery
local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen population_tmp_`k' = population if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen population_`m' = max(population_tmp_`m')
replace population_`m' = 0 if `m' != year_firstCVM
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach k of local years {
bysort munic_code: gen revenue_IPEA_tmp_`k' = revenue_IPEA if year == `k'
}

local years "2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"
foreach m of local years {
bysort munic_code: egen revenue_IPEA_`m' = max(revenue_IPEA_tmp_`m')
replace revenue_IPEA_`m' = 0 if `m' != year_firstCVM
}

drop population_tmp_* 
drop revenue_IPEA_tmp_*


gen population_disc_yr = population_2000 + population_2001 + population_2002 + population_2003 + population_2004 + population_2005 + population_2006 + population_2007 + population_2008 + population_2009 + population_2010 + population_2011 + population_2012 + population_2013 + population_2014 + population_2015 + population_2016 + population_2017

gen revenue_IPEA_disc_yr = revenue_IPEA_2000 + revenue_IPEA_2001 + revenue_IPEA_2002 + revenue_IPEA_2003 + revenue_IPEA_2004 + revenue_IPEA_2005 + revenue_IPEA_2006 + revenue_IPEA_2007 + revenue_IPEA_2008 + revenue_IPEA_2009 + revenue_IPEA_2010 + revenue_IPEA_2011 + revenue_IPEA_2012 + revenue_IPEA_2013 + revenue_IPEA_2014 + revenue_IPEA_2015 + revenue_IPEA_2016 + revenue_IPEA_2017

gen expected_oilrev_pc = expected_oilrevenue_total / population if year < year_firstCVM
replace expected_oilrev_pc = expected_oilrevenue_total / population_disc_yr if year >= year_firstCVM

gen expected_oilrev_budget = expected_oilrevenue_total / revenue_IPEA if year < year_firstCVM 
replace expected_oilrev_budget = expected_oilrevenue_total / revenue_IPEA_disc_yr if year >= year_firstCVM

drop population_2* revenue_IPEA_2* first_CVM_year

	rename expected_oilrevenue_total exp_oilrev_total_high
	rename expected_oilrev_pc exp_oilrev_pc_high
	rename expected_oilrev_budget exp_oilrev_budg_high

*Save dataset with expected stream of oil revenues
save "Expected_Oil_Revenues_High", replace 

********************************************************************************

use "Expected_Oil_Revenues_High", clear

*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp = oil_revenue if year == year_firstCVM 
bysort munic_code: egen oil_rev_event = max(oil_rev_event_tmp)
drop oil_rev_event_tmp 

bysort munic_code: gen oil_rev_2017_tmp = oil_revenue if year == 2017
bysort munic_code: egen oil_rev_2017 = max(oil_rev_2017_tmp)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp = exp_oilrev_total_high if year == 2017
bysort munic_code: egen exp_oilrev_2017 = max(exp_oilrev_2017_tmp)
drop exp_oilrev_2017_tmp 

gen disappointment_total_high = ((oil_rev_2017 + 1) / (oil_rev_event + 1)) / ((exp_oilrev_2017) / (oil_rev_event + 1))

*Generate different disappointment indicators 
gen disappointed_total_high = 0
replace disappointed_total_high = 1 if disappointment_total_high < 0.4
replace disappointed_total_high = 2 if disappointment_total_high >= 0.4

gen disappointed_total_high3 = 0
replace disappointed_total_high3 = 1 if disappointment_total_high < 0.3
replace disappointed_total_high3 = 2 if disappointment_total_high > 0.75 
replace disappointed_total_high3 = 3 if disappointment_total_high >= 0.3 & disappointment_total_high <= 0.75

********************************************************************************
*Repeat calculations for per capita disappointment 
*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp_pc = oil_revenue_pc if year == year_firstCVM 
bysort munic_code: egen oil_rev_pc_event = max(oil_rev_event_tmp_pc)
drop oil_rev_event_tmp_pc 

bysort munic_code: gen oil_rev_2017_tmp_pc = oil_revenue_pc if year == 2017
bysort munic_code: egen oil_rev_pc_2017 = max(oil_rev_2017_tmp_pc)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp_pc = exp_oilrev_pc_high if year == 2017
bysort munic_code: egen exp_oilrev_pc_2017 = max(exp_oilrev_2017_tmp_pc)
drop exp_oilrev_2017_tmp 

gen disappointment_pc_high = ((oil_rev_pc_2017 + 1) / (oil_rev_pc_event + 1)) / ((exp_oilrev_pc_2017) / (oil_rev_pc_event + 1))

*Generate different disappointment indicators 
gen disappointed_pc_high = 0
replace disappointed_pc_high = 1 if disappointment_pc_high < 0.4
replace disappointed_pc_high = 2 if disappointment_pc_high >= 0.4

gen disappointed_pc_high3 = 0
replace disappointed_pc_high3 = 1 if disappointment_pc_high < 0.3
replace disappointed_pc_high3 = 2 if disappointment_pc_high > 0.75 
replace disappointed_pc_high3 = 3 if disappointment_pc_high >= 0.3 & disappointment_pc_high <= 0.75



********************************************************************************
*Repeat calculations for budget share disappointment
*Compute disappointment by comparing expected percentage growth in revenue with realized percentage growth 
bysort munic_code: gen oil_rev_event_tmp_budg = oil_revenue_budgetshare if year == year_firstCVM 
bysort munic_code: egen oil_rev_budg_event = max(oil_rev_event_tmp_budg)
drop oil_rev_event_tmp_budg 

bysort munic_code: gen oil_rev_2017_tmp_budg = oil_revenue_budgetshare if year == 2017
bysort munic_code: egen oil_rev_budg_2017 = max(oil_rev_2017_tmp_budg)
drop oil_rev_2017_tmp 

bysort munic_code: gen exp_oilrev_2017_tmp_budg = exp_oilrev_budg_high if year == 2017
bysort munic_code: egen exp_oilrev_budg_2017 = max(exp_oilrev_2017_tmp_budg)
drop exp_oilrev_2017_tmp 

*TEMPORARY: FIND BETTER SOLUTION FOR ZEROS
gen disappointment_budg_high = ((oil_rev_budg_2017 + 0.01) / (oil_rev_budg_event + 0.01)) / ((exp_oilrev_budg_2017) / (oil_rev_budg_event + 0.01))

*Generate different disappointment indicators 
gen disappointed_budg_high = 0
replace disappointed_budg_high = 1 if disappointment_budg_high < 0.4
replace disappointed_budg_high = 2 if disappointment_budg_high >= 0.4

gen disappointed_budg_high3 = 0
replace disappointed_budg_high3 = 1 if disappointment_budg_high < 0.3
replace disappointed_budg_high3 = 2 if disappointment_budg_high > 0.75 
replace disappointed_budg_high3 = 3 if disappointment_budg_high >= 0.3 & disappointment_budg_high <= 0.75


save "Expected_Oil_Revenues_withDisappointment_High", replace 

********************************************************************************
********************************************************************************
use "Expected_Oil_Revenues_withDisappointment_Low", clear 
keep munic_code year exp_oilrev_total_low exp_oilrev_pc_low exp_oilrev_budg_low disappointment_total_low disappointed_total_low disappointed_total_low3 disappointment_pc_low disappointed_pc_low disappointed_pc_low3 disappointment_budg_low disappointed_budg_low disappointed_budg_low3
save "Expected_Oil_Revenues_withDisappointment_Low_short", replace 

use "Expected_Oil_Revenues_withDisappointment_Medium", clear 
keep munic_code year exp_oilrev_total_med exp_oilrev_pc_med exp_oilrev_budg_med disappointment_total_med disappointed_total_med disappointed_total_med3 disappointment_pc_med disappointed_pc_med disappointed_pc_med3 disappointment_budg_med disappointed_budg_med disappointed_budg_med3
save "Expected_Oil_Revenues_withDisappointment_Medium_short", replace 

use "Expected_Oil_Revenues_withDisappointment_High", clear 
keep munic_code year exp_oilrev_total_high exp_oilrev_pc_high exp_oilrev_budg_high disappointment_total_high disappointed_total_high disappointed_total_high3 disappointment_pc_high disappointed_pc_high disappointed_pc_high3 disappointment_budg_high disappointed_budg_high disappointed_budg_high3
save "Expected_Oil_Revenues_withDisappointment_High_short", replace 

use "Expected_Oil_Revenues_withDisappointment_Low", clear 
merge 1:1 munic_code year using "Expected_Oil_Revenues_withDisappointment_Medium_short"
drop _merge 
merge 1:1 munic_code year using "Expected_Oil_Revenues_withDisappointment_High_short"
drop _merge 

order munic_code municipality year number_cvm_announcements announced_new_volume_mmboe imputed_volume_mmboe basin oil_revenue disappointment_total_low disappointed_total_low disappointed_total_low3 disappointment_pc_low disappointed_pc_low disappointed_pc_low3 disappointment_budg_low disappointed_budg_low disappointed_budg_low3 disappointment_total_med disappointed_total_med disappointed_total_med3 disappointment_pc_med disappointed_pc_med disappointed_pc_med3 disappointment_budg_med disappointed_budg_med disappointed_budg_med3 disappointment_total_high disappointed_total_high disappointed_total_high3 disappointment_pc_high disappointed_pc_high disappointed_pc_high3 disappointment_budg_high disappointed_budg_high disappointed_budg_high3

save "Expectations_withParameters", replace 
************************************************************************************
*Collapse to municipality level to create disappointment list 
use "Expectations_withParameters", clear 

collapse (firstnm) municipality disappointment_pc_low disappointment_pc_med disappointment_pc_high disappointed_total_low disappointed_total_low3 disappointed_pc_low disappointed_pc_low3 disappointed_budg_low disappointed_budg_low3 disappointed_total_med disappointed_total_med3 disappointed_pc_med disappointed_pc_med3 disappointed_budg_med disappointed_budg_med3 disappointed_total_high disappointed_total_high3 disappointed_pc_high disappointed_pc_high3 disappointed_budg_high disappointed_budg_high3, by(munic_code)

sort municipality 

order munic_code municipality disappointment_pc_low disappointment_pc_med disappointment_pc_high disappointed_total_low disappointed_total_med disappointed_total_high disappointed_pc_low disappointed_pc_med disappointed_pc_high disappointed_budg_low   disappointed_budg_med disappointed_budg_high disappointed_total_low3 disappointed_total_med3 disappointed_total_high3 disappointed_pc_low3 disappointed_pc_med3 disappointed_pc_high3 disappointed_budg_low3 disappointed_budg_med3 disappointed_budg_high3

*Plot disappointment 
_pctile disappointment_pc_low, p(10(1)90)
ret li

_pctile disappointment_pc_med, p(10(1)90)
ret li

_pctile disappointment_pc_high, p(10(1)90)
ret li

grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color red red red
grstyle set lpattern solid dash dot
grstyle set linewidth .8pt 1pt 2pt
twoway kdensity disappointment_pc_low || kdensity disappointment_pc_med || kdensity disappointment_pc_high, xlabel(0(0.5)7) xline(0.4, lcolor(black) lwidth(thin) lpatter(dash)) legend(order(1 "Low Forecast" 2 "Medium Forecast" 3 "High Forecast") size(small)) xtitle("Disappointment (Per Capita)", size(small)) ytitle("Kernel Density", size(small)) text(1.5 1.425 "Disappointed-Satisfied Cutoff = 0.4", size(vsmall)) text(1.4 1.4 "= 54th Percentile for Low Forecast", size(tiny)) text(1.3 1.46 "= 59th Percentile for Medium Forecast", size(tiny)) text(1.2 1.4 "= 64th Percentile for High Forecast", size(tiny))



save "Disappointed_List_Long", replace


***********************************************************************************
*Graphing individual municipalities

use "Expectations_withParameters", clear 

*Plot expected royalties relative to realized royalties for municipalities that recieved CVM announcements 
keep if cvm_announcements_2000_2017 > 0

replace exp_oilrev_total_low = exp_oilrev_total_low / 1000000
replace exp_oilrev_total_med = exp_oilrev_total_med / 1000000
replace exp_oilrev_total_high = exp_oilrev_total_high / 1000000
replace oil_revenue = oil_revenue / 1000000

graph drop _all
local munics "ANCHIETA32 ANGRADOSREIS33 ARACAJU28 ARACRUZ32 ARARUAMA33 AREIABRANCA24 ARMACAODOSBUZIOS33 ARRAIALDOCABO33 BALNEARIOCAMBORIU42 BARRADOSCOQUEIROS28 CABOFRIO33 CAMPOSDOSGOYTACAZES33 CANANEIA35 CANAVIEIRAS29 CARAGUATATUBA35 CASIMIRODEABREU33 FUNDAO32 IGUAPE35 ILHABELA35 ILHACOMPRIDA35 ITANHAEM35 ITAPEMA42 ITAPEMIRIM32 ITAPORANGADAJUDA28 LINHARES32 MACAE33 MANGARATIBA33 MARATAIZES32 MARICA33 MONGAGUA35 NITEROI33 PACATUBA28 PARACURU23 PARATI33 PERUIBE35 PIRAMBU28 PRESIDENTEKENNEDY32 QUISSAMA33 RIODASOSTRAS33 RIODEJANEIRO33 SAOFRANCISCODEITABAPOANA33 SAOSEBASTIAO35 SAQUAREMA33 SERRA32 UBATUBA35 UNA29 VILAVELHA32 VITORIA32"
*local munics "ARACAJU28"
foreach i of local munics {

	sum year_firstCVM if municipality=="`i'"
		local xline_munic = `r(mean)'
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 3, nobox
grstyle set lpattern dash solid dash solid 
grstyle set color orange_red red orange_red black
	twoway line exp_oilrev_total_low year if municipality == "`i'", lpattern(dash) || line exp_oilrev_total_med year if municipality == "`i'", lpattern(solid) || line exp_oilrev_total_high year if municipality == "`i'", lpattern(dash) || line oil_revenue year if municipality == "`i'", lpattern(solid) title("`i'") xtitle("Year") ytitle("Royalties (Constant 2010 BRL)") legend(order(1 "Expected Royalties (Low)" 2 "Expected Royalties (Main)" 3 "Expected Royalties (High)" 4 "Realized Oil Revenues")) name(`i') xline(`xline_munic')
*yscale(range(0 500000000)) ylabel(0 (50000000) 500000000)
}





replace exp_oilrev_pc_low = exp_oilrev_pc_low / 1000
replace exp_oilrev_pc_med = exp_oilrev_pc_med / 1000
replace exp_oilrev_pc_high = exp_oilrev_pc_high / 1000
replace oil_revenue_pc = oil_revenue_pc / 1000

*Redo graphs with expected versus realized oil revenues PER CAPITA
graph drop _all

local munics "ANCHIETA32 PRESIDENTEKENNEDY32 ARACRUZ32 FUNDAO32 ITAPEMIRIM32 ITAPORANGADAJUDA28 MARATAIZES32 SAOFRANCISCODEITABAPOANA33 ARMACAODOSBUZIOS33 CAMPOSDOSGOYTACAZES33 MARICA33 RIODASOSTRAS33 SERRA32 CABOFRIO33 IGUAPE35 ILHABELA35 NITEROI33 SAQUAREMA33 UBATUBA35 QUISSAMA33 BALNEARIOCAMBORIU42 CANANEIA35 CANAVIEIRAS29 ITAPEMA42 UNA29 ARRAIALDOCABO33 CASIMIRODEABREU33 ILHACOMPRIDA35 MONGAGUA35 SAOSEBASTIAO35 ANGRADOSREIS33 ARACAJU28 ITANHAEM35 MACAE33 PACATUBA28 PERUIBE35 VITORIA32 CARAGUATATUBA35 LINHARES32 MANGARATIBA33 PARATI33 RIODEJANEIRO33 BARRADOSCOQUEIROS28 PARACURU23 PIRAMBU28 VILAVELHA32 ARARUAMA33 AREIABRANCA24"
*local munics "ANCHIETA32 ANGRADOSREIS33 ARACAJU28 ARACRUZ32 ARARUAMA33 AREIABRANCA24 ARMACAODOSBUZIOS33 ARRAIALDOCABO33 BALNEARIOCAMBORIU42 BARRADOSCOQUEIROS28 CABOFRIO33 CAMPOSDOSGOYTACAZES33 CANANEIA35 CANAVIEIRAS29 CARAGUATATUBA35 CASIMIRODEABREU33 FUNDAO32 IGUAPE35 ILHABELA35 ILHACOMPRIDA35 ITANHAEM35 ITAPEMA42 ITAPEMIRIM32 ITAPORANGADAJUDA28 LINHARES32 MACAE33 MANGARATIBA33 MARATAIZES32 MARICA33 MONGAGUA35 NITEROI33 PACATUBA28 PARACURU23 PARATI33 PERUIBE35 PIRAMBU28 PRESIDENTEKENNEDY32 QUISSAMA33 RIODASOSTRAS33 RIODEJANEIRO33 SAOFRANCISCODEITABAPOANA33 SAOSEBASTIAO35 SAQUAREMA33 SERRA32 UBATUBA35 UNA29 VILAVELHA32 VITORIA32"
*local munics "QUISSAMA33 PACATUBA28 SAQUAREMA33 ILHABELA35 ITAPEMIRIM32 PRESIDENTEKENNEDY32"
foreach i of local munics {

	sum year_firstCVM if municipality=="`i'"
		local xline_munic = `r(mean)'

	grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 3, nobox
grstyle set lpattern dash solid shortdash solid 
*grstyle set color gs11 gs7 gs11 black
grstyle set color orange_red red orange_red black
	twoway line exp_oilrev_pc_low year if municipality == "`i'", lpattern(shortdash) || line exp_oilrev_pc_med year if municipality == "`i'", lpattern(solid) || line exp_oilrev_pc_high year if municipality == "`i'", lpattern(dash) || line oil_revenue_pc year if municipality == "`i'", lpattern(solid) title("`i'", size(medium)) xtitle("Year", size(small)) ytitle("Royalties p.c.", size(small)) xlabel(2000 (10) 2020, labsize(small)) legend(order(3 "Expected Royalties (High)" 2 "Expected Royalties (Main)" 1 "Expected Royalties (Low)" 4 "Realized Oil Revenues") size(small)) name(`i') xline(`xline_munic', lpattern(vshortdash) lcolor(black))
*yscale(range(0 20000)) ylabel(0 (10000) 20000, labsize(vsmall))

}
*grc1leg2 QUISSAMA33 PACATUBA28 SAQUAREMA33 ILHABELA35 ITAPEMIRIM32 PRESIDENTEKENNEDY32  
*Satisfied Examples 
grc1leg2 PRESIDENTEKENNEDY32 FUNDAO32 ITAPEMIRIM32 IGUAPE35 ILHABELA35 NITEROI33, name("munics_satisfied", replace) title("Satisfied (Non-Negative Forecast Error)") loff
*loff

*Disappointed Examples 
grc1leg2 QUISSAMA33 CANAVIEIRAS29 ARACAJU28 MACAE33 PACATUBA28 LINHARES32, name("munics_disappointed", replace) title("Disappointed (Negative Forecast Error)") lrows(2)

graph combine munics_satisfied munics_disappointed, rows(2) 


