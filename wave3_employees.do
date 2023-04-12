**************************************
********Manali Sovani Paper 1*********
**************************************

****************Wave 3****************
****************Employees*************


clear all
set more off
drop _all
cls

global raw_data_wave3 "C:\Users\msovan01\Box\Paper 1\Data\Wave 3"
global final_data_wave3 "C:\Users\msovan01\Box\Paper 1\Data\Wave 3\New Files"

*For Weighting*
/*
global Nigeria_GHS_W1_pop_tot 158503197
global Nigeria_GHS_W1_pop_rur 89586007
global Nigeria_GHS_W1_pop_urb 68917190
*/

********************************************************************************

use "${raw_data_wave3}\sect1_harvestw3.dta", clear

*Renaming the variables*
ren s1q2 sex
ren s1q17 religion
ren s1q4 age

*Relationship to the household head*
drop if s1q3b =="FORMER HEAD (DEAD)" //dead hoh
tab s1q3
sort s1q3
replace s1q3=0 if s1q3>=6 & s1q3<=11 //Other Relations
replace s1q3=0 if s1q3==14 //Other Relations
replace s1q3=3 if s1q3==4 | s1q3==5 //Own, adopted or step child 
replace s1q3=4 if s1q3==12 | s1q3==13 | s1q3==15 //Non-relations
rename s1q3 relation_hh
label define relation_hh 1 "Head" 2 "Spouse" 3 "Child" 0 "Other relation" 4 "Other Non relation", replace
label values relation_hh relation_hh
tab relation_hh

*Marital Status* 
gen marriage_stat=.
replace marriage_stat=1 if s1q7==1 | s1q7==2 | s1q7==3 //partnered (married(mono), married(poly), informal union)
replace marriage_stat=2 if s1q7==4 | s1q7==5 | s1q7==6 | s1q7==7 //not partnered (never married, widowed, separated, divorced)
label define marriage_stat 1 "partnered" 2 "not partnered", replace
label values marriage_stat marriage_stat
tab marriage_stat
label variable marriage_stat "Marital Status"

gen female= sex==2
la var female "1= individual is female"

keep zone state lga sector ea hhid indiv religion relation_hh sex age marriage_stat 
save "${final_data_wave3}\wave3_basicdata.dta", replace


********************************************************************************
* WEIGHTS *
********************************************************************************

use "${raw_data_wave3}\secta_harvestw3.dta", replace
tab sector
gen rural = (sector==2)
lab var rural "1= Rural"
ren wt_w1_w2_w3 wt_123
ren saq13d interviewday
ren saq13m interviewmonth
ren saq13y interviewyear
keep hhid rural wt_wave3 interviewday interviewmonth interviewyear
save "${final_data_wave3}\wave3_weights.dta", replace

********************************************************************************
*HEAD OF HOUSEHOLD FEMALE*
********************************************************************************

use "${raw_data_wave3}\sect1_harvestw3.dta", replace
ren s1q3 relhead 
ren s1q2 sex
gen female_head = 0
replace female_head =1 if relhead==1 & sex==2 //this person is the head and is a woman
collapse (max) female_head, by(hhid)
save "${final_data_wave3}\wave3_hheadfemale.dta", replace //this saves hhid and female_head, at hh level not indiv level


********************************************************************************
* WAGE INCOME *
********************************************************************************

********************************************************************************
* Yearly Agricultural Income *
********************************************************************************

use "${raw_data_wave3}\sect3_harvestw3.dta", replace

ren s3q14 sector_code
ren s3q16 mainwage_number_months
ren s3q17 mainwage_number_weeks
ren s3q18 mainwage_number_hours
ren s3q21a mainwage_recent_payment

gen worked_as_employee=.
replace worked_as_employee=1 if s3q4==1
replace worked_as_employee=0 if s3q4==2

gen worked_farmofhhmember=.
replace worked_farmofhhmember=1 if s3q5==1
replace worked_farmofhhmember=0 if s3q5==2

gen worked_selfemployed=.
replace worked_selfemployed=1 if s3q6==1
replace worked_selfemployed=0 if s3q6==2

gen employed=.
replace employed=1 if s3q7==1
replace employed=0 if s3q7==2

gen ag_activity = (sector_code==1)
replace mainwage_recent_payment = . if ag_activity!=1 // only ag wages 

ren s3q21b mainwage_payment_period
ren s3q24a mainwage_recent_payment_other
replace mainwage_recent_payment_other = . if ag_activity!=1 // only ag wages 
ren s3q24b mainwage_payment_period_other

ren s3q27 sec_sector_code
ren s3q29 secwage_number_months
ren s3q30 secwage_number_weeks
ren s3q31 secwage_number_hours
ren s3q34a secwage_recent_payment
gen sec_ag_activity = (sec_sector_code==1)
replace secwage_recent_payment = . if sec_ag_activity!=1 // only ag wages 
ren s3q34b secwage_payment_period
ren s3q37a secwage_recent_payment_other
replace secwage_recent_payment_other = . if sec_ag_activity!=1 // only ag wages 
ren s3q37b secwage_payment_period_other

recode  mainwage_number_months secwage_number_months (12/max=12)
recode  mainwage_number_weeks secwage_number_weeks (52/max=52)
recode  mainwage_number_hours secwage_number_hours (84/max=84)

local vars main sec
foreach p of local vars {
	//replace `p'wage_recent_payment=. if worked_as_employee!=1
	gen `p'wage_salary_cash = `p'wage_recent_payment if `p'wage_payment_period==8
	replace `p'wage_salary_cash = ((`p'wage_number_months/6)*`p'wage_recent_payment) if `p'wage_payment_period==7
	replace `p'wage_salary_cash = ((`p'wage_number_months/4)*`p'wage_recent_payment) if `p'wage_payment_period==6
	replace `p'wage_salary_cash = (`p'wage_number_months*`p'wage_recent_payment) if `p'wage_payment_period==5
	replace `p'wage_salary_cash = (`p'wage_number_months*(`p'wage_number_weeks/2)*`p'wage_recent_payment) if `p'wage_payment_period==4
	replace `p'wage_salary_cash = (`p'wage_number_weeks*`p'wage_recent_payment) if `p'wage_payment_period==3
	replace `p'wage_salary_cash = (`p'wage_number_weeks*(`p'wage_number_hours/8)*`p'wage_recent_payment) if `p'wage_payment_period==2
	replace `p'wage_salary_cash = (`p'wage_number_weeks*`p'wage_number_hours*`p'wage_recent_payment) if `p'wage_payment_period==1

	//replace `p'wage_recent_payment_other=. if worked_as_employee!=1
	gen `p'wage_salary_other = `p'wage_recent_payment_other if `p'wage_payment_period_other==8
	replace `p'wage_salary_other = ((`p'wage_number_months/6)*`p'wage_recent_payment_other) if `p'wage_payment_period_other==7
	replace `p'wage_salary_other = ((`p'wage_number_months/4)*`p'wage_recent_payment_other) if `p'wage_payment_period_other==6
	replace `p'wage_salary_other = (`p'wage_number_months*`p'wage_recent_payment_other) if `p'wage_payment_period_other==5
	replace `p'wage_salary_other = (`p'wage_number_months*(`p'wage_number_weeks/2)*`p'wage_recent_payment_other) if `p'wage_payment_period_other==4
	replace `p'wage_salary_other = (`p'wage_number_weeks*`p'wage_recent_payment_other) if `p'wage_payment_period_other==3
	replace `p'wage_salary_other = (`p'wage_number_weeks*(`p'wage_number_hours/8)*`p'wage_recent_payment_other) if `p'wage_payment_period_other==2
	replace `p'wage_salary_other = (`p'wage_number_weeks*`p'wage_number_hours*`p'wage_recent_payment_other) if `p'wage_payment_period_other==1
	recode `p'wage_salary_cash `p'wage_salary_other (.=0) //should we code . as 0???
	egen `p'wage_annual_salary = rowtotal(`p'wage_salary_cash `p'wage_salary_other), m
}

egen annual_salary_agwage = rowtotal(mainwage_annual_salary secwage_annual_salary), m

lab var annual_salary_agwage "Estimated annual earnings from agricultural wage employment over previous 12 months"
lab var ag_activity "Is involved in agricultural activity?"
lab var mainwage_salary_cash "Main occupation yearly cash salary "
lab var mainwage_salary_other "Main occupation yearly other salary (eg. kind)"
lab var secwage_salary_cash "Secondary occupation yearly cash salary"
lab var secwage_salary_other "Secondary occupation yearly other salary (eg. kind)"
lab var mainwage_annual_salary "Total yearly income from main occupation"
lab var secwage_annual_salary "Total yearly income from secondary occupation"
lab var employed "Were you employed in the last 7 days"
lab var worked_as_employee "Worked as an employee outside the household"
lab var worked_farmofhhmember "Worked on the farm for someone in the household"
lab var worked_selfemployed "Worked on own account"

keep if s3q1==1 //keep members above 5 years of age

keep  zone state lga sector ea hhid indiv sector_code ag_activity annual_salary_agwage employed
save "${final_data_wave3}\wave3_agwage.dta", replace

********************************************************************************
* Non-Agricultural Income *
********************************************************************************

use "${raw_data_wave3}\sect3_harvestw3.dta", replace

ren s3q14 sector_code
ren s3q16 mainwage_number_months
ren s3q17 mainwage_number_weeks
ren s3q18 mainwage_number_hours
ren s3q21a mainwage_recent_payment

gen worked_as_employee=.
replace worked_as_employee=1 if s3q4==1
replace worked_as_employee=0 if s3q4==2

gen worked_farmofhhmember=.
replace worked_farmofhhmember=1 if s3q5==1
replace worked_farmofhhmember=0 if s3q5==2

gen worked_selfemployed=.
replace worked_selfemployed=1 if s3q6==1
replace worked_selfemployed=0 if s3q6==2

gen employed=.
replace employed=1 if s3q7==1
replace employed=0 if s3q7==2

gen ag_activity = (sector_code==1)
replace mainwage_recent_payment = . if ag_activity==1 // only non-ag wages 

ren s3q21b mainwage_payment_period
ren s3q24a mainwage_recent_payment_other
replace mainwage_recent_payment_other = . if ag_activity==1 // only non-ag wages 
ren s3q24b mainwage_payment_period_other

ren s3q27 sec_sector_code
ren s3q29 secwage_number_months
ren s3q30 secwage_number_weeks
ren s3q31 secwage_number_hours
ren s3q34a secwage_recent_payment
gen sec_ag_activity = (sec_sector_code==1)
replace secwage_recent_payment = . if sec_ag_activity==1 // only non-ag wages 
ren s3q34b secwage_payment_period
ren s3q37a secwage_recent_payment_other
replace secwage_recent_payment_other = . if sec_ag_activity==1 // only non-ag wages 
ren s3q37b secwage_payment_period_other

recode  mainwage_number_months secwage_number_months (12/max=12)
recode  mainwage_number_weeks secwage_number_weeks (52/max=52)
recode  mainwage_number_hours secwage_number_hours (84/max=84)
//extensive margin of temperature on work in and out of the hh 
local vars main sec
foreach p of local vars {
	//replace `p'wage_recent_payment=. if worked_as_employee!=1
	gen `p'wage_salary_cash = `p'wage_recent_payment if `p'wage_payment_period==8
	replace `p'wage_salary_cash = ((`p'wage_number_months/6)*`p'wage_recent_payment) if `p'wage_payment_period==7
	replace `p'wage_salary_cash = ((`p'wage_number_months/4)*`p'wage_recent_payment) if `p'wage_payment_period==6
	replace `p'wage_salary_cash = (`p'wage_number_months*`p'wage_recent_payment) if `p'wage_payment_period==5
	replace `p'wage_salary_cash = (`p'wage_number_months*(`p'wage_number_weeks/2)*`p'wage_recent_payment) if `p'wage_payment_period==4
	replace `p'wage_salary_cash = (`p'wage_number_weeks*`p'wage_recent_payment) if `p'wage_payment_period==3
	replace `p'wage_salary_cash = (`p'wage_number_weeks*(`p'wage_number_hours/8)*`p'wage_recent_payment) if `p'wage_payment_period==2
	replace `p'wage_salary_cash = (`p'wage_number_weeks*`p'wage_number_hours*`p'wage_recent_payment) if `p'wage_payment_period==1

	//replace `p'wage_recent_payment_other=. if worked_as_employee!=1
	gen `p'wage_salary_other = `p'wage_recent_payment_other if `p'wage_payment_period_other==8
	replace `p'wage_salary_other = ((`p'wage_number_months/6)*`p'wage_recent_payment_other) if `p'wage_payment_period_other==7
	replace `p'wage_salary_other = ((`p'wage_number_months/4)*`p'wage_recent_payment_other) if `p'wage_payment_period_other==6
	replace `p'wage_salary_other = (`p'wage_number_months*`p'wage_recent_payment_other) if `p'wage_payment_period_other==5
	replace `p'wage_salary_other = (`p'wage_number_months*(`p'wage_number_weeks/2)*`p'wage_recent_payment_other) if `p'wage_payment_period_other==4
	replace `p'wage_salary_other = (`p'wage_number_weeks*`p'wage_recent_payment_other) if `p'wage_payment_period_other==3
	replace `p'wage_salary_other = (`p'wage_number_weeks*(`p'wage_number_hours/8)*`p'wage_recent_payment_other) if `p'wage_payment_period_other==2
	replace `p'wage_salary_other = (`p'wage_number_weeks*`p'wage_number_hours*`p'wage_recent_payment_other) if `p'wage_payment_period_other==1
	recode `p'wage_salary_cash `p'wage_salary_other (.=0) //should we code . as 0???
	egen `p'wage_annual_salary = rowtotal(`p'wage_salary_cash `p'wage_salary_other), m
}

egen annual_salary_nonagwage = rowtotal(mainwage_annual_salary secwage_annual_salary), m

lab var annual_salary_nonagwage "Estimated annual earnings from agricultural wage employment over previous 12 months"
lab var ag_activity "Is involved in agricultural activity?"
lab var mainwage_salary_cash "Main occupation yearly cash salary "
lab var mainwage_salary_other "Main occupation yearly other salary (eg. kind)"
lab var secwage_salary_cash "Secondary occupation yearly cash salary"
lab var secwage_salary_other "Secondary occupation yearly other salary (eg. kind)"
lab var mainwage_annual_salary "Total yearly income from main occupation"
lab var mainwage_annual_salary "Total yearly income from secondary occupation"
lab var employed "Were you employed in the last 7 days"
lab var worked_as_employee "Worked as an employee outside the household"
lab var worked_farmofhhmember "Worked on the farm for someone in the household"
lab var worked_selfemployed "Worked on own account"

keep if s3q1==1 //keep members above 5 years of age

keep  zone state lga sector ea hhid indiv sector_code ag_activity annual_salary_nonagwage employed
save "${final_data_wave3}\wave3_nonagwage.dta", replace


********************************************************************************
* HOUSEHOLD CONSUMPTION *
********************************************************************************

use "${raw_data_wave3}\cons_agg_wave3_visit1.dta", replace
ren totcons totcons_v1
la var totcons_v1 "Total consumption per capita visit 1"
merge 1:1 hhid using "C:\Users\msovan01\Box\Paper 1\Data\Wave 3\cons_agg_wave3_visit2.dta", nogen
ren  totcons totcons_v2
la var totcons_v2 "Total consumption per capita visit 2"
egen percapitacons=rowmean(totcons_v1 totcons_v2) 
la var percapitacons "Yearly per capita consumption"
gen percapitacons_daily=percapitacons/365
la var percapitacons_daily "Daily per capita consumption"
gen totcons_hh=percapitacons*hhsize
la var totcons_hh "Yearly household consumption"
keep hhid hhsize percapitacons percapitacons_daily totcons_hh
save "${final_data_wave3}\wave3_hhconsumption.dta", replace

********************************************************************************
* HOURS WORKED *
********************************************************************************
//sum s3q4b if s3q4==1
use "${raw_data_wave3}\sect3_harvestw3.dta", replace 

gen  hrs_main_wage_off_farm=s3q18 if (s3q14>1 & s3q14!=.) & s3q15b1!=1	// s3q14=1 is agriculture and exclude apprenticeship (unpaid) jobs
gen  hrs_sec_wage_off_farm= s3q31 if (s3q27>1 & s3q27!=.) & s3q28b1!=1
gen  hrs_other_wage_off_farm= s3q47 if (s3q44b>1 & s3q44b!=.) 
egen hrs_wage_off_farm= rowtotal(hrs_main_wage_off_farm hrs_sec_wage_off_farm hrs_other_wage_off_farm) 
gen  hrs_main_wage_on_farm=s3q18 if (s3q14==1 & s3q14!=.) & s3q15b1!=1 	// s3q14=1 is agriculture and exclude apprenticeship (unpaid) jobs
gen  hrs_sec_wage_on_farm= s3q31 if (s3q27==1 & s3q27!=.) & s3q28b1!=1
gen  hrs_other_wage_on_farm= s3q47 if (s3q44b==1 & s3q44b!=.) 
egen hrs_wage_on_farm= rowtotal(hrs_main_wage_on_farm hrs_sec_wage_on_farm hrs_other_wage_on_farm)
drop *main* *sec* 

recode s3q39_new s3q40_new (.=0)  //time spent gathering wood or fetching water
gen hrs_domestic=7*(s3q39_new+s3q40_new)/60 //domestic hours worked per week

ren  s3q5b hrs_ag_activ //agricultural activity for the hh
ren  s3q6b hrs_self_off_farm //hh non farm enterprise
egen hrs_off_farm=rowtotal(hrs_wage_off_farm hrs_self_off_farm)  //worked for wage AND hh non farm enterprise 
egen hrs_on_farm=rowtotal(hrs_ag_activ hrs_wage_on_farm) //hours worked for wage AND hh farm activities

la var hrs_off_farm "Total individual hours - work off-farm"
la var hrs_on_farm "Total individual hours - work on-farm"
la var hrs_domestic "Total individual hours - domestic activities"

keep if s3q1==1 //keep members above 5 years of age

keep zone state lga ea hhid indiv hrs_off_farm hrs_on_farm hrs_domestic
save "C:\Users\msovan01\Box\Paper 1\Data\Wave 3\New Files\wave3_indivhoursworked.dta", replace

gen member_count = 1 //this file only contains people older than 5
collapse (sum) hrs_*  member_count, by(hhid)
ren hrs_off_farm hrs_off_farm_hh
ren hrs_on_farm hrs_on_farm_hh
ren hrs_domestic hrs_domestic_hh
la var member_count "Number of HH members age 5 or above"
la var hrs_off_farm_hh "Total household hours - work off-farm"
la var hrs_on_farm_hh "Total household hours - work on-farm"
la var hrs_domestic_hh "Total household hours - domestic activities"

save "${final_data_wave3}\wave3_hhoursworked.dta", replace
