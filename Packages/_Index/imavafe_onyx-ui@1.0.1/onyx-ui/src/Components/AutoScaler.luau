--[=[
		@class AutoScaler
		
		Automatically scales children for the user's screen. 📱💻📺🥽
]=]

--[=[
	@interface AutoScalerProps
	@within AutoScaler
	
	. ... FrameProps -- All Frame properties are accepted.
	.BaseResolution Vector2 -- The base resolution to scale from.
	.MinScale number -- The minimum scale factor.
	.MaxScale number -- The maximum scale factor.
	.ScaleMultiplier number -- A multiplier applied to the calculated scale.
]=]

local Workspace = game:GetService("Workspace")

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)

local Out = Fusion.Out

local Base = require(script.Parent.Base)
local Frame = require(script.Parent.Frame)
local Components = {
	Base = Base,
	Frame = Frame,
}

export type Props = Base.Props & {
	BaseResolution: Fusion.UsedAs<Vector2>?,
	MinScale: Fusion.UsedAs<number>?,
	MaxScale: Fusion.UsedAs<number>?,
	ScaleMultiplier: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)

	local BaseResolution = Util.Fallback(Props.BaseResolution, Vector2.new())
	local MinScale = Util.Fallback(Props.MinScale, 0.8)
	local MaxScale = Util.Fallback(Props.MaxScale, math.huge)
	local ScaleMultiplier = Util.Fallback(Props.ScaleMultiplier, 1)

	local ViewportSize = Scope:Value(Vector2.new())
	Scope:Hydrate(Workspace.CurrentCamera) {
		[Out "ViewportSize"] = ViewportSize,
	}

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		Scale = {
			Scale = Scope:Computed(function(Use)
				local Ratio = Use(ScaleMultiplier)
					/ math.max(
						(Use(BaseResolution).X / Use(ViewportSize).X),
						(Use(BaseResolution).Y / Use(ViewportSize).Y)
					)
				return math.clamp(Ratio, Use(MinScale), Use(MaxScale))
			end),
		},
	}))
end
