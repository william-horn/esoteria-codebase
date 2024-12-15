
	--[[
		--------------------
		| # Name aliases : |
		--------------------
	]]

return function(enums)
	local MachineType, RemoteType, ProtocolType = unpack(enums)

	local machineTypeToName = {
		[MachineType.Server] = "Server",
		[MachineType.Client] = "Client",
	}

	local protocolToName = {
		[ProtocolType.TCP] = "TCP",
		[ProtocolType.UDP] = "UDP",
	}

	local remoteTypeToAPI = {
		[RemoteType.RemoteEvent] = {
			[MachineType.Server] = {
				dispatch = "FireClient",
				dispatchAll = "FireAllClients",
				listen = "OnServerEvent",
			},

			[MachineType.Client] = {
				dispatch = "FireServer",
				listen = "OnClientEvent",
			},
		},

		[RemoteType.RemoteFunction] = {
			[MachineType.Server] = {
				dispatch = "InvokeClient",
				listen = "OnServerInvoke",
			},

			[MachineType.Client] = {
				dispatch = "InvokeServer",
				listen = "OnClientInvoke",
			},
		},

		[RemoteType.Event] = {
			[MachineType.All] = {
				dispatch = "Fire",
				listen = "Event",
			},
		},

		[RemoteType.Function] = {
			[MachineType.All] = {
				dispatch = "Invoke",
				listen = "OnInvoke",
			},
		},
	}

	remoteTypeToAPI[RemoteType.UnreliableRemoteEvent] = remoteTypeToAPI[RemoteType.RemoteEvent]

	return {
		machineTypeToName = machineTypeToName,
		protocolToName = protocolToName,
		remoteTypeToAPI = remoteTypeToAPI,
	}
end
