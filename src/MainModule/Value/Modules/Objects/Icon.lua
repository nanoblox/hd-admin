local main = script:FindFirstAncestor("MainModule")
local packages = main.Value.Packages
local package = packages["janitor"]
local Package = require(package)
return Package