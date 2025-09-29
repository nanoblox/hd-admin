local main = script:FindFirstAncestor("MainModule")
local packages = main.Value.Packages
local package = packages["TopbarPlus"]
local Package = require(package)

export type Icon = Package.Icon

return Package
