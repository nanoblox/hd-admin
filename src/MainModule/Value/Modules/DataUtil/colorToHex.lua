return function (color3: Color3): string
	local r = math.floor(color3.r*255+.5)
	local g = math.floor(color3.g*255+.5)
	local b = math.floor(color3.b*255+.5)
	return ("%02x%02x%02x"):format(r, g, b)
end