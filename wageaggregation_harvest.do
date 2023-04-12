**************************************
********Manali Sovani Paper 1*********
**************************************

cls
clear all
set more off

***************************************
************EMPLOYEE DATA**************
***************************************

**************************************
****************Wave 1****************
**************************************

global wave1 "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\New Files"


//Merge individual files
use "${wave1}\wave1_basicdata.dta", replace
merge m:1 hhid using "${wave1}\wave1_weights.dta", nogen
merge 1:1 hhid indiv using "${wave1}\wave1_hheadfemale.dta", nogen
merge 1:1 hhid indiv using "${wave1}\wave1_agwage.dta", nogen
merge 1:1 hhid indiv using "${wave1}\wave1_nonagwage.dta", nogen
merge 1:1 hhid indiv using "${wave1}\wave1_indivhoursworked.dta", nogen

merge m:1 hhid using "${wave1}\wave1_indivtemperature.dta"

gen wave=1

drop *merge*

egen hrs_tot_work=rowtotal(hrs_wage_off_farm hrs_wage_on_farm)

//save wave 1 individual file
save "${wave1}\wave1_final_individual.dta", replace 


**************************************
****************Wave 2****************
**************************************

global wave2 "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\New Files"


//Merge individual files
use "${wave2}\wave2_basicdata.dta", replace
merge m:1 hhid using "${wave2}\wave2_weights.dta", nogen
merge 1:1 hhid indiv using "${wave2}\wave2_hheadfemale.dta", nogen
merge 1:1 hhid indiv using "${wave2}\wave2_agwage.dta", nogen
merge 1:1 hhid indiv using "${wave2}\wave2_nonagwage.dta", nogen
merge 1:1 hhid indiv using "${wave2}\wave2_indivhoursworked.dta", nogen

merge m:1 hhid using "${wave2}\wave2_indivtemperature.dta"

gen wave=2

drop *merge*

egen hrs_tot_work=rowtotal(hrs_wage_off_farm hrs_wage_on_farm)

//save wave 1 individual file
save "${wave2}\wave2_final_individual.dta", replace 

 