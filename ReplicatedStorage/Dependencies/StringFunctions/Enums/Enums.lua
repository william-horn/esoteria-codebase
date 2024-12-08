local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Path__Dependencies = ReplicatedStorage.Dependencies

local Package__Enumify = require(Path__Dependencies.Enumify)
local EnumifyDirectory = Package__Enumify.EnumifyDirectory

return EnumifyDirectory(script)
