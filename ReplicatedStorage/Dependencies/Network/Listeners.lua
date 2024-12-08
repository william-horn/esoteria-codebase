
--[[
	Require modules
]]
local ReplicationStorage = game:GetService('ReplicatedStorage')

-- paths
local Path__Dependencies = ReplicationStorage.Dependencies
local Path__Network = ReplicationStorage.Network
-- local Path__NetworkSend = Path__Network.Send
-- local Path__NetworkReceive = Path__Network.Receive

-- enums
local LocalEnums = require(script.Parent.Enums)
local GlobalEnums = require(Path__Dependencies.Enums)
local MachineType = GlobalEnums.MachineType
local NetworkType = LocalEnums.NetworkType
local NetworkRequest = LocalEnums.NetworkRequest

-- modules
local System = require(Path__Dependencies.System)
local Table = require(Path__Dependencies.TableFunctions)

local Package__Event = require(Path__Dependencies.EventSignal)
local Event = Package__Event.Event

--[[
	Create package module
]]
local Listeners = {}

-- all relevant remote data
local Remotes = {}
--[[
	Map MachineType enum to remote event listener types
]]
local ConnectionAliases = {
	RemoteFunction = {
		[MachineType.Server:getBaseName()] = 'OnServerInvoke',
		[MachineType.Client:getBaseName()] = 'OnClientInvoke'
	},
	
	RemoteEvent = {
		[MachineType.Server:getBaseName()] = 'OnServerEvent',
		[MachineType.Client:getBaseName()] = 'OnClientEvent'
	},
	
	BindableFunction = {
		[MachineType.Server:getBaseName()] = 'OnInvoke',
		[MachineType.Client:getBaseName()] = 'OnInvoke'
	},
	
	BindableEvent = {
		[MachineType.Server:getBaseName()] = 'Event',
		[MachineType.Client:getBaseName()] = 'Event'
	}
}

local SystemFolderAliases = {
	[MachineType.Server:getBaseName()] = 'Server',
	[MachineType.Client:getBaseName()] = 'Client'
}

-- get the remote listener type for the current system
local remoteFunctionConnectionType = ConnectionAliases.RemoteFunction[System.MachineType:getBaseName()]
local remoteEventConnectionType = ConnectionAliases.RemoteEvent[System.MachineType:getBaseName()]

local bindableFunctionConnectionType = ConnectionAliases.BindableFunction[System.MachineType:getBaseName()]
local bindableEventConnectionType = ConnectionAliases.BindableEvent[System.MachineType:getBaseName()]

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
			child:IsA('Folder') and (child.Name == SystemFolderAliases[MachineType.Client:getBaseName()] 
				or child.Name == SystemFolderAliases[MachineType.Server:getBaseName()])
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
	local networkType = {}
	local requestType = {}
	local remotes = {}

	-- create the initial path for 'Send' and 'Receive' remotes
	System.print("remote name: ", remoteType.Name)
	System.print("Network type: ", NetworkType[remoteType.Name])
	
	Remotes[NetworkType[remoteType.Name]] = remotes

	-- scan over all remote folders inside network type
	local signals = remoteType:GetChildren()

	for _, signalFolder in next, signals do
		local remoteName = signalFolder.Name
		local remote = signalFolder:WaitForChild('Remote')

		local systemFolder = signalFolder:FindFirstChild(SystemFolderAliases[System.MachineType:getBaseName()])

		if (not systemFolder) then
			System.warn('No handlers for ['..remoteName..'] on this system')
		end

		local handlerModules = getLocalHandlersModulesFromFolder(systemFolder)
		local requestTypes = getNetworkRequestTypesFromFolder(signalFolder)

		-- get the global and local remote settings (if any)
		local remoteGlobalSettings = signalFolder:FindFirstChild('_Settings')
		local remoteLocalSettings = (systemFolder and systemFolder:FindFirstChild('_Settings')) or nil

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

		-- update the enum tables with the remote data
		-- NOTE: these objects will be converted into Enum objects later on
		-- their purpose is just to provide the structure for doing so
		networkType[tostring(NetworkType[remoteName])] = remoteName
		requestType[tostring(NetworkRequest[remoteName])] = Table:arrayToDict(requestTypes)

		-- update the remote data table
		-- this stores all relevant info about the remote
		remotes[remoteName] = {
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
System.print(Remotes)

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
	for _, remoteData in next, Remotes:get(NetworkType.Receive) do
		remoteData.remote[remoteFunctionConnectionType] = handleRequest(getRequiredHandlerModules(remoteData.handlers))
	end
	
	-- connect remote events
	for _, remoteData in next, Remotes:get(NetworkType.Send) do
		remoteData.remote[remoteEventConnectionType]:Connect(handleRequest(getRequiredHandlerModules(remoteData.handlers)))
	end
	
	for _, remoteData in next, Remotes:get(NetworkType.Functions) do
		remoteData.remote[bindableFunctionConnectionType] = handleRequest(getRequiredHandlerModules(remoteData.handlers))
	end
	
	for _, remoteData in next, Remotes:get(NetworkType.Events) do
		remoteData.remote[bindableEventConnectionType]:Connect(handleRequest(getRequiredHandlerModules(remoteData.handlers)))
	end
	
	--print('[Remote Data]', System.MachineType.value..': ', Remotes)
	
	return self
end

return {
	Listeners = Listeners,
	Remotes = Remotes,
}
