
return function(import, _, pm)
	print("started server")
	local enums = game.ReplicatedStorage.Enums.Network
	local network = pm.from(script).import("Network")

	network:init()
	
	-- network:sendTCP(
	-- 	{
	-- 		channel = enums.Channel.Common,
	-- 		request = enums.Request.GetPlayer,
	-- 		_dependencies = {"same"},
	-- 	},
	-- 	{
	-- 		data = "FROM CLIENT"
	-- 	}
	-- )

end

