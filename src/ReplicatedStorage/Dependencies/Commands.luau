--[[
	@author: William J. Horn
	@written: 12/9/2024

	Command control package for creating custom command rulesets.
	"Techinically" a standalone package, since it does not rely on `import()`.
	
	However, this package still has one dependency which is obtained using `require()`:
		- String
		
	This package exports a single `Commands` class, therefore it can be imported using:
		- import("Commands", "*")
]]

return function()
	
	-- dependencies
	local StringEscaper = require(script.Parent.String)()

	local Commands = {} 
	Commands.__index = Commands

	local defaultSettings = {
		-- prefixes
		commandPrefix = "$",
		flagPrefix = "-",
		escapePrefix = "/",

		-- seperators
		argumentSeperator = " ",
		commandNameSeperator = " ",
		flagSeperator = " ",
		listSeperator = ",",

		-- other
		flags = {},
		listBrackets = { "{", "}" },
	}

	Commands.defaultSettings = defaultSettings

	--[[
		hasCommandPrefix(text<string>, err<string|boolean|nil>):
		
		@desc: Determines whether or not a string starts with the defined
		prefix. Ex: "$foo bar" is true
		
		@param text<string>: 
			the text to check the command prefix of
			
		@param strict<string|boolean|nil>: 
			run the function in strict mode (error if match fails)
	]]
	function Commands:hasCommandPrefix(text, strict)
		local hasPrefix = text:sub(1, #self.commandPrefix) == self.commandPrefix
		
		if (not hasPrefix and strict) then
			error("Command parse error: Could not parse command name \"" .. text .. "\" - does not start with command prefix", 2)
		end
		
		return hasPrefix
	end

	function Commands:splitCommand(text, strict)
		-- if string does not start with command prefix
		-- ex: "foo" or ""
		-- return {nil, nil}
		if (not self:hasCommandPrefix(text, strict)) then return nil, nil end
		
		--[[
			-- match "$foo" in "$foo bar":
			
			-- no prefix
			"" --> strict: error, non-strict: nil, nil
			"foo" --> strict: error, non-strict: nil, nil
			
			-- prefix
			"$" --> strict: error, non-strict: nil, nil
			"$-" --> strict: error, non-strict: nil, nil
			"$foo" --> strict: "foo", nil, non-strict: "foo", nil
			"$-foo" --> strict: error, non-strict: nil, "foo"
			"$foo-" --> strict: error, non-strict: "foo", nil
		]]
		
		-- if total string is the command prefix
		-- return {nil, nil}
		local onlyPrefixError = #text == #self.commandPrefix
		
		if (onlyPrefixError and strict) then
			error("Could not parse command: Command must be more than just the prefix", 2)
			
		elseif (onlyPrefixError) then
			return nil, nil
		end
		
		local commandPrefixStart = #self.commandPrefix + 1
		local sepOpen, sepClose = text:find(self.escCommandNameSeperator)
		
		-- if no seperator between command name and command body exists:
		-- ex: "$foo bar"
		-- return {"foo bar", nil}
		if (not sepOpen) then return text:sub(commandPrefixStart), nil end
		
		-- if commandBody or commandName don't exist
		-- ex: "$-" or "$foo-" or "$-foo"
		local commandNameError = sepOpen == commandPrefixStart
		local commandBodyError = sepClose == #text
		
		if (commandNameError and strict) then error("Could not parse command name (no command name given)", 2) end
		if (commandBodyError and strict) then error("Could not parse command body (no command body was given)", 2) end
		
		local commandName = text:sub(commandPrefixStart, sepOpen - 1)
		local commandBody = text:sub(sepClose + 1)
		
		-- case 1) both missing: "$-", return {nil, nil}
		if (commandBodyError and commandNameError) then
			return nil, nil
		
		-- case 2) body missing: "$foo-", return {"foo", nil}
		elseif (commandBodyError) then
			return commandName, nil
			
		-- case 3) name missing: "$-foo", return {nil, "foo"}
		elseif (commandNameError) then
			return nil, commandBody
		end
		
		return commandName, commandBody
	end

	function Commands:get(name, strict)
		local commandData = self._commands[name]
		
		if (commandData == nil and strict) then
			error("Could not find command \"" .. tostring(name) .. "\"", 2)
		end
		
		return commandData
	end

	function Commands:getFlagToken(text)
		if (not text:match("^" .. self.flagPrefix)) then
			
		end
	end

	function Commands:parseCommandBody(text, err)
		local parsedBody = {}
		
		return parsedBody
	end

	--[[
		ex:
		
		Command:run("$nocache -m arg1")
	]]
	function Commands:run(text, strict)
		-- split "$foo bar" into "foo" and "bar"
		local commandName, commandBody = self:splitCommand(text, strict)
		
		-- get command data for command "foo"
		--local commandData = self:get(commandName, strict)
		
		return commandName, commandBody
	end

	function Commands:add(name, commandData)
		if (self:getName(name) ~= nil) then
			error("Could not add command \"" .. name .. "\" - command already exists", 2)
		end
		
		self._commands[name] = commandData
	end

	function Commands.new(settings)
		settings = table.clone(settings or {})
		
		local commandInstance = {}
		commandInstance._commands = {}
		
		local Escaper = StringEscaper.new(settings.escapePrefix)

		for key, value in next, defaultSettings do
			commandInstance[key] = settings[key] or defaultSettings[key]
			
			if (type(defaultSettings[key]) == "string") then
				commandInstance["esc_"..key] = 0
			end
		end
		
		return setmetatable(commandInstance, Commands)
	end

	-- $fly me telamon
	-- $give [will, me] "lots of gold"
	-- $benchmark -m "ran in %s seconds"-
	-- $this "okay"
	-- $this okay
	-- $   
	-- $this -t
	-- $this {100, "something"}
	-- $this -m:okay test/-g:{500, "something else"}/nice/try/{bucko}

	local output = {
		flags = {
			message = "okay",
			global = { 500, "something else"}
		},
		args = {
			"nice",
			"try",
			{"bucko"}
		}
	}
	-- $this -m 500
	-- PackageManager:import("Enumify", "$nocache", $benchmark -m")

	--[[
		
		should expect values:
			{ "command", "arg1", "arg2" }
			
		from: "$command arg1 arg2"

		PackageManager:import("Enumify", "$nocache -g", "$benchmark \"tested\"")
	]]

	local testCommands = Commands.new({
		commandPrefix = "$",
		listBrackets = {"{", "}"},
		argumentSeperator = " ",
		commandNameSeperator = ".*", 
		flagSeperator = ":",
		listSeperator = ",",
		flagPrefix = "-",
		
		flags = {
			g = "global",
			m = "message"
		}

		--isPlayerCommands = false,

		--permissionLevels = {
		--	"basic", 
		--	"admin"
		--}
	})

	-- "$benchmark"

	return { 
		default = Commands 
	}
end
