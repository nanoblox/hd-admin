local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local IconSwap = require(script.Parent.IconSwap)
local Frame = require(script.Parent.Frame)

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, {
			IconSwap = IconSwap,
			Frame = Frame,
		})
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
				Scope:IconSwap {
					Options = { "rbxassetid://13852158988", "rbxassetid://13852161637" },
				},
			},
		}
	end,
	fusion = Fusion,
}
