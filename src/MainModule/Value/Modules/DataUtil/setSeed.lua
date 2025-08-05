-- We set seed here instead of just math.seed, as once a value
-- exceeds ~1000000000 if continues to generate the same output
-- This accounts for this, and trims the input accordingly
return function(value: number): number
	local LIMIT = 100000000
	if value > LIMIT then
		local maxChars = #tostring(LIMIT)
		value = tonumber(string.sub(tostring(value), -maxChars))
	end
	math.randomseed(value)
	return value
end