local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)

local Icon = require(script.Parent.Icon)
local Components = {
	Icon = Icon,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)

		Scope:Icon {
			Parent = Props.target,
			Image = "rbxassetid://11560341132",
		}
	end,
	fusion = Fusion,
}
