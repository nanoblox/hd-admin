--!strict
-- For the reasons explaind in the server command module, this is NOT the most optimal
-- and desirable way to create Client commands. Typically, it's much better practise
-- to create them via Client Command tables and their tasks, etc. I have done this
-- for now to quickly transition commands over to v2, and will likely re-write a later date


-- LOCAL
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Remote = require(modules.Objects.Remote)
local controlAction = Remote.get("ControlAction")
local Task = require(modules.Objects.Task)


-- SETUP
controlAction:onClientEvent(function(action: string, value: any)
	if action == "BecomeControlled" then
		local enabled = value
		local playerscripts = localPlayer.PlayerScripts :: any
		if not playerscripts then
			return
		end
		local playerModule = playerscripts:WaitForChild("PlayerModule", 3) :: ModuleScript?
		if not playerModule then
			return
		end
		local playerModule = require(playerModule) :: any
		local controls = playerModule and playerModule:GetControls()
		local char = localPlayer.Character
		local animate = char and char:FindFirstChild("Animate")
		if controls and animate and animate:IsA("LocalScript") then
			if enabled then
				if animate then
					animate.Enabled = false
				end
				controls:Disable()
			else
				controls:Enable()
				if animate then
					animate.Enabled = true
				end
			end
		end

	elseif action == "ViewPlayer" then
		local setCameraSubject = require(modules.CommandUtil.setCameraSubject)
		setCameraSubject(value)

	elseif action == "SetResetButtonCallbackEnabled" then
		local StarterGui = game:GetService("StarterGui")
		local RunService = game:GetService("RunService")
		for i = 1, 100 do
			local success = pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", value)
			if success then
				break
			end
			RunService.Heartbeat:Wait()
		end

	end
end)


-- COMMANDS
local clientCommands: Task.ClientCommands = {

	--------------------
	{
		name = "Control",
		run = function(task: Task.Class)
			
		end,
	},

	--------------------
}


return clientCommands

