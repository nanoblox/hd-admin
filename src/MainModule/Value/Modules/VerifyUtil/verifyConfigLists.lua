return function(caller: Player?, config: {[string]: any}, assetId: number): (boolean, string | number)
	if not config then
		return true, assetId
	end
	local denyList = config.DenyList or {}
	local replaceList = config.ReplaceList or {}
	local allowList = config.AllowList or {}
	local newAssetId = replaceList[assetId] or assetId
	if #allowList > 0 then
		if table.find(allowList, newAssetId) then
			return true, newAssetId
		end
		return false, `{newAssetId} is not within AllowList`
	end
	if table.find(denyList, newAssetId) then
		return false, `{newAssetId} is within DenyList`
	end
	return true, newAssetId
end