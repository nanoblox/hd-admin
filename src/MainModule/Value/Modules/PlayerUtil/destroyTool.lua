--!strict
local Players = game:GetService("Players")
local unequipTools = require(script.Parent.unequipTools)
return function(tool: Tool)
	local character = tool.Parent
	local player = character and character:IsA("Model") and Players:GetPlayerFromCharacter(character)
	if not player then
		tool:Destroy()
		return
	end
	unequipTools(player)
	task.delay(0.01, function()
		tool:Destroy()
	end)
end