--!strict

-- Local
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local UI = require(main.Value.Controllers.UI)
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
icon:bindEvent("deselected", function()
	UI:ToggleOpen()
end)
icon:oneClick()

return TestController
