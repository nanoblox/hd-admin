local MarketplaceService = game:GetService("MarketplaceService")
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
		assetIdOrProductName = productInfo.Id
	end
	local assetId = assetIdOrProductName :: number
	if isClient then
		player = Players.LocalPlayer
	end
	if typeof(player) ~= "Instance" and not player:IsA("Player") then
		return false, "Player must be specified on server"
	end
	local productInfo: products.Product? = nil
	for _, product in products do
		if product.Id == assetId then
			productInfo = product
			break
		end
	end
	if productInfo then
		if productInfo.Type == "Bundle" then
			return pcall(function()
				return MarketplaceService:PlayerOwnsBundleAsync(player, assetId)
			end)
		elseif productInfo.Type ~= "GamePass" and productInfo.Type ~= "DevProduct" then
			return pcall(function()
				return MarketplaceService:PlayerOwnsAssetAsync(player, assetId)
			end)
		end
	end
	return pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, assetId)
	end)
end