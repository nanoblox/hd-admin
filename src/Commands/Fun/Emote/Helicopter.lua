--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Args = require(modules.Parser.Args)
local commands: Task.Commands = {

    --------------------
	{
		name = "Test",
		args = {"Color", "Text"},
		run = function(task: Task.Class, args: {any})
			print("TEST RESULT:", unpack(args))
		end
	},
	
    --------------------
	{
		name = "Tool",
		args = {"Tool"}, -- "Leaderstat", "Team"
		run = function(task: Task.Class, args: {any})
			local tool = args[1]
			local toolClone = tool and tool:Clone()
			local backpack = task.caller and task.caller.Backpack
			if toolClone and backpack then
				toolClone.Parent = backpack
			end
		end
	},
	
    --------------------
	{
		name = "/Helicopter",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			print("helicopter (B)")
			
		end
	},

    --------------------
	{
		name = "Message",
		aliases = {"M"},
		args = {"Color", "Text"}, --"OptionalPlayer", "OptionalColor", "Text"
		run = function(task, args: {any})
			print("args =", unpack(args))
		end
	},

    --------------------
}
return commands