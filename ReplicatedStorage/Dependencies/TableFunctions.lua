
local Path__Dependendies = script.Parent

local Package__StringFunctions = require(Path__Dependendies.StringFunctions)
local String = Package__StringFunctions.StringFunctions

local TableFunctions = {}

--[[
	@desc: Returns an array of all keys in a table
	@args: <table> dict
	@returns: <array> keys
]]
function TableFunctions:getKeys(dict)
	local arr = {}
	
	for k, v in next, dict do
		arr[#arr + 1] = k
	end
	
	return arr
end

function TableFunctions:getValues(dict)
	local arr = {}
	
	for k, v in next, dict do
		arr[#arr + 1] = v
	end
	
	return arr
end

--[[
	@desc: Returns the quantity of entries in a table
	@args: <table> dict
	@returns: <number> size
]]
function TableFunctions:getSize(dict)
	local size = 0
	
	for k, v in next, dict do
		size = size + 1
	end
	
	return size
end

--[[
	@desc: Converts an array into a dictionary with the structure:
		array: {'a', 'b', 'c', ...}
		dict: {['a'] = 'a', ['b'] = 'b', ['c'] = 'c', ...}
	@args: <array> arr
	@returns: <dictionary> dict
]]
function TableFunctions:arrayToDict(arr)
	local dict = {}
	
	for i = 1, #arr do
		local v = arr[i]
		dict[v] = v
	end
	
	return dict
end

--[[
	@desc: Merges two tables (dictionaries) into one
	@param <table> a
	@param <table> b
	@param <boolean> overwrite - If true, values from a will overwrite values in b
	@returns: <table> c
]]
function TableFunctions:mergeDict(a, b, overwrite)
	local c = table.clone(b)
	
	for k, v in next, a do
		if (not c[k]) or overwrite then
			c[k] = v
		end
	end

	return c
end

--[[
	local dict1 = { x = 1, y = 2 }
	local dict2 = { y = 3, z = 5 }
	local dict3 = { x = 8, z = 3, a = 1 }
	
	mergeDicts({dict1, dict2, dict3}) -> { x = 1, y = 2, z = 5, a = 1}
	mergeDicts({dict1, dict2, dict3}, true) -> { x = 8, y = 3, z = 3, a = 1}
]]

function TableFunctions:mergeDicts(dicts, overwrite)
	local dict = dicts[1]
	
	for i = 2, #dicts do
		local iv = dicts[i]
		for k, v in next, iv do
			if (not dict[k]) or overwrite then
				dict[k] = v
			end
		end
	end
	
	return dict
end

--[[
	@desc: Merges two tables (arrays) into one
	@param <table> a
	@param <table> b
	@returns: <table> c
]]
function TableFunctions:mergeArray(a, b)
	local c = table.clone(b)
	
	for i = 1, #a do
		local v = a[i]
		c[#c + 1] = v
	end
	
	return c
end

function TableFunctions:mergeArrays(arrays)
	local all = {}
	
	for i = 1, #arrays do
		local iv = arrays[i]
		for j = 1, #iv do
			local jv = iv[j]
			all[#all + 1] = jv
		end
	end
	
	return all
end

function TableFunctions:match(data, query, options)
	local queue = {{data, query}}

	while (#queue > 0) do
		local dataDir, queryDir = unpack(table.remove(queue, 1))

		for queryKey, queryVal in next, queryDir do
			local dataVal = dataDir[queryKey]

			local queryValIsTable = type(queryVal) == "table"
			local dataValIsTable = type(dataVal) == "table"

			if (dataVal == nil or queryVal == nil) then return false end

			if (dataValIsTable and queryValIsTable) then
				queue[#queue + 1] = {dataVal, queryVal}

			elseif (not String:isValidMatch(dataVal, queryVal, options)) then
				return false

			end
		end
	end

	return true
end

-- Function to search through an array of tables and find matches based on a query table
function TableFunctions:queryMany(array, query, options)
	local matches = {}  -- List to store matching tables

	-- Iterate through the array
	for _, item in ipairs(array) do
		-- Check if the item matches the query
		if self:match(item, query, options) then
			table.insert(matches, item)
		end
	end

	return matches
end

function TableFunctions:queryOne(array, query, options)
	-- Iterate through the array
	for _, item in ipairs(array) do
		-- Check if the item matches the query
		if self:match(item, query, options) then
			return item
		end
	end

	return nil
end

function TableFunctions:isInArray(arr, element)
	for i = 1, #arr do
		local v = arr[i]
		if (v == element) then
			return true
		end
	end
	
	return false
end

function TableFunctions:getElement(arr, element)
	for i = 1, #arr do
		local v = arr[i]
		if (v == element) then
			return v
		end
	end
end

function TableFunctions:removeElement(arr, element)
	for i = 1, #arr do
		local v = arr[i]
		if (v == element) then
			table.remove(arr, i)
			return
		end
	end
end

function TableFunctions:toString(t, indent)
	-- Check if the input is actually a table
	if type(t) ~= "table" then
		print("Input is not a table")
		return
	end

	-- Initialize an empty string to store the formatted table
	local formattedString = "{\n"

	-- Initialize the indentation level
	if not indent then
		indent = 1
	end

	-- Create the indentation string
	local indentation = string.rep("\t", indent)

	-- Iterate through the table
	for key, value in pairs(t) do
		-- If the value is a table, recursively call printTable with increased indentation
		if type(value) == "table" then
			formattedString = formattedString .. indentation .. key .. " = " .. self:toString(value, indent + 1) .. ",\n"
		else
			-- If the value is not a table, add it to the formatted string with current indentation
			formattedString = formattedString .. indentation .. key .. " = " .. tostring(value) .. ",\n"
		end
	end

	-- Add closing curly brace with proper indentation and return the formatted string
	formattedString = formattedString .. string.rep("\t", indent - 1) .. "}"
	return formattedString
end

function TableFunctions:traverse(t, callback)
  local queue = {t}

  while (#queue > 0) do
    local dir = table.remove(queue, 1)

    for itemKey, itemVal in next, dir do
      if (type(itemVal) == "table") then
        queue[#queue + 1] = itemVal
      end

      callback(dir, itemKey, itemVal)
    end
  end
end

return TableFunctions
