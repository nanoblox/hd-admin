return function(t)
	local tCopy = table.create(#t)
	for k,v in (t) do tCopy[k] = v end
	return tCopy
end