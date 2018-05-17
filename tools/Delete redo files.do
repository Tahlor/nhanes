	gl path 	"D:\Data\NHANES\NHANES\cdc"
	global path "D:\Data\NHANES_XPT\NHANES\cdc"

	gl root "D:\\Data\\NHANES\\NHANES\\"
	gl input "$root/cdc"
	gl output "$root/output"
	gl temp "$root/temp"
	gl year 2013
	gl redo 0
	do "D:\Applications\Stata14\Scripts\dirlist.do"
	
	use "$temp/Redo files.dta", replace
	replace fname = subinstr(fname, ".xpt", "_SUMM.xlsx", .)
	forval i = 1/`=_N' {
		capture rm "`=fname[`i']'"
		if _rc != 0 disp in red "`=fname[`i']'"
	}
