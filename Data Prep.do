clear
cd "G:\My Drive\ECON 999\"

input str16 station str16 line latitude1 longitude1
	"Mill Woods" SE 53.458426 -113.429282
	"Grey Nuns"  SE 53.462795 -113.434393
	"Millbourne" SE 53.475083 -113.438730
	"Davies"     SE 53.500497 -113.444912
	"Avonmore"   SE 53.509456 -113.455004
	"Bonnie Doon" SE 53.519140 -113.455431
	"Holyrood"   SE 53.527748 -113.457370
	"Strathearn" SE 53.531696 -113.463199
	"Muttart"    SE 53.536019 -113.480236
	"Quarters"   SE 53.544441 -113.483628
	"Churchill"  SE 53.543421 -113.489812
	"102 Street" SE 53.543122 -113.495298
end 
save valleylinese, replace
clear
input str16 station str16 line latitude1 longitude1
	"Alex Decoteau" W 53.543064 -113.501246
	"Norquest"      W 53.545417 -113.504800
	"Macewan Arts"  W 53.546239 -113.513914
	"The Yards"     W 53.546233 -113.521247
	"Brewery"       W 53.546182 -113.528655
	"124 Street"    W 53.546896 -113.535945
	"Glenora"       W 53.543957 -113.559622
	"Grovenor"      W 53.542943 -113.565677
	"149 Street"    W 53.541324 -113.580577
	"Jasper Place"  W 53.540591 -113.590401
	"Glenwood"      W 53.531530 -113.590315
	"Meadowlark"    W 53.521704 -113.595070
	"Misercordia"   W 53.519689 -113.611990
	"WEM"           W 53.520314 -113.622726
	"Aldergrove"    W 53.521500 -113.639517
	"Lewis Farms"   W 53.523028 -113.664155
end
save valleylinewest, replace

import delimited "LRT_Stations_and_Stops.csv", clear
drop if lrttraveldirection=="SB" & lrtstopdescription != "NAIT"
keep lrtstopdescription latitude longitude
rename latitude latitude1
rename longitude longitude1
save stationinformation, replace

import delimited "Property_Information__Current_Calendar_Year_.csv", clear
keep accountnumber totalgrossarea
split totalgrossarea
destring totalgross~1, replace
drop totalgrossarea totalgross~2 totalgross~3 totalgross~4 totalgross~5
rename totalgross~1 structuresize
gen structuresizesq=structuresize^2
save propertyinformation, replace


import delimited "Property_Assessment_Data__Historical_.csv", clear
gen garagebinary=1 if garage=="Y"
replace garagebinary=0 if garage=="N"
encode neighbourhood, generate(neighbourhood2)
encode zoning, generate(zoning2)


gen cpi=121.7 if assessmentyear==2012
replace cpi=128.7 if assessmentyear==2013
replace cpi=132.2 if assessmentyear==2014
replace cpi=133.7 if assessmentyear==2015
replace cpi=135.8 if assessmentyear==2016
replace cpi=138.1 if assessmentyear==2017
replace cpi=140.9 if assessmentyear==2018
replace cpi=144.5 if assessmentyear==2019
replace cpi=147.0 if assessmentyear==2020
replace cpi=152.7 if assessmentyear==2021

gen realprice=assessedvalue/cpi*100
gen lnrealprice=ln(realprice)

gen lotsizesq=lotsize^2

gen townhalllat= 53.5456
gen townhalllong= -113.4903

geodist latitude longitude townhalllat townhalllong, generate(distance) sphere

gen distancesq=distance^2

keep if assessmentclass1=="RESIDENTIAL"

merge m:m accountnumber using "propertyinformation.dta"

keep if _merge==3
drop _merge

gen id=_n
geonear id latitude longitude using "stationinformation.dta", n(lrtstopdescription latitude1 longitude1)
rename km_to_nid distancelrtopen
rename nid nearestopenstation
gen distancelrtopensq=distancelrtopen^2

geonear id latitude longitude using "valleylinese.dta", n(station latitude1 longitude1)
rename km_to_nid distancelrtvalleylinese
rename nid nearestvalleylinese
gen distancelrtvalleylinesesq=distancelrtvalleylinese^2

geonear id latitude longitude using "valleylinewest.dta", n(station latitude1 longitude1)
rename km_to_nid distancelrtvalleylinewest
rename nid nearestvalleylinewest
gen distancelrtvalleylinewestsq=distancelrtvalleylinewest^2

gen valleycloser = 1 if distancelrtvalleylinese <= distancelrtopen
replace valleycloser=1 if distancelrtvalleylinewest <= distancelrtopen
replace valleycloser=0 if valleycloser==.

summ
drop streetname legaldescription pointlocation garage id

gen apartment= 0 if suite == ""
replace apartment=1 if apartment==.



drop if lnrealprice==.
drop if lotsize==.
drop if structuresize==.
drop if distancelrtopen==.
drop if actualyearbuilt==.

drop if lotsize<10
drop if structuresize<10
drop if assessmentyear==2021

gen lnlotsize = ln(lotsize)
gen lnstructuresize=ln(structuresize)

drop if assessmentyear==2020

* CRIME DATA 
import delimited "neighbourhoodcrime.csv", clear
rename neighbourhooddescriptionoccurren neighbourhood
rename occurrenceviolationtypegroup crimetype
rename occurrencereportedyear assessmentyear
rename occurrencereportedquarter quarter
rename occurrencereportedmonth month
sort neighbourhood assessmentyear quarter month crimetype
egen count=sum(occurrences), by(assessmentyear crimetype neighbourhood)
keep if month==1
encode crimetype, gen(crimetypes)
gen assault=count if crimetype=="Assault"
gen bne=count if crimetype=="Break and Enter"
gen robbery=count if crimetype=="Robbery"
gen sassault=count if crimetype=="Sexual Assaults"
gen theftvehicle=count if crimetype=="Theft of Vehicle" 
gen theftfromvehicle= count if crimetype=="Theft From Vehicle"
gen theftover5000=count if crimetype=="Theft Over $5000"
gen homicide=count if crimetype=="Homicide"
encode neighbourhood, gen(neighbourhoods)
collapse assault bne robbery sassault theftfromvehicle theftover5000 theftvehicle homicide, by(neighbourhood neighbourhoods assessmentyear)
mvencode _all, mv(0)
save "crime.dta", replace
 

use "cleaneddata.dta",clear

merge m:m neighbourhood assessmentyear using "crime.dta"
keep if _merge==3
drop _merge


egen neighcountyear=count(lnrealprice), by(neighbourhood assessmentyear)
gen theftcrime=(robbery+bne+theftvehicle+theftover5000+theftfromvehicle)/neighcountyear
gen personcrime=(assault+sassault+homicide)/neighcountyear

drop if assessmentyear != 2019
drop suite housenumber latitude longitude assessmentclass1 v17 assessmentclass2 v19 assessmentclass3 v21 neighbourhood2 zoning2 cpi assessedvalue lnrealprice townhalllat townhalllong nearestopenstation nearestvalleylinese nearestvalleylinewest valleycloser lnlotsize lnstructuresize assessmentyear neighbourhoods assault bne robbery theftfromvehicle theftover5000 homicide neighcountyear

export delimited "Edmonton_Housing_2019.csv", replace



