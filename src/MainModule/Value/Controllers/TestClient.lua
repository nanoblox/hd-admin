--!strict

-- Local
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local Icon = require(modules.Objects.Icon)
local TestController = {}


-- Test replication everyone
print("Start tests...")
local clientUser = require(modules.References.clientUser)
local everyone = clientUser.everyone
everyone:observe("Emotes", function(value)
	print("TEST Emotes:", value)
end)
everyone:observe("Roles", function(value)
	print("TEST Roles:", value)
end)
everyone:observe("RoleInfo", function(value)
	print("TEST RoleInfo:", value)
end)
everyone:observe("Commands", function(value)
	print("TEST Commands:", value)
end)
everyone:observe("CommandInfo", function(value)
	print("TEST CommandInfo:", value)
end)

-- Test replication perm
local TEST_EMOTE_ID = "79795305221612"
local perm = clientUser.perm
perm:observe("YouSettings", function(value)
	print("TEST YouSettings:", value)
end)
perm:observe("FavoritedEmotes", TEST_EMOTE_ID, function(value)
	print(`TEST FavoritedEmotes {TEST_EMOTE_ID} changed to:`, value)
end)


-- Update Favorite status of emote
task.defer(function()
	local Remote = require(modules.Objects.Remote)
	local favoriteEmote = Remote.get("FavoriteEmote")
	while true do
		task.wait(3)
		local isFavorited = perm:get("FavoritedEmotes", TEST_EMOTE_ID) ~= nil
		local success, approved, result = favoriteEmote:invokeServerAsync(TEST_EMOTE_ID, not isFavorited)
	end
end)


return TestController