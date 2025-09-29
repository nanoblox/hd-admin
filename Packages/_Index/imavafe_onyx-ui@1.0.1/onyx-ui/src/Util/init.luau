--[=[
		@class Util
		
		Important utilities for UI development.
]=]

local Colors = require(script.Colors)
local EnsureValue = require(script.EnsureValue)
local CombineProps = require(script.CombineProps)
local Fallback = require(script.Fallback)
local Emphasize = require(script.Emphasize)
local Unit = require(script.Unit)

return {
	Colors = Colors,
	EnsureValue = EnsureValue,
	CombineProps = CombineProps,
	Fallback = Fallback,
	Emphasize = Emphasize,

	Vector2 = Unit.Vector2,
	UDim = Unit.UDim,
	UDim2 = Unit.UDim2,
	UDim2Offset = Unit.UDim2Offset,
	UDim2Scale = Unit.UDim2Scale,
	Font = Unit.Font,
}
