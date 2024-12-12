--!nocheck
local PackageManager = require(game.ReplicatedStorage.PackageManager)

local start = os.clock()
PackageManager.require(script.Main)
local fin = os.clock()

print("server fin: ", fin - start)
print("import calls: ", PackageManager.getImportCalls())
