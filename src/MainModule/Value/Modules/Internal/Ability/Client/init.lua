--!strict
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Players = game:GetService("Players")
local getHead = require(modules.PlayerUtil.getHead)
local clientCommands: Task.ClientCommands = {

	--------------------
	{
		name = "NightVision",
		run = function(task: Task.Class)
			local localPlayer = game:GetService("Players").LocalPlayer
			local janitor = task.janitor
			for _, player in Players:GetPlayers() do
				local head = getHead(player)
				local char = player.Character
				if not char or not head or player.Name == localPlayer.Name then
					continue
				end
				for _, instance in char:GetChildren() do
					if not instance:IsA("BasePart") or not instance:FindFirstChild("HDNightVision") == nil then
						continue
					end
					for i: any = 1,6 do
						local nv = janitor:add(script.NightVision:Clone())
						nv.Parent = instance 
						nv.Face = i-1
						nv.Name = "HDAdminNightVision"
					end
				end
				local nv = janitor:add(script.Nickname:Clone())
				nv.TextLabel.Text = player.Name
				nv.Parent = head
				nv.Name = "HDAdminNightVision"
			end
		end,
	},

	--------------------
	{
		name = "Warp",
		run = function(task: Task.Class)
			local localPlayer = game:GetService("Players").LocalPlayer
			local maxDistort = 1
			local increment = 0.005
			local distort = maxDistort-increment
			local distortDirection = -increment
			local RunService = game:GetService("RunService")
			local camera = workspace.CurrentCamera
			repeat RunService.RenderStepped:Wait()
				if distort < increment then
					distort = increment
					distortDirection = increment
				elseif distort > maxDistort then
					distort = maxDistort
					distortDirection = -increment
				end
				camera.CFrame = camera.CFrame*CFrame.new(0,0,0,distort,0,0,0,distort,0,0,0,1)
				distort = distort + distortDirection
			until distort > maxDistort
		end,
	},

	--------------------
	{
		name = "Blur",
		run = function(task: Task.Class, number: number)
			local janitor = task.janitor
			local camera = workspace.CurrentCamera
			local blur = janitor:add(Instance.new("BlurEffect", camera))
			blur.Size = number
		end,
	},

	--------------------
}
return clientCommands