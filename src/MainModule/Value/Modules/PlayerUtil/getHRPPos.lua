--!strict
local getHRP = require(script.Parent.getHRP)
return function(player: Player?): Vector3?
	local hrp = getHRP(player)
	local hrpPos = hrp and hrp.Position
	return hrpPos
end