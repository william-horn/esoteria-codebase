--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side interface for sending requests over the network
]]

return function(import, global, pm) 
	-- Enums
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network
	local ConnectionType = Enums.ConnectionType

	-- Dependencies
	local downloadNetwork = import("@Network/download")
	local RemoteDispatcher = pm.require(script.Parent.Dispatcher)

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	local Network = {}
	Network.protocols = nil

	local function handleRequest(remoteDispatcher)
		local requests = remoteDispatcher.requestHandlers

		return function(fromPlayer, headers, payload)
			print("got signal from player: ", fromPlayer)
			local request = requests[headers.request]

			-- ! error:
			-- If the request is not recognized in the network, throw error
			if (not request) then
				error("Network error: Could not interpret request \"" .. tostring(headers.request) .. "\" (does not have a corresponding Enum)")
				return
			end

			-- make any final changes to headers or payload before firing remote
			headers._fromPlayer = fromPlayer

			-- fire the server-side remote handler
			request.process(headers, payload)
		end
	end

	function Network:dispatchRemote(headers, payload)
		local _dependencies = headers._dependencies
		local _protocolType = headers._protocolType
		local channel = headers.channel
		local request = headers.request

		--[[
			-----------------------------
			| # Handling error checking |
			-----------------------------
		]]
		if (not channel) then
			error("Failed to dispatch remote ('channel' is a required header but was not found): ", headers)
		end

		if (not request) then
			error("Failed to dispatch remote ('request' is a required header but was not found): ", headers)
		end

		local channels = self.protocols[_protocolType]

		if (not channels) then
			error("Failed to dispatch remote (invalid ProtocolType. Got: \"" .. tostring(_protocolType) .. "\")")
		end

		local channelData = channels[channel]

		if (not channelData) then
			warn("Failed to dispatch remote (The channel \"" .. tostring(channel) .. "\" is valid, but does not exist in the shared network.)") 
			return
		end

		--[[
			----------------------------------
			| # Handling dependency checking |
			----------------------------------
		]]
		local remoteDispatcher = channelData.dispatcher
		local outgoingCache = channelData.outgoingCache

		-- retrieve the previously sent network data for this signature
		local lastDispatch = outgoingCache[request]

		if (_dependencies and lastDispatch) then
			-- cache ref variables
			local cachedHeaders = lastDispatch.headers
			local cachedDependencies = cachedHeaders._dependencies
			-- print("reject dupe transmissions is: true")

			if (_dependencies and cachedDependencies and #cachedDependencies == #_dependencies) then
				local sameValues = true
				-- print("both dependency tables exist and are same size")

				-- shallow-check if both dependency arrays are equal in content
				for index = 1, #cachedDependencies do
					if (cachedDependencies[index] ~= _dependencies[index]) then
						sameValues = false
						break
					end
				end

				-- if all dependencies are the same, then return out
				if (sameValues) then
					print("Dependencies are the same for request \"" .. tostring(request) .. "\", aborting dispatch...")
					return
				end 
			end

		-- cache does not exist, create new cache
		elseif (not lastDispatch) then
			lastDispatch = { headers = {} }
			outgoingCache[request] = lastDispatch
			-- print("first time fire, creating cache.")

		end

		-- manually choose which headers and payload data to copy into the cache
		-- print("updating cache. old: ", lastDispatch)
		-- lastDispatch.headers = table.clone(headers) -- to copy all headers
		lastDispatch.payload = payload
		lastDispatch.headers._dependencies = _dependencies
		-- print("updating cache. new: ", lastDispatch)

		--[[
			-----------------------------
			| # Handling cache checking |
			-----------------------------
		]]
		-- TODO: develop this more later. this may work differently between RemoteEvents and RemoteFunctions
		if (headers._userCache) then
			local incomingCache = channelData.incomingCache
		end

		-- remote validation
		return remoteDispatcher:fire(headers, payload) -- should return remote validation status
	end

	--[[
		-----------------------
		| # TCP Remote Events |
		-----------------------
		headers = {
			channel* = Channel
			request* = Request
			_toPlayers = {}
			_allClients = true
			_dependencies = {}
			_protocolType = ProtocolType
			_withValidation
			_useCache = true
		}
	]]
	function Network:sendTCP(headers, payload)
		headers._protocolType = NetworkEnum.ProtocolType.TCPEvent
		return self:dispatchRemote(headers, payload)
	end

	--[[
		--------------------------
		| # TCP Remote Functions |
		--------------------------
	]]
	function Network:requestTCP(headers, payload)
		headers._protocolType = NetworkEnum.ProtocolType.TCPFunction
		return self:dispatchRemote(headers, payload)
	end

	--[[
		------------------
		| # Local Events |
		------------------
	]]
	function Network:sendLocal(headers, payload)
		headers._protocolType = NetworkEnum.ProtocolType.LocalEvent
		return self:dispatchRemote(headers, payload)
	end

	--[[
		---------------------
		| # Local Functions |
		---------------------
	]]
	function Network:requestLocal(headers, payload)
		headers._protocolType = NetworkEnum.ProtocolType.LocalFunction
		return self:dispatchRemote(headers, payload)
	end

	--[[
		-----------------------
		| # UDP Remote Events |
		-----------------------
	]]
	function Network:sendUDP(headers, payload)
		headers._protocolType = NetworkEnum.ProtocolType.UDPEvent
		return self:dispatchRemote(headers, payload)
	end

	function Network:listen()
		for _, remoteDispatcher in next, RemoteDispatcher.instances do
			if (remoteDispatcher:hasHandlers()) then
				local remoteInfo = remoteDispatcher.remoteInfo
				local remote = remoteDispatcher.remote

				-- Listen to remote events/bindable events
				if (remoteInfo.connectionType == ConnectionType.Event) then
					remote[remoteInfo.listener]:Connect(handleRequest(remoteDispatcher))

				-- Listen to remote functions/bindable functions
				elseif (remoteInfo.connectionType == ConnectionType.Callback) then
					remote[remoteInfo.listener] = handleRequest(remoteDispatcher)
				end
			else
				warn("Skipping listener for \"" .. remoteDispatcher.remote:GetFullName() .. "\" because it has no handlers on this machine")
			end
		end
	end

	function Network:init()
		self.protocols = downloadNetwork(script.Parent.Protocols, RemoteDispatcher)
		self:listen()
		return self
	end

	return Network
end
