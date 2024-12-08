
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Path__Dependencies = ReplicatedStorage.Dependencies

local Package__Enumify = require(Path__Dependencies.Enumify)
local Enumify = Package__Enumify.Enumify

return Enumify({
	PlayerClassification = require(script.PlayerClassification),
	MachineType = require(script.MachineType)
})
