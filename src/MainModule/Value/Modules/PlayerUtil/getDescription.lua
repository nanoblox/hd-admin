--!strict
local getHumanoid = require(script.Parent.getHumanoid)
local Players = game:GetService("Players")
return function(player: Player?): HumanoidDescription?
	if type(player) == "number" then -- Checks if it's a userId, which if it isn't; it proceeds as normal.
		local hd = Players:GetHumanoidDescriptionFromUserId(player)
		return hd
	else
		local humanoid = getHumanoid(player)
		local hd = humanoid and humanoid:GetAppliedDescription()
		return hd
	end
end
