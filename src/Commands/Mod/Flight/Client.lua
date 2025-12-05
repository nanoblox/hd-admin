--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local clientCommands: Task.ClientCommands = {

	--------------------
	{
		name = "Fly",
		run = function(task: Task.Class, hello)
			task.iterate(1000, function()
				task.server:replicate("TEST (3)")
				task.wait(0.25)
			end)
		end,
		replicate = function(...)
			print("   >>> received from replication:", ...)
		end
	},

	--------------------
}
return clientCommands