local PrepFilter = require(script.Parent._Filter)
local rshift = bit32.rshift

--[=[
	@function Screen
	@within Blend

	@param background Color3 -- The background color.
	@param foreground Color3 -- The foreground color.
	@return Color3 -- The resulting color.
]=]
return PrepFilter("Screen", function(background: number, foreground: number): number
	return 255 - rshift(((255 - (foreground * 255)) * (255 - (background * 255))), 8)
end)
