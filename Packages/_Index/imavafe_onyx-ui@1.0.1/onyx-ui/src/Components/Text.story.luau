local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)

local Components = {
	Text = require(OnyxUI.Components.Text),
}

return {
	story = function(Props)
		local Scope = Fusion.scoped(Fusion, Util, Components)

		Scope:Text {
			Parent = Props.target,
			Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
		}
	end,
	fusion = Fusion,
}
