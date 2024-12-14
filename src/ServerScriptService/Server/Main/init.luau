
return function(import, pm)
	local enums = pm.from("../Enums/EventSignal")
	local DispatchStatusType = enums.import("DispatchStatusType*")
  local EventValidationStatus = enums.import("EventValidationStatus*")
  local EventStateType = enums.import("EventStateType*")
	print(DispatchStatusType)
	print(EventValidationStatus)
	print(EventStateType)
end
