local Players = game:GetService("Players")

local States = require(script.States)
local StateMods = require(script.StateMods)
local DarkTheme = require(script.Themes.DarkTheme)
local Fusion = require(script.Parent.Parent.Packages.Fusion)
local ScreenGui = require(script.Components.Guis.ScreenGui)
local Config = require(script.Config)
local Signals = require(script.Signals)

local HDAdminUI = {
	Started = false,
	Signals = Signals,
}

function HDAdminUI:Start()
	assert(HDAdminUI.Started == false, "Frontend cannot be started twice!")

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

function HDAdminUI:Configure(Configuration: typeof(Config:Get()))
	assert(typeof(Configuration) == "table", "Config must be of type table!")
	assert(HDAdminUI.Started == false, "Frontend cannot be configured after starting!")

	Config:Update(function()
		return Configuration
	end)
end

function HDAdminUI:SetOpen(Open: boolean)
	States.Menu.Open:set(Open)
end

function HDAdminUI:ToggleOpen()
	States.Menu.Open:set(not Fusion.peek(States.Menu.Open))
end

return HDAdminUI
