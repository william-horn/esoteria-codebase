
return function(import, global, pm)
	local EventValidationStatus = import("../@Enums/@EventSignal/EventValidationStatus*")
	local withDotMethod = import("@Util/withDotMethod")

	local Dispatcher, _Dispatcher = withDotMethod()

	function Dispatcher:execute(payload__local, settings__localEvent, eventValidationReport)
		-- if catalyst event is no longer propagating, exit the event cycle
		-- local eventBlacklist = self.eventBlacklist 

		-- payload metadata
		local event = payload__local.event
		local args = payload__local.args

		eventValidationReport = event.getValidationReport(settings__localEvent)

		-- event data
		local analytics = event.analytics
		local parentEvent = event._parentEvent
		local childEvents = event._childEvents
		local connections = event._connections
		local linkedEvents = settings__localEvent.linkedEvents

		self.blacklist[event] = true

		local function runEventHandlers()
			if (settings__localEvent.dispatchSelf) then
				for index = 1, #connections do
					local connection = connections[index]

					if connection.isActive() and self.catalyst._propagating then

						-- TODO: add a staticArgs table to send back to the handler function which contains
						-- the catalyst event, along with more verbose information
						if (settings__localEvent.async or connection.async) then
							task.defer(
								connection.handler,
								self.catalyst,
								unpack(args)
							)
						else
							connection.handler(self.catalyst, unpack(args))
						end

					elseif (not self.catalyst._propagating) then
						break
					end
				end
			end
		end

		local function runDescendantEventHandlers()
			if (#childEvents == 0) then
				return
			end

			if (settings__localEvent.dispatchChildren or self.catalyst.settings.dispatchDescendants) then
				for index = 1, #childEvents do
					if (not self.catalyst._propagating) then
						break
					end

					local childEvent = childEvents[index]

					self.fire({ 
						event = childEvent,
						args = args,
					})
				end
			end
		end

		local function runAscendantEventHandlers()
			if (not parentEvent) or (not self.catalyst._propagating) then
				return
			end

			if (settings__localEvent.dispatchParent or self.catalyst.settings.dispatchAscendants) then
				self.fire({
					event = parentEvent,
					args = args,
					headers__local = {
						dispatchDescendants = false,
						dispatchChildren = false 
					}
				})
			end
		end

		local function runLinkedEventHandlers()
			if (#linkedEvents == 0) then
				return
			end

			if (settings__localEvent.dispatchLinked) then
				for index = 1, #linkedEvents do
					if (not self.catalyst._propagating) then
						break
					end

					local linkedEvent = linkedEvents[index]

					self.fire({
						event = linkedEvent,
						args = args
					})
				end
			end
		end

		local function executeEvent()
			runEventHandlers()
			runLinkedEventHandlers()
			runAscendantEventHandlers()
			runDescendantEventHandlers()
		end

		-- update time last dispatched to now
		analytics.timeLastDispatched = tick()
		analytics.dispatches.current += 1

		-- fire end of dispatch callbacks. these will run before the dispatch handlers
		if eventValidationReport.result == EventValidationStatus.Successful then
			event.executeDispatchSuccess(eventValidationReport.reasons, event)
			analytics.dispatches.successful += 1

			executeEvent()

		elseif eventValidationReport.result == EventValidationStatus.Rejected then
			event.executeDispatchFailed(eventValidationReport.reasons, event)
		end

		return eventValidationReport
	end

	function Dispatcher:fire(payload__local)
		local event = payload__local.event
		--local initialDispatch = event == self.catalyst

		-- debounce blacklisted events to avoid cyclic occurances
		if (self.blacklist[event]) then
			print("Cyclic event detected. Make sure your events are properly connected.") 
			return
		end

		local settings__localEvent = table.clone(event.settings)
		payload__local.args = payload__local.args or {}

		-- apply global headers, if any
		if (self.headers__global) then
			for key, value in next, self.headers__global do
				settings__localEvent[key] = value
			end
		end

		-- apply local headers, if any
		if (payload__local.headers__local) then
			for key, value in next, payload__local.headers__local do
				settings__localEvent[key] = value
			end
		end

		--[[
			Handle queued dispatches. These are dispatches that were deferred because the event
			had not been connected yet. They will throw a temporary rejection status, but will
			be re-evaluated later on when 'event:connect()' is called.
		]]
		if (settings__localEvent.dispatchQueueEnabled and not event._hasBeenConnectedBefore) then
			local dispatchQueue = event._dispatchQueue
			dispatchQueue[#dispatchQueue + 1] = payload__local

			---- manually throw a rejection status
			--local validationReport = event:getValidationReport({
			--	throwRejection = DispatchStatusType.DispatchQueued
			--})

			----event:executeDispatchFailed(validationReport.reasons, event)

			--return validationReport
		end

		-- execute the dispatch 
		return self.execute(payload__local, settings__localEvent)
	end

	function Dispatcher:new(payload__original)
		local dispatcher = setmetatable({}, _Dispatcher)

		dispatcher.blacklist = {}
		dispatcher.catalyst = payload__original.event
		dispatcher.headers__global = payload__original.headers__global

		return dispatcher
	end

	function Dispatcher:onDispatchFailed(dispatchStatus, event)
		if (event.settings.printDispatchStatus) then
			print("Dispatch rejected for event ["..event.name.."]: ", dispatchStatus)
		end
	end

	function Dispatcher:onDispatchSuccess(dispatchStatus, event)
		if (event.settings.printDispatchStatus) then
			print("Dispatch succeeded for event ["..event.name.."]: ", dispatchStatus)
		end
	end

	return {
		default = Dispatcher
	}
end
