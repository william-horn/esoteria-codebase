
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Path__Dependencies = ReplicatedStorage.Dependencies
local Path__DataFiles = ReplicatedStorage.DataFiles

local EntityData = require(Path__DataFiles.EntityData)

local Table = require(Path__Dependencies.TableFunctions)

local Package__Event = require(Path__Dependencies.EventSignal)
local Event = Package__Event.Event

local System = require(Path__Dependencies.System)

local EntityFolder = workspace:WaitForChild('World').Entities
local NPCsFolder = EntityFolder.NPCs
local ObjectsFolder = EntityFolder.Objects

local EntityService = {}

-- create event listeners for registering/unregistering new entities
EntityService.onEntityRegistered = Event.new({ 
	name = 'onEntityRegistered',
	settings = { 
		requiresConnection = false,
		dispatchQueueEnabled = true
	}
})

EntityService.onEntityUnregistered = Event.new({ 
	name = 'onEntityUnregistered',
	settings = { 
		requiresConnection = false,
		dispatchQueueEnabled = true
	}
})

EntityService._activeEntities = {}

--[[
	@desc: Get the entity settings from an entity instance based on their Configuration member
	@param: <Instance> entityInstance
	@return: <table | nil> entitySettings
]]
function EntityService:getConfigFromEntity(entityInstance)
	local config = entityInstance:FindFirstChildWhichIsA('Configuration')
	
	if (not config) then
		return nil
	end
	
	return {
		id = config.EntityId.Value
	}
end

--[[
	@desc: Returns the entity group registered in the entity service based on an id (contains all existing entities of the same id)
	@param: <string> id
	@return: <table | nil> entityGroup
]]
function EntityService:getEntityGroupById(id)
	return self._activeEntities[id]
end

--[[
	@desc: Waits for the entity group to exist before returning the result.
	@param: <string> id
	@return: <table | nil> entityGroup
]]
function EntityService:waitForEntityGroupById(id)
	local entityGroup = self:getEntityGroupById(id)
	
	if (entityGroup) then
		return entityGroup
	else
		local _, entityData = self.onEntityRegistered:wait()
		
		if (entityData.entitySettings.id == id) then
			return entityData.entityGroup
		else
			return self:waitForEntityGroupById(id)
		end
	end
end

--[[
	@desc: 
		Returns just one entity in a registered entity group. If the entity group has 
		more than one entity, it will return the first entity.
		
	@param: <string> id
	@return: <Instance | nil> entity
]]
function EntityService:getEntityById(id)
	local entityGroup = self:getEntityGroupById(id)
	
	if (not entityGroup) then
		return nil
	end
	
	return entityGroup[1]
end

--[[
	@desc: 
		Waits for an entity group to exist before calling 'getEntityById()' and returning
		the first entity.
	
	@param: <string> id
	@return: <Instance | nil> entity
]]
function EntityService:waitForEntityById(id)
	local entityGroup = self:getEntityById(id)
	
	if (entityGroup) then
		return entityGroup[1]
	else
		return self:waitForEntityGroupById(id)[1]
	end
end

--[[
	@desc: 
		Registers a given instance as an entity, with options field. Once registered, the
		instance will be eligable for lookup later on with methods such as 'EntityService:getEntityById(id)'
		
	@param: <Instance> entityInstance: The entity to register
	
	@param: <table> options: A table of config options for the entity registration
		<boolean> options.existInDatabase: Whether the entity must exist in the EntityData database to be registered (default: true)
		
	@returns: <table> status
]]
function EntityService:registerEntity(entityInstance, options)
	local entitySettings = self:getConfigFromEntity(entityInstance)
	
	-- abort function if no configuration settings exist within the entity instance
	if (not entitySettings) then
		warn(`Failed to register entity '{entityInstance.Name}' (missing Configuration settings)`)

		return {
			success = false
		}
	end
	
	-- create default options
	options = options or {}
	if (options.existInDatabase == nil) then options.existInDatabase = true end
	
	-- retrieve entity group from id
	local entityGroup = self._activeEntities[entitySettings.id]
	
	-- if the entity does not exist in the database and 'options.existInDatabase' is true, abort function
	if (options.existInDatabase and not EntityData.All:findById(entitySettings.id)) then
		warn('Failed to register entity: \''..tostring(entityInstance)..'\' (entity does not exist in database)')
		
		return {
			success = false
		}
	end
	
	-- if there is no prior entity group yet, then create the group with the given entity instance
	if (not entityGroup) then
		entityGroup = { entityInstance }
		self._activeEntities[entitySettings.id] = entityGroup
		
		local entityData = {
			entityInstance = entityInstance,
			entityGroup = entityGroup,
			entitySettings = entitySettings
		}
		
		self.onEntityRegistered:fire(entityData)
		
		return {
			success = true,
			entityData = entityData
		}
	end
	
	-- if the entity instance is already registered, abort the function
	if (Table:isInArray(entityGroup, entityInstance)) then
		warn('Failed to register EntityInstance: \''..tostring(entityInstance)..'\' (entity is already registered)')
		
		return {
			success = false
		}
			
	-- else, the entity has not been registered and is eligable to be registered.
	else
		entityGroup[#entityGroup + 1] = entityInstance
		
		local entityData = {
			entityInstance = entityInstance,
			entityGroup = entityGroup,
			entitySettings = entitySettings
		}

		self.onEntityRegistered:fire(entityData)

		return {
			success = true,
			entityData = entityData
		}
	end
end

--[[
	@desc: 
		Unregister an entity instance from the EntityService. This will remove the entity from the entity group,
		and if the entity group is empty, the entity group will be removed from the entity service.
		
	@param: <Instance> entityInstance
	@returns: <table> status
]]
function EntityService:unregisterEntity(entityInstance)
	local entitySettings = self:getConfigFromEntity(entityInstance)
	
	if (not entitySettings.id) then
		warn('EntityInstance \''..tostring(entityInstance)..'\' is not a valid entity or is missing Configuration settings')
		
		return {
			success = false
		}
	end
	
	local entityGroup = self._activeEntities[entitySettings.id]
	
	if (not entityGroup) then
		warn('Failed to unregister EntityInstance \''..tostring(entityInstance)..'\' (entity group does not exist)')
		
		return {
			success = false
		}
	end
	
	if (Table:isInArray(entityGroup, entityInstance)) then
		Table:removeElement(entityGroup, entityInstance)
		
		local entityData = {
			entityInstance = entityInstance,
			entityGroup = entityGroup,
			entitySettings = entitySettings
		}
		
		if (#entityGroup == 0) then
			self._activeEntities[entitySettings.id] = nil
		end
		
		self.onEntityUnregistered:fire(entityData)
		
		return {
			success = true,
			entityData = entityData
		}

	else
		warn('Failed to unregister EntityInstance \''..tostring(entityInstance)..'\' (entity instance is not registered in group)')
		
		return {
			success = false
		}
	end
end

--[[
	@desc: Register all pre-existing entities in the game world within the entities folder.
]]
function EntityService:registerWorld()
	for _, entityType in next, EntityFolder:GetChildren() do
		for _, entity in next, entityType:GetChildren() do
			self:registerEntity(entity)
		end
	end
	
	--print('Registered all pre-existing entities')
	return self
end

--[[
	@desc: Begin listening to new entities that are added to the game world entities folder.
]]
function EntityService:listen()
	local function registerEntity(child)
		--print('Auto-registering new entity: ', child)
		self:registerEntity(child)
	end
	
	NPCsFolder.ChildAdded:Connect(registerEntity)
	ObjectsFolder.ChildAdded:Connect(registerEntity)
	
	return self
end

return EntityService
