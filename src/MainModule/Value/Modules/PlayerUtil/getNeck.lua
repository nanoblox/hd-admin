--!strict
local getHead = require(script.Parent.getHead)
return function(player: Player?): Motor6D?
    local head = getHead(player)
	if not head then
		return nil
	end
	local char = head.Parent :: Model
	local neck = head:FindFirstChild("Neck")
	local torso = char:FindFirstChild("Torso")
	if not neck and torso then
		neck = torso:FindFirstChild("Neck")
	end
	return neck :: Motor6D?
end