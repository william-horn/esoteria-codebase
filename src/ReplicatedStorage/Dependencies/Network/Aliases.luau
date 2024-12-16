
--[[
	--------------------
	| # Name aliases : |
	--------------------
]]

local Enums = game.ReplicatedStorage.Enums
local Network = Enums.Network
local MachineType = Enums.MachineType
local ChannelType = Network.ChannelType

--[[
	A solved system of the form:

	{
		T + C + E = 1
		T + S + E = 2
		T + C + F = 3
		T + S + F = 4
		L + C + E = 5
		L + S + E = 6
		L + C + F = 7
		L + S + F = 8
		U + C + E = 9
		U + S + E = 10
	}

	where:

	T = -2
	L = 2
	U = 6
	C = 1
	S = 2
	E = 2
	F = 4

	and:

	T = TCP
	U = UDP
	L = Local
	C = Client
	S = Server
	E = Event
	F = Function

local toSystemVariable = {
	[MachineType.Client] = 1,
	[MachineType.Server] = 2,
	[ProtocolType.TCP] = -2,
	[ProtocolType.UDP] = 6,
	[ProtocolType.Local] = 2,
	[ChannelType.RemoteEvent] = 2,
	[ChannelType.RemoteFunction] = 4
}
]]

local channelTypeToAPI = {
	[ChannelType.RemoteEvent] = {
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

	[ChannelType.RemoteFunction] = {
		[MachineType.Server] = {
			dispatch = "InvokeClient",
			listen = "OnServerInvoke",
		},

		[MachineType.Client] = {
			dispatch = "InvokeServer",
			listen = "OnClientInvoke",
		},
	},

	[ChannelType.Event] = {
		[MachineType.All] = {
			dispatch = "Fire",
			listen = "Event",
		},
	},

	[ChannelType.Function] = {
		[MachineType.All] = {
			dispatch = "Invoke",
			listen = "OnInvoke",
		},
	},
}

channelTypeToAPI[ChannelType.UnreliableRemoteEvent] = channelTypeToAPI[ChannelType.RemoteEvent]

return {
	channelTypeToAPI = channelTypeToAPI,
}
