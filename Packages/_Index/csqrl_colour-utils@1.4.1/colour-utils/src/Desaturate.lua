local Assert = require(script.Parent.Util.Assert)
local Saturate = require(script.Parent.Saturate)

local assertTypeOf = Assert.prepTypeOf("Saturate")

--[=[
  @function Desaturate
  @within ColorUtils

  @param color Color3 -- The color to desaturate.
  @param coefficient number -- The coefficient to desaturate by [0-1].
  @return Color3 -- The desaturated color.
]=]
return function(color: Color3, coefficient: number): Color3
	assertTypeOf("color", "Color3", color)
	assertTypeOf("coefficient", "number", coefficient)

	return Saturate(color, -coefficient)
end
