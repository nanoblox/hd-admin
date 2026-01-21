--!strict
local ORDER = 480
local ROLES = {script.Parent.Name, "Utility"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local MarketplaceService = game:GetService("MarketplaceService")
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	{
		name = "Place",
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local caller = task.caller
			local target, integer = unpack(args)
			local success, placeInfo = pcall(function()
				return MarketplaceService:GetProductInfo(integer)
			end)
			local placeName = placeInfo and placeInfo.Name
			if typeof(placeName) ~= "string" then
				Prompt.error(caller, `{integer} is an invalid placeId`)
				return
			end
			Prompt.action(target, `Click to teleport to '{placeName}' ({integer})`, {
				-- Complete this once actions are done
			})
		end
	},

    --------------------
	
}
return commands