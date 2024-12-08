--[[
	@author: William J. Horn
	@written: 12/7/2024
	
	Apparently I have to do all this just to implement even the most basic interface
	for enums in Lua...
]]

local EnumItem = require(script.EnumItem)

local Enumify = function(inputTable) 
	local out = {}
	local queue = {{inputTable, out, ""}}

	while (#queue > 0) do
		local itemDir, outDir, prevPath = unpack(table.remove(queue, 1))

		for itemKey, itemVal in next, itemDir do
			if (type(itemVal) == "table") then
				prevPath = prevPath .. "." .. itemKey

				outDir[itemKey] = EnumItem.new(
					itemKey, 
					prevPath
				)

				queue[#queue + 1] = {itemVal, outDir[itemKey], prevPath}
			else
				outDir[itemKey] = EnumItem.new(
					itemKey,
					prevPath .. "." .. itemKey,
					itemVal
				)
			end
		end
	end

	return out
end

local EnumifyDirectory = function(folder)
	local enums = {}
	local files = folder:GetChildren()
	
	for _, enumFile in next, files do
		if (enumFile:IsA("ModuleScript")) then
			enums[enumFile.Name] = require(enumFile)
		end
	end
	
	return Enumify(enums)
end

return {
	Enumify = Enumify,
	EnumItem = EnumItem,
	EnumifyDirectory = EnumifyDirectory
}