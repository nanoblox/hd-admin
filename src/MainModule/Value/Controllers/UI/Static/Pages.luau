local Main = script:FindFirstAncestor("MainModule")
local UI = Main.Value.Controllers.UI
local Config = require(UI.Config)

local CONFIG = Config:Get()

export type Page = {
	Id: string,
	Name: string?,
	Icon: string?,
	NavigationLocked: boolean?,
}

local PAGES = {
	Dashboard = {
		Id = "Dashboard",
	},
	Commands = {
		Id = "Commands",
		Icon = CONFIG.Icons.Pages.Commands,
	},
	Execute = {
		Id = "Execute",
	},
	Moderation = {
		Id = "Moderation",
		Icon = CONFIG.Icons.Pages.Moderation,
	},
	Bans = {
		Id = "Bans",
	},
	Settings = {
		Id = "Settings",
		Icon = CONFIG.Icons.Pages.Settings,
	},
	About = {
		Id = "About",
		Icon = CONFIG.Icons.LogoGlyph,
	},
	Analytics = {
		Id = "Analytics",
		Icon = CONFIG.Icons.Pages.Analytics,
	},
	Roles = {
		Id = "Roles",
		Icon = CONFIG.Icons.ShieldPerson,
	},
	Tasks = {
		Id = "Tasks",
		Icon = CONFIG.Icons.Info,
	},
	User = {
		Id = "User",
	},
	Users = {
		Id = "Select Users",
	},
	Cosmetics = {
		Id = "Cosmetics",
	},
	Booster = {
		Id = "Booster",
	},
}

return PAGES
