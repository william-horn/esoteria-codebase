
return function(import)
	local getResultFromMathExpression = import("@String/@Util/calcMathExpression")
	
	return {
		vars = {
			pi = math.pi,
			tau = math.pi*2,
		},

		functions = {
			eval = function(exp)
				return getResultFromMathExpression(exp)
			end,
			floor = function(n)
				return math.floor(getResultFromMathExpression(n))
			end,
			ceil = function(n)
				return math.ceil(getResultFromMathExpression(n))
			end,
			min = function(a, b)
				return math.min(
					getResultFromMathExpression(a),
					getResultFromMathExpression(b)
				)
			end,
			max = function(a, b)
				return math.max(
					getResultFromMathExpression(a),
					getResultFromMathExpression(b)
				)
			end,
		}
	}
end