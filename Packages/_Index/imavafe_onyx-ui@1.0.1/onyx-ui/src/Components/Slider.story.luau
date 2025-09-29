local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Components = {
	Slider = require(OnyxUI.Components.Slider),
	Frame = require(OnyxUI.Components.Frame),
}

return {
	story = function(Props)
		local Scope = Fusion.scoped(Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			Size = Scope:UDim2Offset(Theme.Sizing["16"], 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["1"]),
			},
			List = {
				Padding = Scope:UDim(0, Theme.Spacing["1"]),
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			},

			[Children] = {
				Scope:Slider {},
				Scope:Slider {
					Value = 1 / 10,
					Unit = 1 / 10,
					Color = Util.Colors.Cyan["500"],
				},
				Scope:Slider {
					Value = 1 / 4,
					Unit = 1 / 4,
					Color = Util.Colors.Fuchsia["500"],
				},
				Scope:Slider {
					Disabled = true,
				},
			},
		}
	end,
	fusion = Fusion,
}
