return function(string: string)
	string = string.lower(string or "")
	return string:sub(1,1):upper()..string:sub(2)
end