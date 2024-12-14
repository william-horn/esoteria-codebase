--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Server-side and client-side interface for sending requests over the network
]]

--[[
	API:

	? -- remote event TCP API
	Network.sendTCP()
	Network.sendAllTCP()
	Network.sendListTCP()
	Network.sendOthersTCP() -- this will call Network.sendListTCP() internally

	? -- remote event UDP API
	Network.sendAllUDP()
	Network.sendUDP()
	Network.sendListUDP()
	Network.sendOthersUDP()

	? -- remote function API
	Network.request()


	# Examples:

	? Server -> Client:

	Network.sendTCP(
		game.Players.JohnDoe,
		{
			channel = RemoteChannel.Player, 
			request = RequestType.GetPlayer
		},
		{
			...payload...
		}
	)

	? Client -> Server:

	Network.sendTCP(
		{
			channel = RemoteChannel.Player, 
			request = RequestType.GetPlayer
		},
		{
			...payload...
		}
	)

	? Server -> Client:
	? Client -> Server:

	Network.sendAllTCP(
		{
			channel = RemoteChannel.Player, 
			request = RequestType.GetPlayer
		},
		{
			...payload...
		}
	)

	Network.sendOthersTCP() -- same signature as 'Network.sendAllTCP()'

	? Server -> Client:
	? Client -> Server:

	Network.sendListTCP(
		{ ...players affected... },
		{
			channel = RemoteChannel.Player, 
			request = RequestType.GetPlayer
		},
		{
			...payload...
		}
	)



]]

return function(import, pm) 
	-- Directories
	local eventEnums = pm.from("../Enums/EventSignal")
	local systemEnums = pm.from("../Enums/System")
	local networkEnums = pm.from("../Enums/Network")

	-- Enums
	local EventValidationStatus = eventEnums.import("EventValidationStatus*")
	local MachineType = systemEnums.import("MachineType*")
	local RemoteChannel, RequestType = networkEnums.import("RemoteChannel*", "RequestType*")

	-- Dependencies
	local System, isServer, isClient = import("@System", ".", "isServer", "isClient")
	local withDotMethod = import("@Util/withDotMethod")

	-- Listeners
	local remoteListeners, remotes = pm.from(script).import("Listeners")

	--[[
		Remotes = {
			TCP = {
				Client = {
					Events = {
						Player = { remoteSettings = { event = EventSignal, ... }, remote = Instance},
						...
					},
					...
				},
				Serer = {
					...
				}
			}
		}

		local machineTypeName = {
			[System.Client] = "Client",
			[System.Server] = "Server",
		}

		local 

		function Remotes:getProtocol(prot)
			return setmetatable(
				{ this = self[prot] }, 
				getmetatable(self)
			)
		end 

		function Remotes:getTCPChannel(name)
			local source = self.TCP[System.MachineType][name]

			if (not source) then ... handle err ... end

			return setmetatable(
				{ source = source }, 
				getmetatable(self)
			)
		end

		function Remotes:getRemoteChannel(name)
			local channel = self.source[name]

			if (not channel) then ... handle err ... end

			return channel
		end
	]]

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	local Network = withDotMethod()

	--[[
		dispatchRemote({
			protocol = "TCP",
			protocolChannel = "Events",
			remoteChannel = "Player",

			toPlayers = { ... },
			payload = { ... },
		})
	]]

	local function dispatchRemoteTo(settings)
		local machineType = System.machineType

		local protocol = remotes[settings.protocol]											-- TCP/UDP
		local fromMachine = protocol[machineType]												-- Server/Client
		local remoteType = fromMachine[settings.remoteType]							-- Events/Functions
		local remoteDispatcher = remoteType[settings.remoteChannel] 		-- Remote data

		--[[
			-----------------------
			| # Remote validation |
			-----------------------

			Call the internal remote validator to determine whether or not
			the remote is eligable to fire.
		]]
		if (not remoteDispatcher.validate()) then
			return warn("Remote cannot be fired")
		end

		
	end

	function Network:sendTCP(_player, metadata, payload) -- player, metadata, payload
		local players = {}

		dispatchRemoteTo({
			protocol = "TCP",
			remoteType = "Event",
			remoteChannel = metadata.channel,
			request = metadata.request,
			toPlayers = {}
		})
	end

end
