local core = script.Parent
local loader = core.Parent
local mainModule = require(core.MainModule)
mainModule.initialize(loader)