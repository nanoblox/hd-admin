local Assert = require(script.Parent.Parent.Util.Assert)
local CONST = require(script.Parent.Constants)

local function RGB_XYZ(value: number): number
	if value <= 0.04045 then
		return value / 12.92
	end

	return ((value + 0.055) / 1.055) ^ 2.4
end

local function XYZ_LAB(value: number): number
	if value > CONST.t3 then
		return value ^ (1 / 3)
	end

	return value / CONST.t2 + CONST.t0
end

local function ToVector3(color: Color3): Vector3
	local red = RGB_XYZ(color.R)
	local green = RGB_XYZ(color.G)
	local blue = RGB_XYZ(color.B)

	return Vector3.new(
		XYZ_LAB((0.4124564 * red + 0.3575761 * green + 0.1804375 * blue) / CONST.Xn),
		XYZ_LAB((0.2126729 * red + 0.7151522 * green + 0.0721750 * blue) / CONST.Yn),
		XYZ_LAB((0.0193339 * red + 0.1191920 * green + 0.9503041 * blue) / CONST.Zn)
	)
end

--[=[
  @function toLAB
  @within LAB

  @param color Color3 -- The color to convert.
  @return LAB -- The converted color.
]=]
local function ToLAB(color: Color3): CONST.LAB
	Assert.typeOf("ToLAB", "color", "Color3", color)

	local vector = ToVector3(color)
	local l = 116 * vector.Y - 16

	return {
		L = if l < 0 then 0 else l,
		A = 500 * (vector.X - vector.Y),
		B = 200 * (vector.Y - vector.Z),
	}
end

return ToLAB
