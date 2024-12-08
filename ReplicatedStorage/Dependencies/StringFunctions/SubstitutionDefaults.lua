
local Package__StringFunctions = require(script.Parent)
local String = Package__StringFunctions.StringFunctions

return {
	vars = {
		pi = math.pi,
		tau = math.pi*2,
	},
	
	functions = {
		eval = function(exp)
			return String:getResultFromMathExpression(exp)
		end,
		floor = function(n)
			return math.floor(String:getResultFromMathExpression(n))
		end,
		ceil = function(n)
			return math.ceil(String:getResultFromMathExpression(n))
		end,
		min = function(a, b)
			return math.min(
				String:getResultFromMathExpression(a),
				String:getResultFromMathExpression(b)
			)
		end,
		max = function(a, b)
			return math.max(
				String:getResultFromMathExpression(a),
				String:getResultFromMathExpression(b)
			)
		end,
	}
}
