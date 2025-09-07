local Workspace = game:GetService("Workspace")

local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local States = require(script.Parent.Parent.States)

local Out = Fusion.Out

local Scope = Fusion.scoped(Fusion)

local Screen = {}

Scope:Hydrate(Workspace.CurrentCamera) {
	[Out "ViewportSize"] = States.Screen.Resolution,
}

return Screen
