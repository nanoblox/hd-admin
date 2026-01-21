--!strict
local ORDER = 80
local ROLES = {script.Parent.Name, "Utility"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local Task = require(modules.Objects.Task)
local loadCommand = Internal.loadCommand
local Prompt = require(modules.Prompt)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
type Command = Task.Command

local commands: Task.Commands = {
	
    --------------------
	{
		name = "Ping",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target: Player = unpack(args)
			task.client:run(target)
			task.client.replicator = function(replicateTo, ...)
				replicateTo(target, ...)
			end
			task.wait(1)
		end
	},

    --------------------
	{
		name = "HideGuis",
		aliases = {"HideScreen"},
		undoAliases = {"ShowGuis", "ShowScreen"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target: Player = unpack(args)
			task:keep("UntilTargetLeaves")
			task.client:run(target)
		end
	},

    --------------------
	loadCommand("Other", "Commands", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	
}

return commands