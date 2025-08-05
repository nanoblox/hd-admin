local value = script:FindFirstAncestor("MainModule").Value
local modules = value.Modules
local Framework = require(modules.Framework)
Framework.startClient()