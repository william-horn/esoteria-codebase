
return function(import, pm)
	return function()
		local types = import("@Util/@Types/*")

		print("toBool: ", types.toBool(500), types.toBool("asd"))
		print("isUserdata: ", types.isUserdata(workspace), types.isUserdata({}))
		print("isTrue: ", types.isTrue(true), types.isTrue(false), types.isTrue(45))
		print("isTable: ", types.isTable({}), types.isTable(453))
		print("isString: ", types.isString(""), types.isString(345))
		print("isNumber: ", types.isNumber(false), types.isNumber(0))
		print("isNil: ", types.isNil(nil), types.isNil(), types.isNil(false))
		print("isModule: ", types.isModule(Instance.new("ModuleScript")), types.isModule(workspace))
		print("isInstance: ", types.isInstance(workspace), types.isInstance(0))
		print("isIndexable: ", types.isIndexable(newproxy()), types.isIndexable({}), types.isIndexable(workspace), types.isIndexable(0))
		print("isFunction: ", types.isFunction(function() end), types.isFunction(0))
		print("isFalse: ", types.isFalse(), types.isFalse(true), types.isFalse(""), types.isFalse(false))
		print("isBool: ", types.isBool(false), types.isBool(nil), types.isBool(true), types.isBool(0))
		print("bothAreTables: ", types.bothAreTables({}, {}), types.bothAreTables({}, 0))
		print("bothAreString: ", types.bothAreStrings("", ""), types.bothAreStrings("", 0))
		print("bothAreNumbers: ", types.bothAreNumbers(0, 0), types.bothAreNumbers(0, ""))
		print("bothAreInstances: ", types.bothAreInstances(Instance.new("Part"), Instance.new("Part")))
		print("bothAreIndexable: ", types.bothAreIndexable({}, {}), types.bothAreIndexable({}, 0))
		print("bothAreFunctions: ", types.bothAreFunctions(function() end, function() end), types.bothAreFunctions(function() end, 0))

		print(types)
	end
end