
return function(import)
	return function()
		local t = import("@Table/*")
		local a = import("@Table/@Array/*")
		local d = import("@Table/@Dictionary/*")

		print("keys: ", d.keys({a = "x", b = "y", c = "z"}))
		print("size: ", t.size({a = "a", b = "b", c = "c"}))
		print("contains: ", a.contains({"a", "b", "c"}, "b"))
		print("values: ", d.values({a = "x", b = "y", c = "z"}))
		print("toDict: ", a.toDict({"a", "b", "c"}))
		print("removeValue: ", a.removeValue({"a", "b", "c", "d"}, "c"))

		local dict1 = { x = 1, y = 2 }
    local dict2 = { y = 3, z = 5 }
    local dict3 = { x = 8, z = 3, a = 1 }

    local d1 = d.mergeAll({dict1, dict2, dict3}) ---> { x = 1, y = 2, z = 5, a = 1}
    local d2 = d.mergeAll({dict1, dict2, dict3}, true) ---> { x = 8, y = 3, z = 3, a = 1}

		print("mergeDicts (no overwrite): ", d1)
		print("mergeDicts (overwrite): ", d2)
	end
end
