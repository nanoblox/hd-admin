--!nocheck
-- This is for modules located within server Config that need to reference back to Shared config
local hd = script:FindFirstAncestor("HD Admin")
local modules = hd.Core.MainModule.Value.Modules
local Framework = require(modules.Framework)
local sharedContainer = Framework.getSharedContainer()
local sharedConfig = sharedContainer.Core.MainModule["Value"].Modules.Config
local ourNewModule = sharedConfig[script.Name]
return require(ourNewModule)