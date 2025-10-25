--!strict

-- Local
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local Icon = require(modules.Objects.Icon)
local TestController = {}


-- Show data
local clientUser = require(modules.References.clientUser)
local everyone = clientUser.everyone

print("RoleInfo.admin =", everyone:fetchAsync("RoleInfo", "admin"))
print("RoleInfo.admin.members =", everyone:fetchAsync("RoleInfo", "admin", "members"))
print("RoleInfo =", everyone:fetchAsync("RoleInfo"))
print("Roles =", everyone:fetchAsync("Roles"))


return TestController
