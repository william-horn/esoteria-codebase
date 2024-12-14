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

	Server -> Client:

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




]]

return function(import, pm) 
	-- Directories
	local eventEnums = pm.from("../Enums/EventSignal")
	local systemEnums = pm.from("../Enums/System")
	local networkEnums = pm.from("../Enums/Network")

	-- Enums
	local EventValidationStatus = eventEnums.import("EventValidationStatus*")
	local MachineType = systemEnums.import("MachineType*")
	local NetworkRequest, NetworkType = networkEnums.import("NetworkRequest*", "NetworkType*")

	-- Dependencies
	local System, isServer, isClient = import("@System", ".", "isServer", "isClient")

	--[[
		---------------------
		| # Network module: |
		---------------------
	]]
	local Network = {}

end
