local HDAdminUI = script.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local Dark = require(HDAdminUI.Themes.DarkTheme)

local Scope = Fusion.scoped(Fusion)

local States = {
	Theme = Scope:Value(nil),
	Menu = {
		Open = Scope:Value(false),
		Page = Scope:Value("Dashboard"),
		Position = Scope:Value(Vector2.new(0.005, 0.005)),
		Pages = {
			Execute = {
				CommandId = Scope:Value(nil),
			},
			Commands = {
				QuickRun = Scope:Value(false),
				ActiveTag = Scope:Value(nil),
			},
			User = {
				UserId = Scope:Value(1),
			},
			Users = {
				Selected = Scope:Value({}),
				SelectedCallback = Scope:Value(nil),
			},
			About = {
				SelectedCredit = Scope:Value(nil),
			},
		},
	},
	Prompts = {
		Prompts = Scope:Value({}),
	},
	CommandBar = {
		Open = Scope:Value(false),
	},
	Settings = {
		ThemeStateMod = Scope:Value(Fusion.peek(Dark.Colors.Primary.Main)),
		Prefix = Scope:Value(";"),
		AlertVolume = Scope:Value(1),
		ErrorVolume = Scope:Value(1),
		NoticeVolume = Scope:Value(1),
		DarkMode = Scope:Value(true),
	},
	Users = {
		Profiles = Scope:Value({}),
	},
	Perks = {
		Cosmetics = {
			Worn = Scope:Value({}),
		},
	},
	Session = {
		Players = Scope:Value({}),
	},
	UnixTime = Scope:Value(os.time()),
	Screen = {
		Resolution = Scope:Value(Vector2.zero),
	},
}

return States
