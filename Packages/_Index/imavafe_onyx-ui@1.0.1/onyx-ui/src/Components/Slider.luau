--[=[
		@class Slider
		
		For draggable linear selection.
]=]

--[=[
	@interface SliderProps
	@within Slider
	
	. ... BaseButtonProps -- All BaseButton properties are accepted.
	.Value number? -- The current value of the slider (0 to 1).
	.Disabled boolean? -- Whether the slider is disabled.
	.Unit number? -- The step size for the slider value.
	.Color Color3? -- The color of the slider.
]=]

local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)

local Children = Fusion.Children
local Out = Fusion.Out
local OnEvent = Fusion.OnEvent

local BaseButton = require(script.Parent.BaseButton)
local Components = {
	BaseButton = BaseButton,
}

function RoundByUnit(Number, Factor)
	return math.floor(Number / Factor + 0.5) * Factor
end

local DISABLED_BACKGROUND_TRANSPARENCY = 0.925

export type Props = BaseButton.Props & {
	Value: Fusion.UsedAs<number>?,
	Disabled: Fusion.UsedAs<boolean>?,
	Unit: Fusion.UsedAs<number>?,
	Color: Fusion.UsedAs<Color3>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Unit = Util.Fallback(Props.Unit, 1 / 100)
	local Value = Scope:EnsureValue(Util.Fallback(Props.Value, 1))
	local Color = Util.Fallback(Props.Color, Theme.Colors.Primary.Main)
	local Disabled = Util.Fallback(Props.Disabled, false)

	local Hovering = Scope:EnsureValue(Util.Fallback(Props.Hovering, false))
	local Holding = Scope:EnsureValue(Util.Fallback(Props.Holding, false))

	local DragDetector = Scope:Value(nil)
	local AbsoluteSize = Scope:Value(Vector2.new())
	local AbsolutePosition = Scope:Value(Vector2.new())

	local EffectiveColor = Scope:Computed(function(Use)
		if Use(Disabled) then
			return Use(Theme.Colors.BaseContent.Main)
		else
			if Use(Holding) then
				return Util.Emphasize(Use(Color), Use(Theme.Emphasis.Regular))
			elseif Use(Hovering) then
				return Util.Emphasize(Use(Color), Use(Theme.Emphasis.Light))
			else
				return Use(Color)
			end
		end
	end)
	local EffectiveStrokeEmphasis = Scope:Computed(function(Use)
		local StrokeEmphasis = Use(Theme.StrokeEmphasis.Regular)

		if Use(Disabled) or Use(Hovering) or Use(Holding) then
			return 0
		else
			return StrokeEmphasis
		end
	end)

	local function ProcessDrag(Position: Vector2)
		local AbsoluteSizeValue = Fusion.peek(AbsoluteSize)
		local AbsolutePositionValue = Fusion.peek(AbsolutePosition)
		local UnitValue = Fusion.peek(Unit)

		local RelativePosition = Position.X - AbsolutePositionValue.X

		Value:set(RoundByUnit(math.clamp(RelativePosition / AbsoluteSizeValue.X, 0, 1), UnitValue))
	end

	local Slider = Scope:BaseButton(Util.CombineProps(Props, {
		Name = script.Name,
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius.Full),
		},
		Size = Scope:UDim2Offset(0, Theme.TextSize["1"]),
		AutomaticSize = Enum.AutomaticSize.Y,

		Disabled = Disabled,
		Hovering = Hovering,
		Holding = Holding,

		[Children] = {
			DragDetector,
			Scope:Hydrate(Scope:Frame {
				Name = "Progress",
				Selectable = false,
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.Colors.Neutral.Main,
				Size = Scope:UDim2(1, 0, 0, Theme.TextSize["0.75"]),
				Corner = {
					Radius = Scope:UDim(0, Theme.CornerRadius.Full),
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

				[Children] = {
					Scope:Frame {
						Name = "Progress",
						Selectable = false,
						Size = Scope:Computed(function(Use)
							local ValueValue = Use(Value)
							return UDim2.fromScale(ValueValue, 1)
						end),
						BackgroundTransparency = Scope:Computed(function(Use)
							if Use(Disabled) then
								return DISABLED_BACKGROUND_TRANSPARENCY
							else
								return 0
							end
						end),
						BackgroundColor3 = Scope:Spring(
							EffectiveColor,
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						AutomaticSize = Enum.AutomaticSize.None,
						Corner = {
							Radius = Scope:UDim(0, Theme.CornerRadius.Full),
						},
						Stroke = {
							Color = Color3.fromRGB(255, 255, 255),
							Gradient = {
								Color = Scope:Computed(function(Use)
									return ColorSequence.new({
										ColorSequenceKeypoint.new(
											0,
											ColorUtils.Lighten(Use(EffectiveColor), Use(EffectiveStrokeEmphasis))
										),
										ColorSequenceKeypoint.new(1, Use(EffectiveColor)),
									})
								end),
								Rotation = 90,
							},
							Transparency = Scope:Computed(function(Use)
								if Use(Disabled) then
									return DISABLED_BACKGROUND_TRANSPARENCY
								else
									return 0
								end
							end),
						},

						[Children] = {
							Scope:Frame {
								Name = "Ball",
								Selectable = false,
								AnchorPoint = Scope:Vector2(Value, 0.5),
								Position = UDim2.fromScale(1, 0.5),
								Size = Scope:UDim2Offset(Theme.TextSize["1"], Theme.TextSize["1"]),
								BackgroundTransparency = 0,
								BackgroundColor3 = Scope:Computed(function(Use)
									if Use(Disabled) then
										return Use(Theme.Colors.Neutral.Main)
									else
										return Use(Theme.Colors.BaseContent.Main)
									end
								end),
								AutomaticSize = Enum.AutomaticSize.None,
								Corner = {
									Radius = Scope:UDim(0, Theme.CornerRadius.Full),
								},
								Stroke = {
									Color = Theme.Colors.Neutral.Main,
									Thickness = Theme.StrokeThickness["1"],
								},
								Aspect = {
									Ratio = 1,
								},

								[Children] = {
									Scope:Frame {
										Name = "SmallBall",
										Selectable = false,
										AspectRatio = 1,
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.fromScale(0.5, 0.5),
										Size = Scope:UDim2Offset(Theme.TextSize["0.75"], Theme.TextSize["0.75"]),
										BackgroundTransparency = 0,
										BackgroundColor3 = Scope:Spring(
											Scope:Computed(function(Use)
												if Use(Disabled) then
													return Use(Theme.Colors.Neutral.Dark)
												else
													return Use(EffectiveColor)
												end
											end),
											Theme.SpringSpeed["1"],
											Theme.SpringDampening["1"]
										),
										AutomaticSize = Enum.AutomaticSize.None,
										Corner = {
											Radius = Scope:UDim(0, Theme.CornerRadius.Full),
										},
									},
								},
							},
						},
					},
				},
			}) {
				[Out "AbsoluteSize"] = AbsoluteSize,
				[Out "AbsolutePosition"] = AbsolutePosition,
			},
		},
	}))

	DragDetector:set(Scope:New "UIDragDetector" {
		DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
		DragAxis = Vector2.new(1, 0),
		BoundingUI = Slider,
		Enabled = Scope:Computed(function(Use)
			return not Use(Disabled)
		end),

		[OnEvent "DragContinue"] = function(Position: Vector2)
			ProcessDrag(Position)
		end,
		[OnEvent "DragStart"] = function(Position: Vector2)
			ProcessDrag(Position)
			Holding:set(true)
		end,
		[OnEvent "DragEnd"] = function()
			Holding:set(false)
		end,
	})

	return Slider
end
