--!strict
local Players = game:GetService("Players")
local uneqipTools = require(script.Parent.uneqipTools)
return function(tool: Tool)
	local character = tool.Parent
	local player = character and character:IsA("Model") and Players:GetPlayerFromCharacter(character)
	if not player then
		tool:Destroy()
		return
	end
	uneqipTools(player)
	task.delay(0.01, function()
		tool:Destroy()
	end)
end