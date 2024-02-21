clear
cd "${user}\Data Directory\Treatment Variables"

use "Event_Analysis_Matching_FirstEvent", clear

collapse (mean) disappointed_pc_med, by(munic_code)

rename munic_code code_muni

save "Treatment_Codes_forDistance", replace 

