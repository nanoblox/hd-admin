local Assert = require(script.Parent.Util.Assert)
local assertTypeOf = Assert.prepTypeOf("Lighten")

local clampColor = require(script.Parent.Util.ClampColor)

--[=[
	@function Lighten
	@within ColorUtils

	@param color Color3 -- The color to lighten.
	@param coefficient number -- The amount to lighten by [0-1].
	@return Color3 -- The lightened color.
]=]
return function(color: Color3, coefficient: number): Color3
	assertTypeOf("color", "Color3", color)
	assertTypeOf("coefficient", "number", coefficient)

	return clampColor(color:Lerp(Color3.new(1, 1, 1), coefficient))
end
