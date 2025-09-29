local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)

local Children = Fusion.Children

local Frame = require(script.Parent.Frame)
local ProgressBar = require(script.Parent.ProgressBar)
local Text = require(script.Parent.Text)
local Components = {
	Frame = Frame,
	ProgressBar = ProgressBar,
	Text = Text,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		local Progress = Scope:Value(0)
		local Color = Scope:Value(Color3.fromRGB(255, 0, 0))

		local ColorThread = task.spawn(function()
			while task.wait(1) do
				Progress:set(math.random(0, 1000) / 1000)
				Color:set(ColorUtils.Rotate(Fusion.peek(Color), 100))
			end
		end)

		Scope:innerScope({
			function()
				task.cancel(ColorThread)
			end,
		})

		Scope:Frame {
			Parent = Props.target,
			List = {
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				Padding = Scope:UDim(0, Theme.Spacing["1.5"]),
			},

			[Children] = {
				Scope:Frame {
					List = {
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
						Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					},

					[Children] = {
						Scope:Text {
							Text = "Horizontal",
						},
						Scope:ProgressBar {
							Progress = 0.75,
						},
						Scope:ProgressBar {
							Progress = Progress,
							Color = Color,
						},
					},
				},
				Scope:Frame {
					List = {
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
						Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					},

					[Children] = {
						Scope:Text {
							Text = "With text",
						},
						Scope:Frame {
							List = {
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
							},

							[Children] = {
								Scope:Text {
									Text = "HP",
								},
								Scope:ProgressBar {
									Progress = Progress,
									Color = Util.Colors.Red["500"],
									FlexMode = Enum.UIFlexMode.Fill,
								},
							},
						},
					},
				},
				Scope:Frame {
					List = {
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
						Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					},

					[Children] = {
						Scope:Text {
							Text = "Inverted",
						},
						Scope:ProgressBar {
							Progress = Progress,
							Inverted = true,
						},
					},
				},
				Scope:Frame {
					List = {
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
						Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
					},

					[Children] = {
						Scope:Text {
							Text = "Vertical",
						},
						Scope:Frame {
							List = {
								FillDirection = Enum.FillDirection.Horizontal,
								Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
							},

							[Children] = {

								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Inverted = true,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Inverted = true,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Inverted = true,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Inverted = true,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Color = Color,
								},
								Scope:ProgressBar {
									Direction = Enum.FillDirection.Vertical,
									Progress = Progress,
									Inverted = true,
									Color = Color,
								},
							},
						},
					},
				},
			},
		}
	end,
	fusion = Fusion,
}
