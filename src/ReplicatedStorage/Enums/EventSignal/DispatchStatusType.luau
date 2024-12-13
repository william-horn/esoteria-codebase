
local DispatchStatusType = {
	default = 0,
	Disabled = 0,
	UnknownRejectionError = 1,
	DispatchQueued = 2,
	NoConnection = 3,
	DispatchLimitReached = 4,
	OnCooldown = 5,
	DispatchOverride = 6,
	ThrowRejection = 7,
	Successful = 8,
	Rejected = 9,
}

return DispatchStatusType
