local Main = script:FindFirstAncestor("MainModule")
local TopbarPlus = require(Main.Value.Packages.TopbarPlus)
local HDAdminUI = require(script.UI)

local UIController = {}

HDAdminUI:Start()

local TopbarIcon = TopbarPlus.new()

TopbarIcon:bindEvent("deselected", function()
	HDAdminUI:ToggleOpen()
end)
TopbarIcon:oneClick()

return UIController
