local function Loose(schema: table, input: table?): table
	if type(input) ~= "table" then
		return schema
	end

	local output = {}

	for key, value in pairs(schema) do
		output[key] = input[key] or value
	end

	return output
end

local function Strict(schema: table, input: table?): table
	if type(input) ~= "table" then
		return schema
	end

	local output = {}

	for key, value in pairs(schema) do
		if typeof(input[key]) == typeof(value) then
			output[key] = input[key]
		else
			output[key] = value
		end
	end

	return output
end

return {
	Loose = Loose,
	Strict = Strict,
}
