local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)

local Children = Fusion.Children

export type Props = OnyxUI.IconSwapProps & {
	Toggled: Fusion.Value<boolean>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Selection = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Selection, 1))
	local Toggled = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Toggled, false))

	Scope:Observer(Selection):onChange(function()
		Toggled:set(Fusion.peek(Selection) == 2)
	end)

	return Scope:IconSwap(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Style = "Filled",
		Color = Theme.Colors.Neutral.Main,
		ContentColor = Scope:Spring(
			Scope:Computed(function(Use)
				if Use(Toggled) then
					return Use(Theme.Colors.Primary.Main)
				else
					return Use(Theme.Colors.BaseContent.Main)
				end
			end),
			Theme.SpringSpeed["1"],
			Theme.SpringDampening["1"]
		),
		Selection = Selection,
	}))
end
