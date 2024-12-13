--[[
	@author: William J. Horn
	@written: 12/13/2024

	A test class to test and benchmark code
]]

return function(import)
	local matchesQuery = import("@Table/matchesQuery")

	local TestMaker = {}
	TestMaker.__index = TestMaker

	function TestMaker:add(testData)
		testData.name = testData.name or "Unnamed Function"

		local tests = testData.tests

		for index, data in next, tests do
			data.attempt = data.attempt or "Attempt: " .. index
			data.iterations = data.iterations or 1
			data.error = data.error or "Expected $exp_1, got $ret_1"
		end

		self.functions[testData.try] = testData
	end 

	function TestMaker:run(func)
		local tests = self.functions[func]

		local result = {}
		result.passed = 0
		result.failed = 0
		result.passPercentage = 0
		result.analysis = {}

		print("Trying \"" .. tests.name .. "\"...")
		
		for index, test in next, tests.tests do
			local record = {}
			record.attempt = test.attempt
			record.fastestRun = math.huge
			record.slowestRun = 0
			record.averageRun = 0
			record.totalRuntime = 0
			record.iterations = test.iterations

			result.analysis[index] = record

			local s0 = os.clock()

			for cycle = 1, test.iterations do
				local s1 = os.clock()
				local returns = { pcall(tests.try, unpack(test.args)) }
				local t1 = os.clock() - s1

				local success = table.remove(returns, 1)
				
				if (not success) then
					record.passed = false
					record.errorMessage = returns[1]
					result.failed += 1
					record.errorType = "runtime"
					break;
				end
				
				if (cycle == 1) then
					local passed = matchesQuery(returns, test.expect)

					if (passed) then
						record.passed = true
						result.passed += 1
					else
						record.passed = false
						record.errorType = "logic"
						result.failed += 1
						record.expected = test.expect
						record.got = returns
						break
					end
				end

				record.averageRun += t1

				if (t1 > record.slowestRun) then
					record.slowestRun = t1
				end

				if (t1 < record.fastestRun) then
					record.fastestRun = t1
				end
			end

			local t0 = os.clock() - s0

			record.averageRun = record.averageRun/test.iterations
			record.totalRuntime = t0
		end

		result.passPercentage = (math.floor(result.passed/#tests.tests*100)) .. "%"

		return result
	end

	function TestMaker.new(title)
		local testMaker = {}

		testMaker.functions = {}
		testMaker.title = title

		return setmetatable(testMaker, TestMaker)
	end

	return { default = TestMaker}
end