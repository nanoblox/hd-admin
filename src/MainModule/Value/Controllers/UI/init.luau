local Players = game:GetService("Players")
local States = require(script.States)
local StateMods = require(script.StateMods)
local DarkTheme = require(script.Themes.DarkTheme)
local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local Modules = Main.Value.Modules
local Fusion = require(Packages.Fusion)
local ScreenGui = require(script.Components.Guis.ScreenGui)
local Config = require(script.Config)
local Signals = require(script.Signals)

local UI = {
	Started = false,
	Signals = Signals,
}

local function start()
	UI.Started = true --!!! REMOVE THIS
	assert(UI.Started == false, "Frontend cannot be started twice!")

	local appIcon = require(Modules.References.appIcon)
	appIcon:bindEvent("toggled", function()
		UI.toggleOpen()
	end)
	
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

function UI.configure(Configuration: typeof(Config:Get()))
	assert(typeof(Configuration) == "table", "Config must be of type table!")
	assert(UI.Started == false, "Frontend cannot be configured after starting!")

	Config:Update(function()
		return Configuration
	end)
end

function UI.setOpen(Open: boolean)
	States.Menu.Open:set(Open)
end

function UI.toggleOpen()
	States.Menu.Open:set(not Fusion.peek(States.Menu.Open))
end

task.defer(start)

return UI