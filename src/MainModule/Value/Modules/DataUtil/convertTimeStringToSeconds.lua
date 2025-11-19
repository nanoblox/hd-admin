return function(timeString: string)
	local totalSeconds = tonumber(timeString) or 0 -- if somebody just specified "100" without any pattern identifiers then by default convert that to seconds
	local patternValues = {
		["s"] = 1, -- seconds
		["m"] = 60, -- minutes
		["h"] = 3600, -- hours
		["d"] = 86400, -- days
		["w"] = 604800, -- weeks
		["o"] = 2628000, -- months
		["y"] = 31540000, -- years
	}
	for value, unit in string.gmatch(timeString, "(%d+)(%a)") do
		local unitValue = patternValues[unit]
		if not unitValue then
			continue
		end
		totalSeconds += value * patternValues[unit]
	end
	return totalSeconds
end