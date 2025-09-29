local Assert = require(script.Parent.Util.Assert)
local ClampColor = require(script.Parent.Util.ClampColor)
local Transparency = require(script.Parent.Blend.Transparency)

local sub = string.sub
local gsub = string.gsub
local fmt = string.format
local rep = string.rep
local split = string.split

local HEX_EXCLUDE_PATTERN = "[^A-Fa-f0-9]"
local HEX_FORMAT_PATTERN = "%.2x%.2x%.2x"
local BACKGROUND_BASE_COLOR = Color3.new()

--[=[
	@function fromHex
	@within Hex

	:::tip

	You can use hex values in any format. This includes with or without
	a leading hash, any case, and any length (`FromHex` will try to
	interpret malformed hex codes as best as possible).

	:::

	@param hex string -- The hex string to convert.
	@return Color3 -- The resulting Color3.
]=]
local function FromHex(hex: string): Color3
	Assert.typeOf("FromHex", "hex", "string", hex)

	hex = gsub(hex, HEX_EXCLUDE_PATTERN, "")

	if #hex == 3 then
		local characters = split(hex, "")
		local finalHex = ""

		for _, character in ipairs(characters) do
			finalHex ..= rep(character, 2)
		end

		hex = finalHex
	elseif #hex < 6 then
		hex = fmt("%s%s", hex, rep(hex, 6 - #hex))
	end

	local red = tonumber(sub(hex, 1, 2), 16)
	local green = tonumber(sub(hex, 3, 4), 16)
	local blue = tonumber(sub(hex, 5, 6), 16)

	return ClampColor(Color3.fromRGB(red, green, blue))
end

--[=[
	@function fromHexRGBA
	@within Hex

	Creates a Color3 from a hex string with an alpha value. The background
	doesn't need to be specified, but the resulting Color3 will vary
	depending on the color of the background, so it's recommended to
	specify a background unless `Color3.new()` is what you want.

	If the hex string is less than 8 characters, it will be passed to
	`fromHex` and the resulting Color3 will be returned without transparency
	applied.

	Hex strings longer than 8 characters will be truncated to 8 characters
	will be accepted. If the hex string is longer than 8 characters, the
	last two characters will be used as the alpha value.

	@param hex string -- The hex string to convert.
	@param background Color3? -- The background color (defaults to black).
	@return Color3 -- The resulting Color3.
]=]
local function FromHexRGBA(hex: string, background: Color3?): Color3
	Assert.typeOf("FromHexRGBA", "hex", "string", hex)

	hex = gsub(hex, HEX_EXCLUDE_PATTERN, "")

	if #hex < 8 then
		return FromHex(hex)
	end

	local transparency = 1 - (tonumber(sub(hex, -2), 16) / 255)
	local color = FromHex(sub(hex, 1, -3))

	return Transparency(color, background or BACKGROUND_BASE_COLOR, transparency)
end

--[=[
	@function toHex
	@within Hex

	:::note

	The hex string is always lowercase, will always be 6 characters long, and
	is not prefixed with a hash.

	:::

	@param color Color3 -- The color to convert.
	@return string -- The hex representation of the color.
]=]
local function ToHex(color: Color3): string
	Assert.typeOf("ToHex", "color", "Color3", color)

	local red = color.R * 255
	local green = color.G * 255
	local blue = color.B * 255

	local hex = fmt(HEX_FORMAT_PATTERN, red, green, blue)

	return hex
end

--[=[
	@class Hex
]=]
return {
	fromHex = FromHex,
	fromHexRGBA = FromHexRGBA,
	toHex = ToHex,
}
