--[[
	@author: William
	@written: 12/15/2024

	Create a tree-like hierarchy table of another nested table with a
	callback function of options. 
		
	Your callback argument does not need to return anything, instead, it 
	is passed a table of options that have been defined internally. You can
	modify these options to determine what should happen during the iteration.

	? Example, this will ignore any value of "a" in the tree:

		deepCopy(t, function(got)
			if (got.value == "a") then
				got.ignore = true
			end
		end)

	If you have not re-assigned the key or value, they will remain as they were.

	# Possible options:
		? got.terminate
			- if true, process the other options and break the loop
		? got.ignore
			- if true, don't include the current entry in the returned tree
		? got.treatAsValue
			- if true, value is implied to be a table, and the table reference will be added to the tree but not iterated over.
		? got.value
			- the value at the current iteration
		? got.key
			- the key at the current iteration

	# These are included as options but are intended as read-only:
		? got.depth
			- the depth of the cycle
		? got.currentTable
			- the current table in the cycle
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
				local got = {
					key = key,
					value = value,
					treatAsValue = false,
					terminate = false,
					ignore = false,
					depth = depth,
					currentTable = dir,
				}

				callback(got)

				if (got.ignore) then
					continue
				end

				if (isTable(got.value) and not got.treatAsValue) then
					local newDir = {}
					treeDir[got.key] = newDir
					queue[#queue + 1] = { got.value, newDir, depth + 1 }

				else
					treeDir[got.key] = got.value
				end

				if (got.terminate) then
					break
				end
			end
		end

		return tree
	end

	return deepCopy
end
