return function (number: number, decimalPlaces: number?): number
	decimalPlaces = decimalPlaces or 0
	local power = 10^decimalPlaces
	return math.round(number * power) / power
end