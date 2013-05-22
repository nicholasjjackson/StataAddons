program progload
syntax [anything] [, DIRectory(string)]
qui {
discard
preserve
/*Deterrmine Current Directory*/
local currdir=c(pwd)
	if "`currdir'" == "c:" {
		local currdir  c:\
	}
	else {
	}


if "`directory'" == "" {
	cd "$addons\\`anything'"
	local myfiles: dir "$addons\\`anything'" files "*.ado"
	capture  foreach x of local myfiles {
		qui: capture run `x'
	}
}
*
if "`directory'" != "" {
	cd "`directory'\\`anything'"
	local myfiles: dir "`directory'\\`anything'" files "*.ado"
	capture foreach x of local myfiles {
		qui: capture  run `x'
	}
}	
*
cd "`currdir'"
restore
}
end
exit
