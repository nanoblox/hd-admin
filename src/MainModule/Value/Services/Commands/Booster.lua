--!strict
local ORDER = 1000000
local ROLES = {"_Booster"}
local PREFIX = "/"
local HIDE = true
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local function createEmoteCommand(emoteName: string, emoteId: number | false, properties: any?)
	local aliases = (properties and properties.Aliases) or {}
	for i, alias in aliases do
		aliases[i] = PREFIX..alias
	end
	local command: Task.Command = {
		name = PREFIX..emoteName,
		aliases = aliases,
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		hide = HIDE,
		run = function(task: Task.Class, args: {any})
			print("RAN the booster emote:", emoteName)
		end
	}
	return command
end
local function createBundleCommand(bundleName: string, properties: any?)
	local command: Task.Command = {
		name = PREFIX..bundleName,
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		hide = HIDE,
		run = function(task: Task.Class, args: {any})
			print("RAN the booster bundle:", bundleName)
		end
	}
	return command
end


local commands: Task.Commands = {

    --------------------
	{
		name = "Bundle",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		hide = HIDE,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	createEmoteCommand("Shake", 132367660388476, {Looped = true});
	createEmoteCommand("Dolphin", 5938365243, {Looped = true, Aliases = {"Dance0"}});
	createEmoteCommand("Dorky", 4212499637, {Looped = true, Aliases = {"Dance1"}});
	createEmoteCommand("Monkey", 3716636630, {Looped = true, Aliases = {"Dance2"}});
	createEmoteCommand("Floss", 5917570207, {Looped = true, Aliases = {"Dance3"}});
	createEmoteCommand("AroundTown", 3576747102, {Looped = true, Aliases = {"Dance4"}});
	createEmoteCommand("TouchDance", 139021427684680, {Looped = true, Aliases = {"Dance5"}});
	createEmoteCommand("HotToGo", 79312439851071, {Looped = true, Aliases = {"Dance6"}});
	createEmoteCommand("FancyFeet", 3934988903, {Looped = true, Aliases = {"Dance7"}});
	createEmoteCommand("Bouncy", 14353423348, {Looped = true, Aliases = {"Dance8"}});
	createEmoteCommand("TopRock", 3570535774, {Looped = true, Aliases = {"Dance9"}});
	
	createEmoteCommand("Dance", false, {Looped = true});
	createEmoteCommand("Emota", false, {Looped = false});
	
	createEmoteCommand("Cheer", 3994127840);
	createEmoteCommand("Backflip", 15694504637);
	createEmoteCommand("Salute", 3360689775);
	createEmoteCommand("Shy", 3576717965);
	createEmoteCommand("Sad", 4849502101);
	createEmoteCommand("Bored", 5230661597);
	createEmoteCommand("Flex", 3994130516);
	createEmoteCommand("Brag", 15506506103);
	createEmoteCommand("Tpose", 3576719440);
	createEmoteCommand("Vpose", 10214418283);
	createEmoteCommand("Ypose", 4391211308);
	createEmoteCommand("ZombieHands", 4212496830);
	createEmoteCommand("Roar", 18524331128);
	createEmoteCommand("HandBlast", 4849497510);
	createEmoteCommand("JumpingJacks", 3570649048);
	createEmoteCommand("GuitarAir", 15506499986);
	createEmoteCommand("Flare", 10214406616);
	createEmoteCommand("FaceFrame", 14353421343);
	createEmoteCommand("Samba", 16276506814);
	createEmoteCommand("Happy", 4849499887);
	
	createBundleCommand("Buff", 594200, {RemoveBodyParts = {"Head"}}),
	createBundleCommand("Snowman", 173035),
	createBundleCommand("Wormy", 394523),
	createBundleCommand("Skeleton", 4778),
	createBundleCommand("Chibi", 6470),
	createBundleCommand("Plush", 3416, {RemoveBodyParts = {"Head"}, ScaleHead = 1.15}),
	createBundleCommand("Chunky", 637696),
	createBundleCommand("Crab", 464998, {IgnoreAccessories = nil}),
	createBundleCommand("Spider", 340256, {IgnoreAccessories = {"Back"}}),
	createBundleCommand("Frog", 386731),
	createBundleCommand("Rat", 1598818, {IgnoreAccessories = true}),
	createBundleCommand("Hamster", 8232),
	createBundleCommand("Capybara", 295597),
	createBundleCommand("Penguin", 319025, {IgnoreBodyParts = true}),
	createBundleCommand("Duck", 394166, {IgnoreAccessories = {"Hat", "Hair"}}),
	createBundleCommand("Goose", 310626, {IgnoreAccessories = true}),
	createBundleCommand("Sponge", 393419),
	createBundleCommand("Freak", 1186597),

	--------------------
	{
		name = PREFIX.."Reset",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		hide = HIDE,
		run = function(task: Task.Class, args: {any})
			-- Reset
		end
	},

    --------------------
}


return commands