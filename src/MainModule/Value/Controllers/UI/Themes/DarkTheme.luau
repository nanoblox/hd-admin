local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local OnyxUI = require(Packages.OnyxUI)
local Fusion = require(Packages.Fusion)
local BaseTheme = require(script.Parent.BaseTheme)

local Scope = Fusion.scoped(Fusion)

return OnyxUI.Themer.NewTheme(Scope, BaseTheme)
