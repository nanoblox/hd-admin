--!strict
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local clientCommands: Task.ClientCommands = {

	--------------------
	{
		name = "View",
		run = function(task: Task.Class, playerToView: Player)
			if not playerToView then return end
			local localPlayer = game:GetService("Players").LocalPlayer
			local janitor = task.janitor
			local setCameraSubject = require(modules.CommandUtil.setCameraSubject)
			setCameraSubject(playerToView)
			janitor:add(playerToView.CharacterAdded:Connect(function()
				local char = playerToView.Character or playerToView.CharacterAdded:Wait()
				task.wait()
				setCameraSubject(playerToView)
			end))
			janitor:add(playerToView:GetPropertyChangedSignal("Parent"):Once(function()
				setCameraSubject(localPlayer)
			end))
			task:onEnded(function()
				setCameraSubject(localPlayer)
			end)
		end,
	},

	--------------------
}
return clientCommands