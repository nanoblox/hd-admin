--[=[
		@class Checkbox
		
		Useful for settings, to-do lists, and anything needing a "Check!"
]=]

--[=[
	@interface CheckboxProps
	@within Checkbox

	. ... BaseButtonProps -- All BaseButton properties are accepted.
	.Checked boolean? -- Whether the checkbox is checked.
	.Icon string? -- The icon to display inside the checkbox.
	.Color Color3? -- The color of the checkbox.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)

local Children = Fusion.Children

local BaseButton = require(script.Parent.BaseButton)
local Icon = require(script.Parent.Icon)
local Components = {
	BaseButton = BaseButton,
	Icon = Icon,
}

export type Props = BaseButton.Props & {
	Checked: Fusion.UsedAs<boolean>?,
	Icon: Fusion.UsedAs<string>?,
	Color: Fusion.UsedAs<Color3>?,
}

local DISABLED_BACKGROUND_TRANSPARENCY = 0.925
local DISABLED_CONTENT_TRANSPARENCY = 0.75

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Checked = Scope:EnsureValue(Util.Fallback(Props.Checked, false))
	local Disabled = Util.Fallback(Props.Disabled, false)
	local Color = Util.Fallback(Props.Color, Theme.Colors.Primary.Main)
	local IconId = Util.Fallback(Props.Icon, "rbxassetid://13858821963")

	local Hovering = Scope:EnsureValue(Util.Fallback(Props.Hovering, false))
	local Holding = Scope:EnsureValue(Util.Fallback(Props.Holding, false))

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

		if Use(Disabled) or (not Use(Checked)) or Use(Hovering) or Use(Holding) then
			return 0
		else
			return StrokeEmphasis
		end
	end)

	return Scope:BaseButton(Util.CombineProps(Props, {
		Name = script.Name,
		BackgroundColor3 = EffectiveColor,
		BackgroundTransparency = Scope:Spring(
			Scope:Computed(function(Use)
				if Use(Disabled) then
					return DISABLED_BACKGROUND_TRANSPARENCY
				else
					if Use(Checked) then
						return 0
					else
						return 1
					end
				end
			end),
			Theme.SpringSpeed["1"],
			Theme.SpringDampening["1"]
		),
		Disabled = Disabled,
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["0.5"]),
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

		Hovering = Hovering,
		Holding = Holding,

		OnActivate = function()
			Checked:set(not Fusion.peek(Checked))
		end,

		[Children] = {
			Scope:Icon {
				Name = "Checkmark",
				Image = IconId,
				ImageTransparency = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(Checked) then
							if Use(Disabled) then
								return DISABLED_CONTENT_TRANSPARENCY
							else
								return 0
							end
						else
							return 1
						end
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
				ImageColor3 = Scope:Computed(function(Use)
					return Util.Emphasize(Use(Color), Use(Theme.Emphasis.Contrast))
				end),
				Rotation = Scope:Spring(
					Scope:Computed(function(Use)
						return (Use(Checked) and 0) or -30
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
			},
		},
	}))
end
