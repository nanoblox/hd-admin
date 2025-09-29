--[=[
		@class Tabs
		
		For tabbing between things.
]=]

--[=[
	@interface TabsProps
	@within Tabs

	. ... ButtonProps -- All Button properties are accepted.
	.Tabs { { string } }? -- List of tabs
	.Tab number? -- The currently active tab
	.Disabled boolean? -- Whether the tabs are disabled
	.Color Color3? -- Color of the active tab
	.ButtonProps Button.Props? -- Property overrides for child buttons
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)

local Children = Fusion.Children

local Frame = require(script.Parent.Frame)
local Button = require(script.Parent.Button)

export type Props = Frame.Props & {
	Tabs: Fusion.UsedAs<{ { string } }>?,
	Tab: Fusion.UsedAs<number>?,
	Disabled: Fusion.UsedAs<boolean>?,
	Color: Fusion.UsedAs<Color3>?,
	ButtonProps: Button.Props?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, {
		Frame = Frame,
		Button = Button,
	})
	local Theme = Themer.Theme:now()

	local Tabs = Util.Fallback(Props.Tabs, {})
	local Disabled = Util.Fallback(Props.Disabled, false)
	local Color = Util.Fallback(Props.Color, Theme.Colors.Primary.Main)
	local Corner = Util.Fallback(Props.Corner, {
		Radius = Scope:UDim(0, Theme.CornerRadius["1"]),
	})
	local ButtonProps = Util.Fallback(Props.ButtonProps, {})

	local Tab = Scope:EnsureValue(Util.Fallback(Props.Tab, 1))

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		Corner = Corner,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
		},

		[Children] = {
			Scope:ForPairs(Tabs, function(Use, Scope, Index: number, TabContent: { string })
				return Index,
					Themer.Theme:is(Theme):during(function()
						return Scope:Button(Util.CombineProps(ButtonProps, {
							Name = "Tab",
							Content = TabContent,
							Disabled = Disabled,
							Color = Scope:Computed(function(Use)
								if Index == Use(Tab) then
									return Use(Color)
								else
									return Use(Theme.Colors.Neutral.Main)
								end
							end),
							Corner = Corner,

							OnActivate = function()
								Tab:set(Index)
							end,
						}))
					end)
			end),
		},
	}))
end
