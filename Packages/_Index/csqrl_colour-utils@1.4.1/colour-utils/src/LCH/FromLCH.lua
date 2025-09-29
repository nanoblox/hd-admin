local Assert = require(script.Parent.Parent.Util.Assert)
local isNaN = require(script.Parent.Parent.Util.isNaN)

local CONST = require(script.Parent.Constants)
local LAB = require(script.Parent.Parent.LAB)

local sin = math.sin
local cos = math.cos

local function LCHtoLAB(lch: CONST.LCH): LAB.LAB
	if isNaN(lch.H) then
		lch.H = 0
	end

	lch.H *= CONST.DEG_RAD

	return {
		L = lch.L,
		A = cos(lch.H) * lch.C,
		B = sin(lch.H) * lch.C,
	}
end

--[=[
	@function fromLCH
	@within LCH

	@param lch LCH -- The color to convert.
	@return Color3 -- The converted color.
]=]
local function FromLCH(lch: CONST.LCH): Color3
	Assert.typeOf("FromLCH", "lch", "table", lch)

	Assert.typeOf("FromLCH", "lch.L", "number", lch.L)
	Assert.typeOf("FromLCH", "lch.C", "number", lch.C)
	Assert.typeOf("FromLCH", "lch.H", "number", lch.H)

	local lab = LCHtoLAB(lch)
	return LAB.fromLAB(lab)
end

return FromLCH
