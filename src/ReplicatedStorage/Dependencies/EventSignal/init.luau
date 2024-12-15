--!nocheck
--[[
	@author: 
		William J. Horn
		ScriptGuider @ROBLOX.com
		
	@description:
		The CustomEvent library allows you to create and manage your own pseudo events in Lua. It comes
		packaged with a powerful API that lets you manipulate event connections, use different connection
		priorities, create event chains, etc.
		
		Note: Note: This program was designed to run in the ROBLOX environment with ROBLOX's modified version of Lua.
		
	@last-updated:
		05/31/2024
		
	@help:
		If you have any questions or concerns, please email me at: williamjosephhorn@gmail.com
]]

return function(import, global, pm)

	---------------
	--- Imports ---
	---------------
	local Enums = game.ReplicatedStorage.Enums
	local this = pm.from(script)

	local UUID = import("@Util/uuid")
	local CustomType = Enums.CustomType

	local DispatchStatusType = Enums.DispatchStatusType
	local EventValidationStatus = Enums.EventSignal.EventValidationStatus
	local EventStateType = Enums.EventSignal.EventStateType

	local Dispatcher = this.import("Dispatcher")
	local EventValidationReport = this.import("EventValidationReport")
	local ConnectionInstance = this.import("ConnectionInstance")

	-- local withDotMethod = import("@Util/withDotMethod")

	-------------------------
	--- Localized globals ---
	-------------------------
	local unpack = table.unpack

	-------------------------
	--- Utility functions ---
	-------------------------

	--[[
	validateSearchQuery(search<table>, against<table>): <boolean>
	@params search:
	The table containing the keys/values to include in the search over
	the object.
	@params against:
	The object being searched.

	Used for searching event connections by their given options.
	]]
	local function validateSearchQuery(search, against)
		for k, v in next, search do
			if (v ~= against[k]) then
				return false
			end
		end

		return true
	end

	local function getDefaultOptions(options)
		options = options or {}
		options.priority = math.max(options.priority or math.huge, 0)

		return options
	end

	local function dispatchEvent(payload__original)
		local dispatcher = Dispatcher.new(payload__original)
		local event = payload__original.event

		-- initiate event propagation state
		event._propagating = true

		-- fire custom internal dispatcher
		local validationReport = dispatcher:fire(payload__original)

		-- fire roblox wait signal
		event._rbxYieldSignal:Fire(unpack(payload__original.args or {}))

		-- cancel any yielding threads for event:wait(), if any
		local yieldTasks = event._yieldTasks

		if (#yieldTasks > 0) then
			for index = 1, #yieldTasks do
				local yieldTask = yieldTasks[index]
				task.cancel(yieldTask)
				yieldTasks[index] = nil
			end
		end

		-- conclude event propagation state
		event:stopPropagating()
		return validationReport
	end

	-------------------------
	--- CustomEvent API ---
	-------------------------
	local EventSignal = {}
	EventSignal.__index = EventSignal

	function EventSignal:getValidationReport(headers)
		local settings = headers or self.settings
		local analytics = self.analytics

		local report = EventValidationReport.new(EventValidationStatus.Rejected)

		-- special case event overrides
		if (settings.withValidation == false) then
			report:addReason(DispatchStatusType.DispatchOverride)
		end

		if (#report.reasons > 0) then
			report:setResult(EventValidationStatus.Successful)
			return report
		end

		if (settings.throwRejection) then
			report:addReason(settings.throwRejection)
			report:setResult(EventValidationStatus.Rejected)
			return report
		end

		if (self.settings.dispatchQueueEnabled and not self._hasBeenConnectedBefore) then
			report:addReason(DispatchStatusType.DispatchQueued)
		end

		-- event dispatch validation
		if (self.isDisabled()) then
			report:addReason(DispatchStatusType.Disabled)
		end

		if #self._connections == 0 and settings.requiresConnection then
			report:addReason(DispatchStatusType.NoConnection)
		end

		if (analytics.dispatches.successful >= settings.dispatchLimit) then
			report:addReason(DispatchStatusType.DispatchLimitReached)
		end

		-- update final dispatch report
		if (#report.reasons == 0) then
			report:addReason(DispatchStatusType.Successful)
			report:setResult(EventValidationStatus.Successful)
		end

		return report
	end

	function EventSignal:connect(options)
		options = getDefaultOptions(options)

		local connections = self._connections
		local connection = ConnectionInstance.new(options)
		connections[#connections + 1] = connection

		table.sort(connections, function(a, b)
			return a.priority < b.priority
		end)

		if (not self._hasBeenConnectedBefore) then
			self._hasBeenConnectedBefore = true

			for i = 1, #self._dispatchQueue do
				local dispatchPayload = self._dispatchQueue[i]
				self._dispatchQueue[i] = nil
				dispatchEvent(dispatchPayload)
			end
		end

		return connection
	end

	function EventSignal:connectAsync(options)
		options.async = true
		self:connect(options)
	end

	function EventSignal:dispatch(options)
		options.event = self
		return dispatchEvent(options)
	end

	function EventSignal:fire(...) 
		return self:dispatch({
			args = {...}
		})
	end

	function EventSignal:fireAll(...)
		return self:dispatch({
			args = {...},
			headers__global = {
				dispatchChildren = true
			}
		})
	end

	function EventSignal:fireAsync(...)
		return self:dispatch({
			args = {...},
			headers__local = {
				async = true
			}
		})
	end

	function EventSignal:fireDescendantsOnly(...)
		return self:dispatch({
			args = {...},
			headers__local = {
				dispatchSelf = false,
			},
			headers__global = {
				dispatchChildren = true
			}
		})
	end

	function EventSignal:stopPropagating() 
		self._propagating = false
	end

	function EventSignal:executeDispatchSuccess(...)
		if (self.onDispatchSuccess) then
			self.onDispatchSuccess(...)
		else
			Dispatcher.onDispatchSuccess(...) 
		end
	end

	function EventSignal:executeDispatchFailed(...)
		if (self.onDispatchFailed) then
			self.onDispatchFailed(...)
		else
			Dispatcher.onDispatchFailed(...)
		end
	end

	function EventSignal:queryDescendantEvents(callback)
		local function searchChildren(_event)
			callback(_event)

			if (#_event._childEvents > 0) then
				for i = 1, #_event._childEvents do
					searchChildren(_event._childEvents[i]) 
				end
			end
		end

		searchChildren(self)
	end

	function EventSignal:queryEventConnections(options, callback)
		options = table.clone(getDefaultOptions(options))
		local connections = self._connections

		for index = #connections, 1, -1 do
			local connection = connections[index]
			if (validateSearchQuery(options, connection)) then
				callback(connections, index, connection)
			end
		end
	end

	function EventSignal:disconnect(options)
		options = getDefaultOptions(options)

		self:queryEventConnections(options, function(connections, index, connection)
			table.remove(connections, index)
		end)
	end

	function EventSignal:disconnectAll(options)
		options = getDefaultOptions(options)

		self:queryDescendantEvents(function(event)
			event:disconnect(options)
		end)
	end

	function EventSignal:wait(timeout)
		local now = tick()

		if timeout then
			local yieldTask = task.delay(timeout, function()
				self._rbxYieldSignal:Fire()

				print("Event timed out after "..tostring(tick() - now).." seconds.")
			end)

			self._yieldTasks[#self._yieldTasks + 1] = yieldTask
		end

		local args = { self._rbxYieldSignal.Event:Wait() }
		return tick() - now, unpack(args)
	end

	function EventSignal:isDisabled()
		return self._state == EventStateType.Disabled
	end

	function EventSignal:isEnabled()
		return not (self:isDisabled())
	end

	function EventSignal:isActive()
		local report = self:getValidationReport()
		return report.result == EventValidationStatus.Successful
	end

	function EventSignal:disable()
		if (self._state == EventStateType.Disabled) then
			print("Attempted to disable event ["..self._id.."] when event is already disabled.")
			return
		else
			self._prevState = self._state
			self._state = EventStateType.Disabled
		end
	end

	function EventSignal:enable()
		if (self._state ~= EventStateType.Disabled) then
			print("Attempted to enable event ["..self._id.."] when event is already enabled.")
			return
		end

		self._state = self._prevState
	end

	function EventSignal:setParent(parentEvent)
		if (self._parentEvent) then
			local oldParentChildren = self._parentEvent._childEvents
			
			for index = 1, #oldParentChildren do
				if (oldParentChildren[index] == self) then
					table.remove(oldParentChildren, index)
					break
				end
			end
		end

		-- create root node chain
		if (parentEvent) then
			self._parentEvent = parentEvent
			parentEvent._childEvents[#parentEvent._childEvents + 1] = self

			self._rootNode = parentEvent._rootNode or parentEvent
		else
			self._rootNode = self
		end
	end

	function EventSignal.new(options)
		options = options or {
			parent = nil,
			settings = {},
			metadata = {},
			childEvents = {},
			scope = {},
		}

		local parentEvent = options.parent
		local settings = options.settings or {}
		local metadata = options.metadata or {}
		local childEvents = options.childEvents or {}

		local event = setmetatable({}, EventSignal)

		event._childEvents = childEvents
		event._id = UUID()
		event._customType = CustomType.EventInstance
		event._propagating = false
		event._hasBeenConnectedBefore = false
		event._prevState = EventStateType.Listening
		event._state = EventStateType.Listening
		event._connections = {}
		event._rbxYieldSignal = Instance.new("BindableEvent")
		event._yieldTasks = {}
		event._dispatchQueue = {}

		-- event dispatch callbacks
		-- event.onDispatchFailed
		-- event.onDispatchSuccess

		event.name = options.name or event._id 
		event.scope = options.scope or {}

		event.analytics = {
			timeLastDispatched = 0,
			dispatches = {
				current = 0,
				whileDisabled = 0,
				whileAnscestorDisabled = 0,
				withoutValidation = 0,
				whileGloballyPaused = 0,
				whileLocallyPaused = 0,
				withNoConnection = 0,
				whileLimitReached = 0,
				failed = 0,
				successful = 0,
			}
		}

		event.settings = {
			linkedEvents = {},

			cooldown = {
				intervalLimit = 0, -- times event fires before being temporarily disabled
				cooldownDuration = 0, -- (seconds) time event is temporarily disabled for
				intervalReset = 0 -- time until the interval counter resets (time resets after every event dispatch)
			},

			dispatchLimit = math.huge,

			dispatchQueueEnabled = false,   -- determines whether or not dispatches will be queued to fire before 'connect()' is called (if 'requiresConnection' is true, dispatches will not queue)
			dispatchLinked = true,			-- determines whether or not linked events will fire
			dispatchParent = false,			-- NEW (untested) determins whether the parent exclusively fires
			dispatchChildren = false,		-- NEW (untested) determins whether the children excluviely fires
			dispatchSelf = true, 			-- determines whether or not the direct connections to this event will fire when triggered
			requiresConnection = true, 		-- determines whether or not the event needs a connection to be triggered
			withValidation = true, 			-- if event handlers should meet conditions to be executed
			printDispatchStatus = false,
			--async = nil, 					-- if event handlers should be run asynchonously or not
		}

		-- update default settings with instantiated settings
		for key, value in next, settings do
			event.settings[key] = value
		end

		event:setParent(parentEvent)
		return event
	end

	return {
		default = EventSignal,
		DispatchStatusType = DispatchStatusType,
		EventValidationReport = EventValidationReport,
		EventValidationStatus = EventValidationStatus
	}
end