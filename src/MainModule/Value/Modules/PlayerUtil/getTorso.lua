--!strict
local PlayerUtil = require(script.Parent)
return function(player: Player? | Instance?): (Instance?)
    if not player then
		player = PlayerUtil.localPlayer
	end
	if not player or not player:IsA("Player") then
		return nil
	end
	local character = player and player.Character
	if not character then
		return nil
	end
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if torso then
		return torso
	end
	return nil
end