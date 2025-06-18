local main = script:FindFirstAncestor("MainModule")
local packages = main.Value.Packages
local package = packages["topbarplus"]
local Package = require(package)
return Package