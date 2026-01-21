-- This will be a user object in the future where data can be synced live between
-- all servers via MemoryStores
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Framework = require(modules.Framework)
local sharedValue = Framework.getSharedValue()
return sharedValue.Assets