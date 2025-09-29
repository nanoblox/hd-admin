--[=[
		@class ProgressBar
		
		Useful for communicating progress towards goals.
]=]

--[=[
	@interface ProgressBarProps
	@within ProgressBar
	
	. ... FrameProps -- All Frame properties are accepted.
	.Inverted boolean? -- Whether the progress bar is inverted.
	.Progress number? -- The progress value, ranging from 0 to 1.
	.Color Color3? -- The color of the progress fill.
	.Direction Enum.FillDirection? -- The direction of the progress bar (Horizontal or Vertical).
	.Length UDim? -- The length of the progress bar.
]=]

local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)

local Children = Fusion.Children

local Frame = require(script.Parent.Frame)
local Components = {
	Frame = Frame,
}

export type Props = Frame.Props & {
	Progress: Fusion.UsedAs<number>?,
	Color: Fusion.UsedAs<Color3>?,
	Direction: Fusion.UsedAs<Enum.FillDirection>?,
	Inverted: Fusion.UsedAs<boolean>?,
	Length: Fusion.UsedAs<UDim>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Progress = Util.Fallback(Props.Progress, 0)
	local Color = Util.Fallback(Props.Color, Theme.Colors.Primary.Main)
	local Direction = Util.Fallback(Props.Direction, Enum.FillDirection.Horizontal)
	local Inverted = Util.Fallback(Props.Inverted, false)
	local Length = Util.Fallback(Props.Length, Scope:UDim(0, Theme.Sizing["6"]))
	local Stroke = Util.Fallback(Props.Stroke, {
		Thickness = Theme.StrokeThickness["1"],
	})

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		Size = Scope:Computed(function(Use)
			local DirectionValue = Use(Direction)
			local LengthValue = Use(Length)
			if DirectionValue == Enum.FillDirection.Horizontal then
				return UDim2.new(LengthValue, UDim.new(0, Use(Theme.TextSize["0.75"])))
			else
				return UDim2.new(UDim.new(0, Use(Theme.TextSize["0.75"])), LengthValue)
			end
		end),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Neutral.Dark,
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["Full"]),
		},
		Padding = {
			All = Scope:Computed(function(Use)
				return UDim.new(0, Use(Use(Stroke).Thickness))
			end),
		},

		[Children] = {
			Scope:Frame {
				Name = "ProgressFill",
				Selectable = false,
				Size = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(Direction) == Enum.FillDirection.Horizontal then
							return UDim2.fromScale(Use(Progress), 1)
						else
							return UDim2.fromScale(1, Use(Progress))
						end
					end),
					Theme.SpringSpeed["0.5"],
					Theme.SpringDampening["1"]
				),
				AnchorPoint = Scope:Computed(function(Use)
					if Use(Inverted) then
						if Use(Direction) == Enum.FillDirection.Horizontal then
							return Vector2.new(1, 0)
						else
							return Vector2.new(0, 1)
						end
					else
						return Vector2.new(0, 0)
					end
				end),
				Position = Scope:Computed(function(Use)
					if Use(Inverted) then
						if Use(Direction) == Enum.FillDirection.Horizontal then
							return UDim2.fromScale(1, 0)
						else
							return UDim2.fromScale(0, 1)
						end
					else
						return UDim2.fromScale(0, 0)
					end
				end),
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundTransparency = 0,
				BackgroundColor3 = Color,
				Stroke = {
					Color = Color3.fromRGB(255, 255, 255),
					Gradient = {
						Color = Scope:Computed(function(Use)
							return ColorSequence.new({
								ColorSequenceKeypoint.new(
									0,
									ColorUtils.Lighten(Use(Color), Use(Theme.StrokeEmphasis.Regular))
								),
								ColorSequenceKeypoint.new(1, Use(Color)),
							})
						end),
						Rotation = 90,
					},
				},
				Corner = {
					Radius = Scope:UDim(0, Theme.CornerRadius["Full"]),
				},
			},
		},
	}))
end
