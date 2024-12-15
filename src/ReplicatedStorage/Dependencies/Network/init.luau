--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side and client-side interface for sending requests over the network
]]

return function(import, global, pm) 
	-- Directories
	local Enums = game.ReplicatedStorage.Enums
	local networkEnums = Enums.Network

	-- Enums
	local MachineType = Enums.MachineType
	local RemoteChannel, Request = networkEnums.RemoteChannel, networkEnums.Request
	local RemoteValidation = networkEnums.RemoteValidation
	local RemoteType, ProtocolType = networkEnums.RemoteType, networkEnums.ProtocolType

	-- Dependencies
	local System, isServer, isClient = import("@System", ".", "isServer", "isClient")
	-- local withDotMethod = import("@Util/withDotMethod")

	-- Listeners
	local remoteListeners = require(script.Listeners)
	local networkTree = pm.require(script.BuildNetwork)

	-- naming aliases
	local aliases = require(script.Aliases)

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	-- local Network = withDotMethod()
	local Network = {}

	function Network:dispatchRemoteTo(settings)
		local machineType = System.MachineType

		local protocolType = networkTree[settings.protocolType] -- TCP/UDP
		local fromMachine = protocolType[machineType] -- Server/Client
		local remoteType = fromMachine[settings.remoteType] -- Events/Functions
		local remoteDispatcher = remoteType[settings.remoteChannel] -- Remote data

		local remoteValidationStatus = remoteDispatcher:validate({
			toPlayers = settings.toPlayers
		})

		return remoteValidationStatus
	end

	function Network:client_sendTCP(metadata, payload)
		self:dispatchRemoteTo({
			protocolType = ProtocolType.TCP,
			remoteType = RemoteType.RemoteEvent,
			remoteChannel = metadata.channel,
			request = metadata.request,
			payload = payload
		})
	end

	function Network:server_sendTCP(players, metadata, payload)
		self:dispatchRemoteTo({
			protocolType = ProtocolType.TCP,
			remoteType = RemoteType.RemoteEvent,
			remoteChannel = metadata.channel,
			request = metadata.request,
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
