--!strict
local ORDER = 340
local ROLE = "Ability"
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Teleport",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Bring",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "To",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Apparate",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

	--------------------
	{
		name = "Farland",
		groups = {"Location"},
		args = {"Player"},
		run = function(task, args: {any})
			local target = args[1]
			local oldLocation = target.Character.HumanoidRootPart.CFrame
			task:keep("Indefinitely")
			task:buff(target,"HumanoidDescription", function(hasEnded, isTop)
				oldLocation = target.Character.HumanoidRootPart.CFrame
				local humanoid = getHumanoid(target)
				local location = if hasEnded then oldLocation else CFrame.new(47483648,47483648,47483648)
				if humanoid then
					TeleportAsync(target, location)
				end
			end)
			task:onEnded(function()
				task.wait(0.2)
				TeleportAsync(target, oldLocation)
			end)
		end
	},
	--------------------
}
	
}
return commands
