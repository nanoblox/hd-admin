--[=[
		@class Avatar
		
		Useful for displaying player headshots and profile pictures. And optionally, user status.
]=]

--[=[
	@interface AvatarProps
	@within Avatar
	
	. ... ImageProps -- All Image properties are accepted.
	.Image string? -- The image to display in the avatar.
	.RingEnabled boolean? -- Whether the ring around the avatar is enabled.
	.RingColor Color3? -- The color of the ring around the avatar.
	.RingThickness number? -- The thickness of the ring around the avatar.
	.IndicatorEnabled boolean? -- Whether the indicator is enabled.
	.IndicatorColor Color3? -- The color of the indicator.
	.IndicatorIcon string? -- The icon to display in the indicator.
	.IndicatorIconColor Color3? -- The color of the indicator icon.
	.IndicatorCornerRadius UDim? -- The corner radius of the indicator.
]=]

local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Image = require(script.Parent.Image)
local Group = require(script.Parent.Group)
local Icon = require(script.Parent.Icon)
local Components = {
	Image = Image,
	Group = Group,
	Icon = Icon,
}

export type Props = Image.Props & {
	Image: Fusion.UsedAs<string>?,
	RingEnabled: Fusion.UsedAs<boolean>?,
	RingColor: Fusion.UsedAs<Color3>?,
	RingThickness: Fusion.UsedAs<number>?,
	IndicatorEnabled: Fusion.UsedAs<boolean>?,
	IndicatorColor: Fusion.UsedAs<Color3>?,
	IndicatorIcon: Fusion.UsedAs<string>?,
	IndicatorIconColor: Fusion.UsedAs<Color3>?,
	IndicatorCornerRadius: Fusion.UsedAs<UDim>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local ImageProp = Util.Fallback(Props.Image, nil)
	local RingEnabled = Util.Fallback(Props.RingEnabled, false)
	local RingColor = Util.Fallback(Props.RingColor, Theme.Colors.Primary.Main)
	local RingThickness = Util.Fallback(Props.RingThickness, Theme.StrokeThickness["2"])
	local IndicatorEnabled = Util.Fallback(Props.IndicatorEnabled, false)
	local IndicatorColor = Util.Fallback(Props.IndicatorColor, Theme.Colors.Primary.Main)
	local IndicatorCornerRadius = Util.Fallback(Props.IndicatorCornerRadius, Scope:UDim(0, Theme.CornerRadius["Full"]))
	local IndicatorIcon = Util.Fallback(Props.IndicatorIcon, nil)
	local IndicatorIconColor = Util.Fallback(Props.IndicatorIconColor, Util.Colors.White)

	return Scope:Image(Util.CombineProps(Props, {
		Name = script.Name,
		Image = ImageProp,
		Size = Scope:UDim2Offset(Theme.TextSize["4.5"], Theme.TextSize["4.5"]),
		BackgroundColor3 = Theme.Colors.Neutral.Dark,
		Stroke = {
			Enabled = RingEnabled,
			Color = Scope:Spring(RingColor, Theme.SpringSpeed["0.5"], Theme.SpringDampening["1"]),
			Thickness = Scope:Spring(RingThickness, Theme.SpringSpeed["0.5"], Theme.SpringDampening["1"]),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1"]),
		},

		[Children] = {
			Scope:Computed(function(Use)
				if Use(IndicatorEnabled) then
					return Themer.Theme:is(Theme):during(function()
						return Scope:Group {
							Name = "Indicator",
							BackgroundColor3 = Scope:Spring(
								IndicatorColor,
								Theme.SpringSpeed["0.5"],
								Theme.SpringDampening["1"]
							),
							BackgroundTransparency = 0,
							Size = UDim2.fromScale(0.25, 0.25),
							AutomaticSize = Enum.AutomaticSize.None,
							AnchorPoint = Vector2.new(1, 1),
							Position = UDim2.fromScale(1, 1),
							Aspect = {
								Ratio = 1,
							},
							Corner = {
								Radius = IndicatorCornerRadius,
							},

							[Children] = {
								Scope:Icon {
									Image = IndicatorIcon,
									ImageColor3 = IndicatorIconColor,
									ImageTransparency = Scope:Computed(function(Use)
										if Use(IndicatorIcon) then
											return 0
										else
											return 1
										end
									end),
									Size = UDim2.fromScale(1, 1),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
								},
							},
						}
					end)
				else
					return
				end
			end),
		},
	}))
end
