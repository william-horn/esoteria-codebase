--[[
	@author: William
	@written: 12/15/2024

	Create a tree-like hierarchy table of another nested table. This
	can also be used to get the hierarchy tree of instance descendants, by
	doing:

		deepCopy(a:GetChildren(), function(_, v)
				local c = v:GetChildren()
				return v.Name, #c > 0 and c or v
		end)

	? --> note:
		If no callback is given, the tree will just be the deep copy of the 
		table provided.
	? <--

	? --> note:
		If the callback returns nil for the key, the deepCopy will stop
		once it is done finishing it's current cycle.
	? <--

	? Example of using depth to determine when to stop deep cycling:

		deepCopy(t, function(key, value, depth)
			if (depth == 2) then
				return nil, ... <-- key is nil, don't move down another level
			end

			return key, value
		end)

	? This will stop the next cycle, and the returned table will have a depth of 2
]]

return function(import)
	local isFunction, isTable = import("@Util/@Types", "isFunction", "isTable")

	local function deepCopy(t, callback)
		if (callback and not isFunction(callback)) then
			error("Callback passed to buildTree() must be nil or a function")
		end

		local tree = {}
		local queue = {{ t, tree, 1 }}

		while (#queue > 0) do
			local set = queue[#queue]
			local dir, treeDir, depth = set[1], set[2], set[3]

			queue[#queue] = nil

			for key, value in next, dir do
				local skipTable = false

				if (callback) then
					local _key, _value = callback(key, value, dir, depth)

					if (_key ~= nil) then
						key, value = _key, _value
					else
						skipTable = true
					end
				end

				if (isTable(value) and not skipTable) then
					local newDir = {}
					treeDir[key] = newDir
					queue[#queue + 1] = { value, newDir, depth + 1 }

				else
					treeDir[key] = value
				end
			end
		end

		return tree
	end

	return deepCopy
end
