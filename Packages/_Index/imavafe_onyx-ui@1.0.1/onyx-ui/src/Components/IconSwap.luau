--[=[
		@class IconSwap
		
		Swap between an array of icons.
]=]

--[=[
	@interface IconSwapProps
	@within IconSwap
	
	. ... IconButtonProps -- All IconButton properties are accepted.
	.Options {string}? -- Array of image strings to swap between
	.Selection number? -- The currently selected option index
]=]

local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)
local Fusion = require(OnyxUI.Parent.Fusion)

local IconButton = require(script.Parent.IconButton)

export type Props = IconButton.Props & {
	Options: Fusion.UsedAs<{ string }>?,
	Selection: Fusion.UsedAs<number>?,
	OnSwap: Fusion.UsedAs<(number) -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, {
		IconButton = IconButton,
	})
	local Theme = Themer.Theme:now()

	local Options = Util.Fallback(Props.Options, {})
	local Selection = Scope:EnsureValue(Util.Fallback(Props.Selection, 1))
	local OnSwap = Util.Fallback(Props.OnSwap, function() end)

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

	return Scope:IconButton(Util.CombineProps(Props, {
		Name = script.Name,
		Style = "Ghost",
		Color = Theme.Colors.BaseContent.Main,
		Image = Scope:Computed(function(Use)
			return Use(Options)[Use(Selection)]
		end),

		OnActivate = function()
			local SelectionValue = Fusion.peek(Selection)
			local OnSwapValue = Fusion.peek(OnSwap)

			RotateSelection(1)
			OnSwapValue(SelectionValue, SelectionValue + 1)
		end,
	}))
end
