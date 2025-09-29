local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Heading = require(script.Parent.Heading)
local Frame = require(script.Parent.Frame)
local Text = require(script.Parent.Text)
local Components = {
	Heading = Heading,
	Text = Text,
	Frame = Frame,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			List = {
				Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			},

			[Children] = {
				Scope:Heading {
					Parent = Props.target,
					Text = "Heading",
				},
				Scope:Text {
					Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
				},
			},
		}
	end,
	fusion = Fusion,
}
