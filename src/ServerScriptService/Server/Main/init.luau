
return function(import, pm)
	local TestMaker = import("@Dev/TestMaker")
	local types = import("@Util/@Types/*")
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
			{args = {"a123b123cd", "%d+", { usePatterns = true }}, expect = {{"a", "b", "c"}}},
		}
	})

	StringTest:runAll()
end
