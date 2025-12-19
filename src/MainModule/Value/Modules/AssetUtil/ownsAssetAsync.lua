--!strict
local MarketplaceService = game:GetService("MarketplaceService") :: any
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local isClient = RunService:IsClient()
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local products = require(modules.References.products)
local promptProduct

return function(assetIdOrProductName: number | products.ProductName, player: Player?)
	if typeof(assetIdOrProductName) ~= "number" then
		local productInfo = products[assetIdOrProductName]
		if not productInfo then
			return false, `Invalid product name: {assetIdOrProductName}`
		end
		assetIdOrProductName = productInfo.passId
	end
	local assetId = assetIdOrProductName :: number
	if isClient then
		player = Players.LocalPlayer
	end
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return false, "Player must be specified on server"
	end
	local productInfo: products.Product? = nil
	for _, product in products do
		if product.passId == assetId then
			productInfo = product
			break
		end
	end
	if productInfo then
		if productInfo.passType == Enum.InfoType.Bundle then
			return pcall(function()
				return MarketplaceService:PlayerOwnsBundleAsync(player, assetId)
			end)
		elseif productInfo.passType ~= Enum.InfoType.GamePass and productInfo.passType ~= Enum.InfoType.Product then
			return pcall(function()
				return MarketplaceService:PlayerOwnsAssetAsync(player, assetId)
			end)
		end
	end
	return pcall(function()
		local playerToCheck = player :: Player
		return MarketplaceService:UserOwnsGamePassAsync(playerToCheck.UserId, assetId)
	end)
end