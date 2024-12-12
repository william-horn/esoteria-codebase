local splitPattern = "[^,]+"
local lastSplitDelim = ","

return function(import)
  local StringEscaper = import("@String/@Classes/StringEscaper")
  local trimAround = import("@String/@Util/trimAround")
	
	--[[
		String:splitWith(str<string>, delim<string>, options<table>):
	
		@desc: 
			Splits a string by a delimiter and returns a table of the split values
		@params: 
			str<string>: The string to split
			delim<string>: The delimiter to split by
			options<table>: (optional) A table of options
		@returns: <table> splitStr
	]]
	local function splitWith(str, delim, options)
		options = options or {}
		-- options.usePatterns<boolean>: default - nil

		if (not options.usePatterns) then
			delim = StringEscaper.escapeMagicChars(delim)
		end

		if (delim ~= lastSplitDelim) then
			splitPattern = "[^" .. delim .. "]+"
		end

		local t = {}

		for element in str:gmatch(splitPattern) do
			t[#t + 1] = trimAround(element)
		end

		return t
	end
	
	return splitWith
end