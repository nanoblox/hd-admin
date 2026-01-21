--!strict
-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Prompt = require(modules.Prompt)
local Task = require(modules.Objects.Task)
local Players = game:GetService("Players")
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local createCommand = require(modules.CommandUtil.createBundleCommand)
local runBundleId = require(modules.OutfitUtil.runBundleId)
local AssetService = game:GetService("AssetService")
local bundleCache = {}


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "Bundle",
		groups = {"Bundle"},
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local _, bundleId = unpack(args)
			runBundleId(task, bundleId)
		end
	},

    --------------------
	createCommand("Buffify", 594200, {RemoveBodyParts = {"Head"}, Aliases = {"Buff"}}),
	createCommand("Wormify", 394523, {}),
	createCommand("Chibify", 6470, {Aliases = {"Chibi"}}),
	createCommand("Plushify", 3416, {RemoveBodyParts = {"Head"}, ScaleHead = 1.15}),
	createCommand("Freakify", 1186597, {Aliases = {"Freak"}}),
	createCommand("Frogify", 386731, {}),
	createCommand("Spongify", 393419, {}),
	createCommand("Bigify", 455999, {}),
	createCommand("Creepify", 946396, {}),
	createCommand("Dinofy", 369985, {IgnoreAccessories = {"Hair"}}),
	createCommand("Fatify", 637696, {}),
	--------------------
}


return commands