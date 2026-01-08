--!strict
--[[

	HD Admin Settings

	- Use this to configure player and system settings within HD Admin
	- For most users, you don't need to worry about editing this file
	- Roles (formerly Ranks) are now located under Config -> Roles
	- Commands are now configurable and located under Config -> Roles -> [ROLE]
	- Bans (formerly Banland) are now located under Config -> Bans -> Groups/Users
	- You can give Roles to players (via Passes, Goups, Friends, etc) by
	  configuring the Attributes of each [ROLE] and Presets under Config -> Presets
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
		Theme = {
			DarkMode = true,
			PrimaryColor = Color3.fromRGB(94, 86, 213),
		},
		Sound = { -- Min: 0, Max: 2
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
		},
	},


	-- System settings are specific to the game, and can only be configured
	-- by the game owner, or users with the correct permissions
	["SystemSettings"] = {
		
		-- Parser Settings
		PlayerIdentifier = "@", -- The character used to identify players (e.g. ,fly @ForeverHD vs ,fly Ben)
		PlayerUndefinedSearch = "DisplayName" :: PlayerSearch, -- 'Undefined' means *without* the 'playerIdentifier' (e.g. ";fly Ben)
		PlayerDefinedSearch = "UserName" :: PlayerSearch, -- 'Defined' means *with* the 'playerIdentifier' (e.g. ";fly @ForeverHD)
		
		-- Command Limits
		Limits = { -- While strongly recommended, can be disabled by setting `BypassLimits` to false in Role attributes
			RequestSize = 1000, -- Maximum number of characters in a message request until it's cutoff
			RequestsPerSecond = 10, -- Maximum message requests that can be parsed per second per second. When disabled, this is still capped to 20.
			CommandsPerMinute = 60, -- Maximum number of commands a player can run per minute
		},

		-- Colors to be used for commands with the Color arg
		CommandColors = {
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

		-- Recommended colors when customizing theme settings
		ThemeColors = {
			{"Blurple", Color3.fromRGB(94, 86, 213)},
			{"Red", Color3.fromRGB(199, 80, 82)},
			{"Orange", Color3.fromRGB(152, 114, 69)},
			{"Green", Color3.fromRGB(73, 148, 104)},
			{"Blue", Color3.fromRGB(0, 100, 150)},
			{"Blue", Color3.fromRGB(91, 122, 189)},
			{"Pink", Color3.fromRGB(172, 121, 167)},
			{"Black", Color3.fromRGB(35, 39, 47)},
		},
		
		-- Moderation, Utility & Saving
		MinimumAccountAge = 0, -- Kicks accounts younger than x days (0 to disable)
		DisableBoosterBundles = false, -- This disables the Booster bundles. Please keep enabled to support the development of HD Admin.
		DataGroupName = "HD" -- CHANGING THIS WILL RESET ALL DATA. Only change if you wish to reset all saved data within HD Admin. For example, player data with a DataGroupName of 'HD' is structured as 'HDAdmin/HD/PlayerStore/[USER_ID]/Profile'

	}
}


-- TYPES
export type PlayerSearch = "None" | "UserName" | "DisplayName" | "UserNameAndDisplayName"


return Settings
