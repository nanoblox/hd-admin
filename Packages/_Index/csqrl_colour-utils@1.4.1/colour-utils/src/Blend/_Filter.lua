local Assert = require(script.Parent.Parent.Util.Assert)
local ClampColor = require(script.Parent.Parent.Util.ClampColor)

return function(filterName: string, applyFilter: (number, number) -> number): (Color3, Color3) -> Color3
	local assertTypeOf = Assert.prepTypeOf(filterName)

	return function(background: Color3, foreground: Color3): Color3
		assertTypeOf("background", "Color3", background)
		assertTypeOf("foreground", "Color3", foreground)

		local newColor = Color3.fromRGB(
			applyFilter(background.R, foreground.R),
			applyFilter(background.G, foreground.G),
			applyFilter(background.B, foreground.B)
		)

		return ClampColor(newColor)
	end
end
