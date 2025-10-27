local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI

local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)
local Config = require(UI.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

local FilteredTextInput = require(script.Parent.FilteredTextInput)

type TextItemProps = {
	Index: number,
	Text: string,
	OnClose: () -> (),
	Items: Fusion.Value<{ string }>,
}
export type Props = OnyxUI.FrameProps & {
	Items: Fusion.UsedAs<{ string }>?,
}

local function TextItem(Scope: Fusion.Scope<>, Props: TextItemProps)
	local Theme = OnyxUI.Themer.Theme:now()

	local Items = Props.Items
	local Index = Props.Index
	local Text = Props.Text
	local OnClose = Props.OnClose

	local TextReactive = Scope:Value(Text)

	return Scope:Frame {
		Name = "TextItem",
		LayoutOrder = Index,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
		},

		[Children] = {
			Scope:FilteredTextInput {
				Text = TextReactive,
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

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
			},
			Scope:IconButton {
				Image = CONFIG.Icons.Close,
				Style = "Ghost",
				Color = Theme.Colors.NeutralContent.Main,

				OnActivate = function()
					OnClose()
				end,
			},
		},
	}
end

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
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
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
									return TextItem(Scope, {
										Index = Index,
										Text = Text,
										Items = Items,

										OnClose = function()
											local ItemsValue = Fusion.peek(Items)

											if #ItemsValue > 1 then
												table.remove(ItemsValue, Index)
											else
												ItemsValue[Index] = ""
											end

											Items:set(ItemsValue)
										end,
									})
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
