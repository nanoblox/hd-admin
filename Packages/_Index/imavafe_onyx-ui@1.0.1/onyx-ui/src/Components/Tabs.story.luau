local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Tabs = require(script.Parent.Tabs)
local Frame = require(script.Parent.Frame)
local Components = {
	Tabs = Tabs,
	Frame = Frame,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			List = {
				Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
			},
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["1"]),
			},

			[Children] = {
				Scope:Tabs {
					Tabs = { { "Tab 1" }, { "Tab 2" } },
				},
				Scope:Tabs {
					Tabs = { { "Tab 1" }, { "Tab 2" } },
					Disabled = true,
				},
				Scope:Tabs {
					Tabs = { { "1" }, { "2" }, { "3" } },
					Color = Theme.Colors.BaseContent.Main,
					Corner = {
						Radius = Scope:UDim(0, Theme.CornerRadius["0"]),
					},
					List = {
						Padding = Scope:UDim(0, Theme.Spacing["0"]),
					},
				},
			},
		}
	end,
	fusion = Fusion,
}
