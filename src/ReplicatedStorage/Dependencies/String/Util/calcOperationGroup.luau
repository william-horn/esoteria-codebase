
return function(import, pm)
	local StringMath = require(script.Parent.Parent.Enums.StringMath)
	local StringEscaper = require(script.Parent.Parent.Classes.StringEscaper)().default
	local doMathOp = require(script.Parent.doMathOp)()
	
	--[[
		@desc: Replaces all math operations of the same type in a string with their computed value
		@params: <string> str, <LocalEnum> ops
		@returns: <string> result
		
		Example:
			String:replaceWithCombinedOperationResult('1+2+3*4*5+6', StringEnum.Math.OperationType.Multiplication)
			
		output: 
			'1+2+60+6'
	]]
	local function calcOperationGroup(str, ops)
		local OperationType = StringMath.OperationType
		local opString

		if (ops == OperationType.Exponent) then
			opString = '^'
		elseif (ops == OperationType.Multiplication or ops == OperationType.Division) then
			opString = '*/'
		elseif (ops == OperationType.Addition or ops == OperationType.Subtraction) then
			opString = '+-'
		else
			error('OperationType is not recognized')
		end

		opString = StringEscaper.escapeMagicChars(opString)

		-- Saftey measure to stop negative numbers from being detected by the initial combined operations pattern
		-- This gets picked up by multiplication parsing: 3*2-5 when only 3*2 should pass.
		-- Now we turn 3*2-5 into 3*2+-5 to ensure just 3*2 passes.
		str = str:gsub('(%d)(%-[%d%.])', '%1+%2'):gsub('%-%-', '+')

		-- match and replace all consecutive math operations of the same type
		-- ex: matches '3*4*5' and '7*8' from '1+2+3*4*5+6+7*8'
		str = str:gsub('(%-?%d*%.?%d+['..opString..'])([%-?%.?%d'..opString..']+)', function(startSequence, subSequence)
			subSequence = startSequence .. subSequence

			-- keep track of the total as we run through the consecutive math operations
			local result = 0

			-- match the individual operations and compute them
			for a, op, b in subSequence:gmatch('(%-?%d*%.?%d*)(['..opString..'])(%-?%d*%.?%d+)') do
				a = tonumber(a)
				b = tonumber(b)

				if (not a) then
					result = doMathOp(result, op, b)
				else
					result = doMathOp(a, op, b)
				end
			end

			return tostring(result)
		end)

		return str
	end
	
	return calcOperationGroup
end