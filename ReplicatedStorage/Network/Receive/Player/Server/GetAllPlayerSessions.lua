local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Path__Dependencies = ReplicatedStorage.Dependencies

local System = require(Path__Dependencies.System)
local PlayerManager = require(ServerScriptService.GameServer.PlayerManager)

local toClientSession = require(script.Parent._toClientSession)

return function(player, options)
	System.print('Client ['..player.Name..'] requesting ALL session data')
	
	local sessions = PlayerManager.sessionData
	local clientSessions = {}
	
	-- convert server sessions to client sessions for network transfer
	for player, sessionData in next, sessions do
		clientSessions[player] = toClientSession(sessionData)
	end

	return {
		status = 1,
		payload = clientSessions
	}
end
