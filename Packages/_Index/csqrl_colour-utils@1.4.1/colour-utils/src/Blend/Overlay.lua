local PrepFilter = require(script.Parent._Filter)

--[=[
	@function Overlay
	@within Blend

	@param background Color3 -- The background color.
	@param foreground Color3 -- The foreground color.
	@return Color3 -- The resulting color.
]=]
return PrepFilter("Overlay", function(background: number, foreground: number): number
	local bg = background * 255
	local fg = foreground * 255

	return (bg < 128) and (2 * fg * bg / 255) or (255 - 2 * (255 - bg) * (255 - fg) / 255)
end)
