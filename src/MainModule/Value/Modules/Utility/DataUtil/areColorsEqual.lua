return function(colorA: Color3, colorB: Color3, epsilonIncoming: number): boolean
	local epsilon = epsilonIncoming or 0.001
	if math.abs(colorA.R - colorB.R) > epsilon then
		return false
	end
	if math.abs(colorA.G - colorB.G) > epsilon then
		return false
	end
	if math.abs(colorA.B - colorB.B) > epsilon then
		return false
	end
	return true
end