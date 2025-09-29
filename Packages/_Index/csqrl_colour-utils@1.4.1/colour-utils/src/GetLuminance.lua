local Assert = require(script.Parent.Util.Assert)

local assertTypeOf = Assert.prepTypeOf("GetLuminance")

local function transformValue(value: number): number
	return value <= 0.03928 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
end

--[=[
	@function GetLuminance
	@within ColorUtils

	@param color Color3 -- The color to get the luminance of.
	@return number -- The luminance of the color [0-1].
]=]
return function(color: Color3): number
	assertTypeOf("color", "Color3", color)

	local red = transformValue(color.R)
	local green = transformValue(color.G)
	local blue = transformValue(color.B)

	local lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue

	return lum
end
