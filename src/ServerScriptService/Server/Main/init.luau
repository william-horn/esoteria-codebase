
return function(import, pm)
	local TestMaker = import("@Dev/TestMaker")
	local types = import("@Util/@Types/*")

	local StringTest = TestMaker.new("String Util Test")

	local f = function() import("@Dev/TestMaker"); return true end

	StringTest:add({
		try = f,
		name = "isString",
		class = {},
		tests = {
			{attempt = "Test 1", args = {""}, expect = {true}, iterations = 10000, error = nil},
			-- {attempt = "Test 2", args = {5}, expect = {false}, iterations = 100, error = nil},
			-- {attempt = "Test 3", args = {false}, expect = {false}, iterations = 100, error = nil},
		},
	})

	local result = StringTest:run(f)

	print("Result: ", result)
end
