--!strict
-- LOCAL
local ORDER = 440
local ROLES = {script.Parent.Name, "Utility"}
local MarketplaceService = game:GetService("MarketplaceService")
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local promptPurchaseAsync = require(modules.AssetUtil.promptPurchaseAsync)
local Prompt = require(modules.Prompt)


-- LOCAL FUNCTIONS
local function warnCaller(caller: Player?, warning: string)
	if caller then
		Prompt.warn(caller, warning)
	end
end

local function sellForType(player: Player, caller: Player?, assetId: number, infoType: Enum.InfoType)
	local success, infoOrWarning = pcall(function()
		return MarketplaceService:GetProductInfo(assetId, infoType)
	end)
	if not success then
		warnCaller(caller, `Invalid Id`)
		return
	end
	local success, warning = promptPurchaseAsync(assetId, player, infoType)
	if not success then
		warnCaller(caller, `Failed to Sell {infoType.Name}: {warning}`)
		return
	end
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "SellPass",
		aliases = {"SellGamepass"},
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			sellForType(target, task.caller, integer, Enum.InfoType.GamePass)
		end
	},

    --------------------
	{
		name = "SellAsset",
		aliases = {"SellModel", "SellDecal", "SellAudio"},
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			sellForType(target, task.caller, integer, Enum.InfoType.Asset)
		end
	},

    --------------------
	{
		name = "SellHat",
		aliases = {"SellAccessory", "SellUGC"},
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			sellForType(target, task.caller, integer, Enum.InfoType.Asset)
		end
	},

    --------------------
	{
		name = "SellBundle",
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			sellForType(target, task.caller, integer, Enum.InfoType.Bundle)
		end
	},

    --------------------
	{
		name = "SellProduct",
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			sellForType(target, task.caller, integer, Enum.InfoType.Product)
		end
	},

    --------------------

}


return commands