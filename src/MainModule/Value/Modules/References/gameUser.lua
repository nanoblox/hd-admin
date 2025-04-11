-- This will be a user object in the future where data can be synced live between
-- all servers via MemoryStores
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local User = require(modules.Objects.User)
local user = User.new("Game", "GameStore")
return user