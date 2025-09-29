--[=[
		@class Frame
		
		A barebones container object. Unlike Roblox's `Frame`, it is transparent by default.
]=]

--[=[
		@within Frame
		@interface FrameProps

		. ... BaseProps -- All Base properties are accepted.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)

local Base = require(script.Parent.Base)
local Components = {
	Base = Base,
}

export type Props = Base.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)

	return Scope:Base(Util.CombineProps(Props, {
		ClassName = "Frame",
		Name = script.Name,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	}))
end
