local Assert = require(script.Parent.Util.Assert)
local ClampColor = require(script.Parent.Util.ClampColor)
local assertTypeOf = Assert.prepTypeOf("Invert")

--[=[
	@function Invert
	@within ColorUtils

	@param color Color3 -- The color to invert.
	@return Color3 -- The inverted color.
]=]
return function(color: Color3): Color3
	assertTypeOf("color", "Color3", color)

	local inverse = Color3.new(1 - color.R, 1 - color.G, 1 - color.B)

	return ClampColor(inverse)
end
