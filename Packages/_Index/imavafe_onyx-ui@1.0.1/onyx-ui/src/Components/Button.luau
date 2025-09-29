--[=[
		@class Button
		
		A robust button component, supporting text and icons, and multiple variants.
]=]

--[=[
	@interface ButtonProps
	@within Button

	. ... BaseButtonProps -- All BaseButton properties are accepted.
	.Disabled boolean? -- Whether the button is disabled.
	.Style string? -- The style of the button (e.g., "Filled", "Outlined", "Ghost").
	.Color Color3? -- The background color of the button.
	.Content {string}? -- The content of the button (e.g., text or icons).
	.ContentColor Color3? -- The color of the button's content.
	.ContentSize number? -- The size of the button's content.
	.ContentWrapped boolean? -- Whether the content should wrap.
	.SizeVariant "ExtraSmall" | "Small" | "Medium" | "Large" | "ExtraLarge"? -- The size variant of the button.
	.Holding boolean? -- Whether the button is being held.
	.Hovering boolean? -- Whether the button is being hovered over.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)

local Children = Fusion.Children

local BaseButton = require(script.Parent.BaseButton)
local IconText = require(script.Parent.IconText)
local Components = {
	BaseButton = BaseButton,
	IconText = IconText,
}

local DISABLED_BACKGROUND_TRANSPARENCY = 0.925
local DISABLED_CONTENT_TRANSPARENCY = 0.75

export type Props = BaseButton.Props & {
	Disabled: Fusion.UsedAs<boolean>?,
	Style: Fusion.UsedAs<string>?,
	Color: Fusion.UsedAs<Color3>?,
	Content: Fusion.UsedAs<{ string }>?,
	ContentColor: Fusion.UsedAs<Color3>?,
	ContentSize: Fusion.UsedAs<number>?,
	ContentWrapped: Fusion.UsedAs<boolean>?,
	SizeVariant: Fusion.UsedAs<"ExtraSmall" | "Small" | "Medium" | "Large" | "ExtraLarge">?,
	Holding: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local SizeVariant = Util.Fallback(Props.SizeVariant, "Medium")
	local Disabled = Util.Fallback(Props.Disabled, false)
	local Content = Util.Fallback(Props.Content, {})
	local Style = Util.Fallback(Props.Style, "Filled")
	local Color = Util.Fallback(Props.Color, Theme.Colors.Neutral.Main)
	local ContentColor = Util.Fallback(
		Props.ContentColor,
		Scope:Computed(function(Use)
			return Util.Emphasize(Use(Color), Use(Theme.Emphasis.Contrast))
		end)
	)
	local ContentSize = Util.Fallback(
		Props.ContentSize,
		Scope:Computed(function(Use)
			local VariantSizes = {
				ExtraSmall = Use(Theme.TextSize["0.875"]),
				Small = Use(Theme.TextSize["1"]),
				Medium = Use(Theme.TextSize["1"]),
				Large = Use(Theme.TextSize["1.25"]),
				ExtraLarge = Use(Theme.TextSize["1.25"]),
			}

			return VariantSizes[Use(SizeVariant)]
		end)
	)
	local ContentWrapped = Util.Fallback(Props.ContentWrapped, false)

	local Hovering = Scope:EnsureValue(Util.Fallback(Props.Hovering, false))
	local Holding = Scope:EnsureValue(Util.Fallback(Props.Holding, false))

	local EffectiveColor = Scope:Computed(function(Use)
		if Use(Disabled) then
			return Use(Theme.Colors.BaseContent.Main)
		else
			local BaseColor = Use(Color)

			if Use(Holding) then
				return Util.Emphasize(BaseColor, Use(Theme.Emphasis.Regular))
			elseif Use(Hovering) then
				return Util.Emphasize(BaseColor, Use(Theme.Emphasis.Light))
			else
				return BaseColor
			end
		end
	end)
	local EffectiveContentColor = Scope:Computed(function(Use)
		if Use(Disabled) then
			return Use(Theme.Colors.BaseContent.Main)
		else
			if Use(Style) == "Filled" then
				return Use(ContentColor)
			elseif Use(Style) == "Outlined" then
				return Use(EffectiveColor)
			elseif Use(Style) == "Ghost" then
				return Use(EffectiveColor)
			else
				return Use(ContentColor)
			end
		end
	end)
	local EffectiveStrokeEmphasis = Scope:Computed(function(Use)
		local StrokeEmphasis = Use(Theme.StrokeEmphasis.Regular)

		if (Use(Style) ~= "Filled") or Use(Disabled) or Use(Hovering) or Use(Holding) then
			return 0
		else
			return StrokeEmphasis
		end
	end)
	local EffectiveContentTransparency = Scope:Computed(function(Use)
		if Use(Disabled) then
			return DISABLED_CONTENT_TRANSPARENCY
		else
			return 0
		end
	end)
	local PaddingX = Scope:Computed(function(Use)
		local VariantSizes = {
			ExtraSmall = Use(Theme.Padding["0.25"]),
			Small = Use(Theme.Padding["0.5"]),
			Medium = Use(Theme.Padding["0.75"]),
			Large = Use(Theme.Padding["1"]),
			ExtraLarge = Use(Theme.Padding["1.5"]),
		}

		return UDim.new(0, VariantSizes[Use(SizeVariant)])
	end)
	local PaddingY = Scope:Computed(function(Use)
		local VariantSizes = {
			ExtraSmall = 0.5,
			Small = 0.75,
			Medium = 1.25,
			Large = 1.5,
			ExtraLarge = 2,
		}

		return UDim.new(0, Use(Theme.Padding["0.25"]) * VariantSizes[Use(SizeVariant)])
	end)

	return Scope:BaseButton(Util.CombineProps(Props, {
		Name = script.Name,
		BackgroundTransparency = Scope:Computed(function(Use)
			if Use(Style) == "Filled" then
				if Use(Disabled) then
					return DISABLED_BACKGROUND_TRANSPARENCY
				else
					return 0
				end
			else
				return 1
			end
		end),
		BackgroundColor3 = Scope:Spring(EffectiveColor, Theme.SpringSpeed["1"], Theme.SpringDampening["1"]),
		Padding = {
			Left = PaddingX,
			Right = PaddingX,
			Top = PaddingY,
			Bottom = PaddingY,
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1"]),
		},
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Wraps = false,
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
				if Use(Style) == "Ghost" then
					return 1
				elseif Use(Disabled) then
					return DISABLED_BACKGROUND_TRANSPARENCY
				else
					return 0
				end
			end),
		},

		Holding = Holding,
		Hovering = Hovering,

		[Children] = {
			Scope:IconText {
				Content = Content,
				ContentColor = EffectiveContentColor,
				ContentTransparency = EffectiveContentTransparency,
				ContentSize = ContentSize,
				ContentWrapped = ContentWrapped,
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				},
			},
		},
	}))
end
