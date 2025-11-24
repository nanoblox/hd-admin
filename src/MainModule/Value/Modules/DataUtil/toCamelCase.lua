local function toCamelCase(s: string): string
	if s == nil or s == "" then
		return ""
	end

	-- Normalize separators to spaces (treat any non-alphanumeric as a separator)
	local norm = s:gsub("[^%w]", " ")

	-- Insert spaces for camel/Pascal/acronym boundaries:
	--  - lowerUpper -> "lower Upper" (split before an uppercase after a lowercase)
	--  - upperUpperLower -> "upper UpperLower" (split acronym from following mixed-case word)
	norm = norm
		:gsub("(%l)(%u)", "%1 %2")
		:gsub("(%u)(%u%l)", "%1 %2")

	-- Split into words
	local words = {}
	for w in norm:gmatch("%S+") do
		table.insert(words, w)
	end
	if #words == 0 then
		return ""
	end

	-- Build camelCase: first word all lower, subsequent words Capitalized
	local parts = {}
	parts[1] = string.lower(words[1])
	for i = 2, #words do
		local w = words[i]
		local first = w:sub(1, 1)
		local rest = w:sub(2)
		parts[i] = string.upper(first) .. string.lower(rest)
	end

	return table.concat(parts, "")
end

return toCamelCase