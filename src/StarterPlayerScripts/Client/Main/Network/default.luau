--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Client-side interface for sending requests over the network

	TODO: Potential optimizations
		? Reduce functions calls between network API and remote firing
		? Pass arguments to dispatcher instead of creating a new table
]]

return function(import, _, pm) 
	-- Enums
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network

	-- Dependencies
	local downloadNetwork = import("@Network/Download")

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	local Network = {}
	Network.protocols = nil
	Network.cachedDispatches = {}

	function Network:dispatchRemote(headers, payload)
		local _dependencies = headers._dependencies
		local _protocolType = headers._protocolType
		local channels = self.protocols[_protocolType]

		if (not channels) then
			error("\"" .. tostring(_protocolType) .. "\" is not a valid network ProtocolType")
		end

		local channel = headers.channel
		local channelData = channels[channel]

		if (not channelData) then
			error("\"" .. tostring(headers.channel) .. "\" is not a valid Channel")
		end

		local request = channelData[headers.request]

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
			cachedDispatch = {}
			request.cache = cachedDispatch
			-- print("first time fire, creating cache.")

		end

		-- update the cache after cache processing is done
		-- print("updating cache. old: ", cachedSignature)
		cachedDispatch.headers = headers
		cachedDispatch.payload = payload
		cachedDispatch.headers._dependencies = _dependencies
		-- print("updating cache. new: ", cachedSignature)

		-- remote validation
		local remoteDispatcher = channelData.dispatcher
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
			(x) _fromMachine
			_dependencies = {}
			_protocolSignature = ProtocolSignature
			_channelType = ChannelType
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
		return self:dispatchRemote(headers, payload)
	end

	--[[
		------------------
		| # Local Events |
		------------------
	]]
	function Network:sendLocal(headers, payload)
		return self:dispatchRemote(headers, payload)
	end

	--[[
		---------------------
		| # Local Functions |
		---------------------
	]]
	function Network:requestLocal(headers, payload)
		return self:dispatchRemote(headers, payload)
	end

	--[[
		-----------------------
		| # UDP Remote Events |
		-----------------------
	]]
	function Network:sendUDP(headers, payload)
		return self:dispatchRemote(headers, payload)
	end

	function Network:listen()
		for protocolSignature, protocolData in next, self.protocols do
			
		end
	end

	function Network:init()
		self.protocols = downloadNetwork()
		self:listen()

		return self
	end

	return {
		default = Network
	}
end
