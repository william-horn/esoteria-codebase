
return function(serverSession)
	return {
		_playerDataFailed = serverSession._playerDataFailed,
		_playerDataReady = serverSession._playerDataReady,
		joinTime = serverSession.joinTime,
		playerData = serverSession.playerData,
		firstJoin = serverSession.firstJoin,
		serverSpawn = serverSession.serverSpawn
	}
end
