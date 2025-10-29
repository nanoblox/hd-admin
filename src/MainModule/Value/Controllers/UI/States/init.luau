local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local Dark = require(UI.Themes.DarkTheme)

local Scope = Fusion.scoped(Fusion)

local States = {
	Theme = Scope:Value(nil),
	Panels = Scope:Value({}),
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
	Commands = {
		Tasks = Scope:Value({}),
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
	Guide = {
		Image = Scope:Value(nil),
		ImageCallback = Scope:Value(nil),
		Open = Scope:Value(true),
	},
}

return States
