set excelxlsxlargefile on
gl path "D:\Data\NHANES\NHANES\cdc"

gl out "D:\Applications\Stata14\Scripts\All files.dta"
gl output "D:\Data\NHANES\NHANES\output"
adopath ++ "D:\Applications\Stata ADO"

do "D:\Applications\Stata14\Scripts\dirlist.do"
do "D:\Data\NHANES\NHANES\output\~Program for data summary.do"

local replace 1

dirlist, fromdir("$path") save("$out") replace

replace fname = lower(fname)
keep if substr(fname, -5, .) == ".xlsx"
drop if strpos(fname, "/~") > 0
drop if strpos(fname, "_summ.xlsx") > 0

** Limit -- only redo a few
keep if strpos(fname, "ph_") | strpos(fname, "135_")| strpos(fname, "dex_c_summ")

gsort -fname
tempfile a
save `a'

save "$output/all_files_summary.dta", replace emptyok

set trace off
forval i = 1/`=_N' {
	local in = fname[`i']
	*local in = "d:\data\nhanes\nhanes\cdc/1999/dietary/dsbi.xlsx"
	local out = subinstr("`in'", ".xlsx", ".dta", 1)
	local outsummary = subinstr("`in'", ".xlsx", "_SUMM.xlsx", 1)
	disp in red "`out'"
	
	* Skip completed files
	if !`replace' {
		capture confirm file "`outsummary'"
		if _rc == 0 continue
	}
	capture {
		
		* Load file
		capture confirm file "`out'"
		if _rc == 0 {
			use "`out'", clear
		}
		else {
			import excel using "`in'", clear firstrow
			save "`out'", replace
		}
		
		summarize_data "`out'" "`outsummary'"
	}	
	use `a', clear
}
