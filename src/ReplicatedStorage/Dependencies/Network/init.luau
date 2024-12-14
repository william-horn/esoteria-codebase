--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side and client-side interface for sending requests over the network
]]

return function(import, pm) 
	local eventEnums = pm.from("../Enums/EventSignal")
	local systemEnums = pm.from("../Enums/System")
	local networkEnums = pm.from("../Enums/Network")

	local EventValidationStatus = eventEnums.import("EventValidationStatus*")
	local MachineType = systemEnums.import("MachineType*")
	local NetworkRequest, NetworkType = networkEnums.import("NetworkRequest*", "NetworkType*")

	local System, isServer, isClient = import("@System", ".", "isServer", "isClient")

	local Network = {}

	--[[
		Get remote trigger methods based on current system
	]]
	local signalDispatchAliases = {
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
			if (isServer()) then
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
			return remoteData.remote[remoteSignalAlias[System.MachineType]](
				remoteData.remote, 
				request, 
				...
			)
		end
	end

	--[[
		@desc: Send an outgoing network request
		@param: signalName (string)
		@param: request (string)
		@param: ... (any)
	]]
	function Network:fire(signalName, request, ...)
		return handleRemoteRequest(Remotes[NetworkType.Send], SignalDispatchAliases.RemoteEvent)(
			signalName, 
			request, 
			...
		)
	end

	function Network:fireAll(signalName, request, ...)
		local remoteData = Remotes[NetworkType.Send][signalName]

		if (isClient()) then
			System.error('fireAll cannot be called from client')
			return
		end

		local remoteValidation = remoteData.event:getValidationReport()

		if (remoteValidation.result == EventValidationStatus.Rejected) then
			System.warn('REMOTE VALIDATION REJECTED: ', remoteValidation.reasons)
			return 
		end

		remoteData.event:fire(request, ...)
		remoteData.remote:FireAllClients(Enumify:serialize(request), ...)
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
		default = Network,
		NetworkRequest = NetworkRequest,
		NetworkType = NetworkType
	}
end
