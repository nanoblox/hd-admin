local Pages = require(script.Parent.Pages)

-- Commands, Analytics, Moderation, Roles, Tasks, Logs, Settings, About

local NAVIGATION = {
	Page = Pages.Dashboard,
	Children = {
		{
			Page = Pages.Commands,
		},
		{
			Page = Pages.Analytics,
		},
		{
			Page = Pages.Moderation,
		},
		{
			Page = Pages.Roles,
		},
		{
			Page = Pages.Tasks,
		},
		{
			Page = Pages.Logs,
		},
		{
			Page = Pages.Settings,
		},
		{
			Page = Pages.About,
		},
	},
}

return NAVIGATION
