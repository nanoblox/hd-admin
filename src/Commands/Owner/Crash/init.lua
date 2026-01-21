--!strict
local ORDER = 600
local ROLES = {script.Parent.Name, "Moderate"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Crash",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local crash = script.CrashScript:Clone()
			local playerGui = target:FindFirstChildOfClass("PlayerGui")
			if not playerGui then return end
			crash.Parent = playerGui
			crash.Disabled = false
		end
	},

    --------------------
	
}
return commands