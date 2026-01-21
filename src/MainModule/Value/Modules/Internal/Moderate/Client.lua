--!strict
-- LOCAL
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local StarterGui = game:GetService("StarterGui")


-- COMMANDS
local clientCommands: Task.ClientCommands = {

	--------------------
	{
		name = "Mute",
		run = function(task: Task.Class)
			local getCoreGuiEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
			if getCoreGuiEnabled then
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
				task:onEnded(function()
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
				end)
			end
		end,
	},

	--------------------
}


return clientCommands