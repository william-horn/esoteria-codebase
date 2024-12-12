
return function(import, pm)
  local substitutionDefaults = pm.from(script).import("defaults*")
  local splitWith = import("@String/@Util/splitWith")
	
	--[[
		@desc: Substitutes variables and functions in a string
		@params: 
			<table> options:
				<string> source, 
				<table> vars, 
				<table> functions
		@returns: <string> substituted string
		
		Example:
			local source = 'Hello $name, how are $getPerson() today?'
			
			local substituted = String:substitute(source, {
				vars = { name = 'Bob' },
				functions = {
					getPerson = function()
						return 'you'
					end
				}
			})
			
			print(substituted)
			> Hello Bob, how are you today?
	]]
	local function vars(str, options)
		-- OPTIONS CONFIG
		if (options) then
			options = table.clone(options)

			for opKey, opVal in pairs({ vars = substitutionDefaults.vars, functions = substitutionDefaults.functions }) do
				if (not options[opKey]) then
					options[opKey] = opVal
				else
					for key, val in pairs(opVal) do
						if (typeof(options[opKey][key]) == 'nil') then
							options[opKey][key] = val
						end
					end
				end
			end
		else
			options = substitutionDefaults
		end

		-- SUBSTITUTION LOGIC
		local variables = options.vars or {}
		local functions = options.functions or {}

		local varStr = str:gsub("%$([%w_]+)", variables)

		local function replaceStr(str)
			str = str:gsub('%$([%w_]+)(%b())', function(funcName, matched)
				local func = functions[funcName]

				if (func) then
					local args = replaceStr(matched:sub(2, -2))
					return func(table.unpack(splitWith(args, ',')))
				else
					return '$' .. funcName .. matched
				end
			end)

			return str
		end

		return ({ replaceStr(varStr) })[1]
	end
	
	return vars
end