local clamp = math.clamp

return function(color: Color3): Color3
	local red = clamp(color.R, 0, 1)
	local green = clamp(color.G, 0, 1)
	local blue = clamp(color.B, 0, 1)

	return Color3.new(red, green, blue)
end
