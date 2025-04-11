local HttpService = game:GetService("HttpService")
return function (incomingData)
	return #HttpService:JSONEncode(incomingData)
end