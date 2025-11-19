return function (hex: string): Color3
	hex = hex:gsub("#","")
	local r = tonumber("0x"..hex:sub(1,2))
	local g = tonumber("0x"..hex:sub(3,4))
	local b = tonumber("0x"..hex:sub(5,6))
	return Color3.fromRGB(r,g,b)
end