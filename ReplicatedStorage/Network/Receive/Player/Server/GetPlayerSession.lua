
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Path__Dependencies = ReplicatedStorage.Dependencies

local System = require(Path__Dependencies.System)
local PlayerManager = require(ServerScriptService.GameServer.PlayerManager)

-- local utilities
local toClientSession = require(script.Parent._toClientSession)

return function(player, options)
	System.print('Client ['..player.Name..'] requesting player data for: ', options.player)
	
	-- config options
	options.player = options.player or player
	
	-- get the server-side player session data
	local playerSession = PlayerManager:getPlayerSession(options.player)

	-- return a filtered version of the session data to exclude data that can't be encoded
	-- over the network
	return {
		status = 1,
		payload = toClientSession(playerSession),
	}
end
