
return function(import, pm)
	local TestMaker = import("@Dev/TestMaker")
	local types = import("@Util/@Types/*")

	local StringTest = TestMaker.new("String Util Test")

	local x = {}

	local function thing(a)
		table.insert(x, a)
		return x
	end

	StringTest:add({
		try = thing,
		name = "thing",
		class = {},
		attempts = {
			{args = {1}, expect = {{1}}, iterations = 4},
			-- {attempt = "Test 2", args = {5}, expect = {false}, iterations = 100, error = nil},
			-- {attempt = "Test 3", args = {false}, expect = {false}, iterations = 100, error = nil},
		},
	})

	local result = StringTest:run(thing)

	print("Result: ", result)
end
