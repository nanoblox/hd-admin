local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local States = require(HDAdminUI.States)
local StateMods = require(HDAdminUI.StateMods)
local DarkTheme = require(HDAdminUI.Themes.DarkTheme)

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

	States.Menu.Open:set(true)
	-- States.Menu.Page:set("Moderation")

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
			States.Menu.Open:set(not Fusion.peek(States.Menu.Open))
		end,
	}

	return function()
		Scope:doCleanup()
		StateMods:Destroy()
	end
end
