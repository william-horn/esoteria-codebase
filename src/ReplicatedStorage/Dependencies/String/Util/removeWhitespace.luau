
return function()
	
	--[[
		@desc: Removes all whitespace from a string
		@params: <string> str
		@returns: <string> trimmedStr
	]]
	local function removeWhitespace(str)
		return str:gsub("%s+", "")
	end
	
	return removeWhitespace
end