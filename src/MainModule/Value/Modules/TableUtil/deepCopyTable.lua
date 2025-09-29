-- Performs a deep copy of the given table. In other words,
-- all nested tables will also get copied.
local function deepCopyTable(t): {any}
	assert(type(t) == "table", "First argument must be a table")
	local tCopy = table.create(#t)
	for k,v in (t) do
		if (type(v) == "table") then
			tCopy[k] = deepCopyTable(v)
		else
			tCopy[k] = v
		end
	end
	return tCopy :: {any}
end
return deepCopyTable