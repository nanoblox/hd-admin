--!strict
local main = script:FindFirstAncestor("MainModule")
local packages = main.Value.Packages
local package = packages["Promise"]
local Package = require(package)
return Package
