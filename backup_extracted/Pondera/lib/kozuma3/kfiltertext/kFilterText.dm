var list/disallow = list(
	"bitch","ass","kaiochao","nadrew","ter13",
	"pussy","fag","nigger","queer","nadrew",
	"vylocity","unity","<",">",
)

proc/Filter(v)
	for(. in disallow){v = replacetext(v,.,"[FilterOut(.)]")}
	return v

proc/FilterOut(v)
	v = length(v); var r
	for(. = 1 to v){r += "*"}
	return r