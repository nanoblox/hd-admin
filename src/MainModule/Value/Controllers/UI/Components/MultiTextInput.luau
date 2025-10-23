local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local Children = Fusion.Children

local FilteredTextInput = require(script.Parent.FilteredTextInput)

export type Props = OnyxUI.FrameProps & {
	Items: Fusion.UsedAs<{ string }>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		FilteredTextInput = FilteredTextInput,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local Items = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Items, { "" }))

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Frame {
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},

				[Children] = {
					Scope:ForPairs(Items, function(Use, Scope, Index, Text: string)
						return Index,
							OnyxUI.Themer.Theme:is(Theme):during(function()
								return PanelsStateMod.Panel:is(Panel):during(function()
									local TextReactive = Scope:Value(Text)

									return Scope:FilteredTextInput {
										Text = TextReactive,

										OnFocusEnd = function()
											local TextReactiveValue = Fusion.peek(TextReactive)

											local ItemsValue = Fusion.peek(Items)

											for ItemIndex, _ in ItemsValue do
												if ItemIndex == Index then
													ItemsValue[ItemIndex] = TextReactiveValue

													break
												end
											end

											Items:set(ItemsValue)
										end,
									}
								end)
							end)
					end),
				},
			},
			Scope:Button {
				Content = { "Add" },
				ContentSize = Theme.TextSize["1"],
				SizeVariant = "ExtraLarge",

				OnActivate = function()
					local ItemsValue = Fusion.peek(Items)

					table.insert(ItemsValue, "")

					Items:set(ItemsValue)
				end,
			},
		},
	}))
end
