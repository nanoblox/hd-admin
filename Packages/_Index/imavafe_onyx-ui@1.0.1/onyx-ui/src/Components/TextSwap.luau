--[=[
		@class TextSwap
		
		Swap between an array values.
]=]

--[=[
	@interface TextSwapProps
	@within TextSwap
	
	. ... BaseButtonProps -- All BaseButton properties are accepted.
	.Options {string}? -- Array of string options to swap between
	.Selection number? -- The currently selected option index
	.Disabled boolean? -- Whether the TextSwap is disabled
	.Color Color3? -- The color of the content
	.ContentSize number? -- The size of the content
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local BaseButton = require(script.Parent.BaseButton)
local Components = {
	BaseButton = BaseButton,
	Text = require(script.Parent.Text),
	IconButton = require(script.Parent.IconButton),
}

export type Props = BaseButton.Props & {
	Options: Fusion.UsedAs<{ string }>?,
	Selection: Fusion.UsedAs<number>?,
	Disabled: Fusion.UsedAs<boolean>?,
	Color: Fusion.UsedAs<Color3>?,
	ContentSize: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Options = Util.Fallback(Props.Options, {})
	local Selection = Scope:EnsureValue(Util.Fallback(Props.Selection, 1))
	local Color = Util.Fallback(Props.Color, Theme.Colors.BaseContent.Main)
	local Disabled = Util.Fallback(Props.Disabled, false)
	local ContentSize = Util.Fallback(Props.ContentSize, Theme.TextSize["1"])

	local Holding = Scope:Value(false)
	local Hovering = Scope:Value(false)
	local ShownIncrement = Scope:Value(0)

	local SelectionContent = Scope:Computed(function(Use)
		local OptionsValue = Use(Options)
		local SelectionValue = Use(Selection)

		return OptionsValue[SelectionValue]
	end)
	local EffectiveContentColor = Scope:Computed(function(Use)
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

	Scope:Observer(Options):onChange(function()
		Selection:set(1)
	end)

	local function RotateSelection(Increment: number)
		local OptionsValue = Fusion.peek(Options)
		local SelectionValue = Fusion.peek(Selection)
		local NewSelection = SelectionValue + Increment

		if NewSelection > #OptionsValue then
			NewSelection = 1
		elseif NewSelection < 1 then
			NewSelection = #OptionsValue
		end

		Selection:set(NewSelection)
	end

	local OldSelectionValue = Fusion.peek(Props.Selection) or 1
	Scope:Observer(Selection):onChange(function()
		local SelectionValue = Fusion.peek(Selection)

		local SelectionIncreased = SelectionValue > OldSelectionValue
		ShownIncrement:set((SelectionIncreased and 1) or -1)
		task.wait(0.1)
		ShownIncrement:set(0)
	end)

	local NoPadding = Scope:UDim(0, Theme.Spacing["0"])

	return Scope:BaseButton(Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		Padding = {
			All = Scope:UDim(0, Theme.Padding["0.5"]),
		},
		Stroke = {
			Color = Color,
			Transparency = Scope:Spring(
				Scope:Computed(function(Use)
					if Use(Disabled) then
						return 0.9
					else
						return 0.8
					end
				end),
				Theme.SpringSpeed["1"],
				Theme.SpringDampening["1"]
			),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1"]),
		},

		Disabled = Disabled,

		Holding = Holding,
		Hovering = Hovering,

		OnActivate = function()
			RotateSelection(1)
		end,

		[Children] = {
			Scope:IconButton {
				Name = "LeftArrow",
				Image = "rbxassetid://136326079088976",
				Style = "Ghost",
				Color = Color,
				Disabled = Disabled,
				ContentSize = Scope:Spring(
					Scope:Computed(function(Use)
						local ShownIncrementValue = Use(ShownIncrement)
						local ContentSizeValue = Use(ContentSize)

						if ShownIncrementValue < 0 then
							return ContentSizeValue * (1 - Use(Theme.Emphasis.Regular))
						else
							return Use(ContentSizeValue)
						end
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
				Padding = {
					Top = NoPadding,
					Left = NoPadding,
					Right = NoPadding,
					Bottom = NoPadding,
				},

				OnActivate = function()
					RotateSelection(-1)
				end,
			},
			Scope:Text {
				Text = Scope:Computed(function(Use)
					local SelectionContentValue = Use(SelectionContent)
					if SelectionContentValue ~= nil then
						return SelectionContentValue
					else
						return ""
					end
				end),
				TextColor3 = EffectiveContentColor,
				TextTransparency = Scope:Computed(function(Use)
					if Use(Disabled) then
						return 0.75
					else
						return 0
					end
				end),
				SizeLimit = {
					Min = Scope:Vector2(0, ContentSize),
				},
			},
			Scope:IconButton {
				Name = "RightArrow",
				Image = "rbxassetid://85293585205481",
				Style = "Ghost",
				Color = Color,
				Disabled = Disabled,
				ContentSize = Scope:Spring(
					Scope:Computed(function(Use)
						local ShownIncrementValue = Use(ShownIncrement)
						local ContentSizeValue = Use(ContentSize)

						if ShownIncrementValue > 0 then
							return Use(ContentSizeValue * (1 - Use(Theme.Emphasis.Regular)))
						else
							return Use(ContentSizeValue)
						end
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
				Padding = {
					Top = NoPadding,
					Left = NoPadding,
					Right = NoPadding,
					Bottom = NoPadding,
				},

				OnActivate = function()
					RotateSelection(1)
				end,
			},
		},
	}))
end
