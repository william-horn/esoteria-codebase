
return function()
	
	--[[
		@desc: Removes all whitespace from a string
		@params: <string> str
		@returns: <string> trimmedStr
	]]
	local function noSpace(str)
		str = str:gsub("%s+", "")
		return str
	end
	
	return noSpace
end
