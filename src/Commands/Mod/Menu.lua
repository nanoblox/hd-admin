--!strict
local ORDER = 330
local ROLES = {script.Parent.Name, "Utility"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	{
		name = "Banland",
		aliases = {"Bans"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info(task.caller, "Coming Soon!")
		end
	},

    --------------------
	{
		name = "Logs",
		aliases = {"ChatLogs"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info(task.caller, "Coming Soon!")
		end
	},

    --------------------
	{
		name = "CommandBar",
		aliases = {"CmdBar"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info(task.caller, "Coming Soon!")
		end
	},

    --------------------
	{
		name = "Roles",
		aliases = {"RoleList"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info(task.caller, "Coming Soon!")
		end
	},

    --------------------
	{
		name = "Members",
		aliases = {"MemberList"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info(task.caller, "Coming Soon!")
		end
	},

    --------------------
	
}
return commands