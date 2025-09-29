-- Is this string safe to save in datastores?
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Demojify = require(modules.Serializer.Demojify)
local isNumberSafe = require(script.Parent.isNumberSafe)

return function (value)
	if typeof(value) ~= "string" then
		return false
	end
	local utfLength = utf8.len(value)
	if not utfLength then
		return false
	end
	local safeValue = Demojify.process(value)
	if safeValue ~= value then
		return false
	end
	if not isNumberSafe(value) then
		return false
	end
	return true
end