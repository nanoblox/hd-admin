--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Args = require(modules.Parser.Args)
local particlesArg = Args.create({
	name = "Particles",
	description = "Whether to spawn particles",
	parse = function(self, stringToParse)
		print("CUSTOM PARTICLE ARG HERE!!")
		if math.random(1,2) == 1 then
			return "FireParticles"
		else
			return "LightningParticles"
		end
	end,
})
local commands: Task.Commands = {

    --------------------
	{
		name = "Helicopter",
		args = {"Player"},
		run = function(task, args: {any})
			print("helicopter (A)")
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