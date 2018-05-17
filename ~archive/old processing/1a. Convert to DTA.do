	gl path 	"D:\Data\NHANES\NHANES\cdc"
	global path "D:\Data\NHANES_XPT\NHANES\cdc"

	gl root "D:\\Data\\NHANES\\NHANES\\"
	gl input "$root/cdc"
	gl output "$root/output"
	gl temp "$root/temp"
	gl year 2013
	gl redo 0
	do "D:\Applications\Stata14\Scripts\dirlist.do"

	dirlist, fromdir("$path") save("$temp/All XPT files") replace
	
	** 
	if $redo {
		use "$temp/Redo files.dta", replace
		replace fname = subinstr(fname, ".dta", ".xpt", 1)
		replace fname = subinstr(fname, `"""', "", .)
		save "$temp/Redo files.dta", replace
	}
	replace fname = lower(fname)
	keep if substr(fname, -4, .) == ".xpt"
	gen dta = subinstr(fname, ".xpt", ".dta", 1)
	gen excel = subinstr(fname, ".xpt", ".xlsx", 1)

	** Limit to one year
	*keep if strpos(fname, "$year")

	tempfile a
	save `a'

	* Create Excel
	local create_excel = 0
	
	set trace off
	forval i = 1/`=_N' {
		local out = excel[`i']
		local stata_out = dta[`i']
		local in = fname[`i']
		local excel = excel[`i']
		if !$redo {
			capture confirm file "`excel'"
			if _rc == 0 continue
		}
		
		capture {
			disp in red "`in'"
			import sasxport "`in'", clear	
			save "`stata_out'", replace
			Stop
			if `create_excel' export excel using "`excel'", replace firstrow(varlabels)
			disp "`in' success"
		}
		use `a', clear

	}
