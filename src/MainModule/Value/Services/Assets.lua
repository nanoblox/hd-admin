--!strict
-- LOCAL
local Assets = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local permittedAssets: {[string]: true} = {}


-- FUNCTIONS
function Assets.permitAsset(assetId: number)
	permittedAssets[tostring(assetId)] = true
end

function Assets.isValidAsset(assetId: number)
	return permittedAssets[tostring(assetId)] == true
end


-- SETUP
-- PromptBulkPurchase can only be called from the server, hence this remote, however
-- it's also important we verify that the incoming assetId is related to a valid-hd product
-- otherwise we reject the prompt (for example, the game dev may have their own private UGC)
local promptBulkPurchaseAsync = require(modules.AssetUtil.promptBulkPurchaseAsync)
Remote.new("PromptBulkPurchase", "Function"):onServerInvoke(function(player: Player, assetId: unknown)
	if typeof(assetId) ~= "number" then
		return false, "Invalid assetId number"
	end
	local success, warning = promptBulkPurchaseAsync(assetId, player)
	return success, warning
end)

-- Same for prompting products
local promptAssetAsync = require(modules.AssetUtil.promptAssetAsync)
Remote.new("PromptProduct", "Function"):onServerInvoke(function(player: Player, assetId: unknown)
	if typeof(assetId) ~= "number" then
		return false, "Invalid assetId number"
	end
	local success, warning = promptAssetAsync(assetId, player)
	return success, warning
end)

-- Permit HD Gamepasses and Accessories
local products = require(modules.References.products)
for _, productInfo in products do
	Assets.permitAsset(productInfo.Id)
end

-- Initialize the Sound Handler
require(modules.AssetUtil.registerSound)


return Assets