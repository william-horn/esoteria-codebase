--[[
	LocalPlayerManager is responsible for:
		* Creating/Storing/Updating local player session data for all players
		* Accessing the LocalPlayer's character model and character model components
		
	== Local Session Data ==
	
	Local sessions are stored inside LocalPlayerManager._playerSessions and can be
	accessed through the 'getPlayerSession()' api. They can also be created
	using the same function with 'options.autoCreate' set to true.
	
	Local sessions must exist before anything regarding the character or player metadata
	is manipulated. Data that streams in from the server will bounce if no client session
	is established first, however this bounced data can be retrieved later by calling:
	
		getPlayerSession({ refetch = true })
		
	This will update the local session data with the corresponding data in the server session.
]]

-- import module manager
local ModuleManager = require(game.ReplicatedStorage:WaitForChild('ModuleManager'))

-- import packaged dependancies
local Package__Event = ModuleManager:require('CustomEvent')
local Event = Package__Event.Event

local Package__System = ModuleManager:require('SystemAPI')
local System = Package__System.System

local Package__Table = ModuleManager:require('TableFunctions')
local Table = Package__Table.TableFunctions

local Package__CharacterController = ModuleManager:require('CharacterController')
local CharacterController,
	CharacterControls = 
		Package__CharacterController.CharacterController,
		Package__CharacterController.CharacterControls

local Package__Network = ModuleManager:require('NetworkAPI')
local Network, 
	NetworkEnums = 
		Package__Network.Network, 
		Package__Network.NetworkEnums

-- import standalone dependancies
local Debug = ModuleManager:require('Debug')
local UUID = ModuleManager:require('UUID')

-- Enums
local NetworkType, 
	NetworkRequest = 
		NetworkEnums.NetworkType,
		NetworkEnums.NetworkRequest

-- ROBLOX services/globals
local PlayerService = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- module
local LocalPlayerManager = {}

-- LocalPlayerManager._playerSessions structure:
LocalPlayerManager._playerSessions = {}

--[[
	LocalPlayerManager.onPlayerAdded<Event>
	
	Fires when a new player joins the game on the client-side. This
	event fires AFTER the new player session is already created.
	
	Handler callback:
		@arg1 <Event> event: The event object
		@arg2 <Player> player: The ROBLOX player instance that joined the game
]]
LocalPlayerManager.onPlayerAdded = Event.new({
	name = 'onPlayerAdded',
})

--[[
	LocalPlayerManager.onPlayerRemoved<Event>
	
	Fires when a player leaves the game on the client-side. This
	fires after the player session is removed.
	
	Handler callback:
		@arg1 <Event> event: The event object
		@arg2 <Player> player: The ROBLOX player instance that joined the game
]]
LocalPlayerManager.onPlayerRemoved = Event.new({
	name = 'onPlayerRemoved',
})

--[[
	@desc: 
		fetchPlayerSession() returns the player session for the specified player.
		if no player is specified, it will return the local player's session. All
		server-side session data is filtered before returning to the client, as some
		data is not compatible for sending over the network (such as events or cyclic
		tables)
		
	@param: options <table>
		player <Instance> - the player to fetch the session from
		
	@return: serverPlayerSession <table> - a filtered version of the player's server-side session data
]]
function LocalPlayerManager:fetchPlayerSession(options)
	-- config default options
	options = options or {}
	options.player = options.player or self:getLocalPlayer()
	
	-- begin fetching player session from the server
	Debug.print('fetching player session locally for: ', options.player)
	
	local playerSessionResponse = Network:invoke(
		NetworkType.Receive.Player.value, 
		NetworkRequest.Receive.Player.GetPlayerSession.value,
		options
	)

	-- fetch was valid
	if (playerSessionResponse.status == 1) then
		Debug.print('got player session locally for: ', options.player)
		return playerSessionResponse.payload
		
	-- fetch was invalid
	else
		Debug.error('Something went wrong with retrieving session for: ', options.player)
	end
end

--[[
	@desc:
		getPlayerSession() returns the local player session for a given
		player in the options argument. If no player is given then it defaults
		to the client player. 
		
		If this get is called before a local player session exists for a given
		player, it will create the local session data if 'options.autoCreate' is
		set to true (default is false). If set to false, it will return nil
		if no data exists
		
		This function will cache any created local session data that is created,
		unless 'options.refetch' is set to true. In which case, it will refetch 
		the server session and update the client session accordingly.
		
	@param: options <table>
		player <Instance> - the player to fetch the session from
		refetch <boolean | default: false> - whether or not to automatically fetch player session from the server
		autoCreate <boolean | default: false> - whether or not a client-side session is automatically created if it doesn't exist

	@return: updatedPlayerSession <table | nil> - the player's client-side session data
]]
function LocalPlayerManager:getPlayerSession(options)
	-- options config
	options = options or {}
	options.player = options.player or self:getLocalPlayer()
	
	-- set options.autoCreate to true by default
	if (options.autoCreate == nil) then options.autoCreate = false end
	
	-- retreive potential cached local session
	local cachedPlayerSession = self._playerSessions[options.player]
	local updatedPlayerSession = nil
		
	-- if prior cached data exists then set the updated player session to the current cached one
	if (cachedPlayerSession) then
		updatedPlayerSession = cachedPlayerSession
		
	-- elseif options.autoCreate is true, create a new blank local session 
	elseif (options.autoCreate == true) then
		updatedPlayerSession = self:createPlayerSession(options.player)
		
	-- if no cached data and options.autoCreate is false, return nil
	else
		return nil
	end
	
	--== ! note: if options.autoCreate is false, nothing below is reached ! ==--
	
	-- if options.refetch is enabled then fetch the updated server session for the player
	if (options.refetch == true) then
		local serverSession = self:fetchPlayerSession({
			player = options.player,
		})
		
		-- update the local session with new data from the server session
		-- server session data will overwrite local session data here
		updatedPlayerSession = Table:mergeDicts({
			updatedPlayerSession,
			serverSession
		}, true)
	end
		
	-- update the local session cache
	self._playerSessions[options.player] = updatedPlayerSession
		
	-- return the local session data
	return updatedPlayerSession
end

--[[
	@desc:
		getLocalPlayerData() returns the player data for a given player.
		if no player is specified, it will return the local player's data.
		
	@param: options <table>
		player <Instance> - the player to fetch the data from
		
	@return: playerSession.playerData <table | nil> - the player's saved data
]]
function LocalPlayerManager:getPlayerData(options)
	options = options or {}
	options.player = options.player or self:getLocalPlayer()
	
	local playerSession = self:getPlayerSession({
		player = options.player
	})
	
	if (not playerSession) then
		Debug.warn(`getPlayerData() failed for player: {options.player} (player's session does not exist)`)
		return nil
	end
	
	-- debug
	if (not playerSession.playerData) then
		Debug.warn(`getPlayerData() failed for player '{options.player}' (player's data has not loaded in yet)`)
		return nil
	end
	
	return playerSession.playerData
end


--[[
	@desc: returns the local player
]]
function LocalPlayerManager:getLocalPlayer()
	return PlayerService.LocalPlayer
end

--[[
	@desc: returns the local player's name
]]
function LocalPlayerManager:getPlayerName()
	return self:getLocalPlayer().Name
end

--[[
	@desc: returns the local player gui container
]]
function LocalPlayerManager:getPlayerGui()
	return self:getLocalPlayer():WaitForChild('PlayerGui')
end


--[[
	@desc: Remove a player from the session pool
	
	@param: player <Instance> - the player to remove from the session pool
	@return playerSession <table | nil> - the player's local session data
]]
function LocalPlayerManager:removePlayerSession(player)
	-- remove player character and local session data from client
	local playerSession = self:getPlayerSession({
		player = player
	})
	
	if (not playerSession) then
		Debug.warn(`removePlayerSession() failed for: {player} (player does not have any session data yet)`)
		return nil
	end
	
	self._playerSessions[player] = nil
	return playerSession
end

--[[
	@desc: Create the local session data for a player
	
	@param: player <Instance> - the player to add to the session pool
	@return playerSession <table> - the player's local session data
]]
function LocalPlayerManager:createPlayerSession(player)
	local playerSession = {}
	playerSession.player = player
	playerSession.clientId = UUID()
	playerSession.controller = CharacterController.new({
		player = player
	})

	playerSession.onPlayerDataReady = Event.new({
		name = 'onPlayerDataReady',
		settings = {
			dispatchLimit = 1
		}
	})
	
	playerSession.onServerSessionUpdate = Event.new({
		name = 'onServerSessionUpdate',
		settings = {
			dispatchQueueEnabled = true
		}
	})

	return playerSession
end

--[[
	@desc: Create a quick local session for all players in the game. This should be called 
	soon after LocalPlayerManager:listen(), if not immediately after, so that session
	data exists before other functions try to access it.
	
	@param: empty
	@return nil
]]
function LocalPlayerManager:createPlayerSessions()
	for _, player in next, PlayerService:GetPlayers() do
		self:getPlayerSession({
			player = player,
			autoCreate = true
		})
	end
	
	return self:getPlayerSessions()
end

--[[
	@desc: Updates an existing local session with the corresponding data within 
	the sessionUpdate object
	
	@param: player <Instance> - the player who's session is updated
	@param: sessionUpdate <table> - the data to update in the local session
	@return playerSession <table>
]]
function LocalPlayerManager:updatePlayerSession(player, sessionUpdate)
	local playerSession = self:getPlayerSession({
		player = player,
	})
	
	if (not playerSession) then
		Debug.warn(`Cannot update session data for player: {player} (their session data does not exist yet)`)
		return nil
	end
	
	self._playerSessions[player] = Table:mergeDicts({
		playerSession,
		sessionUpdate
	}, true)
	
	return playerSession
end

--[[
	@desc: Returns a random player from the ROBLOX player service
	@param: empty
	@return player <Instance>
]]
function LocalPlayerManager:getRandomPlayer()
	local players = PlayerService:GetPlayers()
	local randomPlayer = players[math.random(#players)]
	return randomPlayer
end

--[[
	@desc: Returns a random local session from the active local sessions
	@param: empty
	@return playerSession <table>
]]
function LocalPlayerManager:getRandomPlayerSession()
	return self._playerSessions[self:getRandomPlayer()]
end

--[[
	@desc: return the dictionary of player sessions
]]
function LocalPlayerManager:getPlayerSessions()
	return self._playerSessions
end


--[[
	@desc:
		listen() will listen for player added and player removing events and will
		load and unload characters accordingly.
	
	@return: LocalPlayerManager <table>
]]
function LocalPlayerManager:listen()
	PlayerService.PlayerAdded:Connect(function(player)
		Debug.print('JOINED: player ', player)
		
		self:getPlayerSession({
			player = player,
			autoCreate = true
		})
		
		LocalPlayerManager.onPlayerAdded:fire(player)
	end)
	
	PlayerService.PlayerRemoving:Connect(function(player)
		self:removePlayerSession(player)
		LocalPlayerManager.onPlayerRemoved:fire(player)
		
		Debug.print('LEAVE: player left: ', player)
		Debug.print(`session data after leave: `, self._playerSessions)
	end)
	
	-- disable roblox default player controls and camera
	self:getLocalPlayer()
		:WaitForChild('PlayerScripts')
		:WaitForChild('PlayerScriptsLoader')
		.Enabled = false
	
	return self
end

return LocalPlayerManager