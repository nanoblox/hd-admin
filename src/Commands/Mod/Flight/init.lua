--!strict
local ORDER = 210
local ROLES = {script.Parent.Name, "Ability"}
local GROUPS = {"Flight"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Fly",
		aliases = {"Flight"},
		groups = GROUPS,
		roles = ROLES,
		order = ORDER,
		args = {"Player", "FlightSpeed"},
		run = function(task: Task.Class, args: {any})
			local target, flightSpeed = unpack(args)
			task:keep("UntilTargetRespawns")
			task.client:run(target, flightSpeed)
		end
	},

    --------------------
	{
		name = "Fly2",
		aliases = {"Flight2"},
		groups = GROUPS,
		roles = ROLES,
		order = ORDER,
		args = {"Player", "FlightSpeed"},
		run = function(task: Task.Class, args: {any})
			local target, flightSpeed = unpack(args)
			task:keep("UntilTargetRespawns")
			task.client:run(target, flightSpeed)
		end
	},

    --------------------
	{
		name = "Noclip",
		undoAliases = {"Clip"},
		groups = GROUPS,
		roles = ROLES,
		order = ORDER,
		args = {"Player", "FlightSpeed"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local flightSpeed = task:getOriginalArg("FlightSpeed") or 100
			task:keep("UntilTargetRespawns")
			task.client:run(target, flightSpeed)
		end
	},

    --------------------
	{
		name = "Noclip2",
		undoAliases = {"Clip2"},
		groups = GROUPS,
		roles = ROLES,
		order = ORDER,
		args = {"Player", "FlightSpeed"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local flightSpeed = task:getOriginalArg("FlightSpeed") or 25
			task:keep("UntilTargetRespawns")
			task.client:run(target, flightSpeed)
		end
	},

    --------------------
	
}
return commands