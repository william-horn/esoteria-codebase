
return function()
	local trimLeft = require(script.Parent.trimLeft)()
	local trimRight = require(script.Parent.trimRight)()
	
	--[[
		@desc: Removes whitespace from the left and right of a string
		@params: <string> str
		@returns: <string> trimmedStr
	]]
	local function trimAround(str)
		return trimLeft(trimRight(str))
	end
	
	return trimAround
end
