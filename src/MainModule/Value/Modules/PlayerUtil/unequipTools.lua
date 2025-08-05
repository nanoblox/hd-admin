--!strict
local getHumanoid = require(script.Parent.getHumanoid)
return function(player: Player?): (boolean, string)
	local humanoid = getHumanoid(player)
	if not humanoid or not player then
		return false, "Missing Humanoid or Character or Player"
	end
	local character = player.Character
	if not character then
		return false, "Missing Character"
	end
	humanoid:UnequipTools()
	return true, "Success"
end