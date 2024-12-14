
return function(import, pm)
	-- local test = import("@Dev/TestMaker").new("IMPORT TEST")
	-- local values = import("@Table/@Dictionary/values")

	-- print(values)

	-- test:add({
	-- 	try = import,
	-- 	name = "Import",
	-- 	attempts = {
	-- 		{args = {"@Table/@Dictionary", "values", "merge", "keys", "mergeAll"}, expect = {values}, iterations = 10000}
	-- 	}
	-- })

	-- test:runAll()

	-- print(pm._cachedImportPaths)

	local t0 = import("@Table/@Dictionary/keys")
	import("@Table/@Dictionary/values")
	t0 = import("@Util/@Types", "*")
	-- local t1 = import("@Table/@Dictionary/values")
	-- local t3 = import("../@Enums/@Network/*")
	-- local t4 = import("@Table/*")
	-- local t5 = import("@Table/@Array/*")

	print(t0)
	-- print(t1)
	-- print(t3)
	-- print(t4)
	-- print(t5)
	print("Tree: ", pm._cachedImportPaths)
	
end
