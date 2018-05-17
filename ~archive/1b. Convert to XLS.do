	gl path "D:\OneDrive\Documents\Graduate School\2017 Fall\CS 478\NHANES"
	gl path "D:\OneDrive\Documents\Graduate School\2017 Fall\CS 478\NHANES\cdc\2013"
	gl path "D:\Data\NHANES\NHANES\cdc"

	gl out "D:\Applications\Stata14\Scripts\All files.dta"

	do "D:\Applications\Stata14\Scripts\dirlist.do"

	dirlist, fromdir("$path") save("$out") replace

	set excelxlsxlargefile on
	
	replace fname = lower(fname)
	keep if substr(fname, -4, .) == ".dta" & strpos(fname, "SUMM") == 0
	gen xls = subinstr(fname, ".dta", ".xls", 1)
	gsort -fname
	tempfile a
	save `a'

	set trace off
	forval i = 1/`=_N' {
		local out = xls[`i']
		local in = fname[`i']
		capture confirm file "`out'"
		if _rc == 0 continue

		*capture {
			disp in red "`in'"
			use "`in'", clear
			export excel using "`out'", replace firstrow(varlabels)
			disp "`in' success"
		*}
		STOP
		
		use `a', clear

	}
