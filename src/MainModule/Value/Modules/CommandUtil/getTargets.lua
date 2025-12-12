--!strict
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
export type TargetType = "All" | "Others" | "Nearby" | "OthersNearby"
return function (targetType: TargetType, originPlayer: Player?, customRadius: number?): {Player}
	local targetPlayers: {Player} = {}
	if targetType == "All" then
		targetPlayers = Players:GetPlayers()
	elseif targetType == "Nearby" or targetType == "OthersNearby" then
		local radius = customRadius or 50
		local getHRP = require(modules.PlayerUtil.getHRP)
		local hrp = getHRP(originPlayer)
		local origin = hrp and hrp.Position
		if origin and radius then
			for _, player in pairs(Players:GetPlayers()) do
				local excludeOriginal = targetType == "OthersNearby" and player == originPlayer
				if not excludeOriginal and player:DistanceFromCharacter(origin) <= radius then
					table.insert(targetPlayers, player)
				end
			end
		end
	elseif targetType == "Others" then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= originPlayer then
				table.insert(targetPlayers, player)
			end
		end
	end
	return targetPlayers
end