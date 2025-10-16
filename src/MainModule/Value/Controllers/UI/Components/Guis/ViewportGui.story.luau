local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local StateMods = require(UI.StateMods)
local DarkTheme = require(UI.Themes.DarkTheme)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local Viewport = require(script.Parent.ViewportGui)
local CustomButton = require(script.Parent.Parent.CustomButton)

return function(Target: Instance)
	local Scope = Fusion.scoped(Fusion, OnyxUI.Components, {
		Viewport = Viewport,
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	StateMods:Initialize()
	StateMods:Start()

	local Panel = PanelsStateMod.New(Scope)

	States.Users.Profiles:set({
		[1] = {
			UserId = 1,
			Banned = true,
			Role = "Admin",
			Warnings = {},
		},
		[2] = {
			UserId = 1,
			Role = "Guest",
			Warnings = { {} },
		},
	})

	States.Theme:set(DarkTheme)

	Scope:Viewport {
		Parent = Target,
	}

	Scope:Button {
		Content = { "Toggle" },
		Parent = Target,
		AnchorPoint = Vector2.new(0, 0),
		Position = Scope:Computed(function(Use)
			return UDim2.new(0, Use(Theme.Spacing["1"]), 0, Use(Theme.Spacing["1"]))
		end),

		OnActivate = function()
			Panel.Open:set(not Fusion.peek(Panel.Open))
		end,
	}

	return function()
		Scope:doCleanup()
		StateMods:Destroy()
	end
end
