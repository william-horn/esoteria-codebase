--[[
	@author: William J. Horn
	@written: 12/13/2024

	A test class to test and benchmark code
]]

return function(import)
	local matchesQuery = import("@Table/matchesQuery")
	local TestStatus = import("../@Enums/@Dev/TestStatus*")
	local isTable = import("@Util/@Types/isTable")

	local TestMaker = {}
	TestMaker.__index = TestMaker

	local testStatusAliases = {
		[TestStatus.Failed] = "Failed",
		[TestStatus.Success] = "Success",
		[TestStatus.Indeterminate] = "Indeterminate"
	}

	local function createAttemptRecord(attempt)
		local record = {}
		record.lastStatus = nil
		record.runtime = 0
		record.iterations = attempt.iterations
		record.errorMessages = {}

		local mt = {}
		mt.__index = mt

		function mt:addError(status, message)
			self.errorMessages[status] = message
		end

		return setmetatable(record, mt)
	end

	function TestMaker:add(testData)
		testData.name = testData.name or "Unnamed Function"
		testData.class = isTable(testData.class) and testData.class

		local usedNames = {}

		for index, data in next, testData.attempts do
			local name = data.name or "Attempt: " .. index

			if (usedNames[name]) then
				usedNames[name] += 1
				name = name .. " - " .. usedNames[name]
			end

			usedNames[name] = 0
			data.name = name
			data.iterations = data.iterations or 1
			-- data.error = data.error or "Expected $exp_1, got $ret_1"
		end

		self.functions[testData.try] = testData
	end 

	function TestMaker:run(func)
		local testData = self.functions[func]

		local final = {}
		final.passed = 0
		final.failed = 0
		final.passPercentage = 0
		final.analysis = {}

		print("Trying \"" .. testData.name .. "\"...")

		local function runAttempt(record, attempt)
			local t0 = os.clock()

			local returns 

			if (testData.class) then
				returns = { testData.try(testData.class, unpack(attempt.args)) }
			else
				returns = { testData.try(unpack(attempt.args)) }
			end

			local t1 = os.clock()
			local dt = t1 - t0
			record.runtime += dt 

			local AttemptStatus = matchesQuery(returns, attempt.expect, { strictlyEquals = true })
				and TestStatus.Success
				or TestStatus.Failed

			local responses = {}

			if (AttemptStatus == TestStatus.Failed) then
				record.expected = attempt.expect
				record.got = returns

				responses[TestStatus.Failed] = true

			else
				responses[TestStatus.Success] = true
			end

			if (record.lastStatus and AttemptStatus ~= record.lastStatus) then
				responses[TestStatus.Indeterminate] = true
			end

			record.lastStatus = AttemptStatus
			record.finalStatus = responses
			return responses
		end
		
		for index, attempt in next, testData.attempts do
			local record = createAttemptRecord(attempt)
			final.analysis[attempt.name] = record

			for cycle = 1, attempt.iterations do
				local attemptResults = runAttempt(record, attempt)

				if (attemptResults[TestStatus.Indeterminate]) then
					record:addError(TestStatus.Indeterminate, "Function results were different with the same arguments across multiple iterations")
					break
				end
			end

			if (record.finalStatus[TestStatus.Indeterminate]) then
				final.failed += 1

			elseif (record.lastStatus == TestStatus.Success) then
				final.passed += 1

			elseif (record.lastStatus == TestStatus.Failed) then
				final.failed += 1
			end

			-- re-format status enums to their display name aliases for the developer
			for status in next, record.finalStatus do
				record.finalStatus[status] = testStatusAliases[status]
			end

			record.lastStatus = testStatusAliases[record.lastStatus]
			--

		end

		final.passPercentage = (math.floor(final.passed/#testData.attempts*100)) .. "%"

		return final
	end

	function TestMaker.new(title)
		local testMaker = {}

		testMaker.functions = {}
		testMaker.title = title

		return setmetatable(testMaker, TestMaker)
	end

	return { default = TestMaker}
end