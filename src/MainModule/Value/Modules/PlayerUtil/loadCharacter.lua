--!strict
-- This enables us to track when loadCharacter is called which is essential
-- for some tasks that need to check before a character is re-added
-- This is necessary thanks to shortcomings with deferred signals:
-- https://devforum.roblox.com/t/-/2842369/5

local loadCharacterStarted = require(script.Parent.loadCharacterStarted)
local function loadCharacter(player: Player?)
	if player then
		loadCharacterStarted:fire(player)
		player:LoadCharacter()
	end
end
return loadCharacter