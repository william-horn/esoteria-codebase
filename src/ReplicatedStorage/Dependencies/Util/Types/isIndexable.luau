

return function()
	local isTable = require(script.Parent.isTable)()
	local isUserdata = require(script.Parent.isUserdata)()
	
	local function isIndexable(v)
		return isTable(v) or isUserdata(v)
	end

	return isIndexable
end
