
--[[
	--------------------
	| # Name aliases : |
	--------------------
]]

local Enums = game.ReplicatedStorage.Enums
local MachineType = Enums.MachineType
local RemoteType = Enums.Network.RemoteType
local ProtocolType = Enums.Network.ProtocolType
local RemoteChannel = Enums.Network.RemoteChannel

local machineTypeToName = {
	[MachineType.Server] = "Server",
	[MachineType.Client] = "Client",
}

local protocolFolderToEnum = {
	TCP = ProtocolType.TCP,
	UDP = ProtocolType.UDP,
	Local = ProtocolType.Local
}

local machineTypeToEnum = {
	Server = MachineType.Server,
	Client = MachineType.Client
}

local remoteTypeFolderToEnum = {
	Events = RemoteType.RemoteEvent,
	Functions = RemoteType.RemoteFunction
}

local remoteChannelFolderToEnum = {
	Player = RemoteChannel.Player
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
	protocolFolderToEnum = protocolFolderToEnum,
	remoteTypeToAPI = remoteTypeToAPI,
	machineTypeToEnum = machineTypeToEnum,
	remoteTypeFolderToEnum = remoteTypeFolderToEnum,
	remoteChannelFolderToEnum
}
