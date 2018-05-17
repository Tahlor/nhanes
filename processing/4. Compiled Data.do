set excelxlsxlargefile on

gl root "D:\\Data\\NHANES\\NHANES\\"
gl input "$root/cdc"
gl output "$root/output"
gl temp "$root/temp"

adopath ++ "D:\\Applications\\Stata ADO"

/*
import excel using "$output\\master summary - with flags.xlsx", firstrow clear
rename A flag
rename (missing	zero	negative) =_perc
rename *, lower
save "$temp/master summary - with flags.dta", replace
*/

use "$temp/master summary - with flags.dta", replace
replace flag = subinstr(flag, ", ", "", .)

** Remove _summ suffix
foreach var of varlist filename path {
	replace `var' = subinstr(`var', "_summ", "", .)
}

bysort variablename (flag): replace flag = flag[_N] /* extend flag */
*bysort Filename (flag): gen flag_file = flag[_N] 	/* extend flag to file*/
tempfile a
save `a'


** Limit to main files
keep if !mi(flag) | feature == "laboratory"
drop if feature == "dietary"

keep path year filename
duplicates drop


tempfile filelist
save "`filelist'"

levelsof year, local(years)

foreach year of local years {
	use "`filelist'", clear
	keep if year == "`year'"
	tempfile a
	save `a'
	
	local total = `=_N'
	forval i = 1/`=_N' {
		use `a', clear
		local year = "`=year[`i']'"
		local path =  "`=path[`i']'"
		local pathdta = subinstr("`path'", ".xlsx", ".dta", 1)
		local filename =  subinstr("`=filename[`i']'", ".xlsx", ".dta", 1)
		
		** Import
		/*import excel using "`path'", clear firstrow
		capture mkdir "$temp/`year'"
		save "$temp/`year'/`filename'", replace*/
		
		/*use "`pathdta'", clear
		tempfile `i'
		save ``i''*/
		
		local `i' = "`pathdta'"
	}
	clear
	use `1', clear
	forval i = 2/`total' {
		capture merge 1:1 Respondentsequencenumber using "``i''", gen(_merge`i')
		if _rc != 0 {
			/*tempfile b
			save `b'
			use ``i'', clear
			
			brdup Respondentsequencenumber
			merge 1:1 Respondentsequencenumber using "`b'"
			Stop*/
			disp in red "``i''"
		}
	}
	save "$temp/`year'.dta", replace
}
* ideas: make everything strings
* standardize variable names...
* Go back to using coded varible names...
