--!strict
-- This enables us to track when loadCharacter is called which is essential
-- for some tasks that need to check before a character is re-added
-- This is necessary thanks to shortcomings with deferred signals:
-- https://devforum.roblox.com/t/-/2842369/5

local Signal = require(script.Parent.Parent.Objects.Signal)
local loadCharacterStarted = Signal.new()
return loadCharacterStarted