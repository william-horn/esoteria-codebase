
--[[
	Require  modules
]]

-- ROBLOX services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- folder paths
local Path__Dependencies = ReplicatedStorage.Dependencies

-- enums
local LocalEnums = require(script.Enums)
local GlobalEnums = require(Path__Dependencies.Enums)

local EventSignalEnums = require(Path__Dependencies.EventSignal.Enums)

local ReplicationType = LocalEnums.ReplicationType
local EventValidationStatus = EventSignalEnums.EventValidationStatus
local MachineType = GlobalEnums.MachineType

local NetworkRequest = LocalEnums.NetworkRequest
local NetworkType = LocalEnums.NetworkType

-- dependencies
local System = require(Path__Dependencies.System)
local Package__Enumify = require(Path__Dependencies.Enumify)
local Enumify = Package__Enumify.Enumify

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
local SignalDispatchAliases = Enumify:createEnumTable({
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
})

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
	return handleRemoteRequest(Remotes[NetworkType.Send], SignalDispatchAliases.RemoteEvent)(signalName, request, ...)
end

function Network:fireAll(signalName, request, ...)
	local remoteData = Remotes[NetworkType.Send][signalName]
	
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
	return handleRemoteRequest(Remotes[NetworkType.Receive], SignalDispatchAliases.RemoteFunction)(signalName, request, ...)
end

-- for executing BindableFunctions
function Network:run(signalName, request, ...)
	return handleRemoteRequest(Remotes[NetworkType.Functions], SignalDispatchAliases.BindableFunction)(signalName, request, ...)
end

-- for executing BindableEvents
function Network:dispatch(signalName, request, ...)
	return handleRemoteRequest(Remotes[NetworkType.Events], SignalDispatchAliases.BindableEvent)(signalName, request, ...)
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
