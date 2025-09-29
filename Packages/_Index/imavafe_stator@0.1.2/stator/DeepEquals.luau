local function DeepEquals(TableA: { [any]: any }, TableB: { [any]: any })
	for Key, Value in pairs(TableA) do
		if typeof(Value) == "table" then
			if not DeepEquals(TableB[Key], Value) then
				return false
			end
		elseif Value ~= TableB[Key] then
			return false
		end
	end

	return true
end

return DeepEquals
