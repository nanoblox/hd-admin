local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Switch = require(script.Parent.Switch)
local Frame = require(script.Parent.Frame)
local Components = {
	Switch = Switch,
	Frame = Frame,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		Scope:Frame {
			Parent = Props.target,
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["1"]),
			},
			List = {
				Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			},

			[Children] = {
				Scope:Switch {},
				Scope:Switch {
					Disabled = true,
				},
			},
		}
	end,
	fusion = Fusion,
}
