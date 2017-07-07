
self = false

read_globals = {
	"love",
}

files["example/main.lua"] = {
	globals = { "love", "print" },
}

files["init.lua"] = {
	globals = { "love", },
}

files["*.lua"] = {
	unused_args = false,
}
