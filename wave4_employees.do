**************************************
********Manali Sovani Paper 1*********
**************************************

****************Wave 4****************
****************Employees*************


clear all
set more off
drop _all
cls

global raw_data_wave4 "C:\Users\msovan01\Box\Paper 1\Data\Wave 4"
global final_data_wave4 "C:\Users\msovan01\Box\Paper 1\Data\Wave 4\New Files"

*For Weighting*
/*
global Nigeria_GHS_W1_pop_tot 158503197
global Nigeria_GHS_W1_pop_rur 89586007
global Nigeria_GHS_W1_pop_urb 68917190
*/

********************************************************************************

use "${raw_data_wave4}\sect1_harvestw4.dta", clear

*Renaming the variables*     
ren s1q2 sex
ren s1q17 religion
ren s1q4 age

*Relationship to the household head*
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
save "${final_data_wave4}\wave4_basicdata.dta", replace


*******************************************************************************
* WEIGHTS *
********************************************************************************

use "${raw_data_wave4}\secta_harvestw4.dta", replace
tab sector
gen rural = (sector==2)
lab var rural "1= Rural"

gen interviewyear = yofd(dofc( InterviewStart ))
gen interviewmonth = mofd(dofc( InterviewStart ))

//get day only from entire date time 
gen date=dofc( InterviewStart)
format date %td
generate date_text = string(date, "%td")
replace date_text=substr( date_text ,1,2)
destring date_text, replace
drop date
rename date_text interviewday
ren wt_longpanel weight

keep hhid rural wt_wave4 weight interviewday interviewmonth interviewyear
save "${final_data_wave4}\wave4_weights.dta", replace


********************************************************************************
*HEAD OF HOUSEHOLD FEMALE*
********************************************************************************

use "${raw_data_wave4}\sect1_harvestw4.dta", clear
ren s1q3 relhead 
ren s1q2 sex
gen female_head = 0
replace female_head =1 if relhead==1 & sex==2 //this person is the head and is a woman
collapse (max) female_head, by(hhid)
save "${final_data_wave4}\wave4_hheadfemale.dta", replace //this saves hhid and female_head, at hh level not indiv level


********************************************************************************
* WAGE INCOME *
********************************************************************************

********************************************************************************
* Yearly Agricultural Income *
********************************************************************************

use "${raw_data_wave4}\sect3a_harvestw4.dta", replace

ren s3q14 sector_code

egen mainwage_number_months=rowtotal( s3q16a__8 s3q16a__9 s3q16a__10 s3q16a__11 s3q16a__12 s3q16a__13 s3q16a__14 s3q16a__15 s3q16a__16 s3q16a__17 s3q16a__18 s3q16a__19 s3q16a__20 s3q16a__21 s3q16a__22 ), m
replace mainwage_number_months=12 if s3q16a__0==1

ren s3q17 mainwage_number_weeks
ren s3q18 mainwage_number_hours
ren s3q21a mainwage_recent_payment

gen worked_as_employee=.
replace worked_as_employee=1 if s3q4==1 | s3q7a==1 | s3q7a==2 //worked for someone who is not a hh member OR trainee/apprenticeship
replace worked_as_employee=0 if s3q4==2 | s3q7a==3

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

recode  mainwage_number_months (12/max=12)
recode  mainwage_number_weeks (52/max=52)
recode  mainwage_number_hours (84/max=84)

	//replace mainwage_recent_payment=. if worked_as_employee!=1
	gen mainwage_salary_cash = mainwage_recent_payment if mainwage_payment_period==8
	replace mainwage_salary_cash = ((mainwage_number_months/6)*mainwage_recent_payment) if mainwage_payment_period==7
	replace mainwage_salary_cash = ((mainwage_number_months/4)*mainwage_recent_payment) if mainwage_payment_period==6
	replace mainwage_salary_cash = (mainwage_number_months*mainwage_recent_payment) if mainwage_payment_period==5
	replace mainwage_salary_cash = (mainwage_number_months*(mainwage_number_weeks/2)*mainwage_recent_payment) if mainwage_payment_period==4
	replace mainwage_salary_cash = (mainwage_number_weeks*mainwage_recent_payment) if mainwage_payment_period==3 
	replace mainwage_salary_cash = (mainwage_number_weeks*(mainwage_number_hours/8)*mainwage_recent_payment) if mainwage_payment_period==2
	replace mainwage_salary_cash = (mainwage_number_weeks*mainwage_number_hours*mainwage_recent_payment) if mainwage_payment_period==1

	//replace mainwage_recent_payment_other=. if worked_as_employee!=1
	gen mainwage_salary_other = mainwage_recent_payment_other if mainwage_payment_period_other==8
	replace mainwage_salary_other = ((mainwage_number_months/6)*mainwage_recent_payment_other) if mainwage_payment_period_other==7
	replace mainwage_salary_other = ((mainwage_number_months/4)*mainwage_recent_payment_other) if mainwage_payment_period_other==6
	replace mainwage_salary_other = (mainwage_number_months*mainwage_recent_payment_other) if mainwage_payment_period_other==5
	replace mainwage_salary_other = (mainwage_number_months*(mainwage_number_weeks/2)*mainwage_recent_payment_other) if mainwage_payment_period_other==4
	replace mainwage_salary_other = (mainwage_number_weeks*mainwage_recent_payment_other) if mainwage_payment_period_other==3
	replace mainwage_salary_other = (mainwage_number_weeks*(mainwage_number_hours/8)*mainwage_recent_payment_other) if mainwage_payment_period_other==2
	replace mainwage_salary_other = (mainwage_number_weeks*mainwage_number_hours*mainwage_recent_payment_other) if mainwage_payment_period_other==1
	recode mainwage_salary_cash mainwage_salary_other (.=0) //should we code . as 0???

	egen annual_salary_agwage = rowtotal(mainwage_salary_cash mainwage_salary_other), m


keep if s3q1==1 //keep if age>5
gen secwage_salary_cash=.
gen secwage_salary_other=.
gen mainwage_annual_salary=.
gen secwage_annual_salary=.

lab var annual_salary_agwage "Estimated annual earnings from non-agricultural wage employment over previous 12 months"
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
 
keep  zone state lga sector ea hhid indiv sector_code ag_activity annual_salary_agwage employed
save "${final_data_wave4}\wave4_agwage.dta", replace


********************************************************************************
* Non-Agricultural Income *
********************************************************************************

use "${raw_data_wave4}\sect3a_harvestw4.dta", replace

ren s3q14 sector_code

egen mainwage_number_months=rowtotal( s3q16a__8 s3q16a__9 s3q16a__10 s3q16a__11 s3q16a__12 s3q16a__13 s3q16a__14 s3q16a__15 s3q16a__16 s3q16a__17 s3q16a__18 s3q16a__19 s3q16a__20 s3q16a__21 s3q16a__22 ), m
replace mainwage_number_months=12 if s3q16a__0==1

ren s3q17 mainwage_number_weeks
ren s3q18 mainwage_number_hours
ren s3q21a mainwage_recent_payment

gen worked_as_employee=.
replace worked_as_employee=1 if s3q4==1 | s3q7a==1 | s3q7a==2 //worked for someone who is not a hh member OR trainee/apprenticeship
replace worked_as_employee=0 if s3q4==2 | s3q7a==3

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
replace mainwage_recent_payment = . if ag_activity==1 // only non ag wages 

ren s3q21b mainwage_payment_period
ren s3q24a mainwage_recent_payment_other
replace mainwage_recent_payment_other = . if ag_activity==1 // only non ag wages 
ren s3q24b mainwage_payment_period_other

recode  mainwage_number_months (12/max=12)
recode  mainwage_number_weeks (52/max=52)
recode  mainwage_number_hours (84/max=84)

	//replace mainwage_recent_payment=. if worked_as_employee!=1
	gen mainwage_salary_cash = mainwage_recent_payment if mainwage_payment_period==8
	replace mainwage_salary_cash = ((mainwage_number_months/6)*mainwage_recent_payment) if mainwage_payment_period==7
	replace mainwage_salary_cash = ((mainwage_number_months/4)*mainwage_recent_payment) if mainwage_payment_period==6
	replace mainwage_salary_cash = (mainwage_number_months*mainwage_recent_payment) if mainwage_payment_period==5
	replace mainwage_salary_cash = (mainwage_number_months*(mainwage_number_weeks/2)*mainwage_recent_payment) if mainwage_payment_period==4
	replace mainwage_salary_cash = (mainwage_number_weeks*mainwage_recent_payment) if mainwage_payment_period==3 
	replace mainwage_salary_cash = (mainwage_number_weeks*(mainwage_number_hours/8)*mainwage_recent_payment) if mainwage_payment_period==2
	replace mainwage_salary_cash = (mainwage_number_weeks*mainwage_number_hours*mainwage_recent_payment) if mainwage_payment_period==1

	//replace mainwage_recent_payment_other=. if worked_as_employee!=1
	gen mainwage_salary_other = mainwage_recent_payment_other if mainwage_payment_period_other==8
	replace mainwage_salary_other = ((mainwage_number_months/6)*mainwage_recent_payment_other) if mainwage_payment_period_other==7
	replace mainwage_salary_other = ((mainwage_number_months/4)*mainwage_recent_payment_other) if mainwage_payment_period_other==6
	replace mainwage_salary_other = (mainwage_number_months*mainwage_recent_payment_other) if mainwage_payment_period_other==5
	replace mainwage_salary_other = (mainwage_number_months*(mainwage_number_weeks/2)*mainwage_recent_payment_other) if mainwage_payment_period_other==4
	replace mainwage_salary_other = (mainwage_number_weeks*mainwage_recent_payment_other) if mainwage_payment_period_other==3
	replace mainwage_salary_other = (mainwage_number_weeks*(mainwage_number_hours/8)*mainwage_recent_payment_other) if mainwage_payment_period_other==2
	replace mainwage_salary_other = (mainwage_number_weeks*mainwage_number_hours*mainwage_recent_payment_other) if mainwage_payment_period_other==1
	recode mainwage_salary_cash mainwage_salary_other (.=0) //should we code . as 0???

	egen annual_salary_nonagwage = rowtotal(mainwage_salary_cash mainwage_salary_other), m


keep if s3q1==1 //keep if age>5
gen secwage_salary_cash=.
gen secwage_salary_other=.
gen mainwage_annual_salary=.
gen secwage_annual_salary=.

lab var annual_salary_nonagwage "Estimated annual earnings from non-agricultural wage employment over previous 12 months"
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
 
keep  zone state lga sector ea hhid indiv sector_code ag_activity annual_salary_nonagwage employed
save "${final_data_wave4}\wave4_nonagwage.dta", replace


********************************************************************************
* HOUSEHOLD CONSUMPTION *
********************************************************************************

use "${raw_data_wave4}\totcons_final.dta", replace
ren totcons_pc percapitacons
la var percapitacons "Yearly per capita consumption"
gen percapitacons_daily=percapitacons/365
la var percapitacons_daily "Daily per capita consumption"
gen totcons_hh=percapitacons*hhsize
la var totcons_hh "Yearly household consumption"
keep hhid hhsize percapitacons percapitacons_daily totcons_hh
save "${final_data_wave4}\wave4_hhconsumption.dta", replace


********************************************************************************
* HOURS WORKED *
********************************************************************************

use "${raw_data_wave4}\sect3a_harvestw4.dta", replace

gen  hrs_wage_off_farm=s3q18 if (s3q14>1 & s3q14!=.) & s3q15b1!=1	// s3q14=1 is agriculture and exclude apprenticeship (unpaid) jobs
gen  hrs_wage_on_farm=s3q18 if (s3q14==1 & s3q14!=.) & s3q15b1!=1	// s3q14=1 is agriculture and exclude apprenticeship (unpaid) jobs 

gen hrs_domestic=. //domestic hours worked per week is missing in wave 4

ren  s3q5b hrs_ag_activ //agricultural activity for the hh
ren  s3q6b hrs_self_off_farm //hh non farm enterprise
egen hrs_off_farm=rowtotal(hrs_wage_off_farm hrs_self_off_farm)  //worked for wage AND hh non farm enterprise 
egen hrs_on_farm=rowtotal(hrs_ag_activ hrs_wage_on_farm) //hours worked for wage AND hh farm activities

la var hrs_off_farm "Total individual hours - work off-farm"
la var hrs_on_farm "Total individual hours - work on-farm"
la var hrs_domestic "Total individual hours - domestic activities"

keep if s3q1==1 //keep members above 5 years of age

keep zone state lga ea hhid indiv hrs_off_farm hrs_on_farm hrs_domestic
save "${final_data_wave4}\wave4_indivhoursworked.dta", replace

gen member_count = 1 //this file only contains people older than 5
collapse (sum) hrs_*  member_count, by(hhid)
ren hrs_off_farm hrs_off_farm_hh
ren hrs_on_farm hrs_on_farm_hh
ren hrs_domestic hrs_domestic_hh
la var member_count "Number of HH members age 5 or above"
la var hrs_off_farm_hh "Total household hours - work off-farm"
la var hrs_on_farm_hh "Total household hours - work on-farm"
la var hrs_domestic_hh "Total household hours - domestic activities"

save "${final_data_wave4}\wave4_hhoursworked.dta", replace
