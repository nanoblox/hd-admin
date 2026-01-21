return function(userId: number | string)
	userId = tonumber(userId)
	if not userId then
		return false, "Invalid UserId"
	end
	local Players = game:GetService("Players")
	for _, player in Players:GetPlayers() do
		if player.UserId == userId then
			return true, player.Name
		end
	end
	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	return success, result
end