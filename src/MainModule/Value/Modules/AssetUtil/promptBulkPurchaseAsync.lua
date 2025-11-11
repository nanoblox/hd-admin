local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local isClient = RunService:IsClient()
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local promptBulkPurchase

return function(assetId: number, player: Player?)
	if isClient then
		if not promptBulkPurchase then
			local Remote = require(modules.Objects.Remote)
			promptBulkPurchase = Remote.get("PromptBulkPurchase")
		end
		local success, warning = promptBulkPurchase:invokeServerAsync(assetId)
		return success, warning
	end
	if typeof(player) ~= "Instance" and not player:IsA("Player") then
		return false, "Player must be specified on server"
	end
	local Assets = require(modules.Parent.Services.Assets) :: any
	local isValid = Assets.isValidAsset(assetId)
	if not isValid then
		return false, `Prompting of assetId {assetId} is not permitted`
	end
	local success, warning = pcall(function()
		return MarketplaceService:PromptBulkPurchase(player, {{
			Type = Enum.MarketplaceProductType.AvatarAsset,
			Id = tostring(assetId),
		}}, {})
	end)
	return success, warning
end