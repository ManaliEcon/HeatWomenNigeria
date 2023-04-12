**************************************
********Manali Sovani Paper 1*********
**************************************

****************Temperature***********

clear all
set more off
drop _all
cls

****************Wave 1****************

*Survey Date Calculation*

use "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\NGA_2010_GHSP-W1_v03_M_STATA\Post Harvest Wave 1\Household\secta_harvestw1.dta", clear

gen date1 = mdy(saq13m,saq13d,saq13y)

gen date2 = mdy(01, 01, 2011)

format date1 %td

format date2 %td

gen between = 1+date1 - date2

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\NGA_2010_GHSP-W1_v03_M_STATA\Post Harvest Wave 1\Household\secta_harvestw1_temp.dta", replace

*Individual and Household* 

use "D:\ECONOMICS PHD\Second Year Paper\DATA\NIGERIAN LSMS\WAVE 1\NGA_2010_GHSP-W1_v03_M_STATA\Geodata\NGA_HouseholdGeovariables_Y1.dta", clear
keep zone state lga sector ea hhid lat_dd_mod lon_dd_mod af_bio_1 ssa_aez09 fsrad3_agpct fsrad3_lcmaj srtm_nga af_bio_12

sort lon_dd_mod
replace lon_dd_mod=round(lon_dd_mod, 0.25)
gen temp=floor(lon_dd_mod)
replace temp=lon_dd_mod-temp
replace lon_dd_mod=lon_dd_mod+0.25 if temp==0 | temp==0.5
drop temp

sort lat_dd_mod
replace lat_dd_mod=round(lat_dd_mod, 0.25)
gen temp=floor(lat_dd_mod)
replace temp=lat_dd_mod-temp
replace lat_dd_mod=lat_dd_mod+0.25 if temp==0 | temp==0.5
drop temp

rename lon_dd_mod lon
rename lat_dd_mod lat

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\New Files\wave1_indivtemperature.dta", replace 

*Run R code for temperature merging*

import delimited "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave1tempfile.csv", clear 
replace temperature_7daymean="" if temperature=="NA"
destring temperature_7daymean, replace
replace temperature="" if temperature=="NA"
destring temperature, replace
save "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave1tempfile.dta", replace

use "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\New Files\wave1_indivtemperature.dta", clear 

merge m:1 hhid lat lon using "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave1tempfile.dta", gen(merge2)
drop if hhid==.

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\New Files\wave1_indivtemperature.dta", replace 


**Farmowners*

use "D:\ECONOMICS PHD\Second Year Paper\DATA\NIGERIAN LSMS\WAVE 1\NGA_2010_GHSP-W1_v03_M_STATA\Geodata\NGA_HouseholdGeovariables_Y1.dta", clear
keep zone state lga sector ea hhid lat_dd_mod lon_dd_mod af_bio_1 ssa_aez09 fsrad3_agpct fsrad3_lcmaj srtm_nga af_bio_12

sort lon_dd_mod
replace lon_dd_mod=round(lon_dd_mod, 0.25)
gen temp=floor(lon_dd_mod)
replace temp=lon_dd_mod-temp
replace lon_dd_mod=lon_dd_mod+0.25 if temp==0 | temp==0.5
drop temp

sort lat_dd_mod
replace lat_dd_mod=round(lat_dd_mod, 0.25)
gen temp=floor(lat_dd_mod)
replace temp=lat_dd_mod-temp
replace lat_dd_mod=lat_dd_mod+0.25 if temp==0 | temp==0.5
drop temp

merge 1:m zone state lga sector ea hhid using "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\NGA_2010_GHSP-W1_v03_M_STATA\Geodata\NGA_PlotGeovariables_Y1.dta", keepusing(zone state lga sector ea hhid plotid dist_household) gen(merge1)

rename lon_dd_mod lon
rename lat_dd_mod lat

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\New Files\wave1_farmtemperature.dta", replace 


*Run R code for temperature merging*

import delimited "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave1tempfile.csv", clear 
replace temperature_7daymean="" if temperature=="NA"
destring temperature_7daymean, replace
replace temperature="" if temperature=="NA"
destring temperature, replace
save "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave1tempfile.dta", replace

use "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\New Files\wave1_farmtemperature.dta", clear 

merge m:1 hhid lat lon using "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave1tempfile.dta", gen(merge2)
drop if plotid==. & hhid!=. //drop households that dont own a plotid

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 1\New Files\wave1_farmtemperature.dta", replace 

****************Wave 2****************

*Survey Date Calculation*

use "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Household\secta_harvestw2.dta", clear


gen date1 = mdy(saq13m,saq13d,saq13y)

gen date2 = mdy(01, 01, 2013)

format date1 %td

format date2 %td

gen between = 1+date1 - date2

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Household\secta_harvestw2_temp.dta", replace

*Individual and Household* 

use "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\NGA_2012_GHSP-W2_v02_M_STATA\Geodata Wave 2\NGA_HouseholdGeovars_Y2.dta", clear
keep zone state lga sector ea hhid LAT_DD_MOD LON_DD_MOD af_bio_1 ssa_aez09 fsrad3_agpct fsrad3_lcmaj srtm_nga af_bio_12

rename LAT_DD_MOD lat_dd_mod
rename LON_DD_MOD lon_dd_mod

sort lon_dd_mod
replace lon_dd_mod=round(lon_dd_mod, 0.25)
gen temp=floor(lon_dd_mod)
replace temp=lon_dd_mod-temp
replace lon_dd_mod=lon_dd_mod+0.25 if temp==0 | temp==0.5
drop temp

sort lat_dd_mod
replace lat_dd_mod=round(lat_dd_mod, 0.25)
gen temp=floor(lat_dd_mod)
replace temp=lat_dd_mod-temp
replace lat_dd_mod=lat_dd_mod+0.25 if temp==0 | temp==0.5
drop temp

rename lon_dd_mod lon
rename lat_dd_mod lat

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\New Files\wave2_indivtemperature.dta", replace

*Run R code for temperature merging*

import delimited "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave2tempfile.csv", clear
replace temperature_7daymean="" if temperature=="NA"
destring temperature_7daymean, replace
replace temperature="" if temperature=="NA"
destring temperature, replace
destring lat lon between, force replace
save "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave2tempfile.dta", replace

use "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\New Files\wave2_indivtemperature.dta", clear
 
merge m:1 hhid lat lon using "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave2tempfile.dta", gen(merge2)
drop if hhid==.

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\New Files\wave2_indivtemperature.dta", replace 


**Farmowners*

use "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\NGA_2012_GHSP-W2_v02_M_STATA\Geodata Wave 2\NGA_HouseholdGeovars_Y2.dta", clear
keep zone state lga sector ea hhid LAT_DD_MOD LON_DD_MOD af_bio_1 ssa_aez09 fsrad3_agpct fsrad3_lcmaj srtm_nga af_bio_12

rename LAT_DD_MOD lat_dd_mod
rename LON_DD_MOD lon_dd_mod

sort lon_dd_mod
replace lon_dd_mod=round(lon_dd_mod, 0.25)
gen temp=floor(lon_dd_mod)
replace temp=lon_dd_mod-temp
replace lon_dd_mod=lon_dd_mod+0.25 if temp==0 | temp==0.5
drop temp

sort lat_dd_mod
replace lat_dd_mod=round(lat_dd_mod, 0.25)
gen temp=floor(lat_dd_mod)
replace temp=lat_dd_mod-temp
replace lat_dd_mod=lat_dd_mod+0.25 if temp==0 | temp==0.5
drop temp

merge 1:m zone state lga sector ea hhid using "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\NGA_2012_GHSP-W2_v02_M_STATA\Geodata Wave 2\NGA_PlotGeovariables_Y2.dta", keepusing(zone state lga sector ea hhid plotid dist_household) gen(merge1)

rename lon_dd_mod lon
rename lat_dd_mod lat

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\New Files\wave2_farmtemperature.dta", replace 

*Run R code for temperature merging*

import delimited "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave2tempfile.csv", clear
replace temperature_7daymean="" if temperature=="NA"
destring temperature_7daymean, replace
replace temperature="" if temperature=="NA"
destring temperature, replace
destring lat lon between, force replace
save "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave2tempfile.dta", replace

use "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\New Files\wave2_farmtemperature.dta", clear
 
merge m:1 hhid lat lon using "C:\Users\msovan01\Box\Paper 1\Data\Temperature\wave2tempfile.dta", gen(merge2)
drop if plotid==. & hhid!=. //drop households that dont own a plotid

save "C:\Users\msovan01\Box\Paper 1\Data\Wave 2\New Files\wave2_farmtemperature.dta", replace 
