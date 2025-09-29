--!strict
--[[

	HD Admin Settings

	- Use this to configure player and system settings within HD Admin
	- For most users, you don't need to worry about editing this file
	- Roles (formerly Ranks) and Bans (formerly Banland) are now located under Config
	- Role Givers, such as Passes (formerly Gamepasses), Individuals, Goups, etc are
	  now located under 'Givers' within Config
	- Make sure to only edit the values within here if you're familiar with Luau
	  and HD Admin Settings, otherwise you risk breaking HD Admin

]]


-- SETTINGS
local Settings = {


	-- Player settings are specific to each player, can be viewed on the player's
	-- client, and can be additionally configured and saved *by each player* if
	-- they have the correct permissions.
	-- If you (the developer) makes a change to these PlayerSettings, then all players
	-- will observe this change and automatically change their settings to your newly
	-- changed values.
	["PlayerSettings"] = {
		Prefix = ";", -- The character you use before every command (e.g. ';jump me')
		PreviewIncompleteCommands = true,
		AppTheme = "Blurple", -- The theme of the app
		SoundProperties = { -- Min: 0, Max: 2
			Volume = {
				Music = 1,
				Command = 1,
				Interface = 1,
			},
			Pitch = {
				Music = 1,
				Command = 1,
				Interface = 1,
			},
		}
	},


	-- System settings are specific to the game, and can only be configured
	-- by the game owner, or users with the correct permissions
	["SystemSettings"] = {
		
		-- Parser Settings (Configurable)
		PlayerIdentifier = "@", -- The character used to identify players (e.g. ,fly @ForeverHD vs ,fly Ben)
		PlayerUndefinedSearch = "DisplayName" :: PlayerSearch, -- 'Undefined' means *without* the 'playerIdentifier' (e.g. ",fly Ben)
		PlayerDefinedSearch = "UserName" :: PlayerSearch, -- 'Defined' means *with* the 'playerIdentifier' (e.g. ",fly @ForeverHD)
		
		-- Parser Settings (Recommended NOT TO EDIT)
		ArgCapsule = "(%s)", -- The characters used to encapsulute additional properties (e.g. ,loop(1,2)kill all)
		Collective = ",", -- The character used to split up items (e.g. ,jump player1,player2,player3)
		SpaceSeparator = " ", -- The character inbetween command arguments (e.g. setting it to '/' would change ',jump me' to ',jump/me')
		BatchSeparator = " ", -- The character inbetween batch commands (e.g. setting it to '|' would change ',jump me ,fire me ,smoke me' to ',jump me | ,fire me | ,smoke me'
		DescriptorSeparator = " ",
		
		-- App Colors
		AppThemes = {
			{"Blurple", Color3.fromRGB(94, 86, 213)},
			{"Red", Color3.fromRGB(199, 80, 82)},
			{"Orange", Color3.fromRGB(152, 114, 69)},
			{"Green", Color3.fromRGB(73, 148, 104)},
			{"Blue", Color3.fromRGB(0, 100, 150)},
			{"Blue", Color3.fromRGB(91, 122, 189)},
			{"Pink", Color3.fromRGB(172, 121, 167)},
			{"Black", Color3.fromRGB(35, 39, 47)},
		},

		-- Colors to be used for commands with the Color arg
		Colors = {
			["Red"]	= Color3.fromRGB(255, 0, 0),
			["Orange"] = Color3.fromRGB(250, 100, 0),
			["Yellow"] = Color3.fromRGB(255, 255, 0),
			["Green"] = Color3.fromRGB(0, 255, 0),
			["DarkGreen"] = Color3.fromRGB(0, 125, 0),
			["Blue"] = Color3.fromRGB(0, 255, 255),
			["DarkBlue"] = Color3.fromRGB(0, 50, 255),
			["Purple"] = Color3.fromRGB(150, 0, 255),
			["Pink"] = Color3.fromRGB(255, 85, 185),
			["Black"] = Color3.fromRGB(0, 0, 0),
			["White"] = Color3.fromRGB(255, 255, 255),
		},

		-- Display
		ShowOnlyUsableAndBuyableCommands = true, 	-- Only display commands equal to or below the user's rank on the Commands page OR commands from Ranks or Roles they can purchase.
		DisableBoosterBundles = false,	-- This disables the Booster bundles. Please keep enabled to support the development of HD Admin.
		WelcomeRankNotice = true,			-- The 'You're a [rankName]' notice that appears when you join the game. Set to false to disable.
		WarnIncorrectPrefix = true,			-- Warn the user if using the wrong prefix | "Invalid prefix! Try using [correctPrefix][commandName] instead!"
		DisableAllNotices = false,		-- Set to true to disable all HD Admin notices.
		HideWarningsIfBelowRank = 1, 			-- Hide core notices such as 'CommandName is not a valid command!' and 'You do not have permission to use this command' for ranks below the specified rank
		RankRequiredToViewCommandsIcon = 0, 		-- Minimum rank to view the icon which opens the Commands-Only page. This is hidden if the user can view the dashboard.
		RankRequiredToViewDashboardIcon = 1, 		-- Minimum rank to view the icon which opens the Dashboard
		RankRequiredToViewPage = {				-- || The pages on the main menu ||
			["Commands"] = 0,
			["Moderation"] = 100,
			["Revenue"] = 100,
			["Settings"] = 1,
		},

		-- Commands
		ScaleLimit = 3, -- The maximum size players with a rank lower than 'IgnoreScaleLimit' can scale theirself. For example, players will be limited to ,size me 4 (if limit is 4) - any number above is blocked.
		IgnoreScaleLimit = 3, -- Any ranks equal or above this value will ignore 'ScaleLimit'
		VIPServerCommandBlacklist = {"permRank", "permBan", "globalAnnouncement"}, -- Commands players are probihited from using in VIP Servers
		CommandLimits = { -- Enables you to set limits for commands which have a number argument. Ranks equal to or higher than 'IgnoreLimit' will not be affected by Limit.
			["fly"]	= {
				Limit = 10000,
				IgnoreLimit = 3,
			},
			["fly2"]	= {
				Limit = 10000,
				IgnoreLimit = 3,
			},
			["noclip"]	= {
				Limit = 10000,
				IgnoreLimit = 3,
			},
			["noclip2"]	= {
				Limit = 10000,
				IgnoreLimit = 3,
			},
			["speed"]	= {
				Limit = 10000,
				IgnoreLimit = 3,
			},
			["jumpPower"]	= {
				Limit = 10000,
				IgnoreLimit = 3,
			},
			["animations"]	= {
				Limit = 2,
				Minimum = 0.5,
				IgnoreLimit = 6,
				SilentlyChange = true,
			},
		},

		-- Restrict Gear / Assets
		RestrictedIDs = {
			LibraryAndCatalog = { -- LibraryIds (Sounds, Images, Models, etc) and CatalogIds (Gear, Accessories, Faces, etc)
				Denylist = {["0000"] = true,},
				Allowlist = {},
			},
			Bundle = { -- Bundles
				Denylist = {},
				Allowlist = {},
			},
		},

		-- Replace Gear / Assets
		OverrideIDs = { -- Replaces the item with a corresponding *libraryId*
			LibraryAndCatalog = {
				["80661504"] = "6965147933",
			},
		},

		-- Warning System (Coming Soon)
		WarnExpiryTime = 604800, -- 1 week
		KickUsers = true,
		WarnsToKick = 3,
		ServerBanUsers = true,
		WarnsToServerBan = 4,
		ServerBanTime = 7200, -- 2 hours
		GlobalBanUsers = true,
		WarnsToGlobalBan = 5,
		GlobalBanTime = 172800, -- 2 days

		-- DataStore
		DataGroupName = "HD" -- CHANGING THIS WILL RESET ALL DATA. Only change if you wish to reset all saved data within HD Admin. For example, player data with a DataGroupName of 'HD' is structured as 'HDAdmin/HD/PlayerStore/[USER_ID]/Profile'

	}
}


-- TYPES
export type PlayerSearch = "None" | "UserName" | "DisplayName" | "UserNameAndDisplayName"


return Settings