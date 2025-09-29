local Assert = require(script.Parent.Parent.Util.Assert)
local GetLuminance = require(script.Parent.Parent.GetLuminance)
local Schema = require(script.Parent.Parent.Util.Schema)
local Types = require(script.Parent.Parent.Util.Types)

local assertArrayOf = Assert.prepArrayOf("Vibrant")

local abs = math.abs
local sqrt = math.sqrt
local toHSV = Color3.toHSV

type Array<T> = Types.Array<T>

export type VibrantOptions = {
	TargetLuminance: number,
	TargetSaturation: number,
	TargetValue: number,
}

--[=[
	@interface VibrantOptions
	@within Palette
	.TargetLuminance number -- The target luminance.
	.TargetSaturation number -- The target saturation.
	.TargetValue number -- The target value.
]=]
local DEFAULT_OPTIONS: VibrantOptions = {
	TargetLuminance = 0.49,
	TargetSaturation = 1,
	TargetValue = 0.8,
}

--[=[
	@function Vibrant
	@within Palette

	The default options are:

	```lua
	{
		TargetLuminance = 0.49,
		TargetSaturation = 1,
		TargetValue = 0.8,
	}
	```

	@param swatches {Color3} -- The swatches to select from.
	@param options? VibrantOptions -- The options to use.
	@return Color3 -- The "most vibrant" color.
]=]
return function(swatches: Array<Color3>, options: VibrantOptions?): Color3
	assertArrayOf("swatches", "Color3", swatches)

	options = Schema.Loose(DEFAULT_OPTIONS, options) :: VibrantOptions

	local vibrant: Color3 = nil
	local distance = math.huge

	for _, swatch in ipairs(swatches) do
		local _, sat, val = toHSV(swatch)
		local lum = GetLuminance(swatch)

		local deltaSat = abs(sat - options.TargetSaturation)
		local deltaVal = abs(val - options.TargetValue)
		local deltaLum = abs(lum - options.TargetLuminance)

		local dist = sqrt((deltaSat ^ 2) + (deltaVal ^ 2) + (deltaLum ^ 2))

		if dist < distance then
			distance = dist
			vibrant = swatch
		end
	end

	return vibrant
end
