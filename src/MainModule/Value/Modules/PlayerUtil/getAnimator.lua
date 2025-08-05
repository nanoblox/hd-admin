--!strict
local getHumanoid = require(script.Parent.getHumanoid)
return function(player: Player?): Animator?
	local humanoid = getHumanoid(player)
	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		return animator
	end
	return nil
end