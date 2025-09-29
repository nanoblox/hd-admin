-- We eliminate dangerous numbers for reasons explained here:
-- https://create.roblox.com/docs/scripting/security/security-tactics#value-validation

return function (value)
	if typeof(value) == "string" then
		value = tonumber(value)
	end
	if typeof(value) ~= "number" then
		return false
	end
	if value ~= value then
		-- NaN is never equal to itself
		return false
	end
	if math.abs(value) == math.huge then
		-- Number could be -inf or +inf
		return false
	end
	return true
end