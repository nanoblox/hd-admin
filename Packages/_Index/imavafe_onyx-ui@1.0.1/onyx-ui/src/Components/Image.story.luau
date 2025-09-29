local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Frame = require(OnyxUI.Components.Frame)
local Image = require(OnyxUI.Components.Image)
local Components = {
	Frame = Frame,
	Image = Image,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			AutomaticSize = Enum.AutomaticSize.XY,
			List = {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
			},

			[Children] = {
				Scope:Image {
					Image = "rbxassetid://15307540148",
				},
				Scope:Image {},
				Scope:Image {
					FallbackImage = "rbxassetid://13193902400",
				},
			},
		}
	end,
	fusion = Fusion,
}
