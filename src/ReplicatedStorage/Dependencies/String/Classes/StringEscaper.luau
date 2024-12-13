--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	Lets you create custom escape characters.
	
	Create an escape ruleset by instantiating the StringEscaper:
	
		local Escaper = StringEscaper.new("/", {"!", "$"})
		local source = "hello/! world/$"
		
	To escape:
	
		local escaped = Escaper:escape(source) --> "hello\11\1 world\12\1"
		
	To unescape:
	
		local unescaped = Escaper:unescape(escaped) --> "hello world"
		
	! bug: 	
		Escaped strings will be effected by your parser if your parser is looking
		for the following kind of matches:
			- "\1" - anywhere
			- "%d" - specifically by itself, and with any quantifier
			
		However, this can be worked around by checking for a "\1" match
		in your parser. For example, consider this case:
		
			local string = StringEscaper:escape("match 10 all/,numbers 20")
			
		If we want to match all numbers while escaping "," by using "/", then we will
		run into a weird logic error because "/," will be converted to "\11\1" when escaped.
		
			Ex:
			
				for match in string:gmatch("%d+") do
					print("found number: ", match)
				end
				
			--> "found number: 10"
			--> "found number: 1" (from escaped substitution)
			--> "found number: 20"
			
		TODO: potentially add future options for "freezing" a string once escaped, then
		storing it's unescaped and escaped versions with a unique id to retrieve later.
		
			Ex: 
				"hello /$world test": give this to the parser --> "hello world test"
				
				save: [id] = "hello /$world test"
				
				unescape --> "hello $world test"
]]

return function(import)
	local isNumber = import("@Util/@Types/isNumber")
	local getVacantIndex = import("@Util/getVacantIndex")
	
	local StringEscaper = {}
	StringEscaper.__index = StringEscaper

	--[[
		StringEscaper.escapeMagicChars(text<string>):
		
		@desc:
			Escapes the magic characters in the text.
		@params:
			text<string>: the text to escape
		@returns:
			<string>: the escaped text
	]]
	function StringEscaper.escapeMagicChars(text)
		return text:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
	end

	--[[
		StringEscaper:escape(text<string>):
		
		@desc:
			Escapes the text using the escape characters defined
			in the object's instantiation.
		@params:
			text<string>: the text to escape
		@returns:
			<string>: the escaped text
	]]
	function StringEscaper:escape(text)
		for id, stringData in next, self.escaped do
			text = text:gsub(stringData.escapePattern, stringData.encoded)
		end

		return text
	end

	--[[
		StringEscaper:unescape(text<string>):
		
		@desc:
			Unescapes the text using the escape characters defined
			in the object's instantiation.
		@params:
			text<string>: the text to unescape
		@returns:
			<string>: the unescaped text
	]]
	function StringEscaper:unescape(text)
		for id, stringData in next, self.escaped do
			text = text:gsub(stringData.encoded, stringData.text)
		end

		return text
	end

	--[[
		StringEscaper:add(text<string>):
		
		@desc:
			Add a new string to the StringEscaper object.
		@params:
			text<string>: the text to add
		@returns:
			<number>: the id of the added text
	]]
	function StringEscaper:add(text)
		local stringData = self.escaped
		local stringToId = self._stringToId
		
		-- if added text already exists, then return out 
		if (stringToId[text]) then return end
		
		local id = getVacantIndex(stringData)
		local noMagicText = StringEscaper.escapeMagicChars(text)

		stringData[id] = {
			encoded = "\1" .. id .. "\1",
			text = text,
			noMagicText = noMagicText,
			escapePattern = self.prefix .. "(" .. noMagicText .. ")"
		}
		
		stringToId[text] = id
		return id
	end
	
	--[[
		StringEscaper:remove(text<string|number>):
		
		@desc:
			Removes the string from the StringEscaper object.
		@params:
			text<string|number>: the text or id to remove
		@returns:
			<nil>
	]]
	function StringEscaper:remove(text)
		local stringData = self.escaped
		local stringToId = self._stringToId
		
		local id = isNumber(text) and text or stringToId[text]

		-- ! error:
		-- If the id does not exist. This can happen if the user manually passes an 
		-- invalid id number as the text argument
		if (not id) then
			error("Invalid id passed to StringEscaper.remove(): Got \"" .. tostring(id) .. "\"")
		end

		stringData[id] = nil
		stringToId[text] = nil
	end

	--[[
		StringEscaper.new(prefix<string>, escapedString<table>):
		
		@desc:
			Creates a new StringEscaper object.
		@params:
			prefix<string>: the prefix to use for escaping
			escapedString<table>: the strings to escape
		@returns:
			<StringEscaper>: the StringEscaper object
	]]
	function StringEscaper.new(prefix, escaped)
		escaped = table.clone(escaped or {})

		local stringEscaper = setmetatable({}, StringEscaper)

		--[[
			dict that maps encoded/decoded string segments
			
			escaped: {
				[id] = {
					encoded<string> - the encoded escaped string,
					text<string> - the original string to escape,
					noMagicText<string> - original string but escaping magic characters,
					escapePattern<string> - the pattern to use for finding the escaped string
				},
				...
			}
			
			_stringToId: {
				[text<string>] = id<number>
			}
		]]
		stringEscaper._stringToId = {}
		stringEscaper.escaped = {}
		stringEscaper.prefix = prefix

		for index = 1, #escaped do
			stringEscaper:add(escaped[index])
		end
		
		-- include the escape prefix in with the strings to escape
		stringEscaper:add(prefix)
		return stringEscaper
	end

	return {
		default = StringEscaper
	}
end