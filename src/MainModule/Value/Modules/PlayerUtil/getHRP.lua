--!strict
local PlayerUtil = require(script.Parent)
return function(player: Player?): BasePart?
    if not player then
		player = PlayerUtil.localPlayer
	end
	local character = player and player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp and hrp:IsA("BasePart") then
		return hrp
	end
	return nil
end