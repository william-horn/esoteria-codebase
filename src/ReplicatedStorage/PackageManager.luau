--!nocheck
--[[
	@author: William J. Horn
	@written: 12/9/2024
	
	A super light-weight package manager for handling global dependency imports. This
	module mimmicks a weak version of CommonJS modules. 
	
	TODO:
		- add warning for if multiple instance names exist in a directory
    - store and cache import path names. store first part separetely, then search for the other
      secondary imports in a lookup table

  - Any code indentation abnormalities are due to a weird issue with syncing
    between Rojo and ROBLOX
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local ServerScriptService = game:GetService("ServerScriptService")
-- local PlayerService = game:GetService("Players")
-- local RunService = game:GetService("RunService")

local Path__Dependencies = ReplicatedStorage:WaitForChild("Dependencies")
local Path__UtilPackage = Path__Dependencies.Util

-- dependencies
local isString = require(Path__UtilPackage.Types.isString)()
local isTable = require(Path__UtilPackage.Types.isTable)()
local isInstance = require(Path__Dependencies.Util.Types.isInstance)()
local isModule = require(Path__Dependencies.Util.Types.isModule)()
local isFunction = require(Path__Dependencies.Util.Types.isFunction)()
--local Commands = require(Path__Dependencies.Commands)().default

local PackageManager = {}

PackageManager._importCalls = 0

-- must be called only after PackageManager.import is defined
local function _require(module, withoutDefault)
  PackageManager._importCalls += 1

  -- raw require the module
  local package = require(module)

  --[[
    if module result is a function, then it is implied to be called with
    the package manager environment variables (import function, etc)
  ]]
  if (isFunction(package)) then
    package = package(PackageManager.import, PackageManager)
  end

  local packageIsTable = isTable(package)
		
  --[[
    if the final returned result of the module is a table, then apply 'default'
    export check, where:

      withoutDefault = false:
        return the literal module table
      
      withDefault = true:
        return the 'module.default'
  ]]
  if (packageIsTable and not withoutDefault and package.default ~= nil) then
    return package.default
    
  elseif (packageIsTable and not withoutDefault) then
    error("Import failed. A default export was expected for package: \"" .. module.Name .. "\"", 2)
  end

  --[[
    if the returned module result is not a table, or it is a table but 'withoutDefault' is true, then
    just return the module result.
  ]]
  return package
end

do
	-- ROOT IMPORT DIRECTORY --
	local rootDirectory = Path__Dependencies
	PackageManager._rootDirectory = rootDirectory
	
	-- package manager import commands
	--PackageManager._importCommands = Commands.new()
end


--do
--	-- DEFINE PACKAGE MANAGER IMPORT COMMANDS --
--	local importCommands = PackageManager.importCommands
	
--	importCommands:add("nocache", {
--		execute = function(package)
--			print("Nocache command called")
--		end,
--	})

--	importCommands:add("benchmark", {
--		execute = function(package)
--			print("Benchmark command called")
--		end,
--	})
--end

--[[
  requireDirectory(dictionary<Instance>, withoutDefault<boolean>):

  @desc:
    Require an entire directory (a non-module instance). 

    If directory is a MODULE:
      Pass it to the custom '_require' function with the 'withoutDefault' check.

    If directory is a NON-MODULE:
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
	if (not isInstance(directory)) then
		error("Could not require directory. Instance expected, got: \"" .. type(directory) .. "\"", 2)
	end
	
	-- CASE 1: DIRECTORY IS A MODULE
	if (isModule(directory)) then
		return _require(directory, withoutDefault)
	end
	
	-- CASE 2: DIRECTORY IS NOT A MODULE
	local defaultExport = directory:FindFirstChild("default")
	
  -- if module exists and it's type is a ModuleScript
	if (defaultExport == nil or not isModule(defaultExport)) then
		error("Failed to import from file: \"" .. directory.Name .. "\" (file does not contain a default export module)", 2)
	end

  --[[
    if a 'default' module is found within a folder, then require it without looking for
    a 'default' export inside the return of the module. This is because the module itself
    is the implied 'default' return value. Thus, why we do _require(module, true) here.
  ]]
	return _require(defaultExport, true)
end

--[[
  requireAllChildDirectories(dir<Instance>):

  @desc:
    Require all child directories of a given directory. 
]]
local function requireAllChildDirectories(dir)
	local package = {}

  --[[
    @rules:

    import("@Folder/*") -- represents a TABLE of all REQUIRED modules in the directory

    So, to index a package in this table, you must do:

    import("@Folder/*/Module")

    Which is inferred to mean: { packages }.Module

    If you want the default export of 'Module' from this table, you must do either of these:

    import("@Folder/*/Module/.")
    import("@Folder/*/Module/default")
  ]]
	for moduleName, module in next, dir:GetChildren() do
		-- if (isModule(module)) then
			-- package[module.Name] = _require(module)
      package[module.Name] = requireDirectory(module, true)
		-- end 
	end

	return package
end

-- TODO: this is for returning the module hierarchy with '**' path segment - not implemented yet
-- local function requireAllDescendants(dir)
-- 	local package = {}

-- 	return package
-- end

local function parsePathSegmentName(segment)
	local esc
	local mod

	segment, esc = segment:gsub("^@", "")
	segment, mod = segment:gsub("%*$", "")
	segment = segment:gsub("^%.$", "default")

	return segment, esc > 0, mod > 0
end

local function interpretPathSegment(segment)
	return {
		isBackDirectory = segment == "..",
		isAllChildren = segment == "*",
		isAllDescendants = segment == "**", -- potentially change this to "_*"
		isDefault = segment == "default"
	}
end

local function getPathResult(dir, pathname)
  -- parse the path string
  for segment in pathname:gmatch("[^/]+") do
    local dirIsTable = isTable(dir)
    local segmentName, withoutRequire, withoutDefault = parsePathSegmentName(segment)

    -- DIRECTORY HAS BEEN REQUIRED BEYOND THIS POINT --
    if (dirIsTable and dir[segmentName] ~= nil) then
      -- throw error if "*" is used on a required directory segment
      if (withoutDefault) then 
        error("The 'ignore default export' modifier (*) does nothing in segment \"" .. segment .. "\" - directory is already required") 
      end

      dir = dir[segmentName]
      continue

    elseif (dirIsTable) then
      error("Path segment \"" .. segmentName .. "\" does not exist in directory", 2)
    end

    -- DIRECTORY HAS NOT BEEN REQUIRED YET BEYOND THIS POINT -- 
    local child = dir:FindFirstChild(segmentName)
    local segmentType = interpretPathSegment(segment)

    -- is escaping require by using "@"
    if (withoutRequire and child) then
      dir = child
      continue
    end

    -- back directory "../"
    if (segmentType.isBackDirectory and dir.Parent) then
      dir = dir.Parent
      continue

    elseif (segmentType.isBackDirectory) then
      error("Cannot cd to parent of: \"" .. dir.Name .. "\" (parent does not exist)", 2)
    end

    -- wild card "*"
    if (segmentType.isAllChildren) then
      dir = requireAllChildDirectories(dir)
      continue
    end

    --[[
      import("dir") --> implies: "require(dir).default"
      import("dir*") --> implies: "require(dir)"

      import("folder") --> implies: "require(dir.default)"
    ]]

    -- child not found in directory
    if (not child) then
      error("Import failed. Could not find path segment: \"" .. segmentName .. "\"", 2)
    end

    -- SEGMENT WAS SUCCESSFULLY REQUIRED -- 
    local requiredDirectory = requireDirectory(child, withoutDefault)
    dir = requiredDirectory
  end

  return dir
end

local function getLocation(dir, pathname)
	for segment in pathname:gmatch("[^/]+") do
		local isBackDirectory = segment == ".."
		
		if (isBackDirectory and dir.Parent) then
			dir = dir.Parent
			continue
		elseif (isBackDirectory) then
			error("Cannot cd to parent of \"" .. dir.Name .. "\" (a nil value)")
		end
		
		local child = dir:FindFirstChild(segment)
		
		if (not child) then
			error("Cannot cd to child (\"" .. tostring(segment) .. "\" is not a child of \"" .. tostring(child) .. "\")")
		end
		
		dir = child
	end
	
	return dir
end

local function import(rootDirectory, location, ...)
	--local importCommands = self._importCommands
	-- local importCommands = PackageManager._importCommands

	local export = {}
	local importParams = {...}

	local cd = getPathResult(rootDirectory, location)

	--if no import params are given, return the directory's default export
	if (#importParams == 0) then
		return cd
	end

	--if import params are given, return the file's export
	for _, param in next, importParams do
		if (not isString(param)) then
			error("Invalid import parameter. Got type: \"" .. typeof(param) .. "\" (expected string). Value: \"" .. tostring(param) .. "\"")
		end

		--if (importCommands:hasCommandPrefix(param)) then
		--	importCommands:run(param)
		--else
		--	export[#export + 1] = getPathResult(cd, param)
		--end
		export[#export + 1] = getPathResult(cd, param)
	end

	return unpack(export)
end

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

    local function from_import(...)
      return import(root, ...)
    end

    o.from = from_import
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
