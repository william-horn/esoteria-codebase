
return function(import, global, pm)

	local Enums = game.ReplicatedStorage.Enums
	local MachineType = Enums.MachineType

	local isServer = pm.require(script.Parent.isServer)
	local isClient = pm.require(script.Parent.isClient)
	local isStudio = pm.require(script.Parent.isStudio)

	local System = {}

	if (isServer()) then
		System.MachineType = MachineType.Server
	elseif (isClient()) then
		System.MachineType = MachineType.Client
	elseif (isStudio()) then
		System.MachineType = MachineType.Studio
	end

	return System
end
