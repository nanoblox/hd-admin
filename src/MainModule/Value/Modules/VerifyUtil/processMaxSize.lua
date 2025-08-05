local VerifyUtil = require(script.Parent)
local HttpService = game:GetService("HttpService")
return function (incomingData, customLimit)
	local limit = customLimit or VerifyUtil.KEY_MAX_CHARACTERS*2
	local success, result = pcall(function()
		return HttpService:JSONEncode(incomingData)
	end)
	if success and result then
		local size = #result
		if size <= limit then
			return incomingData, size
		end
	end
	return nil
end