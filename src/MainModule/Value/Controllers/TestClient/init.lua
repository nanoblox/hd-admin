--!strict

-- Local
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local Icon = require(modules.Objects.Icon)

local TestController = {}

-- Test stuff
--[[
local clientUser = require(modules.References.clientUser)
clientUser.perm:observe("Cash", function(value)
	print("CASH (on client) =", value)
end)
clientUser.everyone:observe("Test", function(value)
	print("SERVER TIME (on client) =", value)
end)
--]]

local icon = Icon.new()

icon:setLabel("Test v2")

return TestController
