local Assert = require(script.Parent.Util.Assert)
local ClampColor = require(script.Parent.Util.ClampColor)

local assertTypeOf = Assert.prepTypeOf("Saturate")

local clamp = math.clamp

--[=[
  @function Saturate
  @within ColorUtils

  @param color Color3 -- The color to saturate.
  @param coefficient number -- The coefficient to saturate by [0-1].
  @return Color3 -- The saturated color.
]=]
return function(color: Color3, coefficient: number): Color3
	assertTypeOf("color", "Color3", color)
	assertTypeOf("coefficient", "number", coefficient)

	local H, S, V = color:ToHSV()
	S += S * coefficient

	return ClampColor(Color3.fromHSV(H, clamp(S, 0, 1), V))
end
