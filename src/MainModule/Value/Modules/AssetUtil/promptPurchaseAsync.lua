--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local isClient = RunService:IsClient()
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local products = require(modules.References.products)
local promptProduct: any? = nil
local gamepassLogConnection: RBXScriptConnection? = nil

return function(assetIdOrProductName: number | products.ProductName, player: Player?, infoType: Enum.InfoType?)
	if typeof(assetIdOrProductName) ~= "number" then
		local productInfo = products[assetIdOrProductName]
		if not productInfo then
			return false, `Invalid product name: {assetIdOrProductName}`
		end
		assetIdOrProductName = productInfo.passId
	end
	local assetId = assetIdOrProductName :: number
	if isClient then
		if not promptProduct then
			local Remote = require(modules.Objects.Remote)
			promptProduct = Remote.get("PromptProduct")
		end
		local success, warning = promptProduct:invokeServerAsync(assetId)
		return success, warning
	end
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return false, "Player must be specified on server"
	end
	local passType: Enum.InfoType? = infoType
	local isAccessory: boolean? = nil
	if typeof(passType) ~= "EnumItem" then
		for _, product in products do
			if product and RunService:IsStudio() then
				return false, "This can only be purchased in-game"
			elseif product.passId == assetId then
				passType = product.passType
				isAccessory = true
				break
			end
		end
	end
	if passType == Enum.InfoType.Asset and isAccessory == nil then
		local success, productInfo = pcall(function()
			return MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
		end)
		if success and productInfo and productInfo.CollectibleItemId then
			isAccessory = true
		end
	end
	local isBundle = passType == Enum.InfoType.Bundle
	if isAccessory or isBundle then
		-- Accessories must be prompted via BulkPurchase
		local promptBulkPurchaseAsync = require(modules.AssetUtil.promptBulkPurchaseAsync)
		local bulkType = if isBundle then Enum.MarketplaceProductType.AvatarBundle else Enum.MarketplaceProductType.AvatarAsset
		return promptBulkPurchaseAsync(assetId, player, bulkType)
	end
	-----
	local LogService = game:GetService('LogService')
	if gamepassLogConnection then
		gamepassLogConnection:Disconnect()
		gamepassLogConnection = nil
	end
	gamepassLogConnection = LogService.MessageOut:Connect(function(message, messageType)
		if messageType ~= Enum.MessageType.MessageWarning then
			return
		end
		local message = tostring(message)
		if not message:match("AllowThirdPartySales") then
			return
		end
		--!!! prompt popup to show how to enable third party sales
		if gamepassLogConnection then
			gamepassLogConnection:Disconnect()
			gamepassLogConnection = nil
		end 
	end)
	task.delay(5, function()
		if gamepassLogConnection then
			gamepassLogConnection:Disconnect()
			gamepassLogConnection = nil
		end
	end)
	-----
	local success, warning = pcall(function()
		if passType == Enum.InfoType.Asset then
			return MarketplaceService:PromptPurchase(player, assetId)
		elseif passType == Enum.InfoType.Bundle then
			return MarketplaceService:PromptBundlePurchase(player, assetId)
		elseif passType == Enum.InfoType.Product then
			return MarketplaceService:PromptProductPurchase(player, assetId)
		end
		return MarketplaceService:PromptGamePassPurchase(player, assetId)
	end)
	return success, tostring(warning)
end