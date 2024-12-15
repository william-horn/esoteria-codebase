
--[[
	--------------------
	| # Name aliases : |
	--------------------
]]

local Enums = game.ReplicatedStorage.Enums
local MachineType = Enums.MachineType
local RemoteType = Enums.Network.RemoteType
local ProtocolType = Enums.Network.ProtocolType

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
