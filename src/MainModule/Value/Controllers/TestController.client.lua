--!strict

-- Cancel run if another application has initialized
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
if require(modules.Framework).startAsync() == false then
    return
end

-- Test stuff
local clientUser = require(modules.References.clientUser)
clientUser.perm:observe("Cash", function(value)
	print("CASH (on client) =", value)
end)