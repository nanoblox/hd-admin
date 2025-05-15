--!strict
local DATA_STORE_NAME = "HDAdmin"
local DataStoreService = game:GetService("DataStoreService")
local DataStores = {}
local _dataStore: DataStore = DataStoreService:GetDataStore(DATA_STORE_NAME)
local config = script:FindFirstAncestor("MainModule").Value.Modules.Config
local configSettings = require(config.Settings)


-- PUBLIC
DataStores.dataStoreName = DATA_STORE_NAME
DataStores.dataGroupName = configSettings.SystemSettings.DataGroupName


-- FUNCTIONS
function DataStores.getDataStore(): DataStore
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
	local dataStore = DataStores.getDataStore()
	local dataKey = DataStores.getDataKey(storeName, key)
	local success, result = pcall(function()
		return dataStore:GetAsync(dataKey, options)
	end)
	return success, result
end

function DataStores.setAsync(storeName: string, key: string, value: any, gdprUserIds: {number}, options: DataStoreSetOptions?): (boolean, string? | any)
	local dataStore = DataStores.getDataStore()
	local dataKey = DataStores.getDataKey(storeName, key)
	local success, result = pcall(function()
		return dataStore:SetAsync(dataKey, value, gdprUserIds, options)
	end)
	return success, result
end

function DataStores.updateAsync(storeName: string, key: string, transformFunction): (boolean, string? | any)
	local dataStore = DataStores.getDataStore()
	local dataKey = DataStores.getDataKey(storeName, key)
	local success, result = pcall(function()
		return dataStore:UpdateAsync(dataKey, transformFunction)
	end)
	return success, result
end


return DataStores
