set excelxlsxlargefile on

gl root "D:\\Data\\NHANES\\NHANES\\"
gl input "$root/cdc"
gl output "$root/output"
gl temp "$root/temp"

adopath ++ "D:\\Applications\\Stata ADO"


local limitation "expansive"  /* "all" "limited" */
local reimport 0

if `reimport' {
	import excel using "$output\\master summary - with flags2.xlsx", firstrow clear
	save "$temp/master summary - with flags2.dta", replace
}

** Some preprocessing stuff
use "$temp/master summary - with flags2.dta", replace
rename var variablename
replace flag = "S1" if variablename  == "ridagemn"
replace flag = subinstr(flag, ", ", "", .)

** Remove _summ suffix
foreach var of varlist filename path {
	replace `var' = subinstr(`var', "_summ", "", .)
}

bysort variablename (flag): replace flag = flag[_N] /* extend flag */

** Not for SEQ
if "`limitation'" != "all" {
	replace flag = "" if  variablename == "Respondent Sequence Number"
}

*drop if total_obs < 8000 /* only want relatively complete data fields */

*bysort Filename (flag): gen flag_file = flag[_N] 	/* extend flag to file*/
tempfile a
save `a'
save "$temp/flagged variables.dta", replace


** Limit to main files
keep if !mi(flag) | feature == "laboratory"
drop if feature == "dietary"

keep path year filename
duplicates drop


tempfile filelist
save "`filelist'"

levelsof year, local(years)
*local years 2013

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
	gen seqn = .
	forval i = 1/`total' {
		capture merge 1:1 seqn using "``i''", gen(_merge`i')
		if _rc != 0 {
			disp in red "``i''"

			if 1 {
				tempfile b
				save `b'
				use ``i'', clear
				capture confirm variable seqn
				
				if _rc != 0 {
					disp in red "SEQN not found"
					use `b', clear
					continue
				}
				
				capture isid seqn
				if _rc != 0 {
					disp in red "SEQN not unique"
					use `b', clear
					continue
				}
				
				brdup seqn
				merge 1:1 seqn using "`b'"
				Stop
			} 
		}
	}
	save "$temp/`year'.dta", replace
	export excel using "$output/`year' `limitation'.xlsx", sheetreplace sheet("data") firstrow(varlabels)
}

* ideas: make everything strings
* standardize variable names...
* Go back to using coded varible names...
