--!strict
-- LOCAL
local ClientAssets = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules


-- SETUP
-- Initialize the Sound Handler
require(modules.AssetUtil.registerSound)


return ClientAssets