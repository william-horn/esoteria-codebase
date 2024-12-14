
return function(import)
	local TestMaker = import("@Dev/TestMaker")
	local util = import("@String/@Util/*")

	local StringTest = TestMaker.new("String Util Test")

	StringTest:add({
		try = util.trimLeft,
		name = "trimLeft",
		attempts = {
			{args = {"  a"}, expect = {"a"}},
			{args = {"  a  "}, expect = {"a  "}},
			{args = {"a "}, expect = {"a "}}
		}
	})

	StringTest:add({
		try = util.trimRight,
		name = "trimRight",
		attempts = {
			{args = {"  a"}, expect = {"  a"}},
			{args = {"  a "}, expect = {"  a"}},
			{args = {"a   "}, expect = {"a"}},
		}
	})

	StringTest:add({
		try = util.trimAround,
		name = "trimAround",
		attempts = {
			{args = {"  a  "}, expect = {"a"}},
			{args = {"  a "}, expect = {"a"}},
			{args = {"a  "}, expect = {"a"}},
			{args = {"a"}, expect = {"a"}},
		}
	})

	StringTest:add({
		try = util.toSingleSpace,
		name = "toSingleSpace",
		attempts = {
			{args = {"  a  "}, expect = {" a "}},
			{args = {"  a "}, expect = {" a "}},
			{args = {"a  "}, expect = {"a "}},
			{args = {"a"}, expect = {"a"}},
			{args = {"a   b"}, expect = {"a b"}},
		}
	})

	StringTest:add({
		try = util.splitWith,
		name = "splitWith",
		attempts = {
			{args = {"a b c", " "}, expect = {{"a", "b", "c"}}},
			{args = {"a b c", "%s", { usePatterns = true }}, expect = {{"a", "b", "c"}}},
			{args = {"a123b123cd", "%d+", { usePatterns = true }}, expect = {{"a", "b", "cd"}}},
		}
	})

	StringTest:add({
		try = util.noSpace,
		name = "noSpace",
		attempts = {
			{args = {" a  b   c  d"}, expect = {"abcd"}},
		}
	})

	StringTest:add({
		try = util.isEmpty,
		name = "isEmpty",
		attempts = {
			{args = {" a  b   c  d"}, expect = {false}},
			{args = {"   ", true}, expect = {true}},
			{args = {""}, expect = {true}},
		}
	})

	StringTest:add({
		try = util.doMathOp,
		name = "doMathOp",
		attempts = {
			{args = {"4", "-", "2", }, expect = {2}},
			{args = {"4", "-", "2", }, expect = {2}},
		}
	})

	StringTest:runAll()
end
