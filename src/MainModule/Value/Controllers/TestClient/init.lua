--!strict

-- Local
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local Icon = require(modules.Objects.Icon)

local TestController = {}

-- Test stuff
--[[
local clientUser = require(modules.References.clientUser)
local someData = clientUser.perm:fetchAsync("SomeSavedTable", "SomeDataInThatTable")
clientUser.perm:observe("Rank", function(value)
	print("Rank =", value)
end)
clientUser.everyone:observe("TotalPlayers", function(value)
	print("TotalPlayers =", value)
end)
--]]

local Icon = require(modules.Objects.Icon)
local icon = Icon.new()

icon:setLabel("Test v2")

return TestController
