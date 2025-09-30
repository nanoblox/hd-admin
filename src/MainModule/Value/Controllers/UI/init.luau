local Players = game:GetService("Players")
local States = require(script.States)
local StateMods = require(script.StateMods)
local DarkTheme = require(script.Themes.DarkTheme)
local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Packages
local Modules = Main.Modules
local Fusion = require(script.Parent.Parent.Parent.Packages.Fusion)
local ScreenGui = require(script.Components.Guis.ScreenGui)
local Config = require(script.Config)
local Signals = require(script.Signals)

local HDAdminUI = {
	Started = false,
	Signals = Signals,
}

local function start()
	assert(HDAdminUI.Started == false, "Frontend cannot be started twice!")

	require(Modules.References.appIcon)
	States.Theme:set(DarkTheme)
	StateMods:Initialize()

	local Scope = Fusion.scoped(Fusion)

	local Scope = Fusion.innerScope(Scope, Fusion, {
		ScreenGui = ScreenGui,
	})

	Scope:ScreenGui({
		Parent = Players.LocalPlayer.PlayerGui,
	})
end

function HDAdminUI.configure(Configuration: typeof(Config:Get()))
	assert(typeof(Configuration) == "table", "Config must be of type table!")
	assert(HDAdminUI.Started == false, "Frontend cannot be configured after starting!")

	Config:Update(function()
		return Configuration
	end)
end

function HDAdminUI.setOpen(Open: boolean)
	States.Menu.Open:set(Open)
end

function HDAdminUI.toggleOpen()
	States.Menu.Open:set(not Fusion.peek(States.Menu.Open))
end

task.defer(start)

return HDAdminUI