local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Button = require(script.Parent.Button)
local Frame = require(script.Parent.Frame)
local Divider = require(script.Parent.Divider)
local Components = {
	Button = Button,
	Frame = Frame,
	Divider = Divider,
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
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["1"]),
			},

			[Children] = {
				Scope:Button {
					Content = { "Button" },
				},
				Scope:Button {
					Content = { "Button" },
					Color = Theme.Colors.BaseContent.Main,
				},
				Scope:Button {
					Content = { "Button" },
					Color = Theme.Colors.Primary.Main,
				},
				Scope:Button {
					Content = { "Button" },
					Style = "Outlined",
					Color = Theme.Colors.Primary.Main,
				},
				Scope:Button {
					Content = { "rbxassetid://11560341132", "Purchase" },
					Color = Color3.fromRGB(86, 255, 70),
				},
				Scope:Button {
					Content = { "rbxassetid://13405228418", "Delete" },
					Style = "Outlined",
					Color = Theme.Colors.Error.Main,
				},
				Scope:Button {
					Content = { "Ghost" },
					Style = "Ghost",
					Color = Theme.Colors.BaseContent.Main,
				},
				Scope:Button {
					Content = { "rbxassetid://11560341132", "Bobux" },
					Color = Color3.fromRGB(86, 255, 70),
					Disabled = true,
				},
				Scope:Button {
					Content = { "Testing" },
					Color = Color3.fromRGB(86, 255, 70),
					Disabled = true,
					Style = "Outlined",
				},
				Scope:Divider {},
				Scope:Frame {
					List = {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					},
					Padding = {
						All = Scope:UDim(0, Theme.Padding["1"]),
					},

					[Children] = {
						Scope:Button {
							Content = { "Button (xs)" },
							SizeVariant = "ExtraSmall",
							Color = Theme.Colors.Primary.Main,
						},
						Scope:Button {
							Content = { "Button (sm)" },
							SizeVariant = "Small",
							Color = Theme.Colors.Primary.Main,
						},
						Scope:Button {
							Content = { "Button (md)" },
							SizeVariant = "Medium",
							Color = Theme.Colors.Primary.Main,
						},
						Scope:Button {
							Content = { "Button (lg)" },
							SizeVariant = "Large",
							Color = Theme.Colors.Primary.Main,
						},
						Scope:Button {
							Content = { "Button (xl)" },
							SizeVariant = "ExtraLarge",
							Color = Theme.Colors.Primary.Main,
						},
					},
				},
			},
		}
	end,
	fusion = Fusion,
}
