local main = script:FindFirstAncestor("MainModule")
local packages = main.Value.Packages
local package = packages["Janitor"]
local Package = require(package)
return Package
