local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Fusion)
local BaseTheme = require(script.Parent.BaseTheme)

local Scope = Fusion.scoped(Fusion)

return OnyxUI.Themer.NewTheme(Scope, BaseTheme)
