set excelxlsxlargefile on

gl root "D:\\Data\\NHANES\\NHANES\\"
gl input "$root/cdc"
gl output "$root/output"
gl temp "$root/temp"

adopath ++ "D:\Applications\Stata ADO"

do "D:\Applications\Stata14\Scripts\dirlist.do"
do "D:\Data\NHANES\NHANES\output\~Program for data summary.do"
/*
import excel using "$output\\master summary - with flags.xlsx", firstrow clear
rename A flag
rename (missing	zero	negative) =_perc
rename *, lower
save "$temp/master summary - with flags.dta", replace
*/
use "$temp/master summary - with flags.dta", clear
keep flag variablename
rename variablename proper_label
drop if mi(flag)
replace flag = subinstr(flag, ", ", "", .)
replace flag = "E1" if proper_label == "Waist Circumference (Cm)"

duplicates drop
isid proper_label

tempfile a
save `a'

use "$output/master_summary.dta", replace
merge m:1 proper_label using `a', nogen assert(1 3)

save "$temp/master summary - with flags2TEMP.dta", replace
order flag	proper_label	label	var	unique_values total_obs

replace relative_path  = subinstr(relative_path , "Z1", "AB1", .)
export excel using "$output/master summary - with flags2.xlsx", sheetreplace firstrow(variables)

* read in other one
* merge flags on
* export
* etc.

