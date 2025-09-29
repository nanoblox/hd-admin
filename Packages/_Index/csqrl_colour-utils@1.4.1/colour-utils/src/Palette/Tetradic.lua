local Assert = require(script.Parent.Parent.Util.Assert)
local Rotate = require(script.Parent.Parent.Rotate)
local Types = require(script.Parent.Parent.Util.Types)

local assertTypeOf = Assert.prepTypeOf("Tetradic")

type Array<T> = Types.Array<T>

--[=[
	@function Tetradic
	@within Palette

	@param base Color3 -- The base color.
	@return {Color3} -- The tetradic colors.
]=]
return function(base: Color3): Array<Color3>
	assertTypeOf("base", "Color3", base)

	return {
		Rotate(base, -180),
		Rotate(base, -120),
		Rotate(base, -300),
	}
end
