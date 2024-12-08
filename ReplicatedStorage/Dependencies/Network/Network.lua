
--[[
	Require  modules
]]

-- ROBLOX services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- folder paths
local Path__Dependencies = ReplicatedStorage.Dependencies

-- enums
local Path__LocalEnums = script.Enums
local Path__GlobalEnums = ReplicatedStorage.Enums
local Path__EventSignalEnums = Path__Dependencies.EventSignal.Enums

local ReplicationType = require(Path__LocalEnums.ReplicationType)
local EventValidationStatus = require(Path__EventSignalEnums.EventValidationStatus)
local MachineType = require(Path__GlobalEnums.MachineType)

local NetworkRequest = require(Path__LocalEnums.NetworkRequest)
local NetworkType = require(Path__LocalEnums.NetworkType)

-- dependencies
local System = require(Path__Dependencies.System)

-- local modules
local Package__Listener = require(script.Listeners)

local Listeners, 
	Remotes = 
		Package__Listener.Listeners, 
		Package__Listener.Remotes

local Network = {}

--[[
	Get remote trigger methods based on current system
]]
local SignalDispatchAliases = {
	RemoteFunction = {
		[MachineType.Server] = 'InvokeClient',
		[MachineType.Client] = 'InvokeServer',
	},
	
	RemoteEvent = {
		[MachineType.Server] = 'FireClient',
		[MachineType.Client] = 'FireServer',
	},
	
	BindableFunction = {
		[MachineType.Server] = 'Invoke',
		[MachineType.Client] = 'Invoke',
	},
	
	BindableEvent = {
		[MachineType.Server] = 'Fire',
		[MachineType.Client] = 'Fire'
	}
}

local function handleRemoteRequest(remoteType, remoteSignalAlias)
	return function(signalName, request, ...)
		-- flip first 2 args if calling on server to account for default player arg
		if (System.isServer()) then
			signalName, request = request, signalName
		end

		-- get the remote data from the given signal name
		local remoteData = remoteType[signalName]

		if (not remoteData) then
			System.warn('No remote data was found for remote ['..tostring(signalName)..']')
			return
		end

		-- validate remote event before 
		local remoteValidation = remoteData.event:getValidationReport()

		if (remoteValidation.result == EventValidationStatus.Rejected) then
			System.warn('REMOTE VALIDATION REJECTED: ', remoteValidation.reasons)
			return 
		end

		-- fire custom event to keep track of analytics and run any addition handlers binded to the remote
		remoteData.event:fire(request, ...)

		-- fire the actual remote object
		return remoteData.remote[remoteSignalAlias[System.MachineType]](remoteData.remote, request, ...)
	end
end

--[[
	@desc: Send an outgoing network request
	@param: signalName (string)
	@param: request (string)
	@param: ... (any)
]]
function Network:fire(signalName, request, ...)
	return handleRemoteRequest(Remotes:get(NetworkType.Send), SignalDispatchAliases.RemoteEvent)(signalName, request, ...)
end

function Network:fireAll(signalName, request, ...)
	local remoteData = Remotes:get(NetworkType.Send)[signalName]
	print(signalName, Remotes:get(NetworkType.Send))
	
	if (System.isClient()) then
		System.error('fireAll cannot be called from client')
		return
	end
	
	local remoteValidation = remoteData.event:getValidationReport()
	
	if (remoteValidation.result == EventValidationStatus.Rejected) then
		return 
	end
	
	remoteData.event:fire(request, ...)
	remoteData.remote:FireAllClients(request, ...)
end

function Network:invoke(signalName, request, ...)
	return handleRemoteRequest(Remotes:get(NetworkType.Receive), SignalDispatchAliases.RemoteFunction)(signalName, request, ...)
end

-- for executing BindableFunctions
function Network:run(signalName, request, ...)
	return handleRemoteRequest(Remotes:get(NetworkType.Functions), SignalDispatchAliases.BindableFunction)(signalName, request, ...)
end

-- for executing BindableEvents
function Network:dispatch(signalName, request, ...)
	return handleRemoteRequest(Remotes:get(NetworkType.Events), SignalDispatchAliases.BindableEvent)(signalName, request, ...)
end

--[[
	@desc: Connect all remote listeners to their handler functions
	@param: none
	@return: none
]]
function Network:listen()
	Listeners:listen()
	return self
end

return {
	Network = Network,
	NetworkRequest = NetworkRequest,
	NetworkType = NetworkType
}
