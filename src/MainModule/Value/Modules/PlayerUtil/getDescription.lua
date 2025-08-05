--!strict
local getHumanoid = require(script.Parent.getHumanoid)
return function(player: Player?): HumanoidDescription?
	local humanoid = getHumanoid(player)
	local hd = humanoid and humanoid:GetAppliedDescription()
	return hd
end