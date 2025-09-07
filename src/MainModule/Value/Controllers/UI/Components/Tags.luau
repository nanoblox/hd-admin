local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)

local Children = Fusion.Children

export type Props = OnyxUI.FrameProps & {
	Tags: Fusion.UsedAs<{ { string } }>?,
	Selection: Fusion.UsedAs<number>?,
	Disabled: Fusion.UsedAs<boolean>?,
	Color: Fusion.UsedAs<Color3>?,
	ButtonProps: OnyxUI.ButtonProps?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Tags = OnyxUI.Util.Fallback(Props.Tags, {})
	local Disabled = OnyxUI.Util.Fallback(Props.Disabled, false)
	local Color = OnyxUI.Util.Fallback(Props.Color, Theme.Colors.Primary.Main)
	local Corner = OnyxUI.Util.Fallback(Props.Corner, {
		Radius = Scope:UDim(0, Theme.CornerRadius["1"]),
	})
	local ButtonProps = OnyxUI.Util.Fallback(Props.ButtonProps, {})

	local Selection = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Selection, {}))

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Corner = Corner,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
		},

		[Children] = {
			Scope:ForPairs(Tags, function(Use, Scope, Index: number, Content: { string })
				return Index,
					OnyxUI.Themer.Theme:is(Theme):during(function()
						return Scope:Button(OnyxUI.Util.CombineProps(ButtonProps, {
							Name = "TagButton",
							Content = Content,
							Disabled = Disabled,
							Color = Scope:Computed(function(Use)
								local SelectionValue = Use(Selection)

								if table.find(SelectionValue, Content) then
									return Use(Color)
								else
									return Use(Theme.Colors.Neutral.Main)
								end
							end),
							Corner = Corner,

							OnActivate = function()
								local SelectionValue = Fusion.peek(Selection)
								local TagIndex = table.find(SelectionValue, Content)

								if TagIndex ~= nil then
									table.remove(SelectionValue, TagIndex)
								else
									table.insert(SelectionValue, Content)
								end

								Selection:set(SelectionValue)
							end,
						}))
					end)
			end),
		},
	}))
end
