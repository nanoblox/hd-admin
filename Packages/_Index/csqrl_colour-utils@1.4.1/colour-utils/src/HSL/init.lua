local Assert = require(script.Parent.Util.Assert)

local round = math.round
local floor = math.floor
local clamp = math.clamp
local min = math.min
local max = math.max
local abs = math.abs

--[=[
  @interface HSL
  @within HSL
  .H number
  .S number
  .L number
]=]
export type HSL = {
	H: number,
	S: number,
	L: number,
}

--[=[
  @function toHSL
  @within HSL

  @param color Color3 -- The color to convert.
  @return HSL -- The HSL representation of the color.
]=]
local function ToHSL(color: Color3): HSL
	Assert.typeOf("ToHSL", "color", "Color3", color)

	local channelMin = min(color.R, color.G, color.B)
	local channelMax = max(color.R, color.G, color.B)
	local delta = channelMax - channelMin

	local hue = 0
	local lightness = (channelMax + channelMin) / 2
	local saturation = if delta == 0 then 0 else delta / (1 - abs(2 * lightness - 1))

	if delta == 0 then
		hue = 0
	elseif channelMax == color.R then
		hue = ((color.G - color.B) / delta) % 6
	elseif channelMax == color.G then
		hue = (color.B - color.R) / delta + 2
	else
		hue = (color.R - color.G) / delta + 4
	end

	hue = round(hue * 60)

	if hue < 0 then
		hue += 360
	end

	saturation = clamp(abs(round(saturation * 100)), 0, 100)
	lightness = clamp(abs(round(lightness * 100)), 0, 100)

	return {
		H = hue,
		S = saturation,
		L = lightness,
	}
end

--[=[
  @function fromHSL
  @within HSL

  @param hsl HSL -- The HSL color to convert.
  @return Color3 -- The resulting Color3.
]=]
local function FromHSL(hsl: HSL): Color3
	Assert.typeOf("FromHSL", "hsl", "table", hsl)

	Assert.typeOf("FromHSL", "hsl.H", "number", hsl.H)
	Assert.typeOf("FromHSL", "hsl.S", "number", hsl.S)
	Assert.typeOf("FromHSL", "hsl.L", "number", hsl.L)

	local saturation = hsl.S / 100
	local lightness = hsl.L / 100

	local c = (1 - abs(2 * lightness - 1)) * saturation
	local x = c * (1 - abs((hsl.H / 60) % 2 - 1))
	local m = lightness - c / 2

	local red, green, blue = 0, 0, 0

	if hsl.H >= 0 and hsl.H < 60 then
		red, green, blue = c, x, 0
	elseif hsl.H >= 60 and hsl.H < 120 then
		red, green, blue = x, c, 0
	elseif hsl.H >= 120 and hsl.H < 180 then
		red, green, blue = 0, c, x
	elseif hsl.H >= 180 and hsl.H < 240 then
		red, green, blue = 0, x, c
	elseif hsl.H >= 240 and hsl.H < 300 then
		red, green, blue = x, 0, c
	elseif hsl.H >= 300 and hsl.H < 360 then
		red, green, blue = c, 0, x
	end

	red = min(floor((red + m) * 255), 255)
	green = min(floor((green + m) * 255), 255)
	blue = min(floor((blue + m) * 255), 255)

	return Color3.fromRGB(red, green, blue)
end

--[=[
  @class HSL
]=]
return {
	fromHSL = FromHSL,
	toHSL = ToHSL,
}
