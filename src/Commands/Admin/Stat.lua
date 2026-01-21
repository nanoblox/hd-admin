--!strict
local ORDER = 430
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	{
		name = "ChangeStat",
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Leaderstat", "String"},
		run = function(task: Task.Class, args: {any})
			local target, stat, text = unpack(args)
			if not stat then
				Prompt.warn(task.caller, `Stat not found`)
				return
			end
			if stat:IsA("IntValue") or stat:IsA("NumberValue") then
				local value = tonumber(text)
				if not value then
					Prompt.warn(task.caller, "Value must be a number")
					return
				end
			end
			stat.Value = text
		end
	},

    --------------------
	{
		name = "AddStat",
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Leaderstat", "String"},
		run = function(task: Task.Class, args: {any})
			local target, stat, text = unpack(args)
			if not stat then
				Prompt.warn(task.caller, `Stat not found`)
				return
			end
			local value = tonumber(text)
			if not value then
				Prompt.warn(task.caller, "Value must be a number")
				return
			end
			stat.Value += value
		end
	},

    --------------------
	{
		name = "SubtractStat",
		aliases = {"SubStat"},
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Leaderstat", "String"},
		run = function(task: Task.Class, args: {any})
			local target, stat, text = unpack(args)
			if not stat then
				Prompt.warn(task.caller, `Stat not found`)
				return
			end
			local value = tonumber(text)
			if not value then
				Prompt.warn(task.caller, "Value must be a number")
				return
			end
			stat.Value -= value
		end
	},

    --------------------
	{
		name = "ResetStats",
		aliases = {"ReStats", "ClearStats"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local leaderstats = target:FindFirstChild("leaderstats")
			if not leaderstats then
				return
			end
			for _,stat in leaderstats:GetChildren() do
				if stat:IsA("IntValue") or stat:IsA("NumberValue") then
					stat.Value = 0
				elseif stat:IsA("BoolValue") then
					stat.Value = false
				end
			end
		end
	},

    --------------------
	
}
return commands