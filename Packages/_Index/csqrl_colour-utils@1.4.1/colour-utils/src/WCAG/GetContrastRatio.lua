local Assert = require(script.Parent.Parent.Util.Assert)
local assertTypeOf = Assert.prepTypeOf("GetContrastRatio")

local GetLuminance = require(script.Parent.Parent.GetLuminance)

local max = math.max
local min = math.min

--[=[
	@function GetContrastRatio
	@within WCAG

	@param foreground Color3 -- The foreground color.
	@param background Color3 -- The background color.
	@return number -- The contrast ratio [0-21].
]=]
return function(foreground: Color3, background: Color3): number
	assertTypeOf("foreground", "Color3", foreground)
	assertTypeOf("background", "Color3", background)

	local lumA = GetLuminance(foreground)
	local lumB = GetLuminance(background)

	return (max(lumA, lumB) + 0.05) / (min(lumA, lumB) + 0.05)
end
