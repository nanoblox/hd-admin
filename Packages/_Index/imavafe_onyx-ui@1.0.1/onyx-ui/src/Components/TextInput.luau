--[=[
		@class TextInput
		
		For letting the user input text.
]=]

--[=[
	@interface TextInputProps
	@within TextInput

	. ... BaseProps -- All Base properties are accepted.
	.Disabled boolean? -- Whether the text input is disabled.
	.CharacterLimit number? -- The maximum number of characters allowed in the text input.
	.Color Color3? -- The color of the text input's border when focused.
	.PlaceholderText string? -- The placeholder text displayed when the input is empty.
	.Text string? -- The current text in the text input.
	.ClearTextOnFocus boolean? -- Whether the text should be cleared when the input gains focus.
	.TextWrapped boolean? -- Whether the text should wrap within the input.
	.TextEditable boolean? -- Whether the text input is editable.
	.MultiLine boolean? -- Whether the text input supports multiple lines.
	.TextSize number? -- The size of the text.
	.TextColor3 Color3? -- The color of the text.
	.FontFace Font? -- The font face of the text.
	.PlaceholderColor3 Color3? -- The color of the placeholder text.
	.TextXAlignment Enum.TextXAlignment? -- The horizontal alignment of the text.
	.TextYAlignment Enum.TextYAlignment? -- The vertical alignment of the text.
	.TextTransparency number? -- The transparency of the text.
	.TextProcessor (string) -> string? -- A function to process the text input, and return new text.
	.Focusing boolean? -- Whether the text input is currently focused.
	.Hovering boolean? -- Whether the mouse is hovering over the text input.
	.OnFocus () -> ()? -- A callback function triggered when the text input gains focus.
	.OnFocusEnd () -> ()? -- A callback function triggered when the text input loses focus.
]=]

local SoundService = game:GetService("SoundService")

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local OnEvent = Fusion.OnEvent

local Base = require(script.Parent.Base)
local Components = {
	Base = Base,
}

export type Props = Base.Props & {
	Disabled: Fusion.UsedAs<boolean>?,
	CharacterLimit: Fusion.UsedAs<number>?,
	Color: Fusion.UsedAs<Color3>?,
	PlaceholderText: Fusion.UsedAs<string>?,
	Text: Fusion.UsedAs<string>?,
	ClearTextOnFocus: Fusion.UsedAs<boolean>?,
	TextWrapped: Fusion.UsedAs<boolean>?,
	TextEditable: Fusion.UsedAs<boolean>?,
	MultiLine: Fusion.UsedAs<boolean>?,
	TextSize: Fusion.UsedAs<number>?,
	TextColor3: Fusion.UsedAs<Color3>?,
	FontFace: Fusion.UsedAs<Font>?,
	PlaceholderColor3: Fusion.UsedAs<Color3>?,
	TextXAlignment: Fusion.UsedAs<Enum.TextXAlignment>?,
	TextYAlignment: Fusion.UsedAs<Enum.TextYAlignment>?,
	TextTransparency: Fusion.UsedAs<number>?,
	TextProcessor: Fusion.UsedAs<(string) -> string>?,

	Focusing: Fusion.UsedAs<boolean>?,
	Hovering: Fusion.UsedAs<boolean>?,

	OnFocus: Fusion.UsedAs<() -> ()>?,
	OnFocusEnd: Fusion.UsedAs<() -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Text = Scope:EnsureValue(Util.Fallback(Props.Text, ""))
	local Focusing = Scope:EnsureValue(Util.Fallback(Props.Focusing, false))
	local Hovering = Scope:EnsureValue(Util.Fallback(Props.Hovering, false))

	local Disabled = Util.Fallback(Props.Disabled, false)
	local OnFocus = Util.Fallback(Props.OnFocus, function() end)
	local OnFocusEnd = Util.Fallback(Props.OnFocusEnd, function() end)
	local Color = Util.Fallback(Props.Color, Theme.Colors.Primary.Main)
	local CharacterLimit = Util.Fallback(Props.CharacterLimit, -1)
	local ClearTextOnFocus = Util.Fallback(Props.ClearTextOnFocus, false)
	local PlaceholderText = Util.Fallback(Props.PlaceholderText, "")
	local TextSize = Util.Fallback(Props.TextSize, Theme.TextSize["1"])
	local PlaceholderColor3 = Util.Fallback(Props.PlaceholderColor3, Theme.Colors.NeutralContent.Dark)
	local TextColor3 = Util.Fallback(
		Props.TextColor3,
		Scope:Computed(function(Use)
			return Use(Theme.Colors.BaseContent.Main)
		end)
	)
	local FontFace = Util.Fallback(Props.FontFace, Scope:Font(Theme.Font.Body, Theme.FontWeight.Body))
	local TextXAlignment = Util.Fallback(Props.TextXAlignment, Enum.TextXAlignment.Left)
	local TextYAlignment = Util.Fallback(Props.TextYAlignment, Enum.TextYAlignment.Top)
	local TextTransparency = Util.Fallback(
		Props.TextTransparency,

		Scope:Computed(function(Use)
			if Use(Disabled) then
				return 0.75
			elseif Use(Focusing) then
				return 0
			else
				return 0.5
			end
		end)
	)
	local TextProcessor = Util.Fallback(Props.TextProcessor, function(NewText)
		return NewText
	end)
	local TextEditable = Util.Fallback(
		Props.TextEditable,
		Scope:Computed(function(Use)
			return not Use(Disabled)
		end)
	)

	local InvalidInputActive = Scope:Value(false)

	local function ProcessText(NewText: string)
		local CharacterLimitValue = Fusion.peek(CharacterLimit)
		local TextProcessorValue = Fusion.peek(TextProcessor)
		local LimitedText = NewText:sub(1, utf8.offset(NewText, CharacterLimitValue))
		local FullyProcessedText = TextProcessorValue(LimitedText)

		return FullyProcessedText
	end

	local Object = Scope:Hydrate(Scope:Base(Util.CombineProps(Props, {
		ClassName = "TextBox",
		Name = script.Name,
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1"]),
		},
		Padding = {
			All = Scope:UDim(0, Theme.Padding["0.5"]),
		},
		Stroke = {
			Color = Scope:Spring(
				Scope:Computed(function(Use)
					if Use(InvalidInputActive) then
						return Use(Theme.Colors.Error.Main)
					elseif Use(Focusing) then
						return Use(Color)
					else
						return Use(Theme.Colors.NeutralContent.Dark)
					end
				end),
				Theme.SpringSpeed["1"],
				Theme.SpringDampening["1"]
			),
			Transparency = Scope:Spring(
				Scope:Computed(function(Use)
					if Use(Disabled) then
						return 0.8
					end
					if Use(Focusing) then
						return 0
					else
						return 0.6
					end
				end),
				Theme.SpringSpeed["1"],
				Theme.SpringDampening["1"]
			),
		},
		AutomaticSize = Enum.AutomaticSize.XY,
		AutoLocalize = false,
		Active = Scope:Computed(function(Use)
			return not Use(Disabled)
		end),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}))) {
		Text = Text,
		TextColor3 = Scope:Spring(
			Scope:Computed(function(Use)
				if Use(InvalidInputActive) then
					return Use(Theme.Colors.Error.Main)
				else
					return Use(TextColor3)
				end
			end),
			Theme.SpringSpeed.Immediate,
			Theme.SpringDampening["1"]
		),
		TextSize = TextSize,
		FontFace = FontFace,
		PlaceholderColor3 = PlaceholderColor3,
		PlaceholderText = PlaceholderText,
		TextXAlignment = TextXAlignment,
		TextYAlignment = TextYAlignment,
		ClearTextOnFocus = ClearTextOnFocus,
		TextTransparency = Scope:Spring(TextTransparency, Theme.SpringSpeed["1"], Theme.SpringDampening["1"]),
		TextEditable = TextEditable,

		MultiLine = Props.MultiLine,
		TextWrapped = Props.TextWrapped,

		[OnEvent "Focused"] = function()
			if (not Fusion.peek(Disabled)) and Fusion.peek(TextEditable) then
				Focusing:set(true)

				SoundService:PlayLocalSound(Fusion.peek(Theme.Sound.Focus))

				Fusion.peek(OnFocus)()
			end
		end,
		[OnEvent "FocusLost"] = function()
			Focusing:set(false)

			Fusion.peek(OnFocusEnd)()
		end,
		[OnEvent "MouseEnter"] = function()
			if not Fusion.peek(Disabled) then
				Hovering:set(true)

				SoundService:PlayLocalSound(Fusion.peek(Theme.Sound.Hover))
			end
		end,
		[OnEvent "MouseLeave"] = function()
			if not Fusion.peek(Disabled) then
				Hovering:set(false)
			end
		end,
		[OnEvent "SelectionGained"] = function()
			if (not Fusion.peek(Disabled)) and Fusion.peek(TextEditable) then
				SoundService:PlayLocalSound(Fusion.peek(Theme.Sound.Hover))
			end
		end,
	}

	table.insert(
		Scope,
		Object:GetPropertyChangedSignal("Text"):Connect(function()
			local NewText = Object.Text
			local ProcessedText = ProcessText(NewText)

			Text:set(ProcessedText)
			if Object.Text ~= ProcessedText then
				Object.Text = ProcessedText
			end

			if utf8.len(NewText) ~= utf8.len(ProcessedText) then
				InvalidInputActive:set(true)
				task.wait(0.075)
				InvalidInputActive:set(false)
			end
		end)
	)

	return Object
end
