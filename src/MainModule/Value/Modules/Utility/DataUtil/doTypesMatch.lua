return function (itemA, itemB)
	-- This is more specific, such as checking the enum or classname
	local typeA = typeof(itemA)
	local typeB = typeof(itemB)
	if typeA ~= typeB then
		return false
	end
	if typeA == "EnumItem" then
		if itemA.EnumType ~= itemB.EnumType then
			return false
		end
	elseif typeA == "Instance" then
		if itemA.ClassName ~= itemB.ClassName then
			return false
		end
	end
	return true
end