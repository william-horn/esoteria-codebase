--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side and client-side interface for sending requests over the network
]]

return function(import, global, pm) 
	-- Enums
	local Enums = pm.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network

	local Channel, Request = NetworkEnum.Channel, NetworkEnum.Request
	local ProtocolSignature = NetworkEnum.ProtocolSignature

	-- Dependencies
	local System, isServer, isClient = import("@System", ".", "isServer", "isClient")
	local getEnumByNameFrom = import("@Util/@Types/enum*", "getEnumByNameFrom")
	-- local withDotMethod = import("@Util/withDotMethod")

	-- modules
	local remoteListeners = require(script.Listeners)
	local aliases = require(script.Aliases)

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	-- local Network = withDotMethod()
	local Network = {}

	--[[
	Each protocol should have the structure:

	protocols = {
		[Signature] = {
			folder = Location,
			channels = {
				[Channel 1] = {
					remote = Instance,
					settings = {},
				},
				[Channel 2] = {
					...
				},
				...
			}
		}
	}
	]]

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

		-- include metadata in the remote dispatch
		-- if client is firing to server, metadata MUST contain which player fired the remote
		-- otherwise invalidate the dispatch
		local metadata = {}
		--

		return remoteValidationStatus
	end

	function Network:sendTCPClientEvent(stamp, payload)
		self:dispatchRemoteTo({
			protocol = ProtocolSignature.TCPClientEvent,
			stamp = stamp,
			payload = payload
		})
	end

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

		local function getChannelDataFromFolder(folder)
			local channelData = {}

			local channelSettings = folder:FindFirstChild("Settings")
			local requests = folder:FindFirstChild("Requests")

			if (channelSettings and channelSettings:IsA("ModuleScript")) then
					channelSettings = require(channelSettings)

			elseif (channelSettings) then 
				warn("Found a \"Settings\" object in a remote channel but it is not a ModuleScript.")

			else
				channelSettings = {}
			end

			if (not requests) then
				warn("No requests folder was found in channel: \"" .. folder.Name .. "\"")
				requests = {}
			end

			return channelData
		end

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

	return {
		default = Network
	}
end
