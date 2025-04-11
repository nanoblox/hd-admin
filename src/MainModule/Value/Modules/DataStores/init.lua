--!strict
local DataStoreService = game:GetService("DataStoreService")
local DataStores = {}
local _dataStore = nil


-- PUBLIC
DataStores.dataStoreName = "HDAdmin"
DataStores.dataGroupName = "HD" --!!! This should be configurable in settings, it can be changed to HD2, HD3, etc, if the user ever wants to reset all their data


-- FUNCTIONS
function DataStores.getDataStore(storeName): DataStore
	local store = script:FindFirstChild(storeName)
	if not store then
		error("Invalid data store name: " .. storeName)
	end
	if not _dataStore then
		_dataStore = DataStoreService:GetDataStore(DataStores.dataStoreName)
	end
	_dataStore = _dataStore :: DataStore
	return _dataStore
end

function DataStores.getDataKey(storeName: string, key: string): string
	local store = script:FindFirstChild(storeName)
	if not store then
		error("Invalid data store name: " .. storeName)
	end
	local Store = require(store) :: any
	local dataKeyFormatter = Store.dataKeyFormatter
	local dataKey = dataKeyFormatter:format(key) :: string
	return dataKey
end

function DataStores.getAsync(storeName: string, key: string, options: DataStoreGetOptions?): (boolean, string? | any)
	local dataStore = DataStores.getDataStore(storeName)
	local dataKey = DataStores.getDataKey(storeName, key)
	local success, result = pcall(function()
		return dataStore:GetAsync(dataKey, options)
	end)
	return success, result
end

function DataStores.setAsync(storeName: string, key: string, value: any, gdprUserIds: {number}, options: DataStoreSetOptions?): (boolean, string? | any)
	local dataStore = DataStores.getDataStore(storeName)
	local dataKey = DataStores.getDataKey(storeName, key)
	local success, result = pcall(function()
		return dataStore:SetAsync(dataKey, value, gdprUserIds, options)
	end)
	return success, result
end

function DataStores.updateAsync(storeName: string, key: string, transformFunction): (boolean, string? | any)
	local dataStore = DataStores.getDataStore(storeName)
	local dataKey = DataStores.getDataKey(storeName, key)
	local success, result = pcall(function()
		return dataStore:UpdateAsync(dataKey, transformFunction)
	end)
	return success, result
end


return DataStores
