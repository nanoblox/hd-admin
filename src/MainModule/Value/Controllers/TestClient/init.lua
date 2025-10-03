--!strict

-- Local
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local Icon = require(modules.Objects.Icon)
local TestController = {}


-- Show data
local clientUser = require(modules.References.clientUser)
local everyone = clientUser.everyone

local success, array: any = everyone:fetchAsync("Commands")
print("commands (previews) = ", array)

local firstCommandName = array[1].name
local success, info = everyone:fetchAsync("CommandInfo", firstCommandName)
print("firstCommand =", info)

local secondCommandName = array[2].name
local success, info = everyone:fetchAsync("CommandInfo", secondCommandName)
print("secondCommand =", info)

everyone:fetchAsync("CommandInfo", "Message")
print("allDataOnClient =", everyone._data)


return TestController
