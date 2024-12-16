
local Enums = game.ReplicatedStorage.Enums

local enumLookup = {}

for _, Enum in next, Enums:GetDescendants() do
	enumLookup[Enum] = true
end

-- dynamically adding/removing enums is not encouraged
Enums.DescendantAdded:Connect(function(enum)
	if (enum:IsA("NumberValue")) then
		enumLookup[enum] = true
	end
end)

Enums.DescendantRemoving:Connect(function(enum)
	if (enum:IsA("NumberValue")) then
		enumLookup[enum] = nil
	end
end)

return function()
	local function isEnum(enum)
		return typeof(enum) == "Enum" or enumLookup[enum]
	end

	local function isEnumFrom(enums, enum)
		return enum.Parent == enums
	end

	local function getEnumByNameFrom(enums, name)
		return enums:FindFirstChild(name)
	end

	local function isEnumNameFrom(enums, name)
		return getEnumByNameFrom(enums, name) ~= nil
	end

	return {
		isEnum = isEnum,
		isEnumFrom = isEnumFrom,
		getEnumByNameFrom = getEnumByNameFrom,
		isEnumNameFrom = isEnumNameFrom,
	}
end
