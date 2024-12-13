
return function(import)
	local calcMathExpression = import("@String/@Util/calcMathExpression")
	
	return {
		vars = {
			pi = math.pi,
			tau = math.pi*2,
		},

		functions = {
			eval = function(exp)
				return calcMathExpression(exp)
			end,
			floor = function(n)
				return math.floor(calcMathExpression(n))
			end,
			ceil = function(n)
				return math.ceil(calcMathExpression(n))
			end,
			min = function(a, b)
				return math.min(
					calcMathExpression(a),
					calcMathExpression(b)
				)
			end,
			max = function(a, b)
				return math.max(
					calcMathExpression(a),
					calcMathExpression(b)
				)
			end,
		}
	}
end