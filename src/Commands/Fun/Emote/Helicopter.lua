--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Args = require(modules.Parser.Args)
local particlesArg = Args.createAliasOf("Number", {
	minValue = -100,
	maxValue = 100,
})
local commands: Task.Commands = {

    --------------------
	{
		name = "Particles",
		args = {"Player", particlesArg},
		run = function(task, args: {any})
			print("Particles (A)")
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
		name = "Test",
		args = {"OptionalPlayers", "Text"},
		run = function(task: Task.Class, args: {any})
			print("Test (5):", unpack(args))
		end
	},

    --------------------
	{
		name = "Message",
		aliases = {"M"},
		args = {"Player", "Text"},
		run = function(task, args: {any})
			print("args =", unpack(args))
		end
	},

    --------------------
}
return commands