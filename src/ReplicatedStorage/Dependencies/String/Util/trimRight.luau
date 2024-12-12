
return function()
	
	--[[
		@desc: Removes whitespace from the right of a string
		@params: <string> str
		@returns: <string> trimmedStr
	]]
	local function trimRight(str)
		return str:gsub("%s+$", "")
	end
	
	return trimRight
end