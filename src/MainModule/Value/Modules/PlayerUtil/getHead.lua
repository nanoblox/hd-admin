--!strict
local PlayerUtil = require(script.Parent)
return function(player: Player? | Instance?): (BasePart?, Model?)
    if not player then
		player = PlayerUtil.localPlayer
	end
	if not player or not player:IsA("Player") then
		return nil, nil
	end
	local character = player and player.Character
	local head = character and character:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		return head, character
	end
	return nil, nil
end