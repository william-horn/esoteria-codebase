--[[
	@author: William J. Horn
	@written: 12/7/2024
	
	A small EnumItem class that creates an individual enum interface.
]]

local EnumItem = {}
EnumItem.__index = EnumItem 

function EnumItem:getBaseName()
	return self._baseName
end

function EnumItem:getEnumName()
	return self._enumName
end

function EnumItem:getValue()
	return self._value
end

function EnumItem:getEnums()
	local enums = {}

	for k, v in next, self do
		enums[#enums + 1] = v
	end

	return enums
end

function EnumItem.new(name, path, value)
	local enumItem = {}

	enumItem._value = value
	enumItem._baseName = name
	enumItem._enumName = "Enum" .. path
  enumItem._customType = "EnumItem"

	return setmetatable({}, {
		__index = setmetatable(enumItem, EnumItem),
		__tostring = function(self) 
      return self:getEnumName() 
    end
	})
end

return EnumItem