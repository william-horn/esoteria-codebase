
return function(import)
	return function()
		local util = import("@String/@Util/*")
		local enum = import("../@Enums/@StringMath/*")
	
		print("Util: ", util)
		print("trimLeft: ", "\"" .. util.trimLeft("     SHOULD TRIM LEFT") .. "\"")
		print("trimRight: ", "\"" .. util.trimRight("SHOULD TRIM RIGHT      ") .. "\"")
		print("trimAround: ", "\"" .. util.trimAround("       SHOULD TRIM AROUND      ") .. "\"")
		print("noSpace: ", "\"" .. util.noSpace("       SHOULD     REMOVE      ALL      ") .. "\"")
		print("splitWith: ", util.splitWith("a b c d", " "))
		print("splitWith (patterns)", util.splitWith("x y z w", "%s", { usePatterns = true }))
		print("doMathOp: ", util.doMathOp("4", "+", "5"))
		print("calcOperationGroup: ", util.calcOperationGroup("1+2+3", enum.OperationType.Addition))
		print("calcMathExpression: ", util.calcMathExpression("5+3/2"))
		print("vars: ", util.vars("$pi and $tau and $custom", { vars = { custom = 43 }}))
	end
end
