--!strict
local ORDER = 340
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local teleportAsync = require(modules.PlayerUtil.teleportAsync)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHRP = require(modules.PlayerUtil.getHRP)
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
		args = {"Player"},
		run = function(task, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Teleport", function(hasEnded, originalValue)
				local hrp = getHRP(target)
				local originalCFrame = if hrp then hrp.CFrame else CFrame.new(0, 0, 0)
				local targetCFrame = if hasEnded then originalValue else CFrame.new(583648,683648,583648)
				if hrp then
					hrp.Anchored = true
				end
				teleportAsync(target, targetCFrame)
				if hrp then
					task.wait(3)
					hrp.Anchored = false
				end
				return originalCFrame
			end)
		end
	},
	--------------------
}
	

return commands
