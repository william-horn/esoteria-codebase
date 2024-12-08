--[[
	@author: William J. Horn
	@written: 12/7/2024
	
	Apparently I have to do all this just to implement even the most basic interface
	for enums in Lua...
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Path__Dependencies = ReplicatedStorage.Dependencies

local EnumItem = require(script.EnumItem)

local Enumify = {}

local enumMetatable = {}

enumMetatable.__newindex = function(this, k, v) 
  if (type(v) == "table" and not Enumify:isEnum(v)) then
    setmetatable(v, enumMetatable)
  end
  if (Enumify:isEnum(k)) then
    rawset(this, k:getEnumName(), v)
  else
    rawset(this, k, v)
  end
end

enumMetatable.__index = function(this, k)
  if (Enumify:isEnum(k)) then
    return rawget(this, k:getEnumName())
  else
    return rawget(this, k)
  end
end

function Enumify:isEnum(v)
  return type(v) == "table" and v._customType == "EnumItem"
end

function Enumify:create(inputTable) 
	local out = {}
	local queue = {{inputTable, out, ""}}

	while (#queue > 0) do
		local itemDir, outDir, prevPath = unpack(table.remove(queue, 1))

		for itemKey, itemVal in next, itemDir do
			if (type(itemVal) == "table") then
				local prevPath = prevPath .. "." .. itemKey

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

function Enumify:createEnumTable(t)
  t = t or {}
  -- lazy load Table dependency for now
  local Table = require(Path__Dependencies.TableFunctions)
  
  Table:traverse(t, function(dir, key, val)
    if (self:isEnum(key)) then
      dir[key:getEnumName()] = val
      dir[key] = nil
    end

    if (type(val) == "table" and not self:isEnum(val)) then
      setmetatable(val, enumMetatable)
    end
  end)
  
  return setmetatable(t, enumMetatable)
end

function Enumify:createFromDirectory(folder)
	local enums = {}
	
	for _, enumFile in next, folder:GetChildren() do
		if (enumFile:IsA("ModuleScript")) then
			enums[enumFile.Name] = require(enumFile)
		end
	end
	
	return self:create(enums)
end

return {
	Enumify = Enumify,
	EnumItem = EnumItem,
}