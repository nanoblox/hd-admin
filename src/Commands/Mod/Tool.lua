--!strict
local ORDER = 235
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "HandTo",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local caller = task.caller
			local callerChar = caller and caller.Character
			local callerHumanoid = getHumanoid(caller)
			local targetHumanoid = getHumanoid(target)
			if not callerChar or not callerHumanoid or not targetHumanoid then
				return
			end
			local tool = callerChar:FindFirstChildOfClass("Tool")
			if not tool then
				return
			end
			local toolClone = tool:Clone()
			toolClone.Parent = target.Backpack
			callerHumanoid:UnequipTools()
			targetHumanoid:EquipTool(toolClone)
			tool:Destroy()
		end
	},

    --------------------
	{
		name = "Give",
		aliases = {"GiveTool"},
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Tools"},
		run = function(task: Task.Class, args: {any})
			local target, tools = unpack(args)
			for _, tool in tools do
				tool:Clone().Parent = target.Backpack
			end
		end
	},

    --------------------
	{
		name = "GiveAll",
		aliases = {"GiveAllTools"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local getTools = require(modules.CommandUtil.getTools)
			local target = unpack(args)
			local tools = getTools()
			for _, tool in tools do
				local clone = tool:Clone()
				clone.Parent = target.Backpack
			end
		end
	},

    --------------------
	{
		name = "ClearBackpack",
		aliases = {"ClrBackpack", "ClrBP", "ClearTools", "ClrTools"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local unequipTools = require(modules.PlayerUtil.unequipTools)
			local target = unpack(args)
			unequipTools(target)
			task.wait()
			for _, tool in target.Backpack:GetChildren() do
				tool:Destroy()
			end
		end
	},

    --------------------
	
}
return commands