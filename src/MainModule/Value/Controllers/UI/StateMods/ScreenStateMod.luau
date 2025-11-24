local Workspace = game:GetService("Workspace")

local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local States = require(UI.States)

local Out = Fusion.Out

local Scope = Fusion.scoped(Fusion)

local Screen = {}

local function UpdateCamera()
	local Camera = Workspace.CurrentCamera

	States.Screen.Resolution:set(Camera.ViewportSize)

	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		States.Screen.Resolution:set(Camera.ViewportSize)
	end)
end

UpdateCamera()

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	UpdateCamera()
end)

return Screen
