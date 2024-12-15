
return function(import, global, pm)
	local enums = game.ReplicatedStorage.Enums
	local StringMath = enums.StringMath

	local this = pm.from(script)

	local calcOperationGroup = this.import("../calcOperationGroup")
	local noSpace = this.import("../noSpace")
	
	--[[
		@desc: Takes a math expression and returns the numeric result
		@params: <string> expression
		@returns: <number> result
	]]
	local function calcMathExpression(expression)
		expression = noSpace(expression)
		local OperationType = StringMath.OperationType

		local function evaluate(exp)
			-- Replace all parenthesis first by recursively checking for parenthesis pairs.
			-- Then replace parenthesis with the evaluated result
			local result, count = exp:gsub('(%b())', function(subExp)
				return evaluate(subExp:sub(2, -2))
			end)

			-- If a parenthesis pair was found, we must re-evaluate the expression with the new parenthesis result.
			-- Else, perform all math operations and return the result
			if (count > 0) then
				return evaluate(result)
			else
				-- Compute the expression following the order of operations
				local combinedExponent = calcOperationGroup(result, OperationType.Exponent)
				local combinedMult = calcOperationGroup(combinedExponent, OperationType.Multiplication)
				local combinedAdd = calcOperationGroup(combinedMult, OperationType.Addition)

				return combinedAdd
			end
		end

		return tonumber(evaluate(expression))
	end
	
	return calcMathExpression
end
