local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Sift = require(HDAdminUI.Parent.Parent.Packages.Sift)

local Children = Fusion.Children

local CheckItem = require(script.Parent.CheckItem)

export type Props = OnyxUI.FrameProps & {
	Items: Fusion.UsedAs<{ string }>?,
	Selection: Fusion.Value<{ number }>?,
	ButtonProps: Fusion.UsedAs<OnyxUI.ButtonProps>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		CheckItem = CheckItem,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Items = OnyxUI.Util.Fallback(Props.Items, {})
	local Selection = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Selection, {}))
	local ButtonProps = OnyxUI.Util.Fallback(Props.ButtonProps, {})

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:ForValues(Items, function(Use, Scope, Content: string)
				local Checked = Scope:Value(false)

				local function UpdateChecked()
					Checked:set(table.find(Fusion.peek(Selection), Content) ~= nil)
				end

				Scope:Observer(Selection):onChange(function()
					UpdateChecked()
				end)
				UpdateChecked()

				return OnyxUI.Themer.Theme:is(Theme):during(function()
					return Scope:CheckItem(OnyxUI.Util.CombineProps(ButtonProps, {
						Content = Content,
						Checked = Checked,
						LayoutOrder = Scope:Computed(function(Use)
							local SelectionValue = Use(Selection)

							return string.byte(tostring(Content))
						end),

						OnCheck = function()
							local SelectionValue = Fusion.peek(Selection)
							local Index = table.find(SelectionValue, Content)

							if Index ~= nil then
								table.remove(SelectionValue, Index)
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
