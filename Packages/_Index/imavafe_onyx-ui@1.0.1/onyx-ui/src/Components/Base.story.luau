local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)
local Components = require(OnyxUI.Components)

local Children = Fusion.Children

return {
	story = function(Props)
		local Theme = Themer.Theme:now()
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)

		Scope:Base {
			Parent = Props.target,
			BackgroundTransparency = 1,
			List = {},
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["1"]),
			},

			[Children] = {
				Scope:Base {
					ClassName = "Frame",
					Size = UDim2.fromOffset(100, 100),
					Corner = {
						-- Enabled = false,
						Radius = UDim.new(0, 100),
					},
					Padding = {
						Left = UDim.new(0, 50),
					},
					Stroke = {
						Thickness = 5,
						Color = Color3.fromRGB(255, 0, 0),
					},
				},
				Scope:Base {
					ClassName = "Frame",
					AutomaticSize = Enum.AutomaticSize.XY,
					Padding = {
						All = UDim.new(0, 30),
						Left = UDim.new(0, 10),
					},
					List = {
						Padding = UDim.new(0, 15),
					},

					[Children] = {
						Scope:Base {
							ClassName = "TextButton",
							Size = UDim2.fromOffset(200, 50),
							BackgroundColor3 = Color3.fromRGB(255, 0, 0),
							Stroke = {
								Thickness = 3,
								ApplyMode = Enum.ApplyStrokeMode.Border,
								Transparency = 0.5,
								LineJoinMode = Enum.LineJoinMode.Miter,
							},
						},
						Scope:Base {
							ClassName = "TextButton",
							Size = UDim2.fromOffset(200, 50),
							BackgroundColor3 = Color3.fromRGB(255, 0, 0),
							Text = "Button",
							Scale = {
								Scale = 0.95,
							},
							Stroke = {
								Thickness = 3,
								Color = Color3.fromRGB(0, 0, 0),
								ApplyMode = Enum.ApplyStrokeMode.Border,
							},
							Corner = {
								Radius = UDim.new(0, 15),
							},
							Gradient = {
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
								}),
								Rotation = 90,
								Transparency = NumberSequence.new(0, 0.5),
							},
						},
						Scope:Base {
							ClassName = "TextButton",
							Size = UDim2.fromOffset(200, 50),
							BackgroundColor3 = Color3.fromRGB(255, 0, 0),
							Stroke = {
								Thickness = 3,
								ApplyMode = Enum.ApplyStrokeMode.Border,
							},
							Aspect = {
								Ratio = 1,
								DominantAxis = Enum.DominantAxis.Height,
								AspectType = Enum.AspectType.ScaleWithParentSize,
							},
						},
					},
				},
				Scope:Base {
					ClassName = "Frame",
					Size = UDim2.fromOffset(200, 200),
					BackgroundColor3 = Color3.fromRGB(255, 0, 0),
					Grid = {
						CellSize = UDim2.fromOffset(50, 50),
					},
					Padding = {
						All = UDim.new(0, 10),
					},
					Corner = {
						Radius = UDim.new(0, 10),
					},

					[Children] = {
						Scope:Base {
							ClassName = "Frame",
						},
						Scope:Base {
							ClassName = "Frame",
							Stroke = {
								Color = Color3.fromRGB(0, 0, 255),
								Thickness = 2,
							},
						},
						Scope:Base {
							ClassName = "Frame",
						},
						Scope:Base {
							ClassName = "Frame",
						},
						Scope:Base {
							ClassName = "Frame",
						},
					},
				},
			},
		}
	end,
	fusion = Fusion,
}
