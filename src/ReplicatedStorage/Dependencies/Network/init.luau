--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side and client-side interface for sending requests over the network

	TODO: Potential optimizations
		? Reduce functions calls between network API and remote firing
		? Pass arguments to dispatcher instead of creating a new table
]]

return function(import, global, pm) 
	-- Enums
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network

	local RemoteValidation = NetworkEnum.RemoteValidation
	local Channel, Request = NetworkEnum.Channel, NetworkEnum.Request
	local ProtocolSignature = NetworkEnum.ProtocolSignature
	local ChannelType = NetworkEnum.ChannelType

	-- Dependencies
	local System, isServer, isClient = import("@System", ".*", "isServer", "isClient")
	local getEnumByNameFrom = import("@Util/@Types/enum*", "getEnumByNameFrom")
	local isModule, isRemote = import("@Util/@Types", "isModule", "isRemote")
	local uniquePair = import("Math/uniquePair")
	-- local withDotMethod = import("@Util/withDotMethod")

	-- modules
	local RemoteDispatcher = pm.require(script.Dispatcher)

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	-- local Network = withDotMethod()
	local Network = {}
	Network.protocols = nil
	Network.cachedSignatures = {}

	--[[
		cachedSignature = {
			["1.0.2.4.7"] = { dataLastSent, channelData }
		}
	]]

	function Network:dispatchRemote(headers, payload)
		local protocolSignature = headers._protocolSignature
		local _dependencies = headers._dependencies

		-- create a Szudzik pair
		local signatureId = uniquePair(
			headers.channel.Value,
			headers.request.Value
		) + protocolSignature.Value

		-- retrieve the previously sent network data for this signature
		local cachedSignature = self.cachedSignatures[signatureId]

		if (_dependencies and cachedSignature) then
			-- cache ref variables
			local cachedHeaders = cachedSignature.headers
			local cachedDependencies = cachedHeaders._dependencies
			-- print("reject dupe transmissions is: true")

			if (_dependencies and cachedDependencies and #cachedDependencies == #_dependencies) then
				local sameValues = true
				-- print("both dependency tables exist and are same size")

				-- shallow-check if both dependency arrays are equal in content
				for i = 1, #cachedDependencies do
					if (cachedDependencies[i] ~= _dependencies[i]) then
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
		elseif (not cachedSignature) then
			cachedSignature = {}
			self.cachedSignatures[signatureId] = cachedSignature
			-- print("first time fire, creating cache.")

		end

		-- update the cache after cache processing is done
		-- print("updating cache. old: ", cachedSignature)
		cachedSignature.headers = headers
		cachedSignature.payload = payload
		cachedSignature.headers._dependencies = _dependencies
		-- print("updating cache. new: ", cachedSignature)

		local channels = self.protocols[protocolSignature]
		
		if (not channels) then
			error("\"" .. tostring(protocolSignature) .. "\" is not a valid network protocol")
		end

		local channelData = channels[headers.channel]

		if (not channelData) then
			error("\"" .. tostring(headers.channel) .. "\" is not a valid channel")
		end

		-- remote validation
		local remoteDispatcher = channelData.dispatcher
		local remoteValidationStatus = remoteDispatcher:validate()

		if (remoteValidationStatus.result == RemoteValidation.Rejected) then
			warn("Remote failed.")
			return
		end

		return remoteDispatcher:fire(headers, payload)
	end

	--[[
		-----------------------
		| # TCP Remote Events |
		-----------------------
	]]
	-- from client
	function Network:sendTCPToServer(headers, payload)
		headers._protocolSignature = ProtocolSignature.TCPOnServerEvent
		headers._channelType = ChannelType.RemoteEvent
		
		return self:dispatchRemote(headers, payload)
	end

	-- from server
	function Network:sendTCPToClient(headers, payload)
		-- ? headers should have a 'toPlayer' array of clients to fire
		headers._protocolSignature = ProtocolSignature.TCPOnClientEvent
		headers._channelType = ChannelType.RemoteEvent

		return self:dispatchRemote(headers, payload)
	end

	function Network:sendTCPToAllClients(headers, payload)
		headers._protocolSignature = ProtocolSignature.TCPOnClientEvent -- this will need to be it's own Enum
		headers._channelType = ChannelType.RemoteEvent

		return self:dispatchRemote(headers, payload)
	end

	function Network:sendTCP(...)
		if (isServer()) then
			return self:sendTCPToClient(...)

		elseif (isClient()) then
			return self:sendTCPToServer(...)
		end
	end

	function Network:sendTCPAll(headers, payload)
		if (isServer()) then
			headers._allClients = true
			return self:sendTCPToAllClients(headers, payload)
		end
	end

	--[[
		--------------------------
		| # TCP Remote Functions |
		--------------------------
	]]
	function Network:requestTCPFromServer(headers, payload)
		headers._protocolSignature = ProtocolSignature.TCPOnServerFunction
		return self:dispatchRemote(headers, payload)
	end

	function Network:requestTCPFromClient(headers, payload)
		headers._protocolSignature = ProtocolSignature.TCPOnClientFunction
		return self:dispatchRemote(headers, payload)
	end

	function Network:requestTCP(...)
		if (isServer()) then
			return self:requestTCPFromClient(...)

		elseif (isClient()) then
			return self:requestTCPFromServer(...)
		end
	end

	--[[
		------------------
		| # Local Events |
		------------------
	]]
	function Network:sendLocal(headers, payload)
		if (isServer()) then
			headers._protocolSignature = ProtocolSignature.LocalServerEvent
		elseif (isClient()) then
			headers._protocolSignature = ProtocolSignature.LocalClientEvent
		end

		return self:dispatchRemote(headers, payload)
	end

	--[[
		---------------------
		| # Local Functions |
		---------------------
	]]
	function Network:requestLocal(headers, payload)
		if (isServer()) then
			headers._protocolSignature = ProtocolSignature.LocalServerFunction
		elseif (isClient()) then
			headers._protocolSignature = ProtocolSignature.LocalClientFunction
		end

		return self:dispatchRemote(headers, payload)
	end

	--[[
		-----------------------
		| # UDP Remote Events |
		-----------------------
	]]
	function Network:sendUDPToClient(headers, payload)
		headers._protocolSignature = ProtocolSignature.UDPOnClientEvent
		return self:dispatchRemote(headers, payload)
	end

	function Network:sendUDPToServer(headers, payload)
		headers._protocolSignature = ProtocolSignature.UDPOnServerEvent
		return self:dispatchRemote(headers, payload)
	end

	function Network:sendUDP(...)
		if (isServer()) then
			return self:sendUDPToClient(...)

		elseif (isClient()) then
			return self:sendUDPToServer(...)
		end
	end



	--[[
		* Network:download():

		Download the network data from the initial game folders into
		an internal model that the API will reference for outgoing
		requests.
	]]
	function Network:download()
		local protocols = {}

		--[[
			--------------------------------------------------------
			| # Construct the channel data from the channel folder |
			--------------------------------------------------------
		]]
		local function getChannelDataFromFolder(folder)
			local channelData = {}
			local requests = {}

			local channelSettings = folder:FindFirstChild("Settings")
			local requestModules = folder:FindFirstChild("Requests")
			local RBXRemote = folder:FindFirstChild("Remote")

			-- ! error:
			-- If no ROBLOX remote instance exists in the folder
			if (not RBXRemote) then
				error("Channel folder does not contain a ROBLOX Remote object, or it is not named \"Remote\"")
				
			elseif (not isRemote(RBXRemote)) then
				error("Channel folder contains an object named \"Remote\" but it is not a ROBLOX Remote instance.")
			end

			-- Channel settings exists
			if (channelSettings and isModule(channelSettings)) then
					channelSettings = require(channelSettings)

			-- warn:
			-- Channel settings exists but is not a ModuleScript
			elseif (channelSettings) then 
				warn("Found a \"Settings\" object in a remote channel but it is not a ModuleScript.")

			else
				channelSettings = {}
			end

			-- warn: 
			-- No request folder is found in channel folder
			if (not requests) then
				warn("No requests folder was found in channel: \"" .. folder.Name .. "\"")

			-- Otherwise, scan the request handlers...
			else
				for _, requestModule in next, requestModules:GetChildren() do
					if (not isModule(requestModule)) then
						continue
					end

					local requestEnum = getEnumByNameFrom(Request, requestModule.Name)

					-- warn:
					-- If a request handler module does not have a corresponding Enum representation
					if (not requestEnum) then
						warn("Ignoring request handler \"" .. requestModule.Name .. "\" - (no corresponding Enum was found)")
						continue
					end

					-- add the required handler to the internal requests table in channel data
					-- "true" argument to require without looking for a default export
					requests[requestEnum] = pm.require(requestModule, true)
				end
			end

			-- finalize channel data and return
			channelData.dispatcher = RemoteDispatcher.new(
				RBXRemote, 
				requests, 
				channelSettings
			)

			return channelData
		end

		--[[
			-------------------------
			| # Scan Network folder |
			-------------------------
		]]
		for _, protocolFolder in next, global.Network:GetChildren() do
			local protocolSignature = getEnumByNameFrom(ProtocolSignature, protocolFolder.Name)

			if (not protocolSignature) then
				warn("Ignoring protocol folder \"" .. protocolFolder.Name .. "\" - (no corresponding Enum was found)")
				continue
			end

			local channels = {}

			-- assign the protocol data
			protocols[protocolSignature] = channels

			for _, channelFolder in next, protocolFolder:GetChildren() do
				local channelEnum = getEnumByNameFrom(Channel, channelFolder.Name)

				if (not channelEnum) then
					warn("Ignoring Channel folder \"" .. channelFolder.Name .. "\" - (no corresponding Enum was found)")
					continue
				end

				-- assign the channel data
				channels[channelEnum] = getChannelDataFromFolder(channelFolder)
			end
		end

		self.protocols = protocols
		return protocols
	end

	function Network:listen()
		for protocolSignature, protocolData in next, self.protocols do
			
		end
	end

	function Network:init()
		self:download()
		self:listen()

		return self
	end

	return {
		default = Network
	}
end
