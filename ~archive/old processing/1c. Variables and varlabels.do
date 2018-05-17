	gl path 	"D:\Data\NHANES\NHANES\cdc"
	global path "D:\Data\NHANES_XPT\NHANES\cdc"

	gl root "D:\\Data\\NHANES\\NHANES\\"
	gl input "$root/cdc"
	gl output "$root/output"
	gl temp "$root/temp"

	** Converts XPT file to Stata
	** Exports a file summarizing variable labels, names, and types
	
	do "D:\Applications\Stata14\Scripts\dirlist.do"
	
	
	dirlist, fromdir("$path") save("$temp/All XPT files") replace

	set excelxlsxlargefile on
	
	replace fname = lower(fname)
	keep if lower(substr(fname, -4, .)) == ".xpt"
	gen excel_variables = subinstr(fname, ".xpt", "_VARS.xlsx", 1)
	gsort -fname
	tempfile a
	save `a'

	set trace off
	forval i = 1/`=_N' {
		local out = excel_variables[`i']
		local in = fname[`i']
		disp "`out'"
		capture confirm file "`out'"
		if _rc == 0 continue

		capture {
			disp in red "`in'"
			import sasxport "`in'", clear
			*export excel using "`out'", replace firstrow(varlabels)
			describe, replace clear

			export excel using "`out'"
			disp "`in' success"	
			
		}
		
		use `a', clear

	}
