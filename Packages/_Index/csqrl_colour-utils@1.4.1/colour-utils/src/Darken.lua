local Assert = require(script.Parent.Util.Assert)
local assertTypeOf = Assert.prepTypeOf("Darken")

local clampColor = require(script.Parent.Util.ClampColor)

--[=[
	@function Darken
	@within ColorUtils

	@param color Color3 -- The color to darken.
	@param coefficient number -- The amount to darken by [0-1].
	@return Color3 -- The darkened color.
]=]
return function(color: Color3, coefficient: number): Color3
	assertTypeOf("color", "Color3", color)
	assertTypeOf("coefficient", "number", coefficient)

	return clampColor(color:Lerp(Color3.new(), coefficient))
end
