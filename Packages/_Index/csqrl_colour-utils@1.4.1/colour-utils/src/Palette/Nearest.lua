--!strict
--[=[
	@function Nearest
	@within Palette

	Given an array of Color3s, returns the color that is closest to the given Color3.

	@param to Color3 -- The color to find the nearest color to.
	@param colors { Color3 } -- The array of colors to search through.
	@return Color3 -- The nearest color.
]=]
local function nearest(to: Color3, colors: { Color3 }): Color3
	assert(typeof(to) == "Color3", `Nearest(...): Expected "to" to be a Color3, got "{to}" ({typeof(to)})`)

	local smallestMagnitude: number = math.huge
	local nearestColor: Color3 = nil
	local didWarn = false

	for index, color in colors do
		if typeof(color) ~= "Color3" then
			if didWarn == false then
				warn(
					`Nearest(...): Expected "colors" to be an array of Color3, got "{color}" ({typeof(color)}) at index #{index}`
				)
				didWarn = true
			end

			continue
		end

		local magnitude = math.sqrt((color.R - to.R) ^ 2 + (color.G - to.G) ^ 2 + (color.B - to.B) ^ 2)

		if magnitude < smallestMagnitude then
			smallestMagnitude = magnitude
			nearestColor = color
		end
	end

	return nearestColor
end

return nearest
