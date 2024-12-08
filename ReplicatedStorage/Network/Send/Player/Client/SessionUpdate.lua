--local ModuleManager = require(game.ReplicatedStorage:WaitForChild('ModuleManager'))
--local LocalPlayerManager = ModuleManager:require('LocalPlayerManager')
--local System = ModuleManager:require('Debug')

return function(player, sessionUpdate)
	System.print(`received session update from: {player} (Data): `, sessionUpdate)
	
	local sessionData = LocalPlayerManager:getPlayerSession({
		player = player,
	})
	
	-- keep a reference to the old session data before calling updateClientPlayerSession()
	-- this is to check for any potential states that exist before the update, to trigger
	-- events and other possible conditions
	if (sessionData) then
		sessionData = table.clone(sessionData)
	end
	
	sessionData.onServerSessionUpdate:fire(sessionUpdate)
	
	-- if the update fails, then abort
	if (not LocalPlayerManager:updatePlayerSession(player, sessionUpdate)) then
		System.warn(`session update from: {player} FAILED. Update data: `, sessionUpdate)
		return
	end
	
	-- fire client-side onPlayerDataReady event if playerData streams in
	if ((not sessionData.playerData) and sessionUpdate.playerData) then
		System.print(`streamed in playerData from {player}`)
		sessionData.onPlayerDataReady:fire(sessionUpdate.playerData)
	end
	
	
	System.print(`updated session: `, LocalPlayerManager:getPlayerSession({ player = player, autoCreate = false }))
end
