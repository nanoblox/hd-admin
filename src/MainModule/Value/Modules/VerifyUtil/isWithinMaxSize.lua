local VerifyUtil = require(script.Parent)
local processMaxSize = require(script.Parent.processMaxSize)
return function (incomingData, customLimit)
	local limit = customLimit or VerifyUtil.KEY_MAX_CHARACTERS
	local success, size = processMaxSize(incomingData, limit)
	if success then
		return true, size
	else
		return false
	end
end