--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side and client-side interface for sending requests over the network
]]

return function(import, global, pm) 
	-- Directories
	local systemEnums = pm.from("../Enums/System").location
	local networkEnums = pm.from("../Enums/Network").location

	-- Enums
	local MachineType = systemEnums.import("MachineType*")
	local RemoteChannel, Request = networkEnums.import("RemoteChannel*", "Request*")
	local RemoteValidation = networkEnums.import("RemoteValidation*")
	local RemoteType, ProtocolType = networkEnums.import("RemoteType*", "ProtocolType*")

	-- Dependencies
	local System, isServer, isClient = import("@System", ".", "isServer", "isClient")
	local withDotMethod = import("@Util/withDotMethod")

	-- Listeners
	local remoteListeners, remotes = pm.from(script).import("Listeners")

	-- naming aliases
	local aliases = require(script.Aliases) {
		MachineType,
		RemoteType,
		ProtocolType,
	}

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	local Network = withDotMethod()

	function Network:dispatchRemoteTo(settings)
		local machineType = System.machineType

		local protocolType = remotes[settings.protocolType] -- TCP/UDP
		local fromMachine = protocolType[machineType] -- Server/Client
		local remoteType = fromMachine[settings.remoteType] -- Events/Functions
		local remoteDispatcher = remoteType[settings.remoteChannel] -- Remote data

		--[[
			-----------------------
			| # Remote validation |
			-----------------------

			Call the internal remote validator to determine whether or not
			the remote is eligable to fire.
		]]
		local remoteValidationStatus = remoteDispatcher.validate()

		if (remoteValidationStatus == RemoteValidation.Rejected) then
			return warn("Remote cannot be fired")
		end

		return remoteValidationStatus
	end

	function Network:client_sendTCP(metadata, payload)
		self.dispatchRemoteTo({
			protocolType = ProtocolType.TCP,
			remoteType = RemoteType.RemoteEvent,
			remoteChannel = metadata.channel,
			request = metadata.request,
			toPlayers = {},
			payload = payload
		})
	end

	function Network:server_sendTCP(players, metadata, payload)
		self.dispatchRemoteTo({
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
			self.server_sendTCP(...)

		elseif (isClient()) then
			self.client_sendTCP(...)
		end
	end

	return {
		default = Network
	}
end
