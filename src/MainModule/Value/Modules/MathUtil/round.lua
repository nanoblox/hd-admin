return function (number: number, decimalPlaces: number): number
	local power = 10^decimalPlaces
	return math.round(number * power) / power
end