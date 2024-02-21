
clear
cd "${user}\Data Directory\Discoveries"
use "Fields_with_Centroids.dta" 

gen field_name_2_id = NOM_CAMPO2
gen operator_c_id = OPERADOR_C
gen basin_id = NOM_BACIA 
gen stage_id = ETAPA 
gen fluid_pri_id = FLUIDO_PRI 

label val field_name_2_id 
label val operator_c_id 
label val basin_id
label val stage_id 
label val fluid_pri_id

decode NOM_CAMPO2, gen(field_name_2)
decode OPERADOR_C, gen(operator_c)
decode NOM_BACIA, gen(basin)
decode ETAPA, gen(stage)
decode FLUIDO_PRI, gen(fluid_pri)

rename NOM_CAMPO field_name 

drop NOM_CAMPO2 OPERADOR_C NOM_BACIA ETAPA FLUIDO_PRI field_name_2_id field_name_2 

local strings "field_name operator_c basin stage fluid_pri"
foreach i of local strings {
replace `i' = ustrto(ustrnormalize(`i', "nfd"), "ascii", 2)
}

gen date_signing_id = DAT_ASSINA
gen date_terminate_id = DAT_TERMIN
gen field_initials_id = SIG_CAMPO
gen date_discovery_id = DAT_DESCOB 
gen date_start_id = DAT_INICIO 
gen bidding_round_id = RODADA 

label val date_signing_id
label val date_terminate_id
label val field_initials_id
label val date_discovery_id
label val date_start_id
label val bidding_round_id

decode DAT_ASSINA, gen(date_signing)
decode DAT_TERMIN, gen(date_terminate)
decode SIG_CAMPO, gen(field_initials)
decode DAT_DESCOB, gen(date_discovery)
decode DAT_INICIO, gen(date_start)
decode RODADA, gen(bidding_round)

drop DAT_ASSINA DAT_TERMIN SIG_CAMPO DAT_DESCOB DAT_INICIO RODADA

*Convert to Stata dates 
local dates "date_signing date_terminate date_discovery date_start"
foreach j of local dates {
gen `j'_tmp = date(`j', "DMY")
format `j'_tmp %td
}

drop date_signing date_terminate date_discovery date_start

rename date_signing_tmp date_signing 
rename date_terminate_tmp date_terminate
rename date_discovery_tmp date_discovery
rename date_start_tmp date_start

order ID X Y field_name field_initials basin stage date_signing date_terminate date_discovery date_start bidding_round

sort field_name 

*Save cleaned version with XY coordinates 
save "Field_Coordinates", replace 
********************************************************************************

*Calculate days between discovery and start 
gen discovery_prod_gap_days = date_start - date_discovery 
*Divide by 30 to find months  
gen discovery_prod_gap_yrs = discovery_prod_gap_days / 365

*Gen indicator for offshore fields 
gen offshore = 0
replace offshore = 1 if basin == "Santos" | basin == "Campos" | basin == "Esprito Santo" | basin == "Camamu" | basin == "Sergipe" | basin == "Alagoas" | basin == "Potiguar" | basin == "Cear" 


*Drop extreme outliers 
drop if discovery_prod_gap_yrs > 20

*Summarize gap by offshore onshore 
sum discovery_prod_gap_yrs if offshore == 0
sum discovery_prod_gap_yrs if offshore == 1

*Keep only offshore basins 
keep if basin == "Santos" | basin == "Campos" | basin == "Esprito Santo" | basin == "Camamu" | basin == "Sergipe" | basin == "Alagoas" | basin == "Potiguar" | basin == "Cear" 

drop if discovery_prod_gap_days < 0 // only drops two minor offshore fields
replace basin = "Espirito Santo" if basin == "Esprito Santo"
replace basin = "Sergipe-Alagoas" if basin == "Sergipe" | basin == "Alagoas"
replace basin = "Ceara" if basin == "Cear"
replace basin = "Camamu-Almada" if basin == "Camamu"

*extract year of discovery 
gen year_discovery=year(date_discovery) 

*Summarize total gap and gap by basin 
sum discovery_prod_gap_yrs 
sum discovery_prod_gap_yrs if basin == "Santos"
sum discovery_prod_gap_yrs if basin == "Campos"
sum discovery_prod_gap_yrs if basin == "Espirito Santo"
sum discovery_prod_gap_yrs if basin == "Camamu-Almada"
sum discovery_prod_gap_yrs if basin == "Sergipe-Alagoas"
sum discovery_prod_gap_yrs if basin == "Potiguar"
sum discovery_prod_gap_yrs if basin == "Ceara"

*Collapse to year_discovery/basin level to get dataset of average time to production for basin-yrs 
collapse (mean) discovery_prod_gap_yrs, by(year_discovery basin)
sort basin year_discovery

*generate cumulative average by basin 
bysort basin (year_discovery) : gen cumulative_delay_yrs = sum(discovery_prod_gap_yrs)
gen indicator = 1
bysort basin (year_discovery) : gen cumulative_years = sum(indicator)
gen cumulative_avg_gap_yrs = cumulative_delay_yrs / cumulative_years

*Fill in additional years and then fill all cumulative values down 
*First keep only necessary variable 
keep basin year_discovery cumulative_avg_gap_yrs

input
. 2012 . . . . . 
. 2013 . . . . . 
. 2014 . . . . . 
. 2015 . . . . . 
. 2016 . . . . . 
. 2017 . . . . . 
end

egen basin_id = group(basin)
tsset basin_id year_discovery
tsfill, full
bysort basin_id: carryforward basin cumulative_avg_gap_yrs, gen(basin_new cumulative_avg_gap_yrs_new)

keep year_discovery basin_new cumulative_avg_gap_yrs_new
rename basin_new basin 
rename cumulative_avg_gap_yrs_new cumulative_avg_gap_yrs
drop if cumulative_avg_gap_yrs == .

save "Discovery_Production_Delay", replace 


