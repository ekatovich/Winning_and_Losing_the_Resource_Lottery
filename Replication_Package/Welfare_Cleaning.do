clear 
import delimited "${user}\Data Directory\Census\WelfareData.csv"

rename id_municipio munic_code 	
rename ano year
rename mes month
rename familias_beneficiarias_pbf families_bf
rename pessoas_beneficiarias_pbf people_bf
rename valor_pago_pbf value_bf
rename familias_cadastradas_cu families_cu 
rename pessoas_cadastradas_cu people_cu 

destring families_bf people_bf value_bf families_cu people_cu, replace 

collapse (mean) families_bf people_bf families_cu people_cu (sum) value_bf, by(munic_code year)

save "${user}\Data Directory\Census\BolsaFamilia_Panel_2004_2020", replace 