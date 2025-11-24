local main = script:FindFirstAncestor("MainModule")
local packages = main.Value.Packages
local package = packages["Signal"]
local Package = require(package)
export type Signal<T...> = Package.Signal<T...>
export type Connection = Package.Connection
return Package
