--!strict

-- CONFIG
local MAX_FAVORITES = 50


-- LOCAL
local Emotes = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local AvatarEditorService = game:GetService("AvatarEditorService")
local AssetService = game:GetService("AssetService")
local getEmotesDe = false
local allEmotes: EmoteTable = {}


-- TYPES
type EmoteTable = {[string]: Emote}
export type Emote = {
	name: string,
	originalName: string?,
	order: number,
	animationId: number,
}


-- FUNCTIONS
function Emotes.getEmotesAsync(): (boolean, EmoteTable | string)

	local isTableEmpty = require(modules.TableUtil.isTableEmpty)
	if getEmotesDe == true then
		repeat task.wait(0.2) until getEmotesDe ~= true
	end
	if not isTableEmpty(allEmotes) then
		return true, allEmotes
	end
	getEmotesDe = true

	-- This returns all emotes officially listed under HD Admin
	local searchResults = {}
	local nextPageCursor = nil
	local params = CatalogSearchParams.new() :: any
	params.AssetTypes = {Enum.AvatarAssetType.EmoteAnimation}
	params.CreatorType = Enum.CreatorTypeFilter.Group
	params.CreatorId = 4676369
	params.SortType = Enum.CatalogSortType.RecentlyCreated
	params.Limit = 120
	local success, catalogPages: any
	local waitTime = 1
	while true do
		success, catalogPages = pcall(function()
			return AvatarEditorService:SearchCatalog(params)
		end)
		if success then
			break
		end
		task.wait(waitTime)
		waitTime *= 2
	end
	repeat
		local currentPage = catalogPages:GetCurrentPage()
		for _, item in currentPage do
			table.insert(searchResults, item)
		end
		if catalogPages.IsFinished then
			break
		end
		local nextSuccess, warning = pcall(function()
			return catalogPages:AdvanceToNextPageAsync()
		end)
		if not nextSuccess then
			warn("Failed to advance to next page:", warning)
			break
		end
		task.wait(0.1)
	until catalogPages.IsFinished
	getEmotesDe = false
	if #searchResults == 0 then
		return false, "Unable to retrieve Emotes"
	end
	
	-- This organies the returned data into a dictionary of emotes
	local defaultEmotes = require(script.defaultEmotes) :: EmoteTable
	local toCamelCase = require(modules.DataUtil.toCamelCase)
	allEmotes = {}
	for emoteId, emote in defaultEmotes do
		allEmotes[emoteId] = emote
	end
	for i, result in searchResults do
		local emoteId = tostring(result.Id)
		if not emoteId then
			continue
		end
		local existing = allEmotes[emoteId]
		local existingOriginalName = existing and existing.originalName
		local originalName = existingOriginalName or tostring(result.Name)
		local name = if existing and existing.name then existing.name else toCamelCase(originalName)
		local emote: any = {
			name = name,
			originalName = originalName,
			order = i,
		}
		allEmotes[emoteId] = emote
	end
	local itemsRemaining = 0
	for emoteId, emote in allEmotes do
		-- We have to use LoadAssetAsync on the EmoteId to retrieve the animationId
		-- the animationId which is used by the client to display an animated rig
		local animationId = emote.animationId
		if animationId then
			continue
		end
		local emoteIdNumber = tonumber(emoteId)
		if not emoteIdNumber then
			continue
		end
		itemsRemaining += 1
		task.defer(function()
			local success, assetOrWarning = pcall(function()
				return AssetService:LoadAssetAsync(emoteIdNumber)
			end)
			itemsRemaining -= 1
			if success then
				local animationObject = assetOrWarning:FindFirstChildWhichIsA("Animation", true)
				local animationString = animationObject and animationObject.AnimationId
				animationId = animationString and tonumber(string.match(animationString, "%d+"))
			end
			if not animationId or not success then
				if not success then
					warn(`HD Admin: Failed to load emote animationId ({emoteId}): {assetOrWarning}`)
				end
				allEmotes[emoteId] = nil
				return
			end
			emote.animationId = animationId
		end)
	end

	-- Wait until all animation data loaded
	repeat task.wait() until itemsRemaining == 0

	-- Update to everyone state so clients can access
	local User = require(modules.Objects.User)
	User.everyone:set("Emotes", allEmotes)

	return true, allEmotes
end


-- SETUP
-- This is essential to ensure data fetched via User.everyone is accurate
local State = require(modules.Objects.State)
State.verifyFirstFetch("Emotes", Emotes.getEmotesAsync)

-- This listens for and handles the favoriting of emotes
local Remote = require(modules.Objects.Remote)
Remote.new("FavoriteEmote", "Function"):onServerInvoke(function(player: Player, assetId: unknown, shouldFavorite: unknown): (boolean, any)
	if typeof(assetId) ~= "number" and typeof(assetId) ~= "string" then
		return false, "Invalid assetId (1)"
	end
	assetId = tonumber(assetId)
	if not assetId then
		return false, "Invalid assetId (2)"
	end
	shouldFavorite = if shouldFavorite == true then true else false
	local emoteId = tostring(assetId)
	local emote = allEmotes[emoteId]
	if not emote then
		return false, "Invalid EmoteId"
	end
	local User = require(modules.Objects.User)
	local user = User.getUser(player)
	if not user then
		return false, "User not loaded"
	end
	local perm = user.perm
	local favoritedEmotes = perm:get("FavoritedEmotes")
	local getTableSize = require(modules.TableUtil.getTableSize)
	if shouldFavorite and getTableSize(favoritedEmotes) >= MAX_FAVORITES then
		return false, `Can only favorite max {MAX_FAVORITES} items - remove some then retry.`
	end
	if shouldFavorite then
		perm:set("FavoritedEmotes", emoteId, emote)
	else
		perm:set("FavoritedEmotes", emoteId, nil)
	end
	return true, emote
end)


return Emotes