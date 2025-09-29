local Assert = require(script.Parent.Parent.Util.Assert)
local isNaN = require(script.Parent.Parent.Util.isNaN)

local CONST = require(script.Parent.Constants)

local function XYZ_RGB(value: number): number
	return 255 * (if value <= 0.00304 then 12.92 * value else 1.055 * value ^ (1 / 2.4) - 0.055)
end

local function LAB_XYZ(value: number): number
	return if value > CONST.t1 then value ^ 3 else CONST.t2 * (value - CONST.t0)
end

--[=[
  @function fromLAB
  @within LAB

  @param lab LAB -- The color to convert.
  @return Color3 -- The converted color.
]=]
local function FromLAB(lab: CONST.LAB): Color3
	Assert.typeOf("FromLAB", "lab", "table", lab)

	Assert.typeOf("FromLAB", "lab.L", "number", lab.L)
	Assert.typeOf("FromLAB", "lab.A", "number", lab.A)
	Assert.typeOf("FromLAB", "lab.B", "number", lab.B)

	local y = (lab.L + 16) / 116
	local x = if isNaN(lab.A) then y else y + lab.A / 500
	local z = if isNaN(lab.B) then y else y - lab.B / 200

	y = CONST.Yn * LAB_XYZ(y)
	x = CONST.Xn * LAB_XYZ(x)
	z = CONST.Zn * LAB_XYZ(z)

	local red = XYZ_RGB(3.2404542 * x - 1.5371385 * y - 0.4985314 * z)
	local green = XYZ_RGB(-0.9692660 * x + 1.8760108 * y + 0.0415560 * z)
	local blue = XYZ_RGB(0.0556434 * x - 0.2040259 * y + 1.0572252 * z)

	return Color3.fromRGB(red, green, blue)
end

return FromLAB
