--[[
	@author: William J. Horn
	@written: 05/28/2022
	@last-updated: 10/17/2024
	
	PlayerManager is responsible for:
		- creating server-side player sessions
		- retrieving the player's saved data upon game entry
		- saving the player's data upon leaving the game
		- initializing the server-side player
]]

-- ROBLOX services
local PlayerService = game:GetService('Players')
local DataStoreService = game:GetService('DataStoreService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

-- module imports
local Path__Schema = ReplicatedStorage.Schema
local Path__Dependencies = ReplicatedStorage.Dependencies
local Path__GameConfig = ReplicatedStorage.GameConfig
local Path__Assets = ReplicatedStorage.Assets
local Path__CharacterModels = Path__Assets.CharacterModels

local DataKeys = require(script.DataKeys)
local GameConfig = require(Path__GameConfig.Server)

local System = require(Path__Dependencies.System)
local PlayerDataSchema = require(Path__Schema.PlayerDataSchema)

--local Package__CharacterController = require(Path__Dependencies.CharacterController)
--local CharacterController = Package__CharacterController.CharacterController
--local CharacterControls = Package__CharacterController.CharacterControls

local Package__Network = require(Path__Dependencies.Network)
local Network = Package__Network.Network

local NetworkType, 
	NetworkRequest = 
		Package__Network.NetworkType,
		Package__Network.NetworkRequest

local Package__Event = require(Path__Dependencies.EventSignal)
local Event = Package__Event.Event

-- data store setup
local PlayerDataStore = DataStoreService:GetDataStore(DataKeys.player.playerDataStore)

-- module
local PlayerManager = {}

PlayerManager.service = PlayerService
PlayerManager.sessionData = {}

--[[
	@desc:
		getPlayerDataKey() returns the key used to store player data for the given player.
	@params:
		player: Player
	@returns:
		string
]]
function PlayerManager:getPlayerDataKey(player)
	return DataKeys.player.playerData:format(player.Name, player.UserId)
end

--[[
	@desc:
		getPlayerSession() returns the session data for the given player.
	@params:
		player: Player
	@returns:
		table
]]
function PlayerManager:getPlayerSession(player)
	return self.sessionData[player]
end

--[[
	@desc:
		waitForPlayerData() will return a player's playerData if immediately available,
		otherwise it will wait until the playerData has been loaded in from DataStoreService.
		
	@param: player <Player> The player to retrieve the player data for.
	
	@returns: table
]]
function PlayerManager:waitForPlayerData(player)
	local playerSession = self:getPlayerSession(player)
	local playerData
	
	if (playerSession._playerDataReady == false) then
		--print('waiting on player data...')
		playerData = playerSession.onPlayerDataReady:wait()
		--print('player data loaded')
	else
		playerData = playerSession.playerData
	end
	
	return playerData
end

--[[
	@desc:
		createPlayerSession() creates the session data object for a given player.
		This data may not have all fields loaded in at run time, as the playerData
		is loaded in later.
		
	@param: player <Player> The player to create the session data for.
	@returns: table
]]
function PlayerManager:createPlayerSession(player)
	local playerSession = {
		-- replicated
		joinTime = tick(),
		serverSpawn = Vector3.new(-486, 30.5, 472),
		_playerDataReady = false,
		_playerDataFailed = false,
		--
		
		-- server-only
		
		--
	}
	
	-- server-side events for tracking the playerData retrieval status
	playerSession.onPlayerDataReady = Event.new({ 
		name = 'onPlayerDataReady',
		settings = {
			dispatchLimit = 1
		}
	})
	
	playerSession.onPlayerDataFailed = Event.new({ 
		name = 'onPlayerDataFailed',
		settings = {
			dispatchLimit = 1
		}
	})
	
	-- catch multiple dispatches and handle error messages accordingly
	local function onEventFail(eventName, reasons, event)
		System.warn(`{eventName} fired multiple times - this event is intended for a one-time only use`)
		System.warn(`{eventName} dispatch log: `, reasons)
	end
	
	playerSession.onPlayerDataReady.onDispatchFailed = function(...)
		onEventFail('onPlayerDataReady', ...)
	end
	
	playerSession.onPlayerDataFailed.onDispatchFailed = function(...)
		onEventFail('onPlayerDataFailed', ...)
	end
	
	-- update the player session later (if playerData fails)
	playerSession.onPlayerDataFailed:connect({
		handler = function()
			playerSession._playerDataFailed = true
			
			-- update all clients with the streamed in data
			Network:fireAll(
				NetworkType.Send.Player,
				NetworkRequest.Send.Player.SessionUpdate,
				player,
				{
					_playerDataFailed = playerSession._playerDataFailed 
				}
			)
		end,
	})
	
	-- update the player session later (if playerData succeeds)
	playerSession.onPlayerDataReady:connect({
		handler = function(event, playerData)
			System.print('got player data for: ', player, ' (updating all clients...)')
			
			playerSession.firstJoin = playerData == nil
			playerSession.playerData = playerData or PlayerDataSchema.new():randomize().data
			playerSession._playerDataReady = true
			
			-- update all clients with the streamed in data
			Network:fireAll(
				NetworkType.Send.Player,
				NetworkRequest.Send.Player.SessionUpdate,
				player,
				{
					firstJoin = playerSession.firstJoin,
					playerData = playerSession.playerData,
					_playerDataReady = playerSession._playerDataReady,
				}
			)
		end,
	})
	
	return playerSession
end

--[[
	Handle new player joins. This function will load the player's data from DataStoreService,
	and create the player's session data.
]]
local function onPlayerJoin(player)
	-- get/create session data
	local playerSession = PlayerManager:createPlayerSession(player)

	-- add the characterModel to the server-side session data
	PlayerManager.sessionData[player] = playerSession

	-- stream initial player session data to all clients
	Network:fireAll(
		NetworkType.Send.Player,
		NetworkRequest.Send.Player.SessionUpdate,
		player,
		{
			joinTime = playerSession.joinTime,
			_playerDataReady = playerSession._playerDataReady,
			_playerDataFailed = playerSession._playerDataFailed,
			serverSpawn = playerSession.serverSpawn
		}
	)
	
	-- manually replicate the player gui
	--local playerGui = StarterGui:WaitForChild('Master'):Clone()
	--playerGui.Parent = player:WaitForChild('PlayerGui')
		
	-- try/catch the playerData from DataStoreService
	local success, playerData = pcall(function()
		-- TODO: remove simulated lag once testing phase is over
		task.wait(math.random(10, 20)) -- simulated lag
		return PlayerDataStore:GetAsync(PlayerManager:getPlayerDataKey(player))
	end)

	if (success) then
		print('Successfully loaded data for '..player.Name)
		print('Data: ', playerData)
		
		playerSession.onPlayerDataReady:fire(playerData)
	else
		
		playerSession.onPlayerDataFailed:fire()
		System.warn('Error loading data for '..player.Name)
	end
end

--[[
	Handle player leave events. This function will save the player's data to DataStoreService,
	remove the player's session data from the server, and other necessary clean-up jobs.
]]
local function onPlayerLeave(player)
	local playerSession = PlayerManager:getPlayerSession(player)

	if (playerSession) then
		-- remove cached player session from instance
		PlayerManager.sessionData[player] = nil

		-- if player joined for the first time, use SetAsync
		if (playerSession.firstJoin == true) then
			System.print(player.Name..' joined for the first time - using SetAsync to save data')
			System.print('Data: ', playerSession.playerData)
			
			PlayerDataStore:SetAsync(PlayerManager:getPlayerDataKey(player), playerSession.playerData)
			
		-- if the player leaves before their data loads in, abort overwriting to nil
		elseif (playerSession.playerData == nil) then
			System.warn(`{player.Name} left: No player data found, aborting write operation`)
			
		-- else use UpdateAsync
		else
			System.print(player.Name..' has been here before, using UpdateAsync to save data')
			System.print('Data: ', playerSession.playerData)
			
			--[[
				CONSIDERATION:
				
				Maybe use TableFunctions:mergeDicts() to udpate 'prev' instead of
				returning 'playerSession.playerData'
			]]
			PlayerDataStore:UpdateAsync(PlayerManager:getPlayerDataKey(player), function(prev)
				return playerSession.playerData
			end)
		end
	end
end

-- connect all listeners
function PlayerManager:listen()
	PlayerService.PlayerAdded:Connect(onPlayerJoin)
	PlayerService.PlayerRemoving:Connect(onPlayerLeave)
	
	return self
end


return PlayerManager
