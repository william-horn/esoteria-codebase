
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Path__Dependencies = ReplicatedStorage.Dependencies
local GlobalEnums = require(Path__Dependencies.Enums)

local Package__Network = require(Path__Dependencies.Network)
local Network = Package__Network.Network:listen()

local Package__EventSignal = require(Path__Dependencies.EventSignal)
local Event = Package__EventSignal.Event

local PlayerManager = require(script.PlayerManager):listen()


