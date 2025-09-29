local Assert = require(script.Parent.Util.Assert)
local clampColor = require(script.Parent.Util.ClampColor)

local assertTypeOf = Assert.prepTypeOf("Rotate")
local clamp = math.clamp

--[=[
	@function Rotate
	@within ColorUtils

	@param color Color3 -- The color to rotate.
	@param angle number -- The angle to rotate by.
	@return Color3 -- The rotated color.
]=]
return function(color: Color3, angle: number): Color3
	assertTypeOf("color", "Color3", color)
	assertTypeOf("angle", "number", angle)

	local hue, sat, val = color:ToHSV()
	local newHue = clamp((hue + (angle / 360)) % 1, 0, 1)

	local newColor = Color3.fromHSV(newHue, sat, val)

	return clampColor(newColor)
end
