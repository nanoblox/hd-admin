local validPrefixes = {"!", "/", ".", "?", "~", "-", "$", "%", "^", "&", "*", "+", "=", "<", ">", "|", ":", ";", ","}
local dictionary = {}
for _, prefix in validPrefixes do
	dictionary[prefix] = true
end
return function(incomingPrefix: string)
	local isValid = dictionary[incomingPrefix] == true
	return isValid
end