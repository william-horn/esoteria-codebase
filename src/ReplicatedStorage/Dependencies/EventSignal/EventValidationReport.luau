
return function(import)
	local Enums = game.ReplicatedStorage.Enums
	local EventValidationStatus = Enums.EventSignal.EventValidationStatus

	-- local withDotMethod = import("@Util/withDotMethod")

	local EventValidationReport = {}
	EventValidationReport.__index = EventValidationReport

	function EventValidationReport:hasDispatchStatus(dispatchStatusType)
		for index = 1, #self.reasons do
			local reason = self.reasons[index]
			if (reason == dispatchStatusType) then
				return true
			end
		end

		return false
	end

	function EventValidationReport:addReason(dispatchStatusType)
		self.reasons[#self.reasons + 1] = dispatchStatusType
	end

	function EventValidationReport:setResult(eventValidationStatus)
		self.result = eventValidationStatus
	end

	function EventValidationReport.new(result)
		local evr = setmetatable({}, EventValidationReport)

		evr.result = result or EventValidationStatus.Rejected
		evr.reasons = {}

		return evr
	end

	return { 
		default = EventValidationReport
	}
end
