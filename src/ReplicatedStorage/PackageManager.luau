--!nocheck
--[[
	@author: William J. Horn
	@written: 12/9/2024

	ScriptGuider@ROBLOX.com
	
	A super light-weight package manager for handling global dependency imports. This
	module mimmicks a weak version of CommonJS modules. 
	
	TODO: Add warning if multiple instance names exist in a directory
	TODO: Store and cache import path names. Store first part separetely, then search for the other secondary imports in a lookup table
	TODO: Before adding the import cache feature, benchmark the current usage of it to compare against the cached version
]]

-------------------------
---- ROBLOX SERVICES ---- 
-------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local ServerScriptService = game:GetService("ServerScriptService")
-- local PlayerService = game:GetService("Players")
-- local RunService = game:GetService("RunService")

----------------------
---- DEPENDENCIES ---- 
----------------------

local Path__Dependencies = ReplicatedStorage:WaitForChild("Dependencies")
local Path__UtilPackage = Path__Dependencies.Util

-- dependencies
local isString = require(Path__UtilPackage.Types.isString)()
local isTable = require(Path__UtilPackage.Types.isTable)()
local isInstance = require(Path__Dependencies.Util.Types.isInstance)()
local isModule = require(Path__Dependencies.Util.Types.isModule)()
local isFunction = require(Path__Dependencies.Util.Types.isFunction)()
local exists = require(Path__Dependencies.Util.Types.exists)()
--local Commands = require(Path__Dependencies.Commands)().default

--------------------------------
---- PACKAGE MANAGER MODULE ---- 
--------------------------------

local PackageManager = {}
PackageManager._importCalls = 0
PackageManager._rootDirectory = Path__Dependencies
--PackageManager._importCommands = Commands.new()

--[[
	* _require(module<ModuleScript>, withoutDefault<boolean>):

	@desc:
		! --> warning:
			_require must be called only AFTER 'PackageManager.import' is defined. This is because
			'PackageManager.import' is passed as an argument to the result of 'require(module)'
			if that result is a function.
		! <--

		The PackageManager's internal require function. This is a wrapper function that makes
		a call to Lua's 'require()' after some checks and reassignments. The purpose is to require
		a module while checking for the following:

			? If module return result is a FUNCTION
			? If module return result is a TABLE
			? if require ignores looking for a DEFAULT export

	@param module<ModuleScript>: The module to require
	@param withoutDefault<boolean>: Whether or not to look for a ".default" export, IF the module result is a table

	@return: The required module
]]
local function _require(module, withoutDefault)
	PackageManager._importCalls += 1

	-- native require
	local package = require(module)

	--[[
		? FYI:

		if module result is a function, then it is implied to be called with
		the package manager environment variables (import function, etc)
	]]
	if (isFunction(package)) then
		if (not PackageManager.import) then
			error("Tried using internal _require() before 'PackageManager.import' was defined (aborted call)")
		end

		package = package(PackageManager.import, PackageManager)
	end

	local packageIsTable = isTable(package)

	--[[
		? FYI:

		if the final returned result of the module is a table, then apply 'default'
		export check, where:

		? withoutDefault = false:
			return the literal module table

		? withDefault = true:
			return the 'module.default'
	]]
	if (packageIsTable and not withoutDefault and exists(package.default)) then
		return package.default

	elseif (packageIsTable and not withoutDefault) then
		error("Import failed. A default export was expected for package: \"" .. module.Name .. "\". Did you mean to use \"" .. module.Name .. "*\" instead?", 2)
	end

	--[[
		? FYI:

		if the returned module result is not a table, or it is a table but 'withoutDefault' is true, then
		just return the module result.
	]]

	return package
end

--[[
  * requireDirectory(dictionary<Instance>, withoutDefault<boolean>):

	@desc:
		Require an entire directory (a non-module instance). 

		? If directory is a MODULE:
			Pass it to the internal '_require' function with the 'withoutDefault' check.

		? If directory is a NON-MODULE:
			Check for a 'default' module as a child of the directory. If this module
			exists, then require it with internal '_require' but WITHOUT a 'default' check.
			Read more about why near the return statement.

	@param directory<Instance>: The directory to require

	@param withoutDefault<boolean>: 
		Whether to check for a '.default' after the require (only applied
		if the directory is a module)

	@return: The result of the required directory
]]
local function requireDirectory(directory, withoutDefault)
	-- ! error:
	-- If module is not an instance
	if (not isInstance(directory)) then
		error("Could not require directory. Instance expected, got: \"" .. type(directory) .. "\"", 2)
	end

	-- Case 1: Directory is a module
	if (isModule(directory)) then
		return {
			module = _require(directory, withoutDefault),
			moduleWasRequired = true
		}
	end

	-- Case 2: Directory is a module
	local defaultExport = directory:FindFirstChild("default")
	local defaultExists = exists(defaultExport) and isModule(defaultExport)

	--[[
		? FYI:

		if a 'default' module is found within a folder, then require it without looking for
		a 'default' export inside the return of the module. This is because the module itself
		is the implied 'default' return value. Thus, why we do _require(module, true) here.
	]]
	if (defaultExists and not withoutDefault) then
		return {
			module = _require(defaultExport, true),
			moduleWasRequired = true
		}

	elseif (not defaultExists and withoutDefault) then
		warn("Directory \"" .. directory.Name .. "\" tried to be required, but it has no default export module. Attempt aborted.")

		return {
			module = nil,
			moduleWasRequired = false
		}

	-- ! error:
	-- If default module is nil or not a module script, and a default is required
	else
		error("Failed to import from file: \"" .. directory.Name .. "\" (file does not contain a default export module)", 2)
	end
end

--[[
	* requireAllChildDirectories(dir<Instance>):

	@desc:
		Require all child directories of a given directory. 

		Rules:

		? import("@Folder/*"):
			Represents a TABLE of all REQUIRED modules in the directory. For example, given this
			object structure:
			
			Parent<Folder>
				|
				- ChildFolder<Folder>
					|
					- default<ModuleScript>
				|
				- ChildModule<ModuleScript>

			Calling:
				? import("@Parent/*")

			Will return a table with this structure:

				Packages<table>: {
					ChildFolder: <require(ChildFolder.default)>
					ChildModule: <require(ChildModule)>
				}
			
			So, to index a package in this table, you must do:

				? import("@Parent/*/ChildModule")

			Which is inferred to mean: Packages.ChildModule. This will NOT reference a 'default' export
			inside 'ChildModule' like we would expect with a singular import. If you want to reference 
			the default export, you must do either of these calls:

				? import("@Parent/*/ChildModule/.")
				? import("@Parent/*/ChildModule/default")

	@param dir<Instance>: The directory to require the child directories from
	@return requiredDirectories<table>: A table of all required child directories
]]
local function requireAllChildDirectories(dir)
	local package = {}

	for childName, child in next, dir:GetChildren() do
		local requiredDirectory = requireDirectory(child, true)

		if (requiredDirectory.moduleWasRequired) then
    	package[child.Name] = requiredDirectory.module
		end
	end

	return package
end

local function getReplacedSegment(segment)
	return segment:gsub("^%.$", "default")
end

-- TODO: This is for returning the module hierarchy with '**' path segment - not implemented yet
-- local function requireAllDescendants(dir)
-- 	local package = {}

-- 	return package
-- end

--[[
	* parsePathSegmentInfo(segment<string>):

	@desc:
		# Parses out segment modifiers in a path segment, including:

			? withoutDefault: "*" 
				- Appears at the end of a segment, implying to ignore a ".default" check

			? withoutRequire: "@" 
				- Appears at the beginning of a segment, implying to treat the segment as a path location
					and not a module to require

			? default: "." 
				- Exclusively, which is just short-hand for writing "default"

		# Also determines if a path segment is a special representation, such as:

			? isBackDirectory: ".."
				- If segment is moving up the directory tree
			
			? ifAllChildren: "*"
				- If segment is selecting all children of a directory

			? isAllDescendants: "**"
				- If segment is selecting all descendants of a directory

	@param segment<string>: The path segment to parse

	@return newSegment<string>: The modified path segment, with booleans
]]
local function parsePathSegmentInfo(segment)
	-- booleans indicating if a parse occured
	local withoutRequire
	local withoutDefault
	local parsedSegment

	-- segment parsing
	parsedSegment, withoutRequire = segment:gsub("^@", "")
	parsedSegment, withoutDefault = parsedSegment:gsub("%*$", "")
	parsedSegment = getReplacedSegment(parsedSegment)

	return {
		parsedSegment = parsedSegment,

		withoutDefault = withoutDefault > 0,
		withoutRequire = withoutRequire > 0,

		isBackDirectory = segment == "..",
		isAllChildren = segment == "*",
		isAllDescendants = segment == "**", 
	}
end

--[[
	* interpretImportPath(dir<Instance>, pathname<string):

	@desc:
		Determine what should be returned from an import path. All unique
		permutations of an import path are documented inside this module's README.

		An import path is not the same as a location path, such as: "Parent/Child/Child". 
		interpretImportPath() interprets special path segment modifiers and selectors, and
		the goal is to call PackageManager's internal _require() function on the endpoint 
		of the path.

	@param dir<Instance>: The root directory to begin pathing from

	@param pathname<string>: The special import path string

	@return: importResult<DirectoryInstance|table>
]]
local function interpretImportPath(dir, pathname)
	for segment in pathname:gmatch("[^/]+") do
		--[[
			? FYI: 

			`isTable(dir)` is used to determine how the rest of the path should be interpreted. If
			the current directory is a table, then we should be indexing a table for the subsequent
			path segments. Otherwise, the directory should be an instance.
		]]
		if (not isTable(dir)) then
			-- Directory HAS NOT been required beyond this point -- 
			local segmentInfo = parsePathSegmentInfo(segment)
			local child = dir:FindFirstChild(segmentInfo.parsedSegment)

			-- Escape requiring a module with '@'
			if (segmentInfo.withoutRequire and child) then
				dir = child
				continue
			end

			-- Travel back a directory using '..'
			if (segmentInfo.isBackDirectory and dir.Parent) then
				dir = dir.Parent
				continue

			-- ! error:
			-- If path segment is a back directory but the next directory up doesn't exist
			elseif (segmentInfo.isBackDirectory) then
				error("Cannot cd to parent of: \"" .. dir.Name .. "\" (parent does not exist)", 2)
			end

			-- wild card "*"
			if (segmentInfo.isAllChildren) then
				dir = requireAllChildDirectories(dir)
				continue
			end

			-- ! error:
			-- If the child retrieved per the path segment does not exist in the directory
			if (not child) then
				error("Import failed. Could not find path segment: \"" .. segmentInfo.parsedSegment .. "\" in directory: \"" .. dir.Name .."\"", 2)
			end

			local requiredDirectory = requireDirectory(child, segmentInfo.withoutDefault)

			-- ! error:
			-- The required directory failed to locate and require a module.
			if (not requiredDirectory.moduleWasRequired) then
				error("Import failed. The directory \"" .. child.Name .. "\" does not contain a module to require.")
			end

			dir = requiredDirectory.module
			continue
		end

		-- filter the segment for any replacements needed
		segment = getReplacedSegment(segment)

		-- Directory HAS been required beyond this point --
		if (exists(dir[segment])) then
			dir = dir[segment]
			continue

		-- ! error:
		-- If path segment does not exist in directory table
		else
			error("Path segment \"" .. segment .. "\" does not exist in module table", 2)
		end
	end

	return dir
end

--[[
	* getLocation(dir<Instance>, pathname<string>):

	@desc:
		Get the location of an instance from a root directory through a given
		path. Path uses standard "/" syntax. Ex: "game/Workspace/Baseplate"

	@param dir<Instance>: The root directory to path from

	@param pathname<string>: The path of the instance to locate

	@return location<Instance>:
		The location of the instance at the provided path
]]
local function getLocation(dir, pathname)
	for segment in pathname:gmatch("[^/]+") do
		local isBackDirectory = segment == ".."
		
		-- If directory is ".." move up a level
		if (isBackDirectory and dir.Parent) then
			dir = dir.Parent
			continue

		-- ! error:
		-- If back directory doesn't exist
		elseif (isBackDirectory) then
			error("Cannot cd to parent of \"" .. dir.Name .. "\" (a nil value)")
		end
		
		local child = dir:FindFirstChild(segment)
		
		-- ! error:
		-- If there is no child found in the directory given the path segment
		if (not child) then
			error("Cannot cd to child (\"" .. tostring(segment) .. "\" is not a child of \"" .. tostring(child) .. "\")")
		end
		
		dir = child
	end
	
	return dir
end

--[[
	* import(rootDirectory<Instance>, location<string>, ...importParams<string>):

	@desc:
		Import a module or module from a directory. A root directory must be given, and the
		location to path from. The rest of the arguments index the location and return
		the required module results.

	@param rootDirectory<Instance>: The directory to get the location from
	@param location<string>: The relative path to the root directory
	@param ...importParams<string>: The path names relative to the location

	@return ...requiredModules<any>:
		The returned result from the required modules of the import
]]
local function import(rootDirectory, location, ...)
	-- local importCommands = self._importCommands
	-- local importCommands = PackageManager._importCommands

	local export = {}
	local importParams = {...}

	local cd = interpretImportPath(rootDirectory, location)

	-- if no import params are given, return the directory's default export
	if (#importParams == 0) then
		return cd
	end

	--if import params are given, return the file's export
	for _, param in next, importParams do
		-- ! error:
		-- If any import param is not a string
		if (not isString(param)) then
			error("Invalid import parameter. Got type: \"" .. typeof(param) .. "\" (expected string). Value: \"" .. tostring(param) .. "\"")
		end

		--if (importCommands:hasCommandPrefix(param)) then
		--	importCommands:run(param)
		--else
		--	export[#export + 1] = getPathResult(cd, param)
		--end
		export[#export + 1] = interpretImportPath(cd, param)
	end

	return unpack(export)
end

--[[
	-------------------------------
	| # The PackageManager bundle |
	-------------------------------
]]
do
	local function pm_import(location, ...)
		return import(PackageManager._rootDirectory, location, ...)
	end

	local function pm_from(path)
		local o = {}
		local root

		if (not isInstance(path)) then
			root = getLocation(PackageManager._rootDirectory, path)
		else
			root = path
		end

		o.location = path

		local function import_from(...)
			local export = {}

			for _, fromPath in next, {...} do
				export[#export + 1] = interpretImportPath(root, fromPath)
			end

			return unpack(export)
		end

		o.import = import_from
		return o
	end

	PackageManager.import = pm_import
	PackageManager.from = pm_from
end

function PackageManager:getImportCalls()
	return self._importCalls
end

PackageManager.require = _require

return PackageManager
