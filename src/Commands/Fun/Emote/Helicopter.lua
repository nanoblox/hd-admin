--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Args = require(modules.Parser.Args)

--
local TestArgs = require(modules.Parent.Controllers.TestClient.TestArgs)
local testArgs = TestArgs[1]
local testValues = TestArgs[2]

local Parser = require(modules.Parser)
print("Parser.addCapsule =", Parser.addCapsule("loop", "5"))
print("Parser.addCapsule =", Parser.addCapsule("loop", ""))
print("testArgs =", TestArgs, testArgs)
--

local commands: Task.Commands = {

    --------------------
	{
		name = "Test",
		args = testArgs :: any,
		run = function(task: Task.Class, args: {any})
			print("Arg (1):", args[1])
			print("Arg (2):", args[2])
			print("Arg (3):", args[3])
		end
	},
	
    --------------------
	{
		name = "Material",
		args = {"Player", "Material", "Color", "Text"},
		run = function(task: Task.Class, args: {any})
			print("Arg (1):", args[1])
			print("Arg (2):", args[2])
			print("Arg (3):", args[3])
			print("Arg (4):", args[3])
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
		args = {"OptionalPlayer", "OptionalColor", "Text"},
		run = function(task, args: {any})
			print("Arg (1):", args[1])
			print("Arg (2):", args[2])
			print("Arg (3):", args[3])
		end
	},

    --------------------
}
return commands