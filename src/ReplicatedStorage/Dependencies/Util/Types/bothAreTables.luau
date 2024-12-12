

return function()
	local isTable = require(script.Parent.isTable)()
	
	local function bothAreTables(a, b)
		return isTable(a) and isTable(b)
	end

	return bothAreTables
end

