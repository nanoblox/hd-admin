--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Prompt = require(modules.Prompt)
local Players = game:GetService("Players")
local clientCommands: Task.ClientCommands = {

	--------------------
	{
		name = "Ping",
		run = function(task: Task.Class, hello)
			local startTime = tick()
			local randomValue = math.random(1,1000)
			task.server:replicate(startTime, randomValue)
		end,
		replication = function(startTime: number, returnValue: number)
			local DEPTH = 1000
			local round = require(modules.MathUtil.round)
			local timeTaken = tick() - startTime
			local ping = timeTaken/2
			local pingMs = ping*DEPTH
			local pingMsRounded = round(pingMs, 2)
			Prompt.info(`Your ping is {pingMsRounded} ms`)
		end
	},

	--------------------
	{
		name = "HideGuis",
		run = function(task: Task.Class, hello)
			local localPlayer = Players.LocalPlayer
			local playerGui = localPlayer:WaitForChild("PlayerGui", 3)
			if not playerGui then
				return
			end
			for _, instance in playerGui:GetChildren() do
				if not instance:IsA("ScreenGui") then
					continue
				end
				if not instance.Enabled then
					continue
				end
				if instance.Name == "HDAdmin" then
					continue
				end
				instance.Enabled = false
				task:onEnded(function()
					instance.Enabled = true
				end)
			end
		end,
	},

	--------------------
}

return clientCommands