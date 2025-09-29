--!strict
local convertFromLAB = require(script.Parent.FromLAB)
local convertToLAB = require(script.Parent.ToLAB)

--[=[
	@function Lerp
	@within LAB

	Interpolates between two Color3s using the CIELAB color space.

	@param from Color3 -- The color to interpolate from.
	@param to Color3 -- The color to interpolate to.
	@param alpha number -- The amount to interpolate by (typically between 0-1).
	@return Color3 -- The resulting color.
]=]
local function lerp(from: Color3, to: Color3, alpha: number): Color3
	assert(typeof(from) == "Color3", `Lerp(...): Expected "from" to be a Color3, got {typeof(from)}`)
	assert(typeof(to) == "Color3", `Lerp(...): Expected "to" to be a Color3, got {typeof(to)}`)
	assert(typeof(alpha) == "number", `Lerp(...): Expected "alpha" to be a number, got {typeof(alpha)}`)

	local fromLAB = convertToLAB(from)
	local toLAB = convertToLAB(to)

	local L = fromLAB.L * (1 - alpha) + toLAB.L * alpha
	local A = fromLAB.A * (1 - alpha) + toLAB.A * alpha
	local B = fromLAB.B * (1 - alpha) + toLAB.B * alpha

	return convertFromLAB({ L = L, A = A, B = B })
end

return lerp
