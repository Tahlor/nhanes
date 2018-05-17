gl root "D:\\Data\\NHANES\\NHANES\\"
gl input "$root/cdc"
gl output "$root/output"
gl temp "$root/temp"


forval year = 1999(2)2013 {
	use "$temp/`year'.dta", clear
	disp `year'
	
	capture gen ridageyr = ridageex/12
	if _rc != 0 disp "`year' failed"
	if `year' == 2007 STOP
	save "$temp/`year'.dta", replace
}
