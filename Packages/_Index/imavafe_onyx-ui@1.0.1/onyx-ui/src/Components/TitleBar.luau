--[=[
		@class TitleBar
		
		For displaying a title, and an optional close button.
]=]

--[=[
	@interface TitleBarProps
	@within TitleBar

	. ... FrameProps -- All Frame properties are accepted.
	.Content {string}? -- The content of the title bar.
	.ContentSize number? -- The size of the content text.
	.ContentColor Color3? -- The color of the content text.
	.ContentFontFace Font? -- The font face of the content text.
	.CloseButtonIcon string? -- The icon for the close button.
	.CloseButtonDisabled boolean? -- Whether the close button is disabled.
	.OnClose (() -> ())? -- The callback function when the close button is clicked.
]=]

local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Frame = require(script.Parent.Frame)
local IconButton = require(script.Parent.IconButton)
local IconText = require(script.Parent.IconText)
local Components = {
	Frame = Frame,
	IconButton = IconButton,
	IconText = IconText,
}

export type Props = Frame.Props & {
	Content: Fusion.UsedAs<{ string }>?,
	ContentSize: Fusion.UsedAs<number>?,
	ContentColor: Fusion.UsedAs<Color3>?,
	ContentFontFace: Fusion.UsedAs<Font>?,
	CloseButtonIcon: Fusion.UsedAs<string>?,
	CloseButtonDisabled: Fusion.UsedAs<boolean>?,
	OnClose: Fusion.UsedAs<() -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Content = Util.Fallback(Props.Content, {})
	local ContentSize = Util.Fallback(Props.ContentSize, Theme.TextSize["1"])
	local ContentColor = Util.Fallback(Props.ContentColor, Theme.Colors.BaseContent.Main)
	local ContentFontFace =
		Util.Fallback(Props.ContentFontFace, Scope:Font(Theme.Font.Heading, Theme.FontWeight.Heading))
	local CloseButtonDisabled = Util.Fallback(Props.CloseButtonDisabled, false)
	local CloseButtonIcon = Util.Fallback(Props.CloseButtonIcon, "rbxassetid://80218226919142")
	local OnClose = Util.Fallback(Props.OnClose, function() end)

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		[Children] = {
			Scope:IconText {
				Name = "Title",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Content = Content,
				ContentColor = ContentColor,
				ContentSize = ContentSize,
				ContentFontFace = ContentFontFace,
				ContentWrapped = false,
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},
			},
			Scope:Computed(function(Use)
				if Use(CloseButtonDisabled) == false then
					return Themer.Theme:is(Theme):during(function()
						return Scope:IconButton {
							Name = "CloseButton",
							Image = CloseButtonIcon,
							ContentSize = ContentSize,
							ContentColor = ContentColor,
							Color = ContentColor,
							Style = "Ghost",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.fromScale(1, 0.5),

							OnActivate = function()
								if Use(OnClose) then
									Use(OnClose)()
								end
							end,
						}
					end)
				else
					return
				end
			end),
		},
	}))
end
