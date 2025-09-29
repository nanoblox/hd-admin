local Assert = require(script.Parent.Util.Assert)
local assertTypeOf = Assert.prepTypeOf("isLight")

local isDark = require(script.Parent.isDark)

--[=[
	@function isLight
	@within ColorUtils

	@param color Color3 -- The color to check.
	@return boolean -- Whether the color is light.
]=]
return function(color: Color3): boolean
	assertTypeOf("color", "Color3", color)

	return not isDark(color)
end
