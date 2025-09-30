local Workspace = game:GetService("Workspace")

local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local States = require(UI.States)

local Out = Fusion.Out

local Scope = Fusion.scoped(Fusion)

local Screen = {}

Scope:Hydrate(Workspace.CurrentCamera) {
	[Out "ViewportSize"] = States.Screen.Resolution,
}

return Screen
