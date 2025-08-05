return function(t)
	assert(type(t) == "table", "First argument must be a table")
	local j, temp
	for i = #t, 1, -1 do
		j = math.random(i)
		temp = t[i]
		t[i] = t[j]
		t[j] = temp
	end
	return t
end