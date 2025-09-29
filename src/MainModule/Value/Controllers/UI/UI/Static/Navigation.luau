local Pages = require(script.Parent.Pages)

local NAVIGATION = {
	Page = Pages.Dashboard,
	Children = {
		{
			Page = Pages.Commands,
		},
		{
			Page = Pages.Tasks,
		},
		{
			Page = Pages.Analytics,
		},
		{
			Page = Pages.Moderation,
			Children = {
				{
					Page = Pages.Bans,
				},
			},
		},
		{
			Page = Pages.Roles,
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
