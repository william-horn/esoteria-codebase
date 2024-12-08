

local DispatchStatusType = {
	Disabled = "Disabled",
	UnknownRejectionError = "UnknownRejectionError",
	DispatchQueued = "DispatchQueued",
	NoConnection = "NoConnection",
	DispatchLimitReached = "DispatchLimitReached",
	OnCooldown = "OnCooldown",
	DispatchOverride = "DispatchOverride",
	ThrowRejection = "ThrowRejection",
	Successful = "Successful",
	Rejected = "Rejected",
}


--local DispatchStatusType = {
--	Disabled = {
--		status = "Disabled",
--		verbose = "Event is disabled. To re-enable it, call event:enable()",
--	},
	
--	UnknownRejectionError = {
--		status = "UnknownRejectionError",
--		verbose = "Event could not fire. Notify the developer if you get this error."
--	},
	
--	DispatchQueued = {
--		status = "DispatchQueued",
--		verbose = "Event has 'dispatchQueueEnabled' enabled and no connections have been made yet - so this dispatch is queued until event:connect() is called"
--	},
	
--	NoConnection = {
--		status = "NoConnection",
--		verbose = "No handlers have been connected to the event yet, and event.requiresConnection is set to true. Connect a handler to this event or toggle 'requiresConnection' to false in the event settings or headers."
--	},
	
--	DispatchLimitReached = {
--		status = "DispatchLimitReached",
--		verbose = "Event has reached maximum dispatch limit set in event settings."
--	},
	
--	OnCooldown = {
--		status = "OnCooldown",
--		verbose = "Event failed to fire due to cooldown in event settings."
--	},
	
--	DispatchOverride = {
--		status = "DispatchOverride",
--		verbose = "Event successfully fired. Validation for this dispatch was ignored."
--	},
	
--	ThrowRejection = {
--		status = "ThrowRejection",
--		verbose = "Dispatch was rejected due to: %s"
--	},
	
--	Successful = {
--		status = "Successful",
--		verbose = "Event successfully fired. All validations were met."
--	},
	
--	Rejected = {
--		status = "Rejected",
--		verbose = "Event validation failed."
--	}
--}

--function DispatchStatusType.ThrowRejection:format(reason)
--	return {
--		status = self.status,
--		verbose = self.verbose:format(reason)
--	}
--end

return DispatchStatusType