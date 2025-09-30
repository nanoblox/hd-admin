--[[

-- Commands Icon
:setImage(81506631564371, "deselected")
:setImage(111054392340110, "selected")
:setImageScale(0.55, "deselected")
:setImageScale(0.55, "selected")

]]

local main = script:FindFirstAncestor("MainModule")
local Icon = require(main.Value.Modules.Objects.Icon)

print("Create icon!")
return Icon.new()
	:setLabel("v2")
	:setImage(139559302589584, "deselected")
	:setImage(90888779036359, "selected")
	:setImageScale(0.45, "deselected")
	:setImageScale(0.45, "selected")
	:setOrder(0)