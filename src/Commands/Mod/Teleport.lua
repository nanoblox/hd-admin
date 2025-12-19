--!strict
local ORDER = 340
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local TeleportAsync = require(modules.PlayerUtil.teleportAsync)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getDescription = require(modules.PlayerUtil.getDescription)
local getHRPPos = require(modules.PlayerUtil.getHRPPos)
local commands: Task.Commands = {

    --------------------
	{
		name = "Teleport",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Bring",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "To",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Apparate",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
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
			local oldLocation = getHRP(target).CFrame
			task:keep("Indefinitely")
			task:buff(target,"HumanoidDescription", function(hasEnded, isTop)
				local humanoid = getHumanoid(target)
				local location = if hasEnded then oldLocation else CFrame.new(583648,683648,583648)
				if humanoid then
					TeleportAsync(target, location)
				end
			end)
			task:onEnded(function()
				TeleportAsync(target, oldLocation)
			end)
		end
	},
	--------------------
}
	
}
return commands
