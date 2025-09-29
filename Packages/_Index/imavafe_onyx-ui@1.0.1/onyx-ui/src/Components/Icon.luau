--[=[
		@class Icon
		
		It's an icon, what else can I say?
]=]

--[=[
		@within Icon
		@interface IconProps

		. ... ImageProps -- All Image properties are accepted.
]=]

local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(script.Parent.Parent.Themer)

local Image = require(script.Parent.Image)
local Components = {
	Image = Image,
}

export type Props = Image.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	return Scope:Image(Util.CombineProps(Props, {
		Name = script.Name,
		Size = Scope:UDim2Offset(Theme.TextSize["1"], Theme.TextSize["1"]),
		BackgroundTransparency = 1,
	}))
end
