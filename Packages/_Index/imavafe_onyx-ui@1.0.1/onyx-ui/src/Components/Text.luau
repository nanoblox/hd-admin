--[=[
		@class Text
		
		For displaying text. *Lorem ipsum dolo..*
]=]

--[=[
	@interface TextProps
	@within Text
	
	. ... BaseProps -- All Base properties are accepted.
	.Text string? -- The text to display.
	.TextColor3 Color3? -- The color of the text.
	.TextSize number? -- The size of the text.
	.RichText boolean? -- Whether the text supports rich text formatting.
	.FontFace Font? -- The font face of the text.
	.TextWrapped boolean? -- Whether the text should wrap when it exceeds the label's width.
	.TextXAlignment Enum.TextXAlignment? -- The horizontal alignment of the text.
	.TextYAlignment Enum.TextYAlignment? -- The vertical alignment of the text.
	.Font Enum.Font? -- The font of the text (deprecated, use FontFace instead).
	.TextScaled boolean? -- Whether the text should scale to fit the label.
	.TextTruncate boolean? -- Whether the text should truncate when it exceeds the label's width.
	.LineHeight number? -- The line height of the text.
	.LocalizedText string? -- The localized text to display.
	.MaxVisibleGraphemes number? -- The maximum number of visible graphemes.
	.TextTransparency number? -- The transparency of the text.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Base = require(script.Parent.Base)
local Components = {
	Base = Base,
}

export type Props = Base.Props & {
	Text: Fusion.UsedAs<string>?,
	TextColor3: Fusion.UsedAs<Color3>?,
	TextSize: Fusion.UsedAs<number>?,
	RichText: Fusion.UsedAs<boolean>?,
	FontFace: Fusion.UsedAs<Font>?,
	TextWrapped: Fusion.UsedAs<boolean>?,
	TextXAlignment: Fusion.UsedAs<Enum.TextXAlignment>?,
	TextYAlignment: Fusion.UsedAs<Enum.TextYAlignment>?,
	Font: Fusion.UsedAs<Enum.Font>?,
	TextScaled: Fusion.UsedAs<boolean>?,
	TextTruncate: Fusion.UsedAs<boolean>?,
	LineHeight: Fusion.UsedAs<number>?,
	LocalizedText: Fusion.UsedAs<string>?,
	MaxVisibleGraphemes: Fusion.UsedAs<number>?,
	TextTransparency: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props): Instance
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local TextColor3 = Util.Fallback(Props.TextColor3, Theme.Colors.BaseContent.Main)
	local TextSize = Util.Fallback(Props.TextSize, Theme.TextSize["1"])
	local RichText = Util.Fallback(Props.RichText, true)
	local FontFace = Util.Fallback(Props.FontFace, Scope:Font(Theme.Font.Body, Theme.FontWeight.Body))
	local TextWrapped = Util.Fallback(Props.TextWrapped, true)
	local TextXAlignment = Util.Fallback(Props.TextXAlignment, Enum.TextXAlignment.Left)
	local TextYAlignment = Util.Fallback(Props.TextYAlignment, Enum.TextYAlignment.Top)

	return Scope:Hydrate(Scope:Base(Util.CombineProps(Props, {
		ClassName = "TextLabel",
		Name = script.Name,
		AutomaticSize = Enum.AutomaticSize.XY,
		ClipsDescendants = false,
		BackgroundTransparency = 1,
	}))) {
		TextColor3 = TextColor3,
		TextSize = TextSize,
		RichText = RichText,
		FontFace = FontFace,
		TextWrapped = TextWrapped,
		TextXAlignment = TextXAlignment,
		TextYAlignment = TextYAlignment,

		Text = Props.Text,
		TextTransparency = Props.TextTransparency,
		MaxVisibleGraphemes = Props.MaxVisibleGraphemes,
		LocalizedText = Props.LocalizedText,
		LineHeight = Props.LineHeight,
		TextTruncate = Props.TextTruncate,
		TextScaled = Props.TextScaled,
		Font = Props.Font,
	}
end
