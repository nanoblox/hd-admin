local Assert = require(script.Parent.Util.Assert)
local assertTypeOf = Assert.prepTypeOf("isDark")

local GetLuminance = require(script.Parent.GetLuminance)

--[=[
	@function isDark
	@within ColorUtils

	@param color Color3 -- The color to check.
	@return boolean -- Whether the color is dark.
]=]
return function(color: Color3): boolean
	assertTypeOf("color", "Color3", color)

	return GetLuminance(color) < 0.5
end
