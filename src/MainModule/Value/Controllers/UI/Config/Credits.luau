local Icons = require(script.Parent.Icons)

export type ContributorGroup = {
	Name: string,
	UserIds: { number },
}
export type Library = {
	Name: string,
	Image: string,
	Link: string,
}

local CREDITS = {
	Contributors = {
		{
			Name = "Creator",
			UserIds = { 82347291 },
		},
		{
			Name = "UI",
			UserIds = { 144146784 },
		},
		{
			Name = "Role",
			UserIds = { 1 },
		},
		{
			Name = "Contributors",
			UserIds = { 1, 1, 1, 1, 1, 1, 1 },
		},
	},
	Libraries = {
		{
			Name = "HD",
			Image = Icons.LogoGlyphOutline,
			Link = "https://create.roblox.com/store/asset/857927023/HD-Admin",
		},
		{
			Name = "OnyxUI",
			Image = Icons.Logos.OnyxUI,
			Link = "https://create.roblox.com/store/asset/119264982349837/OnyxUI",
		},
		{ Name = "Fusion", Image = Icons.Logos.Fusion, Link = "https://devforum.roblox.com" },
		{ Name = "ColorUtils", Image = Icons.Logos.GitHub, Link = "https://devforum.roblox.com" },
		{ Name = "Sift", Image = Icons.Logos.GitHub, Link = "https://devforum.roblox.com" },
		{ Name = "Bootloader", Image = Icons.Logos.GitHub, Link = "https://devforum.roblox.com" },
	},
}

return CREDITS
