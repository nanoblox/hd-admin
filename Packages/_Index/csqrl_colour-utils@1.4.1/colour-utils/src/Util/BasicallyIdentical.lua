local fmt = string.format
local abs = math.abs

local function StringifyColor3(color: Color3): string
	return string.format('Color3<%.3g, %.3g, %.3g> "#%s"', color.R * 255, color.G * 255, color.B * 255, color:ToHex())
end

return function(base: Color3, compare: Color3, distance: number?): boolean
	distance = if type(distance) == "number" then distance else 0.005

	assert(typeof(base) == "Color3", '"Base" is not a Color3')
	assert(typeof(compare) == "Color3", '"Compare" is not a Color3')

	local distRed = abs(base.R - compare.R)
	local distGreen = abs(base.G - compare.G)
	local distBlue = abs(base.B - compare.B)

	local identical = distRed <= distance and distGreen <= distance and distBlue <= distance

	if not identical then
		local problems = {}

		if distRed > distance then
			table.insert(problems, fmt("R was out by %.3g", tostring(abs(distance - distRed))))
		end

		if distGreen > distance then
			table.insert(problems, fmt("G was out by %.3g", tostring(abs(distance - distGreen))))
		end

		if distBlue > distance then
			table.insert(problems, fmt("B was out by %.3g", tostring(abs(distance - distBlue))))
		end

		error(
			fmt(
				"Expected %s (%s) to be within %s, got %s (%s) instead; %s",
				StringifyColor3(base),
				typeof(base),
				tostring(distance),
				StringifyColor3(compare),
				typeof(compare),
				table.concat(problems, ", ")
			),
			2
		)
	end

	return identical
end
