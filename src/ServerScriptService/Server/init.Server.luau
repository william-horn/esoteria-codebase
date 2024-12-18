--!nocheck
local PackageManager = require(game.ReplicatedStorage.QuickAccess.PackageManager)

local start = os.clock()
PackageManager.require(script.Main)
local fin = os.clock()

print(string.rep("-", 50))
print("server fin: ", fin - start)
-- print("import calls: ", PackageManager._importCalls)
