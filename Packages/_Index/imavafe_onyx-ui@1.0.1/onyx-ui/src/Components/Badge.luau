--[=[
		@class Badge
		
		Used to inform the user of something's status. E.g. a notification indicator or discount tag.

]=]

--[=[
	@interface BadgeProps
	@within Badge

	. ... FrameProps -- All Frame properties are accepted.
	.Content {string}? -- The content to display inside the badge.
	.ContentWrapped boolean? -- Whether the content should wrap if it overflows.
	.Color Color3? -- The background color of the badge.
	.ContentColor Color3? -- The color of the content inside the badge.
	.ContentSize number? -- The size of the content inside the badge.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Frame = require(script.Parent.Frame)
local IconText = require(script.Parent.IconText)
local Components = {
	Frame = Frame,
	IconText = IconText,
}

export type Props = Frame.Props & {
	Content: Fusion.UsedAs<{ string }>?,
	ContentWrapped: Fusion.UsedAs<boolean>?,
	Color: Fusion.UsedAs<Color3>?,
	ContentColor: Fusion.UsedAs<Color3>?,
	ContentSize: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Content = Util.Fallback(Props.Content, {})
	local ContentWrapped = Util.Fallback(Props.ContentWrapped, true)
	local Color = Util.Fallback(Props.Color, Theme.Colors.Base.Main)
	local ContentColor = Util.Fallback(
		Props.ContentColor,

		Scope:Computed(function(Use)
			return Util.Emphasize(Use(Color), Use(Theme.Emphasis.Contrast))
		end)
	)
	local ContentSize = Util.Fallback(Props.ContentSize, Theme.TextSize["1"])

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		BackgroundColor3 = Color,
		BackgroundTransparency = 0,
		Padding = {
			All = Scope:UDim(0, Theme.Padding["0"]),
			Left = Scope:UDim(0, Theme.Padding["0.25"]),
			Right = Scope:UDim(0, Theme.Padding["0.25"]),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["2"]),
		},
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Wraps = ContentWrapped,
		},
		Stroke = {},

		[Children] = {
			Scope:IconText {
				Content = Content,
				ContentColor = ContentColor,
				ContentSize = ContentSize,
				ContentWrapped = ContentWrapped,
				List = {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
				},
			},
		},
	}))
end
