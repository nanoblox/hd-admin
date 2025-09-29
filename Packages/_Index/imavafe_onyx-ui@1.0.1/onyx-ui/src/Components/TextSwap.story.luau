local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Components = {
	TextSwap = require(OnyxUI.Components.TextSwap),
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
				Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			},

			[Children] = {
				Scope:TextSwap {
					Options = { "Hamburger", "Pizza", "Ice Cream" },
				},
				Scope:TextSwap {
					Options = { "Disabled" },
					Disabled = true,
				},
				Scope:TextSwap {
					Options = { "Cats", "Dogs", "Zebras" },
					Color = Theme.Colors.Primary.Main,
				},
			},
		}
	end,
	fusion = Fusion,
}
