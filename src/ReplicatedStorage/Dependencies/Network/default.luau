--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side and client-side interface for sending requests over the network
]]

return function(import, global, pm) 
	-- Directories
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network

	-- Enums
	local MachineType = Enums.MachineType
	local RemoteChannel, Request = NetworkEnum.RemoteChannel, NetworkEnum.Request
	local RemoteValidation = NetworkEnum.RemoteValidation
	local ChannelType, ProtocolType = NetworkEnum.ChannelType, NetworkEnum.ProtocolType

	-- Dependencies
	local System, isServer, isClient = import("@System", ".", "isServer", "isClient")
	-- local withDotMethod = import("@Util/withDotMethod")

	-- Listeners
	local remoteListeners = require(script.Util.Listeners)

	-- naming aliases
	local aliases = require(script.Aliases)

	--[[
		Channel types:

		channels = {
			[1] = TCP Client Event,
			[2] = TCP Server Event,
			[3] = TCP Client Function,
			[4] = TCP Server Function,
			[5] = Local Client Event,
			[6] = Local Server Event,
			[7] = Local Client Function,
			[8] = Local Server Function,
			[9] = UPD Client Event,
			[10] = UDP Server Event
	]]

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	-- local Network = withDotMethod()
	local Network = {}

	Network.channelTypes = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
		[8] = {},
		[9] = {},
		[10] = {}
	}

	function Network:createChannels(channels)

	end

	function Network:dispatchRemoteTo(settings)
		-- include metadata in the remote dispatch
		-- if client is firing to server, metadata MUST contain which player fired the remote
		-- otherwise invalidate the dispatch
		local metadata = {}
		--

		return remoteValidationStatus
	end

	function Network:client_sendTCP(signature, payload)
		self:dispatchRemoteTo({
			protocol = ProtocolType.TCP,
			channelType = ChannelType.RemoteEvent,
			channel = signature.channel,
			request = signature.request,
			payload = payload
		})
	end

	function Network:server_sendTCP(players, signature, payload)
		self:dispatchRemoteTo({
			protocol = ProtocolType.TCP,
			channelType = ChannelType.RemoteEvent,
			channel = signature.channel,
			request = signature.request,
			toPlayers = players,
			payload = payload
		})
	end

	function Network:sendTCP(...)
		if (isServer()) then
			self:server_sendTCP(...)

		elseif (isClient()) then
			self:client_sendTCP(...)
		end
	end

	function Network:listen()
		remoteListeners:listen()
		return self
	end

	return {
		default = Network
	}
end
