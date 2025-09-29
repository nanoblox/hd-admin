--[=[
		@class Card
		
		Useful for grouping and displaying Content in a user friendly way.
]=]

--[=[
		@within Card
		@interface CardProps

		. ... FrameProps -- All Frame properties are accepted.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)

local Frame = require(script.Parent.Frame)
local Components = {
	Frame = Frame,
}

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local BackgroundColor3 = Util.Fallback(Props.BackgroundColor3, Theme.Colors.Base.Main)

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		BackgroundColor3 = BackgroundColor3,
		BackgroundTransparency = 0,
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1"]),
		},
		Padding = {
			All = Scope:UDim(0, Theme.Padding["1"]),
		},
		Stroke = {
			Color = Scope:Computed(function(Use)
				return Util.Emphasize(Use(BackgroundColor3), Use(Theme.StrokeEmphasis.Light))
			end),
		},
	}))
end
