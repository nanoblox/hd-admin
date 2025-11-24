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
			UserIds = {
				82347291, -- @ForeverHD
			},
		},
		{
			Name = "UI",
			UserIds = {
				144146784 -- @ImAvafe
			},
		},
		{
			Name = "Contributors",
			UserIds = {
				46138509, -- @ObliviousHD
				14398127, -- @H_mzah
				75323, -- @1waffle1
				1884609078, -- @RazaT_D
				421194271, -- @haash_im
				195261420, -- @OptimisticSide
				14943069, -- @Alvin_Blox
				127522050, -- @taycrius
				2718647678, -- @MiIoshiee
				466094764, -- @Emerald_Lijiachen
				68136726, -- @JohnnyMorganz
				484140, -- @GigsD4X
				13683770, -- @Naperin
				126451147, -- @Lucke0051
				1041190634, -- @iM1GHTB3DANI
				30255387, -- @dirtywheel
				6121439357, -- @AdamStarrLawyer
				78371776, -- @Currentlyz
			},
		},
		{
			Name = "Inspiration",
			UserIds = {
				44391621, -- @Scripth
				698712377, -- @Davey_Bones
				214258, -- @Person299
				1670764, -- @elttob
				16492520, -- @pobammer
				2155311, -- @EgoMoose
				80119, -- @stravant
				2312310, -- @loleris
				308165, -- @sleitnick
				4397833, -- @quenty
				223223382, -- @kaan650
				2243026817, -- @do_small
				671440392, -- @BitwiseAndrea
				121643, -- @PeZsmistic
				13953438, -- @NewFissy
				25691148, -- @TheNexusAvenger
				33655127, -- @boatbomber
				87924253, -- @7kayoh
				9543399, -- @xsixx
				851917460, -- @DonKingFrog
				1883128632, -- @blve_hxrizon
				1718501381, -- @luckydroz
				29444141, -- @mario118118
				954868167, -- @iscreator
				5420068, -- @hiddodev
				1659965, -- @buildthomas
				4906577, -- @magnalite
				92658764, -- @evaera
				379082633, -- @ZEDDxR
			},
		},
	},
	Libraries = {
		{
			Name = "HD",
			Image = Icons.LogoGlyphOutline,
			Link = "https://create.roblox.com/store/asset/857927023/HD-Admin",
		},
		{
			Name = "TopbarPlus",
			Image = "rbxassetid://78061770654469",
			Link = "https://create.roblox.com/store/asset/857927023/HD-Admin",
		},
		{
			Name = "OnyxUI",
			Image = Icons.Logos.OnyxUI,
			Link = "https://create.roblox.com/store/asset/119264982349837/OnyxUI",
		},
		{ Name = "Fusion", Image = Icons.Logos.Fusion, Link = "https://devforum.roblox.com/t/fusion/3032067" },
		{ Name = "ColorUtils", Image = Icons.Logos.GitHub, Link = "https://devforum.roblox.com" },
		{ Name = "Sift", Image = Icons.Logos.GitHub, Link = "https://devforum.roblox.com" },
		{ Name = "Bootloader", Image = Icons.Logos.GitHub, Link = "https://devforum.roblox.com" },
		{ Name = "Janitor", Image = Icons.Logos.GitHub, Link = "https://devforum.roblox.com/t/janitor/1601710" },
	},
}

return CREDITS
