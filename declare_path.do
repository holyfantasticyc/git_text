*declare path
set more off, perm
macro drop _all
global path "/Users/holyfantastic/Dropbox/subway"
// global path "C:\Users\wych1\Dropbox\subway"
global data "$path/data"  
global temp "$path/temp"
global table "$path/table"
global figure "$path/figure"
global log "$path/log"
global do "$path/do"
global ado "$do/ado"

pwd
cd "$data"
global festivals new_year spring_festival ching_ming labor_day dragon_boat mid_aulumn national_day

adopath + "$ado"
********************************************************
****passenger flow
*cleaning the copy data from excel
drop if date=="2015-008-12"
gsort -id
gsort year month day
gen id=_n
labmask id,val(date)
rename date date_cn
save "$data/data_bj.dta",replace
*
use "$data/data_bj.dta", clear
gen date = mdy(month, day, year)
format date %tdCCYY/nn/dd
gen week=week(date)
gen dow=dow(date)
label define dow_eng 0 "Sun" 1 "Mon" 2 "Tue" 3 "Wed" 4 "Thu" 5 "Fri" 6 "Sat"
label value dow dow_eng
gen date_1 = mdy(month, day, year)
gen ln_num=ln(num)
generate weekend=(dow==0| dow==6)
******merge date id
preserve
duplicates drop month day,force
keep month day
sort month day
gen date_id=_n
save "$data/date_id.dta", replace
restore

use "$data/data_bj.dta", clear
merge m:1 month day using "$data/date_id.dta"
drop _merge
save "$data/data_bj.dta", replace

*merge worked_weekend
use "$data/data_bj.dta", clear
merge m:1 month day year using "$data/worked_weekend.dta"
drop if _merge==2
drop _merge
save "$data/data_bj.dta", replace


*gasoline consumption
use "/Users/holyfantastic/Box/SecondYear/Environmental/Gasolineproject/data/raw_data/gasbeijing/GS_bj.dta", clear

keep if oil_id==300063 | oil_id==300064 | oil_id==300586 | oil_id==300585 | oil_id ==300776 | oil_id==300667 | oil_id==300590 | oil_id==300668 | oil_id==300591 | oil_id==300060 | oil_id==300775  | oil_id==300684 | oil_id==300757  | oil_id==300777  | oil_id==300061
collapse (mean) price (sum) sale ,by( month day year)
drop if year==.

rename sale gas_sale

replace gas_sale=gas_sale/10000
label var gas_sale "10^4 L"
gen ln_gas_sale=ln(gas_sale*10000)

save "$data/gas_sale.dta", replace

*air pollution data 
*US embassy

split date ,gen(temp) parse(/)
gen year="20"+ temp3
rename temp1 month
rename temp2 day
drop  temp3
destring month,replace
destring day,replace
destring year,replace
replace level=. if level==-999
collapse (mean) level ,by(air_pollutant month day year)
keep if air_pollutant=="PM2_5"
sort year month day
rename level PM2_5
save "$data/air_embassy.dta", replace

*line data
***import subway_bj_line.xls ***
rename linebt line16
rename linecp line17
rename linefs line18
rename lineair line19
rename lineyz line20
rename lines1 line21
gen date = mdy(month, day, year)
duplicates drop date,force
reshape long line, i(date) 
rename line num
rename _j line
tostring line,replace

replace line="bt" if line=="16"
replace line="cp" if line=="17"
replace line="fs" if line=="18"
replace line="air" if line=="19"
replace line="yz" if line=="20"
replace line="s1" if line=="21"

save "$data/data_bj_num.dta", replace
