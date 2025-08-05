--!strict
local getHead = require(script.Parent.getHead)
return function(player: Player?): Vector3?
    local head = getHead(player)
	local headPos = head and head.Position
	return headPos
end