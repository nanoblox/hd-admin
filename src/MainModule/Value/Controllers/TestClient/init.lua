--!strict

-- Local
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local Icon = require(modules.Objects.Icon)
local TestController = {}


-- Test replication everyone
local clientUser = require(modules.References.clientUser)
local everyone = clientUser.everyone
everyone:observe("Emotes", function(value)
	--print("TEST Emotes:", value)
end)
local clientUser = require(modules.References.clientUser)
everyone:observe("Roles", function(value)
	--print("TEST Roles:", value)
end)
everyone:observe("RoleInfo", function(value)
	--print("TEST RoleInfo:", value)
end)
everyone:observe("Commands", function(value)
	--print("TEST Commands:", value)
end)
everyone:observe("CommandInfo", function(value)
	--print("TEST CommandInfo:", value)
end)

-- Test replication perm
local TEST_EMOTE_ID = "79795305221612"
local perm = clientUser.perm
perm:observe("YouSettings", function(value)
	--print("TEST YouSettings:", value)
end)
perm:observe("FavoritedEmotes", function(value)
	--print(`TEST FavoritedEmotes changed to:`, value)
end)


-- Update Favorite status of emote
task.defer(function()
	local Remote = require(modules.Objects.Remote)
	local favoriteEmote = Remote.get("FavoriteEmote")
	while true do
		task.wait(3)
		--local isFavorited = perm:get("FavoritedEmotes", TEST_EMOTE_ID) ~= nil
		--print("isFavorited =", isFavorited)
		--local success, result = favoriteEmote:invokeServerAsync(TEST_EMOTE_ID, not isFavorited)
		--print("success, result =", success, result)
	end
end)


task.delay(3, function()
	-- Test PromptBulkPurchase
	local promptBulkPurchaseAsync = require(modules.AssetUtil.promptBulkPurchaseAsync)
	local testAssetId = 115407270129592
	--local success, warning = promptBulkPurchaseAsync(testAssetId)
	--print(`PromptBulkPurchase result for assetId {testAssetId}:`, success, warning)
end)


-- Test sound settings changing
local testSound = workspace:FindFirstChild("TestSound")
if testSound and testSound:IsA("Sound") then
	local registerSound = require(modules.AssetUtil.registerSound)
	task.delay(0, function()
		--registerSound(testSound, "Command")
		--print('REGISTERED:', testSound)
	end)
	--testSound:Play()
end


-- Test Settings
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local clientUser = require(modules.References.clientUser)
local everyone = clientUser.everyone
local success, value = everyone:fetchAsync("GameSettings", "PlayerIdentifier")




-- Items here, test Parser
local Parser = require(modules.Parser)
local TestArgs = require(modules.Parent.Controllers.TestClient.TestArgs)
local testArgs = TestArgs[1]
local testValues = TestArgs[2] :: {any}
print("Starting final string...")
local finalString = Parser.unparse("Test", {"GLOBAL", "LOOP"}, unpack(testValues))
print("finalString =", finalString)


local selectedPlayers = {"random", "role(admin)"}
local materialEnum = Enum.Material.Sandstone
local colorValue = Color3.fromRGB(255,0,0)
local announcementText = "Hello this is a test announcement"
print("Generating...")
print(Parser.unparse("Material", {}, selectedPlayers, materialEnum, colorValue, announcementText))



return TestController