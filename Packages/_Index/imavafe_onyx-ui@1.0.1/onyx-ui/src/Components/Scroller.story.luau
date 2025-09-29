local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)

local Scroller = require(script.Parent.Scroller)
local Components = {
	Scroller = Scroller,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)

		Scope:Scroller {
			Parent = Props.target,
			Size = UDim2.fromOffset(200, 200),
			CanvasSize = UDim2.new(UDim.new(1, 0), UDim.new(0, 1000)),
			AutomaticCanvasSize = Enum.AutomaticSize.None,
		}
	end,
	fusion = Fusion,
}
