local modules = script:FindFirstAncestor("MainModule").Value.Modules
local User = require(modules.Objects.User)
local user = User.new("AllPowerfulServer")
user.temp:set("ElevatedPermissions", true)
return user