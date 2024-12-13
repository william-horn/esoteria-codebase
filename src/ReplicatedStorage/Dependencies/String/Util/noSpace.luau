
return function()
	
	--[[
		@desc: Removes all whitespace from a string
		@params: <string> str
		@returns: <string> trimmedStr
	]]
	local function noSpace(str)
		return str:gsub("%s+", "")
	end
	
	return noSpace
end
