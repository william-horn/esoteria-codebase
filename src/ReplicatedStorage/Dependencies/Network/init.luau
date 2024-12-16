--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side and client-side interface for sending requests over the network
]]

return function(import, global, pm) 
	-- Enums
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network

	local RemoteValidation = NetworkEnum.RemoteValidation
	local Channel, Request = NetworkEnum.Channel, NetworkEnum.Request
	local ProtocolSignature = NetworkEnum.ProtocolSignature

	-- Dependencies
	local System, isServer, isClient = import("@System", ".*", "isServer", "isClient")
	local getEnumByNameFrom = import("@Util/@Types/enum*", "getEnumByNameFrom")
	local isModule = import("@Util/@Types/isModule")
	local isRemote = import("@Util/@Types/isRemote")

	-- local withDotMethod = import("@Util/withDotMethod")

	-- modules
	-- local remoteListeners = require(script.Listeners)
	-- local aliases = require(script.Aliases)

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	-- local Network = withDotMethod()
	local Network = {}
	Network.protocols = nil

	function Network:dispatchRemoteTo(settings)
		local stamp = settings.stamp
		local protocol = self.protocols[settings.protocol]
		
		if (not protocol) then
			error("\"" .. tostring(settings.protocol) .. "\" is not a valid network protocol")
		end

		local channelData = protocol.channels[stamp.channel]

		if (not channelData) then
			error("\"" .. tostring(stamp.channel) .. "\" is not a valid channel")
		end

		-- remote validation
		local remoteDispatcher = channelData.dispatcher
		local remoteValidationStatus = remoteDispatcher:validate()

		if (remoteValidationStatus.result == RemoteValidation.Rejected) then
			warn("Remote failed.")
			return
		end

		-- include metadata in the remote dispatch
		-- if client is firing to server, metadata MUST contain which player fired the remote
		-- otherwise invalidate the dispatch
		local metadata = {
			fromPlayer = settings.fromPlayer
		}
		--

		remoteDispatcher:fire({
			
		})

		return remoteValidationStatus
	end

	-- from client
	function Network:sendTCPClientEvent(stamp, payload)
		self:dispatchRemoteTo({
			protocol = ProtocolSignature.TCPClientEvent,
			stamp = stamp,
			fromPlayer = global.LocalPlayer,
			payload = payload
		})
	end

	-- from server
	function Network:sendTCPServerEvent(players, stamp, payload)
		self:dispatchRemoteTo({
			protocolID = ProtocolSignature.TCPServerEvent,
			stamp = stamp,
			toPlayers = players,
			payload = payload
		})
	end

	function Network:sendTCP(...)
		if (isServer()) then
			self:sendTCPServerEvent(...)

		elseif (isClient()) then
			self:sendTCPClientEvent(...)
		end
	end

	function Network:downloadProtocols()
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
			channelData.requests = requests
			channelData.settings = channelSettings
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

			local protocolData = {
				folder = protocolFolder,
				channels = {},
			}

			-- assign the protocol data
			protocols[protocolSignature] = protocolData

			for _, channelFolder in next, protocolFolder:GetChildren() do
				local channelEnum = getEnumByNameFrom(Channel, channelFolder.Name)

				if (not channelEnum) then
					warn("Ignoring Channel folder \"" .. channelFolder.Name .. "\" - (no corresponding Enum was found)")
					continue
				end

				-- assign the channel data
				protocolData.channels[channelEnum] = getChannelDataFromFolder(channelFolder)
			end
		end

		self.protocols = protocols
		return protocols
	end

	function Network:listen()
		remoteListeners:listen(self.protocols)
		return self
	end

	Network:downloadProtocols()

	return {
		default = Network
	}
end
