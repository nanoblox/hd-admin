--[[

--------------| ABOUT RANKS |--------------

RANK	| DEFAULT NAME	| COMMANDS	| EXTRA DETAILS
-------------------------------------------------------------------------------------------------------------------
5		| Owner			| All		| Is automtically set. The Owner has full access to commands and features.
-------------------------------------------------------------------------------------------------------------------
4 		| HeadAdmin		| 1,2,3,4	| 
3 		| Admin			| 1,2,3		| 
2		| Mod			| 1,2		| Can only use commands on one person at a time. 
1 		| VIP			| 1			| Can only use commands on theirself.
-------------------------------------------------------------------------------------------------------------------
0		| NonAdmin		| 0			| The default rank. Players are limited to basic features.




--------------| SETUP RANKS |--------------																															 ]] return{

-- RANK, RANK NAMES & SPECIFIC USERS
Ranks = {
	{5,	"Owner",		};
	{4,	"HeadAdmin",	{"ImAvafe",0},	};
	{3,	"Admin",		{"",0},	};
	{2,	"Mod",			{"",0},	};
	{1,	"VIP",			{"",0},	};
	{0,	"NonAdmin",		};
};



-- GAMEPASSES
Gamepasses = {
	[1039997021] = "VIP";
	[1039509747] = "Mod";
	[1045377105] = "Admin";
};


-- ASSETS
Assets = {
	[0] = "VIP";
};


-- GROUPS
Groups = {
	[0] = {
		[254] = "Admin";
		[1] = "VIP";
		};
};


-- FRIENDS
Friends = "NonAdmin";


-- VIP SERVER OWNER
VipServerOwner = "NonAdmin";


-- FREE ADMIN
FreeAdmin = "NonAdmin";








--------------| BANLAND |--------------
Banned = {"",0};








--------------| SYSTEM SETTINGS |--------------
Prefix				= ";";			-- The character you use before every command (e.g. ';jump me').
SplitKey 			= " ";			-- The character inbetween command arguments (e.g. setting it to '/' would change ';jump me' to ';jump/me').
BatchKey 			= "";			-- The character inbetween batch commands (e.g. setting it to '|' would change ';jump me ;fire me ;smoke me' to ';jump me | ;fire me | ;smoke me'
QualifierBatchKey 	= ",";			-- The character used to split up qualifiers (e.g. ;jump player1,player2,player3)

AppTheme			= "Blurple";	-- The default UI theme.
AppThemes = {
	{"Blurple", Color3.fromRGB(94, 86, 213),	};
	{"Red", 	Color3.fromRGB(199, 80, 82),	};
	{"Orange", 	Color3.fromRGB(152, 114, 69),	};
	{"Green", 	Color3.fromRGB(73, 148, 104),	};
	{"Blue", 	Color3.fromRGB(0, 100, 150),	};
--	{"Blue", 	Color3.fromRGB(91, 122, 189),	};
	{"Pink",	Color3.fromRGB(172, 121, 167),	};
	{"Black", 	Color3.fromRGB(35, 39, 47),		};
};

ShowOnlyUsableAndBuyableCommands	= true; 	-- Only display commands equal to or below the user's rank on the Commands page OR commands from Ranks or Roles they can purchase.
DisableBoosterBundles				= false;	-- This disables the Booster bundles. Please keep enabled to support the development of HD Admin.
RankRequiredToViewCommandsIcon		= 0; 		-- Minimum rank to view the icon which opens the Commands-Only page. This is hidden if the user can view the dashboard.
RankRequiredToViewDashboardIcon		= 1; 		-- Minimum rank to view the icon which opens the Dashboard

NoticeSoundId		= 2865227271;	-- The SoundId for notices.
NoticeVolume		= 0.1;			-- The Volume for notices.
NoticePitch			= 1;			-- The Pitch/PlaybackSpeed for notices.
ErrorSoundId		= 2865228021;	-- The SoundId for error notifications.
ErrorVolume			= 0.1;			-- The Volume for error notifications.
ErrorPitch			= 1;			-- The Pitch/PlaybackSpeed for error notifications.
Alert2SoundId		= 6176997734;	-- The SoundId for alerts.
AlertVolume			= 0.5;			-- The Volume for alerts.
AlertPitch			= 1;			-- The Pitch/PlaybackSpeed for alerts.

WelcomeBadgeId		= 0;			-- Award new players a badge, such as 'Welcome to the game!'. Set to 0 for no badge.

CommandDebounce		= true;			-- Wait until the command effect is over to use again. Helps to limit abuse & lag. Set to 'false' to disable.
SaveRank			= true;			-- Saves a player's rank in the server they received it. (e.g. ;rank plrName rank). Use ';permRank plrName rank' to permanently save a rank. Set to 'false' to disable.
LoopCommands		= 3;			-- The minimum rank required to use LoopCommands.

Colors = {							-- The colours for ChatColors and command arguments. | Format: {"ShortName", "FullName", Color3Value};
	{"r", 		"Red",		 		Color3.fromRGB(255, 0, 0)		};
	{"o", 		"Orange",	 		Color3.fromRGB(250, 100, 0)		};
	{"y", 		"Yellow",			Color3.fromRGB(255, 255, 0)		};
	{"g", 		"Green"	,			Color3.fromRGB(0, 255, 0)		};
	{"dg", 		"DarkGreen"	, 		Color3.fromRGB(0, 125, 0)		};
	{"b", 		"Blue",		 		Color3.fromRGB(0, 255, 255)		};
	{"db", 		"DarkBlue",			Color3.fromRGB(0, 50, 255)		};
	{"p", 		"Purple",	 		Color3.fromRGB(150, 0, 255)		};
	{"pk",		"Pink",		 		Color3.fromRGB(255, 85, 185)	};
	{"bk",		"Black",		 	Color3.fromRGB(0, 0, 0)			};
	{"w",		"White",	 		Color3.fromRGB(255, 255, 255)	};
};

Cmdbar						= 1;			-- The minimum rank required to use the Cmdbar.
Cmdbar2						= 3;			-- The minimum rank required to use the Cmdbar2.
ViewBanland					= 3;			-- The minimum rank required to view the banland.
RankRequiredToViewPage		= {				-- || The pages on the main menu ||
	["Commands"]		= 0;
	["Moderation"]		= 3;
	["Revenue"]			= 3;
	["Settings"]		= 1;
};

WelcomeRankNotice			= true;			-- The 'You're a [rankName]' notice that appears when you join the game. Set to false to disable.
WarnIncorrectPrefix			= true;			-- Warn the user if using the wrong prefix | "Invalid prefix! Try using [correctPrefix][commandName] instead!"
DisableAllNotices			= false;		-- Set to true to disable all HD Admin notices.
HideWarningsIfBelowRank		= 1; 			-- Hide core notices such as 'CommandName is not a valid command!' and 'You do not have permission to use this command' for ranks below the specified rank

ScaleLimit					= 3;			-- The maximum size players with a rank lower than 'IgnoreScaleLimit' can scale theirself. For example, players will be limited to ;size me 4 (if limit is 4) - any number above is blocked.
IgnoreScaleLimit			= 3;			-- Any ranks equal or above this value will ignore 'ScaleLimit'
CommandLimits				= {				-- Enables you to set limits for commands which have a number argument. Ranks equal to or higher than 'IgnoreLimit' will not be affected by Limit.
	["fly"]	= {
		Limit 				= 10000;
		IgnoreLimit 		= 3;
	};
	["fly2"]	= {
		Limit 				= 10000;
		IgnoreLimit 		= 3;
	};
	["noclip"]	= {
		Limit 				= 10000;
		IgnoreLimit 		= 3;
	};
	["noclip2"]	= {
		Limit 				= 10000;
		IgnoreLimit 		= 3;
	};
	["speed"]	= {
		Limit 				= 10000;
		IgnoreLimit 		= 3;
	};
	["jumpPower"]	= {
		Limit 				= 10000;
		IgnoreLimit 		= 3;
	};
	["animations"]	= {
		Limit 				= 2;
		Minimum 			= 0.5,
		IgnoreLimit 		= 6;
		SilentlyChange 		= true,
	};
};

VIPServerCommandBlacklist	= {"permRank", "permBan", "globalAnnouncement"};	-- Commands players are probihited from using in VIP Servers.
GearBlacklist				= {67798397};	-- The IDs of gear items to block when using the ;gear command.
IgnoreGearBlacklist			= 4;			-- The minimum rank required to ignore the gear blacklist.

PlayerDataStoreVersion		= "V1.0";		-- Data about the player (i.e. permRanks, custom settings, etc). Changing the Version name will reset all PlayerData.
SystemDataStoreVersion		= "V1.0";		-- Data about the game (i.e. the banland, universal message system, etc). Changing the Version name will reset all SystemData.

CoreNotices					= {				-- Modify core notices. You can find a table of all CoreNotices under [MainModule > Client > SharedModules > CoreNotices]
	--NoticeName = NoticeDetails;
};




--------------| MODIFY COMMANDS |--------------
SetCommandRankByName = {
	["jump"] = 2.2;
};	








};