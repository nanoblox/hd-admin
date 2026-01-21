--!strict
local ORDER = 460
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local Task = require(modules.Objects.Task)
local loadCommand = Internal.loadCommand
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
type Command = Task.Command

return {

	--------------------
	{
		name = "Insert",
		order = ORDER,
		roles = ROLES,
		args = {"Integer"},
		config = {
			DenyList = {0000, 0000}, -- AssetIds to block
			AllowList = {--[[0000, 0000--]]}, -- If more than 0 items, only these AssetIds can be inserted
			ReplaceList = {[0000] = 0000}, -- [IdA] = IdB, where IdA is replaced with IdB
		},
		run = function(task: Task.Class, args: {any})
			local integer = unpack(args)
			local loadAssetCommand = require(modules.CommandUtil.loadAssetCommand)
			loadAssetCommand(Enum.AssetType.Model, task, integer, function(item: Instance)
				task:keep("Indefinitely")
				task.janitor:add(item)
				item.Parent = workspace
			end)
		end,
	},

    --------------------
	
}