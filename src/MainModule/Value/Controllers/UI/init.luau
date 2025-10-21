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
local Callbacks = require(script.Callbacks)
local PanelsStateMod = require(script.StateMods.PanelsStateMod)

local UI = {
	Started = false,
	Signals = Callbacks,
	Scope = Fusion.scoped(Fusion),
}

local function start()
	assert(UI.Started == false, "Frontend cannot be started twice!")

	local Panel = PanelsStateMod.New(UI.Scope)
	Panel.Open:set(true)

	local appIcon = require(Modules.References.appIcon)
	appIcon:bindEvent("toggled", function()
		UI.toggleAllOpen()
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

function UI.setAllOpen(Open: boolean)
	local PanelsValue = Fusion.peek(States.Panels)

	for _, Panel in PanelsValue do
		PanelsStateMod.SetOpen(Panel, Open)
	end
end

function UI.toggleAllOpen()
	local AnyOpen = false
	local PanelsValue = Fusion.peek(States.Panels)

	for _, Panel in PanelsValue do
		if Fusion.peek(Panel.Open) then
			AnyOpen = true
		end
	end

	UI.setAllOpen(not AnyOpen)
end

task.defer(start)

return UI
