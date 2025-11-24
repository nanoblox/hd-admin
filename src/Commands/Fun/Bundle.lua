--!strict
local ORDER = 30
local ROLE = script.Name
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local function createCommand(commandName, properties)
	local command: Task.Command = {
		name = commandName,
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			-- Implementation of the emote command using properties
		end
	}
	return command
end


local commands: Task.Commands = {

    --------------------
	{
		name = "Bundle",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	createCommand("Buffify", 594200, {Rank = 1, RemoveBodyParts = {"Head"}}),
	createCommand("Wormify", 394523, {Rank = 1}),
	createCommand("Chibify", 6470, {Rank = 1}),
	createCommand("Plushify", 3416, {Rank = 1, RemoveBodyParts = {"Head"}, ScaleHead = 1.15}),
	createCommand("Freakify", 1186597, {Rank = 1}),
	createCommand("Frogify", 386731, {Rank = 1}),
	createCommand("Spongify", 393419, {Rank = 1}),
	createCommand("Bigify", 455999, {Rank = 1}),
	createCommand("Creepify", 946396, {Rank = 1}),
	createCommand("Dinofy", 369985, {Rank = 1, IgnoreAccessories = {"Hair"}}),
	createCommand("Fatify", 637696, {Rank = 1}),
	--------------------
}

return commands