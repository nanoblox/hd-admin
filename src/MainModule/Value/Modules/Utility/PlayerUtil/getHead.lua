--!strict
local PlayerUtil = require(script.Parent)
return function(player: Player?): BasePart?
    if not player then
		player = PlayerUtil.localPlayer
	end
	local character = player and player.Character
	local head = character and character:FindFirstChild("Head")
	return head
end