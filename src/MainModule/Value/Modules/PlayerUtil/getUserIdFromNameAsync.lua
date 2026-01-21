return function(userName: string)
	local Players = game:GetService("Players")
	for _, player in Players:GetPlayers() do
		if player.Name:lower() == userName:lower() then
			return true, player.UserId
		end
	end
	local success, result = pcall(function()
		return Players:GetUserIdFromNameAsync(userName)
	end)
	return success, result
end