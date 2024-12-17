--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side interface for sending requests over the network
]]

return function(import, _, pm) 
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
		local requests = remoteDispatcher.requests
		local channel = remoteDispatcher.channel

		return function(fromPlayer, headers, payload)
			print("got signal from player: ", fromPlayer)
			
			-- if (headers.channel ~= channel) then
			-- 	return
			-- end

			--[[
				get the request:

				(on the client-side)
				request = {
					process = handlerFunction(),
					cache = { headers = lastUsedHeaders, payload = lastUsedPayload }
				}
			]]
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
		local channels = self.protocols[_protocolType]

		-- validate the header signatures
		if (not channels) then
			error("\"" .. tostring(_protocolType) .. "\" is not a valid network ProtocolType")
		end

		local remoteDispatcher = channels[channel]

		if (not remoteDispatcher) then
			error("\"" .. tostring(headers.channel) .. "\" is not a valid Channel")
		end

		local request = remoteDispatcher.requests[headers.request]

		if (not request) then
			error("\"" .. tostring(headers.channel) .. "\" is not a valid Request")
		end
		
		-- retrieve the previously sent network data for this signature
		local cachedDispatch = request.cache

		if (_dependencies and cachedDispatch) then
			-- cache ref variables
			local cachedHeaders = cachedDispatch.headers
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
					-- print("the tables are the same, returning...")
					return
				end 
			end

		-- cache does not exist, create new cache
		elseif (not cachedDispatch) then
			cachedDispatch = {
				headers = {},
			}
			request.cache = cachedDispatch
			-- print("first time fire, creating cache.")

		end

		-- manually choose which headers and payload data to copy into the cache
		-- print("updating cache. old: ", cachedDispatch)
		-- cachedDispatch.headers = table.clone(headers) -- to copy all headers
		cachedDispatch.payload = payload
		cachedDispatch.headers._dependencies = _dependencies
		-- print("updating cache. new: ", cachedDispatch)

		-- modify any final changes to headers
		headers._dependencies = nil

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
			(x) _toPlayers = {}
			(x) _allClients = true
			(x) _fromMachine
			_dependencies = {}
			_protocolType = ProtocolType
			(x) _withValidation
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
			local remoteInfo = remoteDispatcher.remoteInfo
			local remote = remoteDispatcher.remote

			-- Listen to remote events/bindable events
			if (remoteInfo.connectionType == ConnectionType.Event) then
				remote[remoteInfo.listener]:Connect(handleRequest(remoteDispatcher))

			-- Listen to remote functions/bindable functions
			elseif (remoteInfo.connectionType == ConnectionType.Callback) then
				remote[remoteInfo.listener] = handleRequest(remoteDispatcher)
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
