--!strict
local ORDER = 320
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Team",
		aliases	= {"JoinTeam", "SwitchTeam"},
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Team"},
		run = function(task: Task.Class, args: {any})
			local target, team = unpack(args)
			if team then
				target.Team = team
				target.TeamColor = team.TeamColor
			end
		end
	},

    --------------------
	
}
return commands