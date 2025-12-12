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
		if not promptProduct then
			local Remote = require(modules.Objects.Remote)
			promptProduct = Remote.get("PromptProduct")
		end
		local success, warning = promptProduct:invokeServerAsync(assetId)
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
	local productInfo: products.Product? = nil
	for _, product in products do
		if product.Id == assetId then
			productInfo = product
			break
		end
	end
	local RunService = game:GetService("RunService")
	if productInfo and RunService:IsStudio() then
		return false, "This can only be purchased in-game"
	end
	if productInfo and productInfo.Type ~= "GamePass" and productInfo.Type ~= "DevProduct" then
		-- Accessories must be prompted via BulkPurchase
		local promptBulkPurchaseAsync = require(modules.AssetUtil.promptBulkPurchaseAsync)
		return promptBulkPurchaseAsync(assetId, player)
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
		return MarketplaceService:PromptGamePassPurchase(player, assetId)
	end)
	return success, warning
end