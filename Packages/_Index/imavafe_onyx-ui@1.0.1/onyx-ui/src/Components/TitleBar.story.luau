local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local TitleBar = require(OnyxUI.Components.TitleBar)
local Frame = require(OnyxUI.Components.Frame)
local Components = {
	Frame = Frame,
	TitleBar = TitleBar,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			Size = Scope:UDim2Offset(Theme.Sizing["16"], 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["1"]),
			},
			List = {
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			},

			[Children] = {
				Scope:TitleBar {
					Content = { "Title" },
				},
				Scope:TitleBar {
					Content = { "rbxassetid://75029721407761", "Shop" },
				},
			},
		}
	end,
	fusion = Fusion,
}
