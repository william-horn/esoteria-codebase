
return function()
	
	--[[
		@desc: Takes an arithmatic math operation string such as '1+1' and computes the numeric value
		@params: <string> operand1, <string> operator, <string> operand2
		@returns: <number> result
	]]
	local function doMathOp(a, op, b)
		a = tonumber(a)
		b = tonumber(b)

		if (op == '/') then
			return a/b
		elseif (op == '*') then
			return a*b
		elseif (op == '^') then
			return math.pow(a, b)
		elseif (op == '+') then
			return a + b
		elseif (op == '-') then
			return a - b
		end

    return nil
	end
	
	return doMathOp
end
