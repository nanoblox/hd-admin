--[=[
		@class IconText
		
		For displaying both text and icons alongside each other as one seamless body.
]=]

--[=[
	@interface IconTextProps
	@within IconText
	
	. ... FrameProps -- All Frame properties are accepted.
	.Content {string}? -- The content to display, can include both text and icons.
	.ContentColor Color3? -- The color of the content.
	.ContentSize number? -- The size of the content.
	.ContentTransparency number? -- The transparency of the content.
	.ContentWrapped boolean? -- Whether the text content should wrap.
	.ContentRichText boolean? -- Whether the text content supports rich text.
	.ContentFontFace Font? -- The font face of the text content.
]=]

local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local Components = {
	Text = Text,
	Icon = Icon,
	Frame = Frame,
}

export type Props = Frame.Props & {
	Content: Fusion.UsedAs<{ string }>?,
	ContentColor: Fusion.UsedAs<Color3>?,
	ContentSize: Fusion.UsedAs<number>?,
	ContentTransparency: Fusion.UsedAs<number>?,
	ContentWrapped: Fusion.UsedAs<boolean>?,
	ContentRichText: Fusion.UsedAs<boolean>?,
	ContentFontFace: Fusion.UsedAs<Font>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Content = Util.Fallback(Props.Content, {})
	local ContentSize = Util.Fallback(Props.ContentSize, Theme.TextSize["1"])
	local ContentColor = Util.Fallback(Props.ContentColor, Theme.Colors.BaseContent.Main)
	local ContentTransparency = Util.Fallback(Props.ContentTransparency, 0)
	local ContentWrapped = Util.Fallback(Props.ContentWrapped, true)
	local ContentRichText = Util.Fallback(Props.ContentRichText, true)
	local ContentFontFace = Util.Fallback(Props.ContentFontFace, Scope:Font(Theme.Font.Body, Theme.FontWeight.Body))

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = Scope:UDim(0, Theme.Spacing["0"]),
		},

		[Children] = {
			Scope:ForPairs(Content, function(Use, Scope, Index: number, ContentString: string)
				return Index,
					Themer.Theme:is(Theme):during(function()
						if string.find(ContentString, "rbxassetid://", 1, true) then
							return Scope:Icon {
								Image = ContentString,
								ImageColor3 = ContentColor,
								Size = Scope:UDim2Offset(ContentSize, ContentSize),
								ImageTransparency = ContentTransparency,
							}
						else
							return Scope:Text {
								Text = ContentString,
								TextColor3 = ContentColor,
								TextSize = ContentSize,
								TextTransparency = ContentTransparency,
								TextWrapped = ContentWrapped,
								RichText = ContentRichText,
								FontFace = ContentFontFace,
							}
						end
					end)
			end),
		},
	}))
end
