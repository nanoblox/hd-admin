local Darken = require(script.Parent.Darken)
local GetLuminance = require(script.Parent.GetLuminance)
local Lighten = require(script.Parent.Lighten)

--[=[
	@function Emphasize
	@within ColorUtils

	@param color Color3 -- The color to emphasize.
	@param coefficient number -- The amount to emphasize by [0-1].
	@param threshold? number -- The threshold for light/dark [0-1] (defaults to 0.5).
	@return Color3 -- The emphasized color.
]=]
return function(color: Color3, coefficient: number, threshold: number?): Color3
	threshold = type(threshold) == "number" and threshold or 0.5
	return GetLuminance(color) > threshold and Darken(color, coefficient) or Lighten(color, coefficient)
end
