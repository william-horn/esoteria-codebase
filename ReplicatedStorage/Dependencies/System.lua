
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Path__Dependencies = ReplicatedStorage.Dependencies

local GlobalEnums = require(Path__Dependencies.Enums)
local MachineType = GlobalEnums.MachineType

local Math = require(Path__Dependencies.MathFunctions)

local System = {}
System.benchmarkOutputEnabled = false

System.isClient = function() return RunService:IsClient() end
System.isServer = function() return RunService:IsServer() end
System.isStudio = function() return RunService:IsStudio() end

if (System.isClient()) then
	System.MachineType = MachineType.Client
elseif (System.isServer()) then
	System.MachineType = MachineType.Server
else
	System.MachineType = MachineType.Studio
end

local prefix = 
	System.isClient() and '[Client]:   ' or
	System.isServer() and '[Server]:   ' or
	System.isStudio() and '[Studio]:   ' or
	'[UNKNOWN]: '

function System.print(...)
	print(prefix, ...)
end

function System.warn(...)
	warn(prefix, ...)
end

function System.error(...)
	error(prefix, ...)
end

function System.printCompletionTime(scriptName, startTime)
	System.print(`{scriptName} finished loading in: {Math.roundToThird(os.clock() - startTime)} seconds`)
end

function System.benchmarkModule(name, module)
	local startTime = os.clock()
	local result = require(module)
	local endTime = os.clock()

	if (System.showBenchmarkOutput) then
		System.print(`{name} completed in: {Math.roundToThird(endTime - startTime)} seconds`)
	end
	
	return result
end

function System:showBenchmarkOutput()
	self.benchmarkOutputEnabled = true
end

function System:hideBenchmarkOutput()
	self.benchmarkOutputEnabled = false
end

return System
