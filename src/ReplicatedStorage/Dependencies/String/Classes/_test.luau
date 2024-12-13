
return function(import)
	return function()
		local StringEscaper = import("@String/@Classes/StringEscaper").new("/", {"$"})

		local s = "hello /$world"
		local e = StringEscaper:escape(s)
		local u = StringEscaper:unescape(e)

		print(s)
		print(e)
		print(u)
	end
end
