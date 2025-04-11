--!strict
local PlayerUtil = require(script.Parent)
return function(player: Player?): Humanoid?
    if not player then
		player = PlayerUtil.localPlayer
	end
	local character = player and player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	return humanoid
end