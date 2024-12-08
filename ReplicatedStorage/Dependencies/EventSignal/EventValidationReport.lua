
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Path__Dependencies = ReplicatedStorage.Dependencies

local Package__Enumify = require(Path__Dependencies.Enumify)
local Enumify = Package__Enumify.Enumify

local LocalEnums = require(script.Parent.Enums)

local EventValidationStatus = LocalEnums.EventValidationStatus

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
	evr.reasons = Enumify:createEnumTable()

	return evr
end

return EventValidationReport