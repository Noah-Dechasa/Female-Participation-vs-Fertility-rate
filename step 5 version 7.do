
clear all

**********************************
*        Noah Dechasa
*            Dec 5 2022
**********************************

log using "NOAH_step version 7", replace

*Importing Data

import excel "/Users/noah/Downloads/bruh..2.xlsx", sheet("Data") firstrow clear

*Dropping irrelevant data
drop if Time == "Data from database: World Development Indicators"
drop if Time == "Last Updated: 09/16/2022"
drop TimeCode


*Encoding Country and CountryCode
encode CountryName, gen(country)
encode CountryCode, gen(countrycode)
drop CountryCode CountryName

order countrycode Time
order country countrycode

destring Time, replace

*Renaming Variables
rename Time year
rename GDPcurrentUSNYGDPMKTPC GDP
rename Fertilityratetotalbirthspe Fertility_rate
rename Laborforceparticipationrate Male_labor_participation 
rename F Female_labor_participation
rename Unemploymentfemaleoffemal Female_Unemployment 
rename Unemploymentmaleofmalela Male_Unemployment 
rename Unemploymentwithadvancededuca Female_advanced_Unemployment 
rename H Male_advanced_Unemployment 

*Relabeling Variables
label var year "Year"
label var GDP "GDP in Current USD"
label var Fertility_rate "Fertility rate (birth per women) "
label var Female_labor_participation "Female Labor Participation rate from ages 15+(%)(National estimate)"
label var Male_labor_participation "Male Labor Participation rate from ages 15+ (%)(National estimate)"
label var Female_Unemployment "Female Unemployment rate from ages 15+ (%)(National estimate)"
label var Male_Unemployment "Male Unemployment rate from ages 15+ (%)(National estimate)"
label var Female_advanced_Unemployment "Female Unemployment rate with Advanced education from ages 15+ (%)(National estimate)"
label var Male_advanced_Unemployment "Male Unemployment rate with Advanced education from ages 15+ (%)(National estimate)"

*Declaring Panel-Data
xtset countrycode year

*Creating lagged key variables
gen lMale_labor_participation = l.Male_labor_participation
gen l2Male_labor_participation = l2.Male_labor_participation
gen l3Male_labor_participation = l3.Male_labor_participation
gen l4Male_labor_participation = l4.Male_labor_participation

gen lFemale_labor_participation = l.Female_labor_participation
gen l2Female_labor_participation = l2.Female_labor_participation
gen l3Female_labor_participation = l3.Female_labor_participation
gen l4Female_labor_participation = l4.Female_labor_participation

*Multiple-Regrassion Analysis
reg Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP year , r
*Model 1- Fixed_Effect
xi: xtreg  Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP i.year, fe r

outreg2 using noah54.doc, replace title(Table 2: Regression estimation of The Relationship between Fertility Rate and Female Labor participation ) ctitle( (Model )) label keep(Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP) addnote(Measured with year effect)

*Model 2- Fixed_Effect
xi: xtreg  Fertility_rate Female_labor_participation lFemale_labor_participatio l2Female_labor_participation l3Female_labor_participation l4Female_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP i.year, fe r

outreg2 using noah54.doc, append title(Table 2: Regression estimation of The Relationship between Fertility Rate and Female Labor participation ) ctitle(  (Model )) label keep(Fertility_rate lFemale_labor_participatio l2Female_labor_participation l3Female_labor_participation l4Female_labor_participation  Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP) 

*Model 3- Fixed_Effect
xi: xtreg  Fertility_rate Male_labor_participation lMale_labor_participation l2Male_labor_participation l3Male_labor_participation l4Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP i.year, fe r

outreg2 using noah54.doc, append title(Table 2: Regression estimation of The Relationship between Fertility Rate and Female Labor participation ) ctitle(  (Model )) label keep(Fertility_rate Female_labor_participation lMale_labor_participation l2Male_labor_participation l3Male_labor_participation l4Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP) 

*Model 4- Fixed_Effect
xi: xtreg  Fertility_rate Female_labor_participation lFemale_labor_participatio l2Female_labor_participation l3Female_labor_participation l4Female_labor_participation Male_labor_participation lMale_labor_participation l2Male_labor_participation l3Male_labor_participation l4Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP i.year, fe r

outreg2 using noah54.doc, append title(Table 2: Regression estimation of The Relationship between Fertility Rate and Female Labor participation ) ctitle(  (Model )) label keep(Fertility_rate lFemale_labor_participatio l2Female_labor_participation l3Female_labor_participation l4Female_labor_participation lMale_labor_participation l2Male_labor_participation l3Male_labor_participation l4Male_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP) 


*Model 5 - Random_Effect
xi: xtreg Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP  i.year, re r

outreg2 using noah54.doc, append title(Table 2: Regression estimation of The Relationship between Fertility Rate and Female Labor participation ) ctitle(Random Effect  (Model )) label keep(Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP) 


*Explanatory Data Analysis
asdoc sum Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP , label

sum Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP , d

*Panel Data Analysis
xtsum

xtdes

*Graphs

xtline Female_labor_participation, overlay

graph bar (mean) Female_labor_participation , over(countrycode, label(labsize(vsmall))) blabel(total, size(vsmall)) ytitle(Female Labor Participation) title( Female Labor Participation in the top Devoleped Countries)

graph export "/Users/noah/Desktop/econometrics/Step 5/Female_labor_participation.jpg", as(jpg) name("Graph") quality(90)

graph bar (mean) Fertility_rate, over(countrycode, label(labsize(vsmall))) blabel(total, size(vsmall)) ytitle(Fertility Rate) title(Mean Fertility Rate in the top Develeped Countries)

graph export "/Users/noah/Desktop/econometrics/Step 5/Fertility_rate.jpg", as(jpg) name("Graph") quality(90)

*Hausman Test
xi: xtreg Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP  i.year i.country, fe
esti store fixedeffect

xi: xtreg Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP , re
esti store randomeffect

hausman fixedeffect randomeffect

*Testing for time effect
xi: xtreg Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP  i.year, fe
testparm _Iyear*

*Multicollinearity
pwcorr Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP 

*Heterokedasticity
xi: xtreg Fertility_rate Female_labor_participation Male_labor_participation Female_Unemployment Male_Unemployment Female_advanced_Unemployment Male_advanced_Unemployment GDP  i.year, fe r
xttest3



log close 
