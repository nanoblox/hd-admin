--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	--[[{
		name = "Gears",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info("Coming soon!")
		end
	},--]]

    --------------------
	{
		name = "Gear",
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			local loadAssetCommand = require(modules.CommandUtil.loadAssetCommand)
			loadAssetCommand(Enum.AssetType.Gear, task, integer, function(item: Instance)
				item.Parent = target.Backpack
			end)
		end
	},
	
    --------------------
	{
		name = "Sword",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local toolClone = script.Sword:Clone()
			toolClone.Parent = target.Backpack
		end
	},

    --------------------
	
}
return commands