	gl path "D:\OneDrive\Documents\Graduate School\2017 Fall\CS 478\NHANES"
	gl path "D:\OneDrive\Documents\Graduate School\2017 Fall\CS 478\NHANES\cdc\2013"
	gl path "D:\Data\NHANES\NHANES\cdc"

	gl out "D:\Applications\Stata14\Scripts\All files.dta"

	do "D:\Applications\Stata14\Scripts\dirlist.do"

	dirlist, fromdir("$path") save("$out") replace

	replace fname = lower(fname)
	keep if substr(fname, -4, .) == ".xpt"
	gen fname2 = subinstr(fname, ".xpt", ".csv", 1)
	gen excel = subinstr(fname, ".xpt", ".xlsx", 1)
	tempfile a
	save `a'

	set trace off
	forval i = 1/`=_N' {
		local out = fname2[`i']
		local in = fname[`i']
		local excel = excel[`i']
		capture confirm file "`excel'"
		if _rc == 0 continue

		capture {
			disp in red "`in'"

			import sasxport "`in'", clear	
			*export delimited using "`out'", replace
			export excel using "`excel'", replace firstrow(varlabels)
			disp "`in' success"
		}
		use `a', clear

	}
