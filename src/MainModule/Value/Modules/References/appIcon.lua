--[[

-- Commands Icon
:setImage(81506631564371, "deselected")
:setImage(111054392340110, "selected")
:setImageScale(0.55, "deselected")
:setImageScale(0.55, "selected")

]]

local main = script:FindFirstAncestor("MainModule")
local Icon = require(main.Value.Modules.Objects.Icon)
return Icon.new()
	:setImage(139559302589584, "deselected")
	:setImage(90888779036359, "selected")
	:setImageScale(0.45, "deselected")
	:setImageScale(0.45, "selected")
	:bindToggleItem(mainFrame)
	:setOrder(0)
	:setEnabled(false)