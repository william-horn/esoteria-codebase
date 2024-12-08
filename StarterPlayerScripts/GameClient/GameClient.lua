-- timestamp
local programStart = os.clock() 

local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Path__Dependencies = require(ReplicatedStorage.Dependencies)

--[[
	@desc: Core modules. These modules are requires before all others because
	they provide prerequisite utility.
]]

local System = require(Path__Dependencies.System)
local loadstring = require(Path__Dependencies.LuaCompiler)

local Path__World = workspace:WaitForChild('World')
local Path__PlayerCharacters = Path__World:WaitForChild('PlayerCharacters')

--[[
	@module NetworkAPI
	@desc: Responsible for all client-to-server and vice-versa communication
]]
local Package__Network = System.benchmarkModule(
	'Network', 
	Path__Dependencies.Network
)

local 
  Network, 
  NetworkType,
  NetworkRequest = 
  --
  Package__Network.Network, 
  Package__Network.NetworkType,
  Package__Network.NetworkRequest

--[[
	@module StringFunctions
	@desc: Contains utility functions for manipulating strings
]]
local Package__StringFunctions = System.benchmarkModule(
	'StringFunctions', 
	Path__Dependencies.StringFunctions
)

local String = Package__StringFunctions.StringFunctions

--[[
	@module UserInputHandler
	@desc: Responsible for handling all user input events in the game
]]
local UserInputHandler = System.benchmarkModule(
	'UserInputHandler', 
	script.UserInputHandler
)

--[[
	@module LocalPlayerManager
	@desc: Provides an API for manipulating the client-side players in the game. Changes
	made through this API do not necessarily replicate to the server.
]]
local LocalPlayerManager = System.benchmarkModule(
	'LocalPlayerManager', 
	script.LocalPlayerManager
)

--[[
	@module CustomCamera
	@desc: Handles all camera activity for the local player
]]
local Package__CustomCamera = System.benchmarkModule(
	'CustomCamera', 
	script.CustomCamera
)

local 
  CustomCamera, 
	CameraMode = 
  --
  Package__CustomCamera.CustomCamera, 
  Package__CustomCamera.CameraMode

--[[
	@module EntityService
	@desc: Tracks all entities in the game and makes them accessible through
	the EntityService API
]]
local EntityService = System.benchmarkModule(
	'EntityService', 
	Path__Dependencies.EntityService
)

--[[
	@module LocalDatabase
	@desc: Provides an API for creating a new local database that can be queried.
]]
local LocalDatabase = System.benchmarkModule(
	'LocalDatabase', 
	ModuleManager:getModule('LocalDatabase')
)

--[[
	@module EntityData
	@desc: A local database of entity data.
]]
local EntityData = System.benchmarkModule(
	'EntityData', 
	ModuleManager:getModule('EntityData')
)

local CollisionPhysics = System.benchmarkModule(
	'CollisionPhysics',
	ModuleManager:getModule('CollisionPhysics')
)

--[[
	@module CharacterController
	@desc: Responsible for all interaction between the player and the character model. Provides an API for 
	manipulating character activity. Only user input is replicated to the server and other clients via
	this module.
]]
local Package__CharacterController = System.benchmarkModule(
	'CharacterController', 
	ModuleManager:getModule('CharacterController')
)

local CharacterController,
	CharacterControls = 
		Package__CharacterController.CharacterController,
		Package__CharacterController.CharacterControls

--[[
	Initialize modules
]]

-- register pre-existing entities in world
EntityService:registerWorld()

-- create local player sessions and load player characters
do
	local playerSessions = LocalPlayerManager:createPlayerSessions()
	
	-- load all player characters
	for _, session in next, playerSessions do
		session.controller:loadCharacter({ parent = Folder__PlayerCharacters })
	end
	
	LocalPlayerManager.onPlayerAdded:connect({
		handler = function(_, player)
			LocalPlayerManager
				:getPlayerSession({
					player = player
				})
				.controller
				:loadCharacter({
					parent = Folder__PlayerCharacters
				})
		end,
	})
	
	local playerSession = LocalPlayerManager:getPlayerSession()
	local controller = playerSession.controller
	
	-- set user input controls for local player
	controller:setDefaultControls()
	
	playerSession.onServerSessionUpdate:connect({
		handler = function(_, sessionUpdate)
			if (sessionUpdate.serverSpawn) then
				controller:getFocusedCharacter():SetPrimaryPartCFrame(
					CFrame.new(sessionUpdate.serverSpawn)
				)
			end
		end,
	})
	
	------------------
	
	--[[
		-- CONCEPT:
		
		local controller = CharacterController.new()
		controller:add({ model })
		
		controller:moveTo()
		controller:moveToWithPathfinding()
	]]
	
	--task.delay(3, function()
	--	local controller = LocalPlayerManager:getPlayerSession().controller
	--	local newChar = CharacterController.createCharacter("Clone")
	--	newChar.Parent = Folder__World

	--	controller:add({ 
	--		newChar 
	--	}, { 
	--		withPhysics = false,
	--		movementSpeed = 1
	--	})	
	--end)

end

--[[
	@listeners
	@desc: Initiate and connect all modules/module listeners
]]
-- begin listening to network calls
Network:listen()

-- register existing entities and listen for new ones
EntityService:listen()

-- begin tracking player sessions
LocalPlayerManager:listen()

-- begin updating the player's camera
CustomCamera:listen()

-- begin updating collision physics
CollisionPhysics:listen()

-- begin listening to user input
UserInputHandler:listen()

--[[
	-- OTHER
]]


----------------------------------------------------
-- EXAMPLE OF SETTING UP LOCAL CHARACTER CONTROLS --
----------------------------------------------------


----------------------------------------------------



--[[
	@benchmark
]]
System.printCompletionTime(script.Name, programStart)