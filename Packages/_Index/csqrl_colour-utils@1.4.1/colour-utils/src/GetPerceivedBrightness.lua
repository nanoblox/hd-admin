local Assert = require(script.Parent.Util.Assert)

local assertTypeOf = Assert.prepTypeOf("GetPerceivedBrightness")

--[=[
	@function GetPerceivedBrightness
	@within ColorUtils

	@param color Color3 -- The color to get the perceived brightness of.
	@return number -- The perceived brightness of the color [0-1].
]=]
return function(color: Color3): number
	assertTypeOf("color", "Color3", color)

	local red = color.R * 255
	local green = color.G * 255
	local blue = color.B * 255

	local bright = ((red * 299 + green * 587 + blue * 114) / 1000) / 255

	return bright
end
