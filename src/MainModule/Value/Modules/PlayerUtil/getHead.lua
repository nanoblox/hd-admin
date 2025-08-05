--!strict
local PlayerUtil = require(script.Parent)
return function(player: Player?): BasePart?
    if not player then
		player = PlayerUtil.localPlayer
	end
	local character = player and player.Character
	local head = character and character:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		return head
	end
	return nil
end