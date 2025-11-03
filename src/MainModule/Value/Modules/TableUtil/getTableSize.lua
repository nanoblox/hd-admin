return function(t)
	local count = 0
	for _, _ in t do
		count += 1
	end
	return count
end