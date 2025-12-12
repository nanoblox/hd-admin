return function(integer: unknown, assetType: Enum.AssetType | Enum.BundleType): (boolean, string?)
	local number = tonumber(integer)
	if not integer then
		return false, "Invalid number"
	end
	number = math.floor(number)
	if number <= 0 then
		return false, "Invalid asset number"
	end
	local infoType = Enum.InfoType.Asset
	local enumType = assetType.EnumType
	if enumType == Enum.BundleType then
		infoType = Enum.InfoType.Bundle
	end
	local MarketplaceService = game:GetService("MarketplaceService")
	local success, productInfo = pcall(function()
		return (MarketplaceService :: any):GetProductInfo(integer, infoType)
	end)
	if not success then
		return false, tostring(productInfo)
	end
	print("productInfo =", productInfo)
	if enumType == Enum.BundleType then
		if productInfo.BundleType == assetType.Name then
			return true, productInfo
		end
	elseif productInfo.AssetTypeId == assetType.Value then
		return true, productInfo
	end
	return false, `AssetId is not type '{tostring(assetType.Name)}'`
end