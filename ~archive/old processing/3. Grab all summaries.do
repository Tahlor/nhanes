set excelxlsxlargefile on

gl root "D:\\Data\\NHANES\\NHANES\\"
gl input "$root/cdc"
gl output "$root/output"
gl temp "$root/temp"

adopath ++ "D:\Applications\Stata ADO"

do "D:\Applications\Stata14\Scripts\dirlist.do"
do "D:\Data\NHANES\NHANES\output\~Program for data summary.do"

local replace 1

dirlist, fromdir("$path") save("$out") replace

replace fname = lower(fname)
keep if lower(substr(fname, -10, .)) == "_summ.xlsx"
drop if strpos(fname, "/~") > 0

gsort -fname
tempfile a
save `a'
local total `=_N'

** Import
set trace off
forval i = 1/`=_N' {
	use `a', clear
	local in = fname[`i']
	disp in red 

	capture {
		import excel using "`in'", clear firstrow sheet("Stats summary")
		gen path = subinstr("`in'", "\", "/", .)
		split path, parse("/")
		drop path1	path2	path3	path4
		tempfile `i'
		save ``i''
		*save "$temp/
	}
	disp in red `"`in'"'

	if _rc != 0 {
		error_log "$output/Failed to Read Summary Files.log" "`in'"
	}

}

** Combine
forval i = 1/`total' {
	capture append using ``i''
}

compress
drop path5
rename (path6 path7 path8) (year feature_class filename)


unique proper_label
sum total_obs
disp %12.0fc r(sum)
unique path

gen documentation_path = subinstr(path, filename, "documentation/" + subinstr(filename, "_summ.xlsx", ".htm", 1), 1   )
gen relative_path = subinstr(path, "d:/data/nhanes/nhanes/cdc/", `"=Z1 & ""', 1)+`"""'

save "$output/master_summary.dta", replace

export excel "$output/master summary.xlsx", sheetreplace firstrow(variables) sheet("Master summary")

*Variable name	Unique values	Missing	% missing	Zero	% zero	Negative	% negative	Range	Type	Mode	Mode count	Mean	sd	p25	Median	p75	Total obs	Path	Year	Feature class	File name
