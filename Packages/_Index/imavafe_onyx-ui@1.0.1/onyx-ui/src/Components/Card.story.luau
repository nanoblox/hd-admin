local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)

local Children = Fusion.Children

local Frame = require(OnyxUI.Components.Frame)
local Card = require(OnyxUI.Components.Card)
local Text = require(OnyxUI.Components.Text)
local Divider = require(OnyxUI.Components.Divider)
local Components = {
	Frame = Frame,
	Divider = Divider,
	Text = Text,
	Card = Card,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			Size = UDim2.fromOffset(300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			List = {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
			},

			[Children] = {
				Scope:Card {
					Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 75)),
					AutomaticSize = Enum.AutomaticSize.None,
				},
				Scope:Card {
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					List = {
						Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					},

					[Children] = {
						Scope:Text {
							Text = "Title",
							TextSize = Theme.TextSize["1.25"],
							FontFace = Scope:Font(Theme.Font.Heading, Theme.FontWeight.Heading),
						},
						Scope:Divider {},
						Scope:Text {
							Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
						},
					},
				},
			},
		}
	end,
	fusion = Fusion,
}
