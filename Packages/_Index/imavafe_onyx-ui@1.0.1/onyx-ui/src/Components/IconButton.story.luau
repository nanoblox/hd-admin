local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)

local Children = Fusion.Children

local IconButton = require(script.Parent.IconButton)
local Frame = require(script.Parent.Frame)
local Components = {
	IconButton = IconButton,
	Frame = Frame,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["1"]),
			},
			List = {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			},

			[Children] = {
				Scope:IconButton {
					Image = "rbxassetid://10814531047",
				},
				Scope:IconButton {
					Image = "rbxassetid://10814531047",
					Color = Theme.Colors.Primary.Main,
				},
				Scope:IconButton {
					Image = "rbxassetid://11560341132",
					Color = Util.Colors.Amber["500"],
				},
				Scope:IconButton {
					Image = "rbxassetid://13405228418",
					Color = Util.Colors.Red["500"],
					Style = "Outlined",
				},
				Scope:IconButton {
					Image = "rbxassetid://13405228418",
					Color = Util.Colors.Red["500"],
					Style = "Ghost",
				},
				Scope:IconButton {
					Image = "rbxassetid://10814531047",
					Disabled = true,
				},
				Scope:IconButton {
					Image = "rbxassetid://10814531047",
					Style = "Ghost",
					Disabled = true,
				},
			},
		}
	end,
	fusion = Fusion,
}
