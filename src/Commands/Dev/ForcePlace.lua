--!strict
local ORDER = 620
local ROLES = {script.Parent.Name, "Utility"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local MarketplaceService = game:GetService("MarketplaceService")
local Prompt = require(modules.Prompt)
local TeleportService = game:GetService("TeleportService")
local commands: Task.Commands = {

    --------------------
	{
		name = "ForcePlace",
		aliases	= {"FPlace"},
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
			local success = pcall(function()
				return TeleportService:Teleport(integer, target)
			end)
			if not success then
				Prompt.error(caller, `Teleport failed for {target.Name}`)
				return
			end
		end
	},

    --------------------
	
}
return commands