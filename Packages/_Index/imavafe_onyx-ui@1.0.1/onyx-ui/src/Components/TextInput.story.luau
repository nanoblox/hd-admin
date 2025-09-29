local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local TextInput = require(script.Parent.TextInput)
local Frame = require(script.Parent.Frame)
local Components = {
	Frame = Frame,
	TextInput = TextInput,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			Size = UDim2.fromOffset(250, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			List = {
				Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			},
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["1"]),
			},

			[Children] = {
				Scope:TextInput {},
				Scope:TextInput {
					PlaceholderText = "Disabled TextInput.",
					Disabled = true,
				},
				Scope:TextInput {
					PlaceholderText = "Twenty characters only!",
					CharacterLimit = 20,
				},
				Scope:TextInput {
					PlaceholderText = "Something dangerous!",
					Color = Theme.Colors.Error.Main,
				},
			},
		}
	end,
	fusion = Fusion,
}
