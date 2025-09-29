local Assert = require(script.Parent.Parent.Util.Assert)

local assertTypeOf = Assert.prepTypeOf("Monochromatic")
local assertEvalArg = Assert.prepEvalArg("Monochromatic")

local push = table.insert
local floor = math.floor
local sort = table.sort

--[=[
	@function Monochromatic
	@within Palette

	@param base Color3 -- The base color.
	@param swatches number -- The number of swatches to generate.
	@return {Color3} -- The monochromatic colors.
]=]
return function(base: Color3, swatches: number?): { Color3 }
	swatches = swatches or 3

	assertTypeOf("base", "Color3", base)
	assertTypeOf("swatches", "number", swatches)

	swatches = floor(swatches)
	assertEvalArg("swatches", "be greater than 0", swatches > 0, swatches)

	local h, s, v = base:ToHSV()
	local increment = 1 / swatches

	local colors = {}

	for _ = 1, swatches do
		push(colors, Color3.fromHSV(h, s, v))
		v = (v + increment) % 1
	end

	sort(colors, function(a, b)
		return select(3, a:ToHSV()) < select(3, b:ToHSV())
	end)

	return colors
end
