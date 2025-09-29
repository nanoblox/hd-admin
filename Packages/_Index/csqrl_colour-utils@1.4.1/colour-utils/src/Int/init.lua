local Assert = require(script.Parent.Util.Assert)
local ClampColor = require(script.Parent.Util.ClampColor)

local floor = math.floor
local rshift = bit32.rshift
local lshift = bit32.lshift
local band = bit32.band

--[=[
	@function fromInt
	@within Int

	@param int number -- The integer to convert.
	@return Color3 -- The resulting Color3.
]=]
local function FromInt(int: number): Color3
	Assert.typeOf("FromInt", "int", "number", int)
	int = floor(int)

	local red = band(rshift(int, 16), 255)
	local green = band(rshift(int, 8), 255)
	local blue = band(int, 255)

	return ClampColor(Color3.fromRGB(red, green, blue))
end

--[=[
	@function toInt
	@within Int

	@param color Color3 -- The color to convert.
	@return number -- The integer representation of the color.
]=]
local function ToInt(color: Color3): number
	Assert.typeOf("ToInt", "color", "Color3", color)

	local int = floor(color.R * 255)
	int = lshift(int, 8) + floor(color.G * 255)
	int = lshift(int, 8) + floor(color.B * 255)

	return int
end

--[=[
	@class Int
]=]
return {
	fromInt = FromInt,
	toInt = ToInt,
}
