local push = table.insert

local function map<T>(array: { T }, mapper: (T?, number?) -> T?): { T }
	local mapped = {}

	for index, value in ipairs(array) do
		local mappedValue = mapper(value, index)

		if mappedValue ~= nil then
			push(mapped, mappedValue)
		end
	end

	return mapped
end

local function reduce<T>(
	array: { T },
	reducer: (({ T } | T)?, T?, number?) -> { T } | T,
	initialValue: ({ T } | T)?
): { T } | T
	local result, start = initialValue, 1

	if not result then
		result, start = array[1], 2
	end

	for index = start, #array do
		result = reducer(result, array[index], index)
	end

	return result
end

return {
	map = map,
	reduce = reduce,
}
