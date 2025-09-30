local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local OnyxUI = require(Packages.OnyxUI)
local Fusion = require(Packages.Fusion)

export type Props = OnyxUI.IconButtonProps & {
	Options: Fusion.UsedAs<{ string }>?,
	Selection: Fusion.UsedAs<number>?,
	OnSwapped: Fusion.UsedAs<(number) -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)

	local Options = OnyxUI.Util.Fallback(Props.Options, {})
	local Selection = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Selection, 1))
	local OnSwapped = OnyxUI.Util.Fallback(Props.OnSwapped, function() end)

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

	return Scope:IconButton(OnyxUI.Util.CombineProps(Props, {
		Name = "SearchToggle",
		Style = "Ghost",
		Image = Scope:Computed(function(Use)
			return Use(Options)[Use(Selection)]
		end),

		OnActivate = function()
			local OldSelection = Fusion.peek(Selection)

			RotateSelection(1)
			OnSwapped(OldSelection, OldSelection + 1)
		end,
	}))
end
