return function(userName: string)
	local Players = game:GetService("Players")
	local success, result = pcall(function()
		return Players:GetUserIdFromNameAsync(userName)
	end)
	return success, result
end