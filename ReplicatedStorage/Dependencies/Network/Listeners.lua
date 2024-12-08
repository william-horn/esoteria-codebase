
--[[
	Require modules
]]
local ReplicationStorage = game:GetService('ReplicatedStorage')

-- paths
local Path__Dependencies = ReplicationStorage.Dependencies
local Path__Network = ReplicationStorage.Network

-- enums
local LocalEnums = require(script.Parent.Enums)
local GlobalEnums = require(Path__Dependencies.Enums)
local MachineType = GlobalEnums.MachineType
local NetworkType = LocalEnums.NetworkType
local NetworkRequest = LocalEnums.NetworkRequest

-- modules
local System = require(Path__Dependencies.System)
local Table = require(Path__Dependencies.TableFunctions)

local Package__Enumify = require(Path__Dependencies.Enumify)
local Enumify = Package__Enumify.Enumify

local Package__Event = require(Path__Dependencies.EventSignal)
local Event = Package__Event.Event

--[[
	Create package module
]]
local Listeners = {}

-- all relevant remote data
local Remotes = Enumify:createEnumTable()
--[[
	Map MachineType enum to remote event listener types
]]
local ConnectionAliases = Enumify:createEnumTable({
	RemoteFunction = {
		[MachineType.Server] = 'OnServerInvoke',
		[MachineType.Client] = 'OnClientInvoke'
	},
	
	RemoteEvent = {
		[MachineType.Server] = 'OnServerEvent',
		[MachineType.Client] = 'OnClientEvent'
	},
	
	BindableFunction = {
		[MachineType.Server] = 'OnInvoke',
		[MachineType.Client] = 'OnInvoke'
	},
	
	BindableEvent = {
		[MachineType.Server] = 'Event',
		[MachineType.Client] = 'Event'
	}
})

local SystemFolderAliases = Enumify:createEnumTable({
	[MachineType.Server] = 'Server',
	[MachineType.Client] = 'Client'
})

-- get the remote listener type for the current system
local remoteFunctionConnectionType = ConnectionAliases.RemoteFunction[System.MachineType]
local remoteEventConnectionType = ConnectionAliases.RemoteEvent[System.MachineType]

local bindableFunctionConnectionType = ConnectionAliases.BindableFunction[System.MachineType]
local bindableEventConnectionType = ConnectionAliases.BindableEvent[System.MachineType]

--[[
	@desc: Check if a handler module is valid
	@params: ModuleScript obj
	@returns: Boolean isValid
]]
local function isValidHandlerModule(obj)
	return obj:IsA('ModuleScript') and obj.Name:sub(1, 1) ~= '_'
end

--[[
	@desc: Get the handler modules from a signal folder
	@params: Folder folder
	@returns: Table<ModuleScript> handlers
]]
local function getLocalHandlersModulesFromFolder(folder)
	local localHandlers = {}
	
	if (not folder) then
		return localHandlers
	end
	
	for _, handlerModule in next, folder:GetChildren() do
		if (isValidHandlerModule(handlerModule)) then
			localHandlers[handlerModule.Name] = handlerModule
		end
	end
	
	return localHandlers
end

--[[
	@desc: Get the network request types from a signal folder
	@params: Folder folder
	@returns: Table<String> requestTypes
]]
local function getNetworkRequestTypesFromFolder(folder)
	local handlerNames = {}
	
	for _, child in next, folder:GetChildren() do
		-- check if folder is the Server or Client folder
		if (
			child:IsA('Folder') and (child.Name == SystemFolderAliases[MachineType.Client] 
				or child.Name == SystemFolderAliases[MachineType.Server])
		) then
			
			-- store the request type names 
			for _, handlerModule in child:GetChildren() do
				if (isValidHandlerModule(handlerModule)) then
					handlerNames[#handlerNames + 1] = handlerModule.Name
				end
			end
		end
	end
	
	return handlerNames
end

--[[
	@desc: Convert a table of modules into their required form
	@args: Table<ModuleScript> modules
	@returns: Table<RequiredModuleScripts> 
]]
local function getRequiredHandlerModules(modules)
	for name, module in next, modules do
		modules[name] = require(module)
	end
	return modules
end

--[[
	Begin scanning the network folder for all network signals and network request handlers
]]
for _, remoteType in next, Path__Network:GetChildren() do
	local remotes = {}

	-- create the initial path for 'Send' and 'Receive' remotes
	Remotes[NetworkType[remoteType.Name]] = remotes

	-- scan over all remote folders inside network type
	local signals = remoteType:GetChildren()

	for _, signalFolder in next, signals do
		local remoteName = signalFolder.Name
		local remote = signalFolder:WaitForChild('Remote')

		local systemFolder = signalFolder:FindFirstChild(SystemFolderAliases[System.MachineType])

		if (not systemFolder) then
			System.warn('No handlers for ['..remoteName..'] on this system')
		end

		local handlerModules = getLocalHandlersModulesFromFolder(systemFolder)
		local requestTypes = getNetworkRequestTypesFromFolder(signalFolder)

		-- get the global and local remote settings (if any)
		local remoteGlobalSettings = signalFolder:FindFirstChild('_settings')
		local remoteLocalSettings = (systemFolder and systemFolder:FindFirstChild('_settings')) or nil

		-- if both global and local settings exist, combine them
		-- else if none exist, default to empty table {}
		-- else, use global or local settings (whichever exists)
		local remoteSettings do
			if (remoteGlobalSettings and remoteLocalSettings) then
				remoteSettings = Table:mergeDict(require(remoteLocalSettings), require(remoteGlobalSettings), true)

			elseif ((remoteGlobalSettings == nil) and (remoteLocalSettings == nil)) then
				remoteSettings = {}

			else
				remoteSettings = require(remoteGlobalSettings or remoteLocalSettings)
			end
		end

		-- update the remote data table
		-- this stores all relevant info about the remote
		remotes[NetworkType[remoteType.Name][remoteName]] = {
			remote = remote,
			handlers = handlerModules,
			requestTypes = requestTypes,
			event = Event.new({ 
				settings = remoteSettings, 
				name = remoteName 
			})
		}
	end
end

-- create the network enums based on the enum structure tables NetworkTypeEnum and NetworkRequestEnum

--[[
	@desc: General handler function for handling incoming remote signals.
	This accounts for both server and client side signals
	
	@param: handlers <table> - a dictionary of handler functions that the network request will choose from
]]
local function handleRequest(handlers)
	return function(player, request, ...)
		
		-- swap player and request args in case system is on the client, where the 'player' arg won't exist
		if (System.isClient()) then
			player, request = request, player
		end

		-- get the handler function based on the network request
		local handler = handlers[request]

		if (handler) then
			return handlers[request](player, ...)
		else
			System.warn('Network request failed - request type not recognized')
			return nil
		end
	end
end

function Listeners:listen()
	-- connect remote functions
	for _, remoteData in next, Remotes[NetworkType.Receive] do
		remoteData.remote[remoteFunctionConnectionType] = handleRequest(getRequiredHandlerModules(remoteData.handlers))
	end
	
	-- connect remote events
	for _, remoteData in next, Remotes[NetworkType.Send] do
		remoteData.remote[remoteEventConnectionType]:Connect(handleRequest(getRequiredHandlerModules(remoteData.handlers)))
	end
	
	for _, remoteData in next, Remotes[NetworkType.Functions] do
		remoteData.remote[bindableFunctionConnectionType] = handleRequest(getRequiredHandlerModules(remoteData.handlers))
	end
	
	for _, remoteData in next, Remotes[NetworkType.Events] do
		remoteData.remote[bindableEventConnectionType]:Connect(handleRequest(getRequiredHandlerModules(remoteData.handlers)))
	end
	
	--print('[Remote Data]', System.MachineType.value..': ', Remotes)
	
	return self
end

return {
	Listeners = Listeners,
	Remotes = Remotes,
}
