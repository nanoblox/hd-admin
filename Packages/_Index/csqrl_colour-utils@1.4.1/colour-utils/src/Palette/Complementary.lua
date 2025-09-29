local Assert = require(script.Parent.Parent.Util.Assert)
local Rotate = require(script.Parent.Parent.Rotate)
local Types = require(script.Parent.Parent.Util.Types)

local assertTypeOf = Assert.prepTypeOf("Complementary")

type Array<T> = Types.Array<T>

--[=[
	@function Complementary
	@within Palette

	@param base Color3 -- The base color.
	@return {Color3} -- The complementary colors.
]=]
return function(base: Color3): Array<Color3>
	assertTypeOf("base", "Color3", base)

	return {
		Rotate(base, 180),
	}
end
