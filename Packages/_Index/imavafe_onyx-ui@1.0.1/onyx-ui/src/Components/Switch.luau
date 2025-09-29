--[=[
		@class Switch
		
		Useful for letting the user switch things on / off.
]=]

--[=[
		@interface SwitchProps
		@within Switch

		. ... BaseButtonProps -- All BaseButton properties are accepted.
		.Switched boolean? -- Whether the switch is toggled on or off
		.Disabled boolean? -- Whether the switch is disabled
		.Color Color3? -- The color of the switch when toggled on
]=]

local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)

local Children = Fusion.Children

local Frame = require(script.Parent.Frame)
local BaseButton = require(script.Parent.BaseButton)
local Components = {
	Frame = Frame,
	BaseButton = BaseButton,
}

export type Props = BaseButton.Props & {
	Switched: Fusion.UsedAs<boolean>?,
	Color: Fusion.UsedAs<Color3>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Switched = Scope:EnsureValue(Util.Fallback(Props.Switched, false))
	local Disabled = Scope:EnsureValue(Util.Fallback(Props.Disabled, false))
	local Color = Util.Fallback(Props.Color, Theme.Colors.Primary.Main)
	local Size = Util.Fallback(
		Props.Size,
		Scope:Computed(function(Use)
			return UDim2.fromOffset(Use(Theme.TextSize["1"]) * 2, Use(Theme.TextSize["1"]))
		end)
	)
	local AutomaticSize = Util.Fallback(Props.AutomaticSize, Enum.AutomaticSize.None)
	local Corner = Util.Fallback(Props.Corner, {
		Radius = Scope:UDim(0, Theme.CornerRadius["Full"]),
	})

	local Hovering = Scope:EnsureValue(Util.Fallback(Props.Hovering, false))
	local Holding = Scope:EnsureValue(Util.Fallback(Props.Holding, false))

	local EffectiveColor = Scope:Computed(function(Use)
		local ActiveColor
		if Use(Switched) then
			ActiveColor = Use(Color)
		else
			ActiveColor = Use(Theme.Colors.NeutralContent.Dark)
		end

		if not Use(Disabled) then
			if Use(Holding) then
				return Util.Emphasize(Use(ActiveColor), Use(Theme.Emphasis.Regular))
			elseif Use(Hovering) then
				return Util.Emphasize(Use(ActiveColor), Use(Theme.Emphasis.Light))
			end
		end

		return ActiveColor
	end)
	local EffectiveBallColor = Scope:Computed(function(Use): any
		local ActiveColor
		if Use(Switched) then
			ActiveColor = Use(Theme.Colors.Base.Main)
		else
			ActiveColor = Use(Theme.Colors.NeutralContent.Dark)
		end

		if not Use(Disabled) then
			if Use(Holding) then
				if not Use(Switched) then
					return Util.Emphasize(Use(ActiveColor), Use(Theme.Emphasis.Regular))
				else
					return ActiveColor
				end
			elseif Use(Hovering) then
				if not Use(Switched) then
					return Util.Emphasize(Use(ActiveColor), Use(Theme.Emphasis.Light))
				else
					return ActiveColor
				end
			end
		end

		return ActiveColor
	end)
	local EffectiveStrokeEmphasis = Scope:Computed(function(Use)
		local StrokeEmphasis = Use(Theme.StrokeEmphasis.Regular)

		if Use(Disabled) or Use(Hovering) or Use(Holding) then
			return 0
		else
			return StrokeEmphasis
		end
	end)

	return Scope:BaseButton(Util.CombineProps(Props, {
		Name = script.Name,
		Size = Size,
		AutomaticSize = AutomaticSize,
		Disabled = Disabled,
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
			Transparency = Scope:Spring(
				Scope:Computed(function(Use)
					if Use(Disabled) then
						return 0.8
					end
					if Use(Switched) then
						return 0
					else
						return 0.6
					end
				end),
				Theme.SpringSpeed["1"],
				Theme.SpringDampening["1"]
			),
		},
		Corner = Corner,

		Hovering = Hovering,
		Holding = Holding,

		ClickSound = Theme.Sound.Switch,

		OnActivate = function()
			Switched:set(not Fusion.peek(Switched))
		end,

		[Children] = {
			Scope:Frame {
				Name = "Switch",
				Size = Size,
				AutomaticSize = AutomaticSize,
				BackgroundColor3 = Scope:Spring(EffectiveColor, Theme.SpringSpeed["1"], Theme.SpringDampening["1"]),
				BackgroundTransparency = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(Switched) then
							return 0
						else
							return 1
						end
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
				Padding = {
					All = UDim.new(0, 2),
				},
				Corner = Corner,

				[Children] = {
					Scope:Frame {
						Name = "Ball",
						AnchorPoint = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(Switched) then
									return Vector2.new(1, 0.5)
								else
									return Vector2.new(0, 0.5)
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						Position = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(Switched) then
									return UDim2.fromScale(1, 0.5)
								else
									return UDim2.fromScale(0, 0.5)
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						Size = Scope:Spring(
							Scope:Computed(function(Use)
								local Scale = 0.85
								if Use(Hovering) then
									Scale *= 1.1
								end

								return UDim2.fromScale(0, Scale)
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						AutomaticSize = Enum.AutomaticSize.None,
						BackgroundTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(Disabled) then
									return 0.7
								end
								if Use(Switched) then
									return 0
								else
									return 0
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						BackgroundColor3 = Scope:Spring(
							EffectiveBallColor,
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						Aspect = {
							Ratio = Scope:Spring(
								Scope:Computed(function(Use)
									if Use(Holding) then
										return 1.2
									else
										return 1
									end
								end),
								Theme.SpringSpeed["1"],
								Theme.SpringDampening["1"]
							),
							Type = Enum.AspectType.ScaleWithParentSize,
							DominantAxis = Enum.DominantAxis.Height,
						},
						Corner = Corner,
					},
				},
			},
		},
	}, { "Size", "AutomaticSize" }))
end
