--[[
	@author: William J. Horn
	@written: 12/13/2024

	A test class to test and benchmark code

	Test example:

		local StringTest = TestMaker.new("String Tests")

		StringTest:add({
			try = function,
			name = "function name",
			object(optional) = <Class>,
			attempts = {
				{name(optional) = "attempt name", args = {...}, expect = {...}, iterations(optional) = 1},
				...
			}
		})

		StringTest:runAll()

	? If the function being tested is a method, you can pass the object of the method in the "object" field.

	? 'iterations' defaults to 1

	? 'name' defaults to 'Attempt: #'
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

		return setmetatable(record, {
			__index = function(self, k)
				if (k == "addError") then
					return function(_, status, message)
						self.errorMessages[status] = message
					end
				else
					return nil
				end
			end
		})
	end

	function TestMaker:add(testData)
		testData.name = testData.name or "Unnamed Function"
		testData.object = isTable(testData.object) and testData.object

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
		self.functionCount += 1
	end 

	function TestMaker:run(func)
		local testData = self.functions[func]

		local final = {}
		final.passed = 0
		final.failed = 0
		final.passPercentage = 0
		final.failedAttempts = {}
		final.analysis = {}

		print("Trying \"" .. testData.name .. "\"...")

		local function runAttempt(record, attempt)
			local t0 = os.clock()

			local returns 

			if (testData.object) then
				returns = { testData.try(testData.object, unpack(attempt.args)) }
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

			if (record.finalStatus[TestStatus.Indeterminate] or record.lastStatus == TestStatus.Failed) then
				final.failed += 1
				final.allPassed = false
				final.failedAttempts[attempt.name] = record
				record:addError(TestStatus.Failed, "Function result did not meet expectations")

			elseif (record.lastStatus == TestStatus.Success) then
				final.passed += 1
				final.allPassed = true
				record.errorMessages = nil
			end

			final.passPercentage = final.passed/#testData.attempts

		end

		return final
	end

	function TestMaker:runAll(withoutPrint)
		local header = "Running tests for: \"" .. self.title .. "\""
		local line = string.rep("-", #header)

		print(line)
		print(header)
		print(line)

		local results = {}
		results.passPercentage = 0
		results.functionsPassed = 0
		results.functionsFailed = 0

		local functionsTested = {}
		results.functionsTested = functionsTested

		local failedData = {}

		for f, data in next, self.functions do
			local result = self:run(f)
			functionsTested[data.name] = result

			if (result.allPassed) then
				results.functionsPassed += 1
			else
				results.functionsFailed += 1
				failedData[data.name] = result
			end
		end

		results.passPercentage = results.functionsPassed/self.functionCount

		print(line)

		if (not withoutPrint) then
			print("Results: |")
			print(line)
			print("Passed: ", results.functionsPassed)
			print("Failed: ", results.functionsFailed)
			print("Pass percentage: ", math.floor(results.passPercentage*100) .. "%")
			print(line)
			print("Failed functions: ", failedData)
			print(line)
			print("Data: ", results)
			print(line)
		end

		return results
	end

	function TestMaker.new(title)
		local testMaker = {}

		testMaker.functions = {}
		testMaker.functionCount = 0
		testMaker.title = title

		return setmetatable(testMaker, TestMaker)
	end

	return { default = TestMaker}
end